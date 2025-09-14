// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  token: AuthResponse._tokenFromJson(json['access_token']),
  user: AuthResponse._userFromJson(json['user']),
  message: json['message'] as String?,
  success: json['success'] as bool?,
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.token,
      'user': instance.user,
      'message': instance.message,
      'success': instance.success,
      'data': instance.data,
    };
