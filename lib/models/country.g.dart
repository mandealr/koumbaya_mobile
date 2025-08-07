// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  isoCode2: json['iso_code_2'] as String,
  isoCode3: json['iso_code_3'] as String,
  phoneCode: json['phone_code'] as String?,
  currencyCode: json['currency_code'] as String?,
  currencySymbol: json['currency_symbol'] as String?,
  flag: json['flag'] as String?,
  isActive: json['is_active'] as bool,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
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
  'is_active': instance.isActive,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
