import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final int loyaltyPoints;
  final DateTime? dateOfBirth;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    required this.loyaltyPoints,
    this.dateOfBirth,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.create({
    required String name,
    String? email,
    String? phone,
    String? address,
    int loyaltyPoints = 0,
    DateTime? dateOfBirth,
    bool isActive = true,
  }) {
    final now = DateTime.now();
    return Customer(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      address: address,
      loyaltyPoints: loyaltyPoints,
      dateOfBirth: dateOfBirth,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    int? loyaltyPoints,
    DateTime? dateOfBirth,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          address == other.address &&
          loyaltyPoints == other.loyaltyPoints &&
          dateOfBirth == other.dateOfBirth &&
          isActive == other.isActive &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      address.hashCode ^
      loyaltyPoints.hashCode ^
      dateOfBirth.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'Customer{id: $id, name: $name, loyaltyPoints: $loyaltyPoints}';
  }

  Customer addPoints(int points) {
    return copyWith(
      loyaltyPoints: loyaltyPoints + points,
      updatedAt: DateTime.now(),
    );
  }

  Customer subtractPoints(int points) {
    return copyWith(
      loyaltyPoints: (loyaltyPoints - points).clamp(0, double.infinity).toInt(),
      updatedAt: DateTime.now(),
    );
  }
}