// アプリケーション全体で使用するエラー定義
abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppError: $message';
}

// ネットワーク関連エラー
class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// データベース関連エラー
class DatabaseError extends AppError {
  const DatabaseError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// バリデーションエラー
class ValidationError extends AppError {
  final Map<String, String>? fieldErrors;

  const ValidationError({
    required super.message,
    this.fieldErrors,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// ビジネスロジックエラー
class BusinessLogicError extends AppError {
  const BusinessLogicError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// 認証・認可エラー
class AuthenticationError extends AppError {
  const AuthenticationError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// システムエラー
class SystemError extends AppError {
  const SystemError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// 在庫関連エラー
class InventoryError extends AppError {
  const InventoryError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

// 決済関連エラー
class PaymentError extends AppError {
  const PaymentError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}