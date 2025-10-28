import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';
import 'sale_item.dart';

part 'sale.g.dart';

@JsonSerializable(explicitToJson: true)
class Sale {
  final String id;
  final String? customerId;
  final String? customerName;
  final List<SaleItem> items;
  final PaymentMethod paymentMethod;
  final SaleStatus status;
  final double discountAmount;
  final int loyaltyPointsUsed;
  final int loyaltyPointsEarned;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Sale({
    required this.id,
    this.customerId,
    this.customerName,
    required this.items,
    required this.paymentMethod,
    required this.status,
    required this.discountAmount,
    required this.loyaltyPointsUsed,
    required this.loyaltyPointsEarned,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Sale.create({
    String? customerId,
    String? customerName,
    required List<SaleItem> items,
    required PaymentMethod paymentMethod,
    SaleStatus status = SaleStatus.pending,
    double discountAmount = 0.0,
    int loyaltyPointsUsed = 0,
    int loyaltyPointsEarned = 0,
    String? notes,
  }) {
    final now = DateTime.now();
    return Sale(
      id: const Uuid().v4(),
      customerId: customerId,
      customerName: customerName,
      items: items,
      paymentMethod: paymentMethod,
      status: status,
      discountAmount: discountAmount,
      loyaltyPointsUsed: loyaltyPointsUsed,
      loyaltyPointsEarned: loyaltyPointsEarned,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
  Map<String, dynamic> toJson() => _$SaleToJson(this);

  Sale copyWith({
    String? id,
    String? customerId,
    String? customerName,
    List<SaleItem>? items,
    PaymentMethod? paymentMethod,
    SaleStatus? status,
    double? discountAmount,
    int? loyaltyPointsUsed,
    int? loyaltyPointsEarned,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      discountAmount: discountAmount ?? this.discountAmount,
      loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sale &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          customerName == other.customerName &&
          items == other.items &&
          paymentMethod == other.paymentMethod &&
          status == other.status &&
          discountAmount == other.discountAmount &&
          loyaltyPointsUsed == other.loyaltyPointsUsed &&
          loyaltyPointsEarned == other.loyaltyPointsEarned &&
          notes == other.notes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      customerId.hashCode ^
      customerName.hashCode ^
      items.hashCode ^
      paymentMethod.hashCode ^
      status.hashCode ^
      discountAmount.hashCode ^
      loyaltyPointsUsed.hashCode ^
      loyaltyPointsEarned.hashCode ^
      notes.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'Sale{id: $id, total: $finalTotal, status: $status, createdAt: $createdAt}';
  }

  // Calculated properties
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get totalTax => items.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get totalBeforeDiscount => subtotal + totalTax;
  double get finalTotal => (totalBeforeDiscount - discountAmount - loyaltyPointsUsed).clamp(0.0, double.infinity);
  
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  
  Sale addItem(SaleItem item) {
    final existingItemIndex = items.indexWhere((i) => i.productId == item.productId);
    final List<SaleItem> newItems;
    
    if (existingItemIndex >= 0) {
      newItems = List.from(items);
      newItems[existingItemIndex] = items[existingItemIndex].copyWith(
        quantity: items[existingItemIndex].quantity + item.quantity,
      );
    } else {
      newItems = [...items, item];
    }
    
    return copyWith(
      items: newItems,
      updatedAt: DateTime.now(),
    );
  }
  
  Sale removeItem(String productId) {
    return copyWith(
      items: items.where((item) => item.productId != productId).toList(),
      updatedAt: DateTime.now(),
    );
  }
  
  Sale updateItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId);
    }
    
    final newItems = items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
    
    return copyWith(
      items: newItems,
      updatedAt: DateTime.now(),
    );
  }
}