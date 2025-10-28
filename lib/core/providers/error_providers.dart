import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../error/app_error.dart';
import '../utils/result.dart';

// エラー状態を管理するProvider
final errorStateProvider = StateNotifierProvider<ErrorStateNotifier, ErrorState>((ref) {
  return ErrorStateNotifier();
});

// エラー状態の定義
class ErrorState {
  final AppError? currentError;
  final List<AppError> errorHistory;
  final bool hasError;

  const ErrorState({
    this.currentError,
    this.errorHistory = const [],
    this.hasError = false,
  });

  ErrorState copyWith({
    AppError? currentError,
    List<AppError>? errorHistory,
    bool? hasError,
  }) {
    return ErrorState(
      currentError: currentError,
      errorHistory: errorHistory ?? this.errorHistory,
      hasError: hasError ?? this.hasError,
    );
  }
}

// エラー状態管理
class ErrorStateNotifier extends StateNotifier<ErrorState> {
  ErrorStateNotifier() : super(const ErrorState());

  // エラーを追加
  void addError(AppError error) {
    final newHistory = List<AppError>.from(state.errorHistory)..add(error);
    state = state.copyWith(
      currentError: error,
      errorHistory: newHistory,
      hasError: true,
    );
  }

  // エラーをクリア
  void clearError() {
    state = state.copyWith(
      currentError: null,
      hasError: false,
    );
  }

  // エラー履歴をクリア
  void clearHistory() {
    state = state.copyWith(
      errorHistory: [],
    );
  }

  // 最新のエラーを取得
  AppError? get latestError => state.currentError;

  // エラーが存在するかチェック
  bool get hasError => state.hasError;
}

// 非同期処理状態を管理するProvider
enum AsyncStatus { idle, loading, success, error }

class AsyncState<T> {
  final AsyncStatus status;
  final T? data;
  final AppError? error;

  const AsyncState({
    this.status = AsyncStatus.idle,
    this.data,
    this.error,
  });

  AsyncState<T> copyWith({
    AsyncStatus? status,
    T? data,
    AppError? error,
  }) {
    return AsyncState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error,
    );
  }

  bool get isLoading => status == AsyncStatus.loading;
  bool get isSuccess => status == AsyncStatus.success;
  bool get isError => status == AsyncStatus.error;
  bool get hasData => data != null;
}

// 非同期処理用のStateNotifier基底クラス
abstract class AsyncStateNotifier<T> extends StateNotifier<AsyncState<T>> {
  AsyncStateNotifier() : super(const AsyncState());

  // 読み込み開始
  void setLoading() {
    state = state.copyWith(status: AsyncStatus.loading, error: null);
  }

  // 成功状態にセット
  void setSuccess(T data) {
    state = state.copyWith(
      status: AsyncStatus.success,
      data: data,
      error: null,
    );
  }

  // エラー状態にセット
  void setError(AppError error) {
    state = state.copyWith(
      status: AsyncStatus.error,
      error: error,
    );
  }

  // Resultを使用した処理
  Future<void> executeWithResult(Future<Result<T>> Function() operation) async {
    setLoading();
    
    try {
      final result = await operation();
      
      result.when(
        success: (data) => setSuccess(data),
        failure: (error) {
          final appError = error is AppError 
              ? error 
              : SystemError(
                  message: 'システムエラーが発生しました',
                  originalError: error,
                );
          setError(appError);
        },
      );
    } catch (error) {
      final appError = error is AppError 
          ? error 
          : SystemError(
              message: 'システムエラーが発生しました',
              originalError: error,
            );
      setError(appError);
    }
  }

  // 通常の非同期処理
  Future<void> execute(Future<T> Function() operation) async {
    setLoading();
    
    try {
      final data = await operation();
      setSuccess(data);
    } catch (error) {
      final appError = error is AppError 
          ? error 
          : SystemError(
              message: 'システムエラーが発生しました',
              originalError: error,
            );
      setError(appError);
    }
  }
}

// リストデータ用の非同期Provider
class AsyncListNotifier<T> extends AsyncStateNotifier<List<T>> {
  // リストにアイテムを追加
  void addItem(T item) {
    if (state.hasData) {
      final newList = List<T>.from(state.data!)..add(item);
      setSuccess(newList);
    }
  }

  // リストからアイテムを削除
  void removeItem(T item) {
    if (state.hasData) {
      final newList = List<T>.from(state.data!)..remove(item);
      setSuccess(newList);
    }
  }

  // リストのアイテムを更新
  void updateItem(T oldItem, T newItem) {
    if (state.hasData) {
      final newList = List<T>.from(state.data!);
      final index = newList.indexOf(oldItem);
      if (index >= 0) {
        newList[index] = newItem;
        setSuccess(newList);
      }
    }
  }

  // リストをクリア
  void clearItems() {
    setSuccess(<T>[]);
  }
}

// エラーハンドリング用のミックスイン
mixin ErrorHandlerMixin<T> on StateNotifier<T> {
  // エラーを安全に処理
  Future<R?> safeExecute<R>(
    Future<R> Function() operation, {
    void Function(AppError)? onError,
  }) async {
    try {
      return await operation();
    } catch (error) {
      final appError = error is AppError 
          ? error 
          : SystemError(
              message: 'システムエラーが発生しました',
              originalError: error,
            );
      
      onError?.call(appError);
      return null;
    }
  }

  // Result を使用した安全な実行
  Future<Result<R>> safeExecuteWithResult<R>(
    Future<R> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (error) {
      final appError = error is AppError 
          ? error 
          : SystemError(
              message: 'システムエラーが発生しました',
              originalError: error,
            );
      return Result.failure(appError);
    }
  }
}

// リトライ機能付きの非同期Provider
class RetryableAsyncNotifier<T> extends AsyncStateNotifier<T> {
  int _retryCount = 0;
  int maxRetries = 3;
  Duration retryDelay = const Duration(seconds: 1);

  Future<void> executeWithRetry(Future<T> Function() operation) async {
    _retryCount = 0;
    await _executeWithRetryInternal(operation);
  }

  Future<void> _executeWithRetryInternal(Future<T> Function() operation) async {
    setLoading();
    
    try {
      final data = await operation();
      setSuccess(data);
      _retryCount = 0;
    } catch (error) {
      if (_retryCount < maxRetries) {
        _retryCount++;
        await Future.delayed(retryDelay);
        await _executeWithRetryInternal(operation);
      } else {
        final appError = error is AppError 
            ? error 
            : SystemError(
                message: 'システムエラーが発生しました（リトライ回数超過）',
                originalError: error,
              );
        setError(appError);
        _retryCount = 0;
      }
    }
  }

  // 手動でリトライ
  Future<void> retry(Future<T> Function() operation) async {
    if (state.isError) {
      await executeWithRetry(operation);
    }
  }
}