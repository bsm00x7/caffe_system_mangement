// ignore_for_file: file_names

class AuthException implements Exception {
  final String message;
  final String code;
  final AuthErrorType type;
  final String? originalError;

  const AuthException({
    required this.message,
    required this.code,
    required this.type,
    this.originalError,
  });

  // Factory constructors for common auth errors
  factory AuthException.emailAlreadyExists() => const AuthException(
    message: 'This email is already registered. Please try signing in instead.',
    code: 'email-already-in-use',
    type: AuthErrorType.emailInUse,
  );

  factory AuthException.weakPassword() => const AuthException(
    message:
    'Password is too weak. Please use at least 8 characters with letters, numbers, and symbols.',
    code: 'weak-password',
    type: AuthErrorType.weakPassword,
  );

  factory AuthException.invalidEmail() => const AuthException(
    message: 'Please enter a valid email address.',
    code: 'invalid-email',
    type: AuthErrorType.invalidEmail,
  );

  factory AuthException.networkError() => const AuthException(
    message:
    'Network connection failed. Please check your internet and try again.',
    code: 'network-request-failed',
    type: AuthErrorType.network,
  );

  factory AuthException.serverError() => const AuthException(
    message: 'Server is temporarily unavailable. Please try again later.',
    code: 'internal-error',
    type: AuthErrorType.server,
  );

  factory AuthException.tooManyRequests() => const AuthException(
    message:
    'Too many attempts. Please wait a few minutes before trying again.',
    code: 'too-many-requests',
    type: AuthErrorType.rateLimited,
  );

  factory AuthException.invalidOtp() => const AuthException(
    message: 'Invalid verification code. Please check and try again.',
    code: 'invalid-otp',
    type: AuthErrorType.invalidOtp,
  );

  factory AuthException.expiredOtp() => const AuthException(
    message: 'Verification code has expired. Please request a new one.',
    code: 'expired-otp',
    type: AuthErrorType.expiredOtp,
  );

  factory AuthException.userNotFound() => const AuthException(
    message: 'User not found. Please check your email and try again.',
    code: 'user-not-found',
    type: AuthErrorType.userNotFound,
  );

  factory AuthException.unknown([String? originalMessage]) => AuthException(
    message: 'An unexpected error occurred. Please try again.',
    code: 'unknown-error',
    type: AuthErrorType.unknown,
    originalError: originalMessage,
  );

  // Factory method to create AuthException from Supabase errors
  factory AuthException.fromSupabaseException(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('email already registered') ||
        errorMessage.contains('user already registered')) {
      return AuthException.emailAlreadyExists();
    }

    if (errorMessage.contains('invalid email') ||
        errorMessage.contains('email not valid')) {
      return AuthException.invalidEmail();
    }

    if (errorMessage.contains('password') && errorMessage.contains('weak')) {
      return AuthException.weakPassword();
    }

    if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      return AuthException.networkError();
    }

    if (errorMessage.contains('too many requests') ||
        errorMessage.contains('rate limit')) {
      return AuthException.tooManyRequests();
    }

    if (errorMessage.contains('invalid') && errorMessage.contains('otp')) {
      return AuthException.invalidOtp();
    }

    if (errorMessage.contains('expired') && errorMessage.contains('otp')) {
      return AuthException.expiredOtp();
    }

    if (errorMessage.contains('user not found')) {
      return AuthException.userNotFound();
    }

    return AuthException.unknown(error.toString());
  }

  @override
  String toString() => 'AuthException: $message (Code: $code)';
}

// Enum for different error types
enum AuthErrorType {
  emailInUse,
  weakPassword,
  invalidEmail,
  network,
  server,
  rateLimited,
  invalidOtp,
  expiredOtp,
  userNotFound,
  unknown,
}