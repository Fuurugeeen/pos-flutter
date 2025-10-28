import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final ProductCategory category;
  final TaxRate taxRate;
  final int stockQuantity;
  final int? lowStockThreshold;
  final String? barcode;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.taxRate,
    required this.stockQuantity,
    this.lowStockThreshold,
    this.barcode,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.create({
    required String name,
    required String description,
    required double price,
    required ProductCategory category,
    TaxRate taxRate = TaxRate.standard,
    int stockQuantity = 0,
    int? lowStockThreshold,
    String? barcode,
    String? imageUrl,
    bool isActive = true,
  }) {
    final now = DateTime.now();
    return Product(
      id: const Uuid().v4(),
      name: name,
      description: description,
      price: price,
      category: category,
      taxRate: taxRate,
      stockQuantity: stockQuantity,
      lowStockThreshold: lowStockThreshold,
      barcode: barcode,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    ProductCategory? category,
    TaxRate? taxRate,
    int? stockQuantity,
    int? lowStockThreshold,
    String? barcode,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      taxRate: taxRate ?? this.taxRate,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          price == other.price &&
          category == other.category &&
          taxRate == other.taxRate &&
          stockQuantity == other.stockQuantity &&
          lowStockThreshold == other.lowStockThreshold &&
          barcode == other.barcode &&
          imageUrl == other.imageUrl &&
          isActive == other.isActive &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      price.hashCode ^
      category.hashCode ^
      taxRate.hashCode ^
      stockQuantity.hashCode ^
      lowStockThreshold.hashCode ^
      barcode.hashCode ^
      imageUrl.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, category: $category}';
  }

  double get priceWithTax => price * (1 + taxRate.rate);
  bool get isLowStock => lowStockThreshold != null && stockQuantity <= lowStockThreshold!;
}