import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);
}

// OCR & Image Processing failures
class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure([String message = 'Failed to process image']) : super(message);
}

class OCRFailure extends Failure {
  const OCRFailure([String message = 'Failed to extract text from image']) : super(message);
}

class ImageQualityFailure extends Failure {
  const ImageQualityFailure([String message = 'Image quality too low. Please retake photo']) : super(message);
}

// Lottery specific failures
class LotteryParseFailure extends Failure {
  const LotteryParseFailure([String message = 'Failed to parse lottery ticket']) : super(message);
}

class InvalidTicketFailure extends Failure {
  const InvalidTicketFailure([String message = 'Invalid lottery ticket']) : super(message);
}

class ResultsNotFoundFailure extends Failure {
  const ResultsNotFoundFailure([String message = 'Results not found for this draw']) : super(message);
}

// Firebase failures
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed']) : super(message);
}

class FirestoreFailure extends Failure {
  const FirestoreFailure([String message = 'Database operation failed']) : super(message);
}

// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission denied']) : super(message);
}

class CameraFailure extends Failure {
  const CameraFailure([String message = 'Camera access denied']) : super(message);
}
