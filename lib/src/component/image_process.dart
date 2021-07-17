import 'dart:typed_data';

class ImageProcess{
  bool isFailed;
  String errorStack;

  ImageProcess({this.isFailed = false, this.errorStack = ''});

  void hasError() {
    isFailed = true;
  }
  void setError(String text) {
    errorStack = text;
  }

  Uint8List getImageFromByteData(ByteData data) {
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}