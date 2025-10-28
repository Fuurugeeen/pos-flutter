import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'sale_item.g.dart';

@JsonSerializable()
class SaleItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double taxRate;
  final String? notes;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.taxRate,
    this.notes,
  });

  factory SaleItem.fromProduct(Product product, int quantity, {String? notes}) {
    return SaleItem(
      productId: product.id,
      productName: product.name,
      unitPrice: product.price,
      quantity: quantity,
      taxRate: product.taxRate.rate,
      notes: notes,
    );
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) => _$SaleItemFromJson(json);
  Map<String, dynamic> toJson() => _$SaleItemToJson(this);

  SaleItem copyWith({
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    double? taxRate,
    String? notes,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      taxRate: taxRate ?? this.taxRate,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItem &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          productName == other.productName &&
          unitPrice == other.unitPrice &&
          quantity == other.quantity &&
          taxRate == other.taxRate &&
          notes == other.notes;

  @override
  int get hashCode =>
      productId.hashCode ^
      productName.hashCode ^
      unitPrice.hashCode ^
      quantity.hashCode ^
      taxRate.hashCode ^
      notes.hashCode;

  @override
  String toString() {
    return 'SaleItem{productName: $productName, quantity: $quantity, unitPrice: $unitPrice}';
  }

  // Calculated properties
  double get subtotal => unitPrice * quantity;
  double get taxAmount => subtotal * taxRate;
  double get total => subtotal + taxAmount;
}