// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  role: json['role'] as String,
  lastLoginDate:
      json['last_login_date'] == null
          ? null
          : DateTime.parse(json['last_login_date'] as String),
  verifiedAt:
      json['verified_at'] == null
          ? null
          : DateTime.parse(json['verified_at'] as String),
  sourceIpAddress: json['source_ip_address'] as String?,
  sourceServerInfo: json['source_server_info'] as String?,
  isActive: json['is_active'] as bool,
  mfaIsActive: json['mfa_is_active'] as bool,
  userTypeId: (json['user_type_id'] as num?)?.toInt(),
  countryId: (json['country_id'] as num?)?.toInt(),
  languageId: (json['language_id'] as num?)?.toInt(),
  lastOtpRequest:
      json['last_otp_request'] == null
          ? null
          : DateTime.parse(json['last_otp_request'] as String),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  country:
      json['country'] == null
          ? null
          : Country.fromJson(json['country'] as Map<String, dynamic>),
  language:
      json['language'] == null
          ? null
          : Language.fromJson(json['language'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'role': instance.role,
  'last_login_date': instance.lastLoginDate?.toIso8601String(),
  'verified_at': instance.verifiedAt?.toIso8601String(),
  'source_ip_address': instance.sourceIpAddress,
  'source_server_info': instance.sourceServerInfo,
  'is_active': instance.isActive,
  'mfa_is_active': instance.mfaIsActive,
  'user_type_id': instance.userTypeId,
  'country_id': instance.countryId,
  'language_id': instance.languageId,
  'last_otp_request': instance.lastOtpRequest?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'country': instance.country,
  'language': instance.language,
};
