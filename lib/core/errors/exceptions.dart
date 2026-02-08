class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred']);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
  @override
  String toString() => message;
}

class ImageProcessingException implements Exception {
  final String message;
  const ImageProcessingException([this.message = 'Failed to process image']);
  @override
  String toString() => message;
}

class OCRException implements Exception {
  final String message;
  const OCRException([this.message = 'Failed to extract text']);
  @override
  String toString() => message;
}

class LotteryParseException implements Exception {
  final String message;
  const LotteryParseException([this.message = 'Failed to parse lottery ticket']);
  @override
  String toString() => message;
}

class InvalidTicketException implements Exception {
  final String message;
  const InvalidTicketException([this.message = 'Invalid lottery ticket']);
  @override
  String toString() => message;
}

class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = 'Permission denied']);
  @override
  String toString() => message;
}

class ResultsNotFoundException implements Exception {
  final String message;
  const ResultsNotFoundException([this.message = 'Results not found']);
  @override
  String toString() => message;
}
