// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sale _$SaleFromJson(Map<String, dynamic> json) => Sale(
      id: json['id'] as String,
      customerId: json['customerId'] as String?,
      customerName: json['customerName'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      status: $enumDecode(_$SaleStatusEnumMap, json['status']),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      loyaltyPointsUsed: (json['loyaltyPointsUsed'] as num).toInt(),
      loyaltyPointsEarned: (json['loyaltyPointsEarned'] as num).toInt(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SaleToJson(Sale instance) => <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'status': _$SaleStatusEnumMap[instance.status]!,
      'discountAmount': instance.discountAmount,
      'loyaltyPointsUsed': instance.loyaltyPointsUsed,
      'loyaltyPointsEarned': instance.loyaltyPointsEarned,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.creditCard: 'creditCard',
  PaymentMethod.debitCard: 'debitCard',
  PaymentMethod.mobilePay: 'mobilePay',
  PaymentMethod.points: 'points',
};

const _$SaleStatusEnumMap = {
  SaleStatus.pending: 'pending',
  SaleStatus.completed: 'completed',
  SaleStatus.cancelled: 'cancelled',
  SaleStatus.refunded: 'refunded',
};
