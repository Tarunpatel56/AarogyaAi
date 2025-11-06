import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

img.Image _convertYUV420ToImage(CameraImage cameraImage) {
  final int width = cameraImage.width;
  final int height = cameraImage.height;

  final int uvRowStride = cameraImage.planes[1].bytesPerRow;
  final int uvPixelStride = cameraImage.planes[1].bytesPerPixel ?? 1;

  final image = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int uvIndex =
          uvPixelStride * (x >> 1) + uvRowStride * (y >> 1);
      final int index = y * width + x;

      final yValue = cameraImage.planes[0].bytes[index];
      final uValue = cameraImage.planes[1].bytes[uvIndex];
      final vValue = cameraImage.planes[2].bytes[uvIndex];

      int r = (yValue + 1.402 * (vValue - 128)).round();
      int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).round();
      int b = (yValue + 1.772 * (uValue - 128)).round();

      image.setPixelRgba(
        x,
        y,
        r.clamp(0, 255),
        g.clamp(0, 255),
        b.clamp(0, 255),
        255,
      );
    }
  }
  return image;
}

Float32List preprocessImage(CameraImage cameraImage) {
  final img.Image rgbImage = _convertYUV420ToImage(cameraImage);

  final img.Image resizedImage = img.copyResize(
    rgbImage,
    width: 640,
    height: 640,
  );

  final Float32List inputTensor = Float32List(1 * 640 * 640 * 3);
  int tensorIndex = 0;

  for (int y = 0; y < 640; y++) {
    for (int x = 0; x < 640; x++) {
      final pixel = resizedImage.getPixel(x, y);
      inputTensor[tensorIndex++] = pixel.r / 255.0;
      inputTensor[tensorIndex++] = pixel.g / 255.0;
      inputTensor[tensorIndex++] = pixel.b / 255.0;
    }
  }

  return inputTensor;
}