import '../error/app_error.dart';
import '../utils/result.dart';

// バリデーションルール
abstract class ValidationRule<T> {
  ValidationRule();
  
  Result<T> validate(T? value, String fieldName);
}

// 必須チェック
class RequiredRule<T> extends ValidationRule<T> {
  RequiredRule();
  
  @override
  Result<T> validate(T? value, String fieldName) {
    if (value == null) {
      return Result.failure(
        ValidationError(
          message: '$fieldNameは必須です',
          fieldErrors: {fieldName: '$fieldNameは必須です'},
        ),
      );
    }
    
    if (value is String && value.trim().isEmpty) {
      return Result.failure(
        ValidationError(
          message: '$fieldNameは必須です',
          fieldErrors: {fieldName: '$fieldNameは必須です'},
        ),
      );
    }
    
    return Result.success(value);
  }
}

// 文字列長チェック
class StringLengthRule extends ValidationRule<String> {
  final int? minLength;
  final int? maxLength;
  
  StringLengthRule({this.minLength, this.maxLength});
  
  @override
  Result<String> validate(String? value, String fieldName) {
    if (value == null) return Result.success('');
    
    if (minLength != null && value.length < minLength!) {
      return Result.failure(
        ValidationError(
          message: '$fieldNameは$minLength文字以上で入力してください',
          fieldErrors: {fieldName: '$fieldNameは$minLength文字以上で入力してください'},
        ),
      );
    }
    
    if (maxLength != null && value.length > maxLength!) {
      return Result.failure(
        ValidationError(
          message: '$fieldNameは$maxLength文字以下で入力してください',
          fieldErrors: {fieldName: '$fieldNameは$maxLength文字以下で入力してください'},
        ),
      );
    }
    
    return Result.success(value);
  }
}

// 数値範囲チェック
class NumberRangeRule extends ValidationRule<num> {
  final num? min;
  final num? max;
  
  NumberRangeRule({this.min, this.max});
  
  @override
  Result<num> validate(num? value, String fieldName) {
    if (value == null) {
      return Result.failure(
        ValidationError(
          message: '$fieldNameを入力してください',
          fieldErrors: {fieldName: '$fieldNameを入力してください'},
        ),
      );
    }
    
    if (min != null && value < min!) {
      return Result.failure(
        ValidationError(
          message: '$fieldNameは$min以上で入力してください',
          fieldErrors: {fieldName: '$fieldNameは$min以上で入力してください'},
        ),
      );
    }
    
    if (max != null && value > max!) {
      return Result.failure(
        ValidationError(
          message: '$fieldNameは$max以下で入力してください',
          fieldErrors: {fieldName: '$fieldNameは$max以下で入力してください'},
        ),
      );
    }
    
    return Result.success(value);
  }
}

// メールアドレスチェック
class EmailRule extends ValidationRule<String> {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  EmailRule();
  
  @override
  Result<String> validate(String? value, String fieldName) {
    if (value == null || value.isEmpty) return Result.success('');
    
    if (!_emailRegex.hasMatch(value)) {
      return Result.failure(
        ValidationError(
          message: '有効なメールアドレスを入力してください',
          fieldErrors: {fieldName: '有効なメールアドレスを入力してください'},
        ),
      );
    }
    
    return Result.success(value);
  }
}

// 電話番号チェック
class PhoneRule extends ValidationRule<String> {
  static final RegExp _phoneRegex = RegExp(r'^[0-9\-\(\)\+\s]+$');
  
  PhoneRule();
  
  @override
  Result<String> validate(String? value, String fieldName) {
    if (value == null || value.isEmpty) return Result.success('');
    
    if (!_phoneRegex.hasMatch(value)) {
      return Result.failure(
        ValidationError(
          message: '有効な電話番号を入力してください',
          fieldErrors: {fieldName: '有効な電話番号を入力してください'},
        ),
      );
    }
    
    return Result.success(value);
  }
}

// カスタムルール
class CustomRule<T> extends ValidationRule<T> {
  final bool Function(T? value) predicate;
  final String errorMessage;
  
  CustomRule({
    required this.predicate,
    required this.errorMessage,
  });
  
  @override
  Result<T> validate(T? value, String fieldName) {
    if (!predicate(value)) {
      return Result.failure(
        ValidationError(
          message: errorMessage,
          fieldErrors: {fieldName: errorMessage},
        ),
      );
    }
    
    return Result.success(value!);
  }
}

// バリデーター
class Validator<T> {
  final List<ValidationRule<T>> _rules = [];
  
  Validator<T> required() {
    _rules.add(RequiredRule<T>());
    return this;
  }
  
  Validator<T> addRule(ValidationRule<T> rule) {
    _rules.add(rule);
    return this;
  }
  
  Result<T> validate(T? value, String fieldName) {
    for (final rule in _rules) {
      final result = rule.validate(value, fieldName);
      if (result.isFailure) {
        return result;
      }
    }
    return Result.success(value!);
  }
}

// 文字列用バリデーター
class StringValidator extends Validator<String> {
  StringValidator minLength(int length) {
    addRule(StringLengthRule(minLength: length));
    return this;
  }
  
  StringValidator maxLength(int length) {
    addRule(StringLengthRule(maxLength: length));
    return this;
  }
  
  StringValidator email() {
    addRule(EmailRule());
    return this;
  }
  
  StringValidator phone() {
    addRule(PhoneRule());
    return this;
  }
  
  StringValidator custom(bool Function(String?) predicate, String errorMessage) {
    addRule(CustomRule<String>(predicate: predicate, errorMessage: errorMessage));
    return this;
  }
}

// 数値用バリデーター
class NumberValidator extends Validator<num> {
  NumberValidator min(num value) {
    addRule(NumberRangeRule(min: value));
    return this;
  }
  
  NumberValidator max(num value) {
    addRule(NumberRangeRule(max: value));
    return this;
  }
  
  NumberValidator range(num min, num max) {
    addRule(NumberRangeRule(min: min, max: max));
    return this;
  }
  
  NumberValidator positive() {
    addRule(NumberRangeRule(min: 0));
    return this;
  }
  
  NumberValidator custom(bool Function(num?) predicate, String errorMessage) {
    addRule(CustomRule<num>(predicate: predicate, errorMessage: errorMessage));
    return this;
  }
}

// フォームバリデーター
class FormValidator {
  final Map<String, ValidationRule> _fieldRules = {};
  
  FormValidator field(String fieldName, ValidationRule rule) {
    _fieldRules[fieldName] = rule;
    return this;
  }
  
  Result<Map<String, dynamic>> validate(Map<String, dynamic> data) {
    final Map<String, String> errors = {};
    final Map<String, dynamic> validatedData = {};
    
    for (final entry in _fieldRules.entries) {
      final fieldName = entry.key;
      final rule = entry.value;
      final value = data[fieldName];
      
      final result = rule.validate(value, fieldName);
      
      if (result.isFailure) {
        final error = result.error as ValidationError;
        if (error.fieldErrors != null) {
          errors.addAll(error.fieldErrors!);
        } else {
          errors[fieldName] = error.message;
        }
      } else {
        validatedData[fieldName] = result.data;
      }
    }
    
    if (errors.isNotEmpty) {
      return Result.failure(
        ValidationError(
          message: '入力内容に誤りがあります',
          fieldErrors: errors,
        ),
      );
    }
    
    return Result.success(validatedData);
  }
}

// よく使用されるバリデーターのファクトリー
class Validators {
  // 商品名バリデーター
  static Validator<String> productName() {
    return StringValidator()
        .required()
        .minLength(1)
        .maxLength(100);
  }
  
  // 顧客名バリデーター
  static Validator<String> customerName() {
    return StringValidator()
        .required()
        .minLength(1)
        .maxLength(50);
  }
  
  // 価格バリデーター
  static Validator<num> price() {
    return NumberValidator()
        .required()
        .min(0)
        .max(999999);
  }
  
  // 在庫数バリデーター
  static Validator<num> stockQuantity() {
    return NumberValidator()
        .required()
        .min(0)
        .max(99999);
  }
  
  // メールアドレスバリデーター（任意）
  static Validator<String> optionalEmail() {
    return StringValidator().email();
  }
  
  // 電話番号バリデーター（任意）
  static Validator<String> optionalPhone() {
    return StringValidator().phone();
  }
  
  // 税率バリデーター
  static Validator<num> taxRate() {
    return NumberValidator()
        .required()
        .range(0, 1);
  }
  
  // ポイントバリデーター
  static Validator<num> loyaltyPoints() {
    return NumberValidator()
        .required()
        .min(0)
        .max(999999);
  }
}