// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
  id: (json['id'] as num).toInt(),
  name: _parseString(json['name']),
  isoCode2: _parseString(json['iso_code_2']),
  isoCode3: _parseString(json['iso_code_3']),
  phoneCode: _parseNullableString(json['phone_code']),
  currencyCode: _parseNullableString(json['currency_code']),
  currencySymbol: _parseNullableString(json['currency_symbol']),
  flag: _parseNullableString(json['flag']),
  flagEmoji: _parseNullableString(json['flag_emoji']),
  isActive: _parseBool(json['is_active']),
  createdAt: _parseNullableDateTime(json['created_at']),
  updatedAt: _parseNullableDateTime(json['updated_at']),
);

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'iso_code_2': instance.isoCode2,
  'iso_code_3': instance.isoCode3,
  'phone_code': instance.phoneCode,
  'currency_code': instance.currencyCode,
  'currency_symbol': instance.currencySymbol,
  'flag': instance.flag,
  'flag_emoji': instance.flagEmoji,
  'is_active': instance.isActive,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
