// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: _parseInt(json['id']),
  firstName: _parseString(json['first_name']),
  lastName: _parseString(json['last_name']),
  email: _parseString(json['email']),
  phone: _parseNullableString(json['phone']),
  address: _parseNullableString(json['address']),
  city: _parseNullableString(json['city']),
  latitude: _parseNullableDouble(json['latitude']),
  longitude: _parseNullableDouble(json['longitude']),
  businessName: _parseNullableString(json['business_name']),
  businessEmail: _parseNullableString(json['business_email']),
  businessDescription: _parseNullableString(json['business_description']),
  canSell: User._intToBool(json['can_sell']),
  canBuy: User._intToBool(json['can_buy']),
  rating: _parseNullableString(json['rating']),
  ratingCount: _parseNullableInt(json['rating_count']),
  facebookId: _parseNullableString(json['facebook_id']),
  googleId: _parseNullableString(json['google_id']),
  appleId: _parseNullableString(json['apple_id']),
  emailNotifications: User._intToBool(json['email_notifications']),
  smsNotifications: User._intToBool(json['sms_notifications']),
  pushNotifications: User._intToBool(json['push_notifications']),
  roles: json['roles'] == null ? const [] : _parseRoles(json['roles']),
  accountType: _parseNullableString(json['account_type']),
  lastLoginDate: _parseNullableDateTime(json['last_login_date']),
  verifiedAt: _parseNullableDateTime(json['verified_at']),
  sourceIpAddress: _parseNullableString(json['source_ip_address']),
  sourceServerInfo: _parseNullableString(json['source_server_info']),
  isActive: _parseBool(json['is_active']),
  mfaIsActive: _parseBool(json['mfa_is_active']),
  userTypeId: _parseNullableInt(json['user_type_id']),
  countryId: _parseNullableInt(json['country_id']),
  languageId: _parseNullableInt(json['language_id']),
  lastOtpRequest: _parseNullableDateTime(json['last_otp_request']),
  createdAt: _parseNullableDateTime(json['created_at']),
  updatedAt: _parseNullableDateTime(json['updated_at']),
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
  'roles': instance.roles,
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
