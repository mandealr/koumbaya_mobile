// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
  id: (json['id'] as num).toInt(),
  name: _parseString(json['name']),
  description: _parseNullableString(json['description']),
  active: json['active'] == null ? true : _parseBool(json['active']),
  mutable: json['mutable'] == null ? true : _parseBool(json['mutable']),
  userTypeId: (json['user_type_id'] as num?)?.toInt(),
  merchantId: (json['merchant_id'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  createdAt: _parseNullableDateTime(json['created_at']),
  updatedAt: _parseNullableDateTime(json['updated_at']),
);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'active': instance.active,
  'mutable': instance.mutable,
  'user_type_id': instance.userTypeId,
  'merchant_id': instance.merchantId,
  'user_id': instance.userId,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
