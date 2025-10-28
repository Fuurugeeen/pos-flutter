// Core enums for the POS system

enum ProductCategory {
  coffee,
  tea,
  pastry,
  sandwich,
  dessert,
  beverage,
  other,
}

enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  mobilePay,
  points,
}

enum TaxRate {
  standard(0.10), // 10% standard tax
  reduced(0.08),  // 8% reduced tax
  exempt(0.0);    // Tax exempt
  
  const TaxRate(this.rate);
  final double rate;
}

enum SaleStatus {
  pending,
  completed,
  cancelled,
  refunded,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.coffee:
        return 'コーヒー';
      case ProductCategory.tea:
        return '紅茶';
      case ProductCategory.pastry:
        return 'ペストリー';
      case ProductCategory.sandwich:
        return 'サンドイッチ';
      case ProductCategory.dessert:
        return 'デザート';
      case ProductCategory.beverage:
        return '飲み物';
      case ProductCategory.other:
        return 'その他';
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return '現金';
      case PaymentMethod.creditCard:
        return 'クレジットカード';
      case PaymentMethod.debitCard:
        return 'デビットカード';
      case PaymentMethod.mobilePay:
        return 'モバイル決済';
      case PaymentMethod.points:
        return 'ポイント';
    }
  }
}