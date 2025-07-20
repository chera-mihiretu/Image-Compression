# Lambda Image Compression Function

This AWS Lambda function compresses images using the Pillow library with configurable compression settings.

## Features

- Accepts images via multipart/form-data
- Configurable compression quality (60-100, default: 70)
- Progressive compression for large images
- Automatic format conversion to JPEG
- Smart resizing for very large images
- Comprehensive error handling and logging

## Configuration Requirements

### Lambda Settings
- **Memory**: Increase to **512 MB** or **1024 MB** for large images
- **Timeout**: Set to **30 seconds** for large image processing
- **Payload Size**: Configure for **6 MB** (synchronous) or **256 MB** (asynchronous)

### Environment Variables
- `PYTHONPATH`: Ensure Pillow is accessible
- `LOG_LEVEL`: Set to `INFO` for detailed logging

## Deployment

1. **Install dependencies**:
   ```bash
   pip install -r requirements.txt -t .
   ```

2. **Create deployment package**:
   ```bash
   zip -r lambda-deployment.zip .
   ```

3. **Update Lambda function**:
   ```bash
   aws lambda update-function-code \
     --function-name your-function-name \
     --zip-file fileb://lambda-deployment.zip
   ```

4. **Update Lambda configuration**:
   ```bash
   aws lambda update-function-configuration \
     --function-name your-function-name \
     --memory-size 1024 \
     --timeout 30
   ```

## Usage

Send a POST request with `multipart/form-data` containing:
- `image`: The image file
- `compress_size`: Compression quality (60-100, optional, default: 70)

## Response

Returns the compressed image as base64-encoded JPEG with appropriate headers.

## Troubleshooting

### Large Image Issues
- **Memory errors**: Increase Lambda memory allocation
- **Timeout errors**: Increase Lambda timeout
- **Payload too large**: Use asynchronous invocation or reduce image size

### Performance Tips
- Use `compress_size` 70-80 for good balance of quality/size
- Very large images (>3MB) get automatic quality reduction
- Images >1MB get more aggressive resizing

## CloudWatch Monitoring

Monitor these metrics:
- Memory usage
- Duration
- Error rates
- Payload sizes 