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
  address: json['address'] as String?,
  city: json['city'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  businessName: json['business_name'] as String?,
  businessEmail: json['business_email'] as String?,
  businessDescription: json['business_description'] as String?,
  canSell: User._intToBool(json['can_sell']),
  canBuy: User._intToBool(json['can_buy']),
  rating: json['rating'] as String?,
  ratingCount: (json['rating_count'] as num?)?.toInt(),
  facebookId: json['facebook_id'] as String?,
  googleId: json['google_id'] as String?,
  appleId: json['apple_id'] as String?,
  emailNotifications: User._intToBool(json['email_notifications']),
  smsNotifications: User._intToBool(json['sms_notifications']),
  pushNotifications: User._intToBool(json['push_notifications']),
  role: json['role'] as String?,
  accountType: json['account_type'] as String?,
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
  'address': instance.address,
  'city': instance.city,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'business_name': instance.businessName,
  'business_email': instance.businessEmail,
  'business_description': instance.businessDescription,
  'can_sell': User._boolToInt(instance.canSell),
  'can_buy': User._boolToInt(instance.canBuy),
  'rating': instance.rating,
  'rating_count': instance.ratingCount,
  'facebook_id': instance.facebookId,
  'google_id': instance.googleId,
  'apple_id': instance.appleId,
  'email_notifications': User._boolToInt(instance.emailNotifications),
  'sms_notifications': User._boolToInt(instance.smsNotifications),
  'push_notifications': User._boolToInt(instance.pushNotifications),
  'role': instance.role,
  'account_type': instance.accountType,
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
