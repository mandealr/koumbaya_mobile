import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token', fromJson: _tokenFromJson)
  final String? token;
  
  @JsonKey(fromJson: _userFromJson)
  final User? user;
  
  final String? message;
  final bool? success;
  
  @JsonKey(name: 'data')
  final Map<String, dynamic>? data;

  AuthResponse({
    this.token,
    this.user,
    this.message,
    this.success,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      return AuthResponse(
        token: data['access_token'] as String? ?? data['token'] as String? ?? json['access_token'] as String? ?? json['token'] as String?,
        user: data['user'] != null 
          ? User.fromJson(data['user'] as Map<String, dynamic>)
          : json['user'] != null 
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        message: json['message'] as String?,
        success: json['success'] as bool? ?? true,
        data: data,
      );
    }
    
    return _$AuthResponseFromJson(json);
  }
  
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  bool get isSuccess => (success == true || success == null) && (token != null || user != null);
  
  static String? _tokenFromJson(dynamic json) {
    if (json == null) return null;
    return json as String;
  }
  
  static User? _userFromJson(dynamic json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) {
      return User.fromJson(json);
    }
    return null;
  }
}