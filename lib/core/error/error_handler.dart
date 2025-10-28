import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_error.dart';

// エラーハンドリングの中央集権管理
class ErrorHandler {
  static const String _logTag = 'ErrorHandler';

  // エラーを処理し、適切なメッセージを返す
  static String handleError(dynamic error) {
    if (error is AppError) {
      _logError(error);
      return _getErrorMessage(error);
    } else {
      final systemError = SystemError(
        message: 'システムエラーが発生しました',
        originalError: error,
        stackTrace: StackTrace.current,
      );
      _logError(systemError);
      return systemError.message;
    }
  }

  // エラーメッセージを取得
  static String _getErrorMessage(AppError error) {
    switch (error.runtimeType) {
      case NetworkError _:
        return _getNetworkErrorMessage(error);
      case DatabaseError _:
        return _getDatabaseErrorMessage(error);
      case ValidationError _:
        return _getValidationErrorMessage(error as ValidationError);
      case BusinessLogicError _:
        return _getBusinessLogicErrorMessage(error);
      case AuthenticationError _:
        return _getAuthenticationErrorMessage(error);
      case InventoryError _:
        return _getInventoryErrorMessage(error);
      case PaymentError _:
        return _getPaymentErrorMessage(error);
      case SystemError _:
      default:
        return error.message;
    }
  }

  static String _getNetworkErrorMessage(AppError error) {
    switch (error.code) {
      case 'CONNECTION_TIMEOUT':
        return '接続がタイムアウトしました。しばらくしてから再度お試しください。';
      case 'NO_INTERNET':
        return 'インターネット接続を確認してください。';
      case 'SERVER_ERROR':
        return 'サーバーエラーが発生しました。しばらくしてから再度お試しください。';
      default:
        return 'ネットワークエラーが発生しました。';
    }
  }

  static String _getDatabaseErrorMessage(AppError error) {
    switch (error.code) {
      case 'DATA_NOT_FOUND':
        return '要求されたデータが見つかりません。';
      case 'DUPLICATE_KEY':
        return '既に存在するデータです。';
      case 'CONSTRAINT_VIOLATION':
        return 'データの整合性エラーが発生しました。';
      default:
        return 'データベースエラーが発生しました。';
    }
  }

  static String _getValidationErrorMessage(ValidationError error) {
    if (error.fieldErrors != null && error.fieldErrors!.isNotEmpty) {
      return error.fieldErrors!.values.first;
    }
    return error.message;
  }

  static String _getBusinessLogicErrorMessage(AppError error) {
    switch (error.code) {
      case 'INSUFFICIENT_STOCK':
        return '在庫が不足しています。';
      case 'INVALID_DISCOUNT':
        return '無効な割引です。';
      case 'CART_EMPTY':
        return 'カートが空です。';
      case 'CUSTOMER_NOT_FOUND':
        return '顧客が見つかりません。';
      case 'PRODUCT_NOT_AVAILABLE':
        return '商品が利用できません。';
      default:
        return error.message;
    }
  }

  static String _getAuthenticationErrorMessage(AppError error) {
    switch (error.code) {
      case 'INVALID_CREDENTIALS':
        return 'ユーザー名またはパスワードが正しくありません。';
      case 'SESSION_EXPIRED':
        return 'セッションが期限切れです。再度ログインしてください。';
      case 'ACCESS_DENIED':
        return 'アクセスが拒否されました。';
      default:
        return '認証エラーが発生しました。';
    }
  }

  static String _getInventoryErrorMessage(AppError error) {
    switch (error.code) {
      case 'NEGATIVE_STOCK':
        return '在庫数がマイナスになることはできません。';
      case 'STOCK_ADJUSTMENT_FAILED':
        return '在庫調整に失敗しました。';
      case 'LOW_STOCK_THRESHOLD':
        return '在庫が最低在庫数を下回っています。';
      default:
        return '在庫エラーが発生しました。';
    }
  }

  static String _getPaymentErrorMessage(AppError error) {
    switch (error.code) {
      case 'PAYMENT_DECLINED':
        return '決済が拒否されました。';
      case 'INSUFFICIENT_FUNDS':
        return '残高不足です。';
      case 'PAYMENT_TIMEOUT':
        return '決済がタイムアウトしました。';
      case 'INVALID_PAYMENT_METHOD':
        return '無効な決済方法です。';
      default:
        return '決済エラーが発生しました。';
    }
  }

  // エラーをログに記録
  static void _logError(AppError error) {
    if (kDebugMode) {
      debugPrint('$_logTag: ${error.runtimeType} - ${error.message}');
      if (error.code != null) {
        debugPrint('$_logTag: Error Code - ${error.code}');
      }
      if (error.originalError != null) {
        debugPrint('$_logTag: Original Error - ${error.originalError}');
      }
      if (error.stackTrace != null) {
        debugPrint('$_logTag: Stack Trace - ${error.stackTrace}');
      }
    }
  }

  // エラーダイアログを表示
  static void showErrorDialog(BuildContext context, dynamic error) {
    final message = handleError(error);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('エラー'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // エラースナックバーを表示
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = handleError(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '閉じる',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

// グローバルエラーハンドラー
class GlobalErrorHandler {
  static void init() {
    // Flutterエラーのキャッチ
    FlutterError.onError = (FlutterErrorDetails details) {
      final error = SystemError(
        message: 'Flutter エラーが発生しました',
        originalError: details.exception,
        stackTrace: details.stack,
      );
      ErrorHandler._logError(error);
      
      // デバッグモードでは標準のエラー表示も行う
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // 非同期エラーのキャッチ
    PlatformDispatcher.instance.onError = (error, stack) {
      final systemError = SystemError(
        message: '非同期エラーが発生しました',
        originalError: error,
        stackTrace: stack,
      );
      ErrorHandler._logError(systemError);
      return true;
    };
  }
}

// エラー状態を管理するウィジェット
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 読み込み状態を管理するウィジェット
class LoadingStateWidget extends StatelessWidget {
  final String? message;

  const LoadingStateWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

// 空状態を管理するウィジェット
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.actionText,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}