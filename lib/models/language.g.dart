// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Language _$LanguageFromJson(Map<String, dynamic> json) => Language(
  id: (json['id'] as num).toInt(),
  name: _parseString(json['name']),
  code: _parseString(json['code']),
  nativeName: _parseNullableString(json['native_name']),
  isActive: _parseBool(json['is_active']),
  isDefault: _parseBool(json['is_default']),
  createdAt: _parseNullableDateTime(json['created_at']),
  updatedAt: _parseNullableDateTime(json['updated_at']),
);

Map<String, dynamic> _$LanguageToJson(Language instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'native_name': instance.nativeName,
  'is_active': instance.isActive,
  'is_default': instance.isDefault,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
