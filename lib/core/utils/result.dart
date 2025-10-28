// Result パターンでエラーハンドリングを型安全に行う
abstract class Result<T> {
  const Result();

  // 成功の場合
  factory Result.success(T data) = Success<T>;
  
  // 失敗の場合
  factory Result.failure(Exception error) = Failure<T>;

  // 結果の種類を判定
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  // データを取得（成功時のみ）
  T? get data => isSuccess ? (this as Success<T>).data : null;
  
  // エラーを取得（失敗時のみ）
  Exception? get error => isFailure ? (this as Failure<T>).error : null;

  // 結果に応じて処理を分岐
  R when<R>({
    required R Function(T data) success,
    required R Function(Exception error) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      return failure((this as Failure<T>).error);
    }
  }

  // map操作（成功時のみ変換）
  Result<R> map<R>(R Function(T) transform) {
    return when(
      success: (data) => Result.success(transform(data)),
      failure: (error) => Result.failure(error),
    );
  }

  // flatMap操作（チェーン処理）
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    return when(
      success: (data) => transform(data),
      failure: (error) => Result.failure(error),
    );
  }

  // エラーハンドリング
  Result<T> handleError(Result<T> Function(Exception) handler) {
    return when(
      success: (data) => Result.success(data),
      failure: (error) => handler(error),
    );
  }
}

// 成功の実装
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Success<T> && other.data == data);
  }

  @override
  int get hashCode => data.hashCode;
}

// 失敗の実装
class Failure<T> extends Result<T> {
  final Exception error;
  
  const Failure(this.error);

  @override
  String toString() => 'Failure(error: $error)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Failure<T> && other.error == error);
  }

  @override
  int get hashCode => error.hashCode;
}

// 非同期処理用のResult拡張
extension FutureResult<T> on Future<T> {
  // Future<T> を Future<Result<T>> に変換
  Future<Result<T>> toResult() async {
    try {
      final data = await this;
      return Result.success(data);
    } catch (error) {
      if (error is Exception) {
        return Result.failure(error);
      } else {
        return Result.failure(Exception(error.toString()));
      }
    }
  }
}

// Result用のユーティリティ関数
class ResultUtils {
  // 複数のResultを結合（全て成功の場合のみ成功）
  static Result<List<T>> combine<T>(List<Result<T>> results) {
    final data = <T>[];
    
    for (final result in results) {
      if (result.isFailure) {
        return Result.failure(result.error!);
      }
      data.add(result.data!);
    }
    
    return Result.success(data);
  }

  // 最初の成功したResultを返す
  static Result<T> firstSuccess<T>(List<Result<T>> results) {
    for (final result in results) {
      if (result.isSuccess) {
        return result;
      }
    }
    
    // 全て失敗の場合は最後のエラーを返す
    return results.isNotEmpty 
        ? results.last 
        : Result.failure(Exception('No results provided'));
  }

  // try-catch を Result に変換
  static Result<T> tryExecute<T>(T Function() operation) {
    try {
      return Result.success(operation());
    } catch (error) {
      if (error is Exception) {
        return Result.failure(error);
      } else {
        return Result.failure(Exception(error.toString()));
      }
    }
  }

  // 非同期のtry-catch を Result に変換
  static Future<Result<T>> tryExecuteAsync<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (error) {
      if (error is Exception) {
        return Result.failure(error);
      } else {
        return Result.failure(Exception(error.toString()));
      }
    }
  }
}