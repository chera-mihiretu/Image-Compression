from fastapi import FastAPI, File, Form, UploadFile, HTTPException
from fastapi.responses import Response
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image, UnidentifiedImageError
import io
import logging
from typing import Optional
import uvicorn

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Image Compression API",
    description="FastAPI service for compressing images with configurable quality",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Image Compression API", "status": "running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "image-compression"}

@app.api_route("/compress", methods=["POST", "GET"])
async def compress_image(
    image: UploadFile = File(..., description="Image file to compress"),
    compress_size: Optional[int] = Form(70, description="Compression quality (60-100)")
):
    """
    Compress an image with configurable quality.
    
    Args:
        image: The image file to compress
        compress_size: Compression quality between 60-100 (default: 70)
    
    Returns:
        Compressed image as JPEG
    """
    try:
        # Validate compress_size
        if not (60 <= compress_size <= 100):
            raise HTTPException(
                status_code=400, 
                detail="compress_size must be between 60 and 100"
            )
        
        # Validate file extension instead of content type
        if not image.filename:
            raise HTTPException(
                status_code=400, 
                detail="File must have a filename"
            )
        
        # Get file extension and check if it's a valid image format
        file_extension = image.filename.lower().split('.')[-1] if '.' in image.filename else ''
        valid_image_extensions = {'jpg', 'jpeg', 'png', 'bmp', 'gif', 'tiff', 'webp', 'tga', 'ico'}
        
        if file_extension not in valid_image_extensions:
            raise HTTPException(
                status_code=400, 
                detail=f"File must be an image. Supported formats: {', '.join(sorted(valid_image_extensions))}"
            )
        
        logger.info(f"Processing image: {image.filename}, size: {image.size} bytes, quality: {compress_size}")
        
        # Read image data
        image_data = await image.read()
        logger.info(f"Image loaded: {len(image_data) / 1024 / 1024:.2f} MB")
        
        # Open and process image with Pillow
        try:
            original_image = Image.open(io.BytesIO(image_data))
            logger.info(f"Image opened: {original_image.mode}, {original_image.size}")
            
            # Force load for large images
            if len(image_data) > 2 * 1024 * 1024:  # > 2MB
                logger.info("Large image detected, forcing load")
                original_image.load()
                
        except UnidentifiedImageError:
            raise HTTPException(
                status_code=400, 
                detail="Invalid or corrupted image file"
            )
        
        # Convert image modes for JPEG compatibility
        if original_image.mode in ("RGBA", "P", "LA", "PA"):
            original_image = original_image.convert("RGB")
            logger.info("Converted image to RGB mode")
        elif original_image.mode == "L":
            logger.info("Keeping grayscale mode")
        elif original_image.mode not in ("RGB", "L"):
            original_image = original_image.convert("RGB")
            logger.info(f"Converted from {original_image.mode} to RGB mode")
        
        # Progressive compression based on image size
        width, height = original_image.size
        logger.info(f"Original dimensions: {width}x{height}")
        
        # Smart resizing for large images
        if len(image_data) > 1 * 1024 * 1024:  # > 1MB
            max_dimension = 1600
            logger.info(f"Large image detected, resizing to max {max_dimension}px")
        else:
            max_dimension = 2048
            logger.info(f"Standard image, resizing to max {max_dimension}px")
        
        if width > max_dimension or height > max_dimension:
            if width > height:
                new_width = max_dimension
                new_height = int((height * max_dimension) / width)
            else:
                new_height = max_dimension
                new_width = int((width * max_dimension) / height)
            
            new_width = max(1, new_width)
            new_height = max(1, new_height)
            
            logger.info(f"Resizing to: {new_width}x{new_height}")
            original_image = original_image.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Progressive quality adjustment for very large images
        final_quality = compress_size
        if len(image_data) > 3 * 1024 * 1024:  # > 3MB
            final_quality = max(60, compress_size - 10)
            logger.info(f"Very large image, reducing quality from {compress_size} to {final_quality}")
        
        # Compress and save image
        compressed_io = io.BytesIO()
        
        try:
            if original_image.mode == "L":
                # Grayscale image
                original_image.save(compressed_io, format='JPEG', quality=final_quality, optimize=True)
            else:
                # Color image
                original_image.save(compressed_io, format='JPEG', quality=final_quality, optimize=True)
            
            logger.info(f"Image compressed with quality {final_quality}")
            
        except Exception as e:
            logger.error(f"Error saving compressed image: {str(e)}")
            raise HTTPException(
                status_code=500, 
                detail=f"Error compressing image: {str(e)}"
            )
        
        compressed_io.seek(0)
        compressed_bytes = compressed_io.read()
        
        # Log compression results
        compressed_size_mb = len(compressed_bytes) / 1024 / 1024
        compression_ratio = (1 - len(compressed_bytes) / len(image_data)) * 100
        
        logger.info(f"Compression complete. Original: {len(image_data) / 1024 / 1024:.2f} MB, "
                   f"Compressed: {compressed_size_mb:.2f} MB, "
                   f"Ratio: {compression_ratio:.1f}%")
        
        # Return compressed image
        return Response(
            content=compressed_bytes,
            media_type="image/jpeg",
            headers={
                "Content-Length": str(len(compressed_bytes)),
                "X-Original-Size": str(len(image_data)),
                "X-Compressed-Size": str(len(compressed_bytes)),
                "X-Compression-Ratio": f"{compression_ratio:.1f}%",
                "X-Compression-Quality": str(final_quality)
            }
        )
        
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        raise HTTPException(
            status_code=500, 
            detail=f"Internal server error: {str(e)}"
        )

@app.post("/compress-url")
async def compress_image_url(
    image: UploadFile = File(..., description="Image file to compress"),
    compress_size: Optional[int] = Form(70, description="Compression quality (60-100)"),
    return_url: bool = Form(False, description="Return S3 URL instead of image data")
):
    """
    Compress an image and optionally return S3 URL.
    This endpoint is for future S3 integration.
    """
    # For now, just return the compressed image
    # In the future, you can integrate with S3 here
    return await compress_image(image, compress_size)

if __name__ == "__main__":
    uvicorn.run(
        "app:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    ) 
