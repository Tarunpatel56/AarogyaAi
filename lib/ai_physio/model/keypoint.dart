class KeyPoint {
  final double x;
  final double y;
  final double confidence;

  KeyPoint(this.x, this.y, this.confidence);
  
  // Create KeyPoint from the raw TFLite output array [x, y, confidence]
  factory KeyPoint.fromList(List<double> data) {
    return KeyPoint(data[0], data[1], data[2]);
  }
}