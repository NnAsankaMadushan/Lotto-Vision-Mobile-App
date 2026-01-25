class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
}

class ImageProcessingException implements Exception {
  final String message;
  const ImageProcessingException([this.message = 'Failed to process image']);
}

class OCRException implements Exception {
  final String message;
  const OCRException([this.message = 'Failed to extract text']);
}

class LotteryParseException implements Exception {
  final String message;
  const LotteryParseException([this.message = 'Failed to parse lottery ticket']);
}

class InvalidTicketException implements Exception {
  final String message;
  const InvalidTicketException([this.message = 'Invalid lottery ticket']);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = 'Permission denied']);
}

class ResultsNotFoundException implements Exception {
  final String message;
  const ResultsNotFoundException([this.message = 'Results not found']);
}
