import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String? token;
  final User? user;
  final String? message;
  final bool? success;

  AuthResponse({
    this.token,
    this.user,
    this.message,
    this.success,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  bool get isSuccess => (success == true || message == "Connexion réussie") && user != null;
}