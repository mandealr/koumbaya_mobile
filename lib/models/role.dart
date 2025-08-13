import 'package:json_annotation/json_annotation.dart';

part 'role.g.dart';

// Helper function for parsing String
String _parseString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

// Helper function for parsing nullable String
String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return value.toString();
}

// Helper function for parsing nullable DateTime
DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}

// Helper function for parsing boolean
bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return false;
}

@JsonSerializable()
class Role {
  final int id;
  @JsonKey(fromJson: _parseString)
  final String name;
  @JsonKey(fromJson: _parseNullableString)
  final String? description;
  @JsonKey(fromJson: _parseBool)
  final bool active;
  @JsonKey(fromJson: _parseBool)
  final bool mutable;
  @JsonKey(name: 'user_type_id')
  final int? userTypeId;
  @JsonKey(name: 'merchant_id')
  final int? merchantId;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'created_at', fromJson: _parseNullableDateTime)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _parseNullableDateTime)
  final DateTime? updatedAt;

  Role({
    required this.id,
    required this.name,
    this.description,
    this.active = true,
    this.mutable = true,
    this.userTypeId,
    this.merchantId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);

  @override
  String toString() => name;

  // Helper methods basés sur le système hybride Koumbaya
  bool get isCustomer => name == 'Particulier';
  bool get isMerchant => name == 'Business';
  bool get isManager => name == 'Agent' || name == 'Agent Back Office' || name == 'Admin' || name == 'Super Admin';
  bool get isAdmin => name == 'Admin' || name == 'Super Admin';
}