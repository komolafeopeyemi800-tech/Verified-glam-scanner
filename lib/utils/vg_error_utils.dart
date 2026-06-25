import 'package:supabase_flutter/supabase_flutter.dart';

/// Typed analysis failure from edge function or client preflight.
class VGAnalysisFailure implements Exception {
  final String message;
  final String errorCode;
  final int? status;

  const VGAnalysisFailure({
    required this.message,
    this.errorCode = 'ANALYSIS_FAILED',
    this.status,
  });

  @override
  String toString() => message;
}

/// Parses edge-function and client errors into [VGAnalysisFailure].
VGAnalysisFailure vgParseAnalysisError(Object error) {
  if (error is VGAnalysisFailure) return error;

  if (error is FunctionException) {
    final details = error.details;
    if (details is Map) {
      final code = details['errorCode']?.toString() ?? 'ANALYSIS_FAILED';
      final message = details['error']?.toString() ??
          details['message']?.toString() ??
          _defaultMessageForCode(code);
      return VGAnalysisFailure(
        message: message,
        errorCode: code,
        status: error.status,
      );
    }
    return VGAnalysisFailure(
      message: error.reasonPhrase ?? 'Analysis failed (${error.status})',
      errorCode: _codeFromStatus(error.status),
      status: error.status,
    );
  }

  final text = error.toString();
  const prefix = 'Exception: ';
  final message = text.startsWith(prefix) ? text.substring(prefix.length) : text;

  if (message.contains('Daily scan limit')) {
    return VGAnalysisFailure(message: message, errorCode: 'DAILY_LIMIT', status: 429);
  }
  if (message.contains('Not signed in')) {
    return VGAnalysisFailure(message: message, errorCode: 'UNAUTHORIZED', status: 401);
  }
  if (message.toLowerCase().contains('network') ||
      message.toLowerCase().contains('socket') ||
      message.toLowerCase().contains('connection')) {
    return VGAnalysisFailure(
      message: 'Please check your connection and try again.',
      errorCode: 'NETWORK_ERROR',
    );
  }

  return VGAnalysisFailure(message: message);
}

String vgFormatAnalysisError(Object error) => vgParseAnalysisError(error).message;

String vgAnalysisErrorTitle(String errorCode) {
  switch (errorCode) {
    case 'NO_FACE_DETECTED':
      return 'No Face Detected';
    case 'NETWORK_ERROR':
      return 'No Internet Connection';
    case 'DAILY_LIMIT':
      return 'Daily Limit Reached';
    case 'RATE_LIMITED':
      return 'Service Busy';
    case 'ANALYSIS_TIMEOUT':
      return 'Analysis Timed Out';
    case 'CONTENT_POLICY':
      return 'Photo Not Accepted';
    case 'INVALID_IMAGE':
      return 'Invalid Photo';
    default:
      return 'Analysis Failed';
  }
}

String _defaultMessageForCode(String code) {
  switch (code) {
    case 'NO_FACE_DETECTED':
      return 'We couldn\'t detect a face in this photo. Please try again with a clearer photo.';
    case 'CONTENT_POLICY':
      return 'Analysis blocked by content policy. Try a clearer front-facing photo.';
    case 'INVALID_IMAGE':
      return 'Could not process this image. Please use a clearer selfie.';
    case 'RATE_LIMITED':
      return 'Service is busy. Please wait a moment and try again.';
    case 'ANALYSIS_TIMEOUT':
      return 'Analysis took too long. Please try with a clearer photo.';
    case 'DAILY_LIMIT':
      return 'Daily scan limit reached. Try again tomorrow.';
    case 'NETWORK_ERROR':
      return 'Please check your connection and try again.';
    case 'SERVICE_UNAVAILABLE':
      return 'Service temporarily unavailable. Please try again.';
    default:
      return 'Something went wrong. Please try again.';
  }
}

String _codeFromStatus(int status) {
  switch (status) {
    case 401:
      return 'UNAUTHORIZED';
    case 422:
      return 'NO_FACE_DETECTED';
    case 429:
      return 'RATE_LIMITED';
    case 503:
      return 'SERVICE_UNAVAILABLE';
    case 504:
      return 'ANALYSIS_TIMEOUT';
    default:
      return 'ANALYSIS_FAILED';
  }
}
