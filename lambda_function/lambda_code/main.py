import json
import base64
import logging
from email.parser import BytesParser
from email.policy import default
from io import BytesIO
from PIL import Image, UnidentifiedImageError

def lambda_image_compressor(event, context):
    try:
        headers = event.get('headers', {})
        logging.info(f"Event headers: {json.dumps(headers)}")
        
        # Check payload size early
        if 'body' in event and event['body']:
            payload_size_mb = len(event['body']) * 3 / 4 / 1024 / 1024  # Approximate base64 decoded size
            logging.info(f"Payload size: {payload_size_mb:.2f} MB")
            
            # Lambda synchronous limit is 6MB, but we'll be conservative
            if payload_size_mb > 5:
                return {
                    'statusCode': 413,
                    'body': json.dumps({'error': f'Payload too large: {payload_size_mb:.2f} MB. Maximum allowed: 5 MB'})
                }

        if not headers:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'No headers provided in the request'})
            }

        # Get content-type (case-insensitive)
        content_type = None
        for key in headers:
            if key.lower() == 'content-type':
                content_type = headers[key]
                break

        if not content_type or not content_type.startswith('multipart/form-data'):
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Content-Type must be multipart/form-data'})
            }

        # Decode base64 body
        if 'body' not in event or not event['body']:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'No body provided in the request'})
            }

        try:
            raw_body = base64.b64decode(event['body'])
            logging.info(f"Decoded body size: {len(raw_body) / 1024 / 1024:.2f} MB")
        except Exception as e:
            logging.error(f"Base64 decode error: {str(e)}")
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Invalid base64 encoding in request body'})
            }

        # Add missing MIME headers
        full_mime_body = (
            f'Content-Type: {content_type}\n'
            f'MIME-Version: 1.0\n\n'
        ).encode('utf-8') + raw_body

        # Parse multipart data
        try:
            parser = BytesParser(policy=default)
            message = parser.parsebytes(full_mime_body)
        except Exception as e:
            logging.error(f"MIME parsing error: {str(e)}")
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Invalid multipart form data'})
            }

        image_data = None
        compress_size = 70  # Default value

        for part in message.walk():
            if part.get_content_disposition() == 'form-data':
                name = part.get_param('name', header='content-disposition')
                if name == 'image':
                    image_data = part.get_payload(decode=True)
                    logging.info(f"Image data size: {len(image_data) / 1024 / 1024:.2f} MB")
                elif name == 'compress_size':
                    try:
                        compress_size = int(part.get_payload(decode=True).decode('utf-8'))
                        logging.info(f"Compress size requested: {compress_size}")
                    except (ValueError, UnicodeDecodeError):
                        return {
                            'statusCode': 400,
                            'body': json.dumps({'error': 'compress_size must be a valid integer'})
                        }

        if not image_data:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'No image found in form-data'})
            }

        # Validate compress_size range
        if not (60 <= compress_size <= 100):
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'compress_size must be between 60 and 100'})
            }

        # === Compress image using Pillow ===
        try:
            original_image = Image.open(BytesIO(image_data))
            logging.info(f"Image opened successfully. Mode: {original_image.mode}, Size: {original_image.size}")
            
            # For very large images, load progressively
            if len(image_data) > 2 * 1024 * 1024:  # > 2MB
                logging.info("Large image detected, using progressive loading")
                # Force load to prevent lazy loading issues
                original_image.load()
            
        except UnidentifiedImageError:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Invalid image format'})
            }
        except Exception as e:
            logging.error(f"Image loading error: {str(e)}")
            return {
                'statusCode': 400,
                'body': json.dumps({'error': f'Error loading image: {str(e)}'})
            }

        # Convert to RGB if needed (JPEG requires RGB)
        if original_image.mode in ("RGBA", "P", "LA", "PA"):
            original_image = original_image.convert("RGB")
            logging.info("Converted image to RGB mode")
        elif original_image.mode == "L":
            # Keep grayscale as is
            logging.info("Keeping grayscale mode")
            pass
        elif original_image.mode not in ("RGB", "L"):
            # Convert any other mode to RGB
            original_image = original_image.convert("RGB")
            logging.info(f"Converted from {original_image.mode} to RGB mode")

        # Calculate new dimensions while maintaining aspect ratio
        width, height = original_image.size
        logging.info(f"Original dimensions: {width}x{height}")
        
        # Progressive compression for large images
        if len(image_data) > 1 * 1024 * 1024:  # > 1MB
            # More aggressive resizing for large images
            max_dimension = 1600
            logging.info(f"Large image detected, resizing to max {max_dimension}px")
        else:
            max_dimension = 2048
            logging.info(f"Standard image, resizing to max {max_dimension}px")
        
        if width > max_dimension or height > max_dimension:
            if width > height:
                new_width = max_dimension
                new_height = int((height * max_dimension) / width)
            else:
                new_height = max_dimension
                new_width = int((width * max_dimension) / height)
            
            # Ensure minimum dimensions
            new_width = max(1, new_width)
            new_height = max(1, new_height)
            
            logging.info(f"Resizing to: {new_width}x{new_height}")
            original_image = original_image.resize((new_width, new_height), Image.Resampling.LANCZOS)

        # Save compressed image to buffer
        compressed_io = BytesIO()
        
        # Progressive quality adjustment for very large images
        final_quality = compress_size
        if len(image_data) > 3 * 1024 * 1024:  # > 3MB
            # Reduce quality further for very large images
            final_quality = max(60, compress_size - 10)
            logging.info(f"Very large image, reducing quality from {compress_size} to {final_quality}")
        
        try:
            # Determine output format based on original image
            if original_image.mode == "L":
                # Grayscale image - save as JPEG
                original_image.save(compressed_io, format='JPEG', quality=final_quality, optimize=True)
            else:
                # Color image - save as JPEG
                original_image.save(compressed_io, format='JPEG', quality=final_quality, optimize=True)
            
            logging.info(f"Image compressed with quality {final_quality}")
            
        except Exception as e:
            logging.error(f"Image saving error: {str(e)}")
            return {
                'statusCode': 500,
                'body': json.dumps({'error': f'Error saving compressed image: {str(e)}'})
            }
        
        compressed_io.seek(0)
        compressed_bytes = compressed_io.read()
        
        compressed_size_mb = len(compressed_bytes) / 1024 / 1024
        compression_ratio = (1 - len(compressed_bytes) / len(image_data)) * 100
        
        logging.info(f"Compression complete. Original: {len(image_data) / 1024 / 1024:.2f} MB, "
                    f"Compressed: {compressed_size_mb:.2f} MB, "
                    f"Ratio: {compression_ratio:.1f}%")

        # Check if compressed result is too large for Lambda response
        if compressed_size_mb > 4:  # Leave some buffer for Lambda limits
            logging.warning(f"Compressed image still too large: {compressed_size_mb:.2f} MB")
            return {
                'statusCode': 413,
                'body': json.dumps({'error': f'Compressed image too large: {compressed_size_mb:.2f} MB. Try reducing compress_size or image dimensions.'})
            }

        # === Return compressed image ===
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'image/jpeg',
                'Content-Length': str(len(compressed_bytes)),
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS'
            },
            'body': base64.b64encode(compressed_bytes).decode('utf-8'),
            'isBase64Encoded': True
        }

    except Exception as e:
        logging.error(f"Unexpected error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Internal server error: {str(e)}'})
        }
