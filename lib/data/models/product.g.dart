// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: $enumDecode(_$ProductCategoryEnumMap, json['category']),
      taxRate: $enumDecode(_$TaxRateEnumMap, json['taxRate']),
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt(),
      barcode: json['barcode'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'category': _$ProductCategoryEnumMap[instance.category]!,
      'taxRate': _$TaxRateEnumMap[instance.taxRate]!,
      'stockQuantity': instance.stockQuantity,
      'lowStockThreshold': instance.lowStockThreshold,
      'barcode': instance.barcode,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ProductCategoryEnumMap = {
  ProductCategory.coffee: 'coffee',
  ProductCategory.tea: 'tea',
  ProductCategory.pastry: 'pastry',
  ProductCategory.sandwich: 'sandwich',
  ProductCategory.dessert: 'dessert',
  ProductCategory.beverage: 'beverage',
  ProductCategory.other: 'other',
};

const _$TaxRateEnumMap = {
  TaxRate.standard: 'standard',
  TaxRate.reduced: 'reduced',
  TaxRate.exempt: 'exempt',
};
