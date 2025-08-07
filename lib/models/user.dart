import 'package:json_annotation/json_annotation.dart';
import 'country.dart';
import 'language.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  final String? phone;
  final String role;
  @JsonKey(name: 'last_login_date')
  final DateTime? lastLoginDate;
  @JsonKey(name: 'verified_at')
  final DateTime? verifiedAt;
  @JsonKey(name: 'source_ip_address')
  final String? sourceIpAddress;
  @JsonKey(name: 'source_server_info')
  final String? sourceServerInfo;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'mfa_is_active')
  final bool mfaIsActive;
  @JsonKey(name: 'user_type_id')
  final int? userTypeId;
  @JsonKey(name: 'country_id')
  final int? countryId;
  @JsonKey(name: 'language_id')
  final int? languageId;
  @JsonKey(name: 'last_otp_request')
  final DateTime? lastOtpRequest;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Relations (optional, loaded when needed)
  final Country? country;
  final Language? language;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.role,
    this.lastLoginDate,
    this.verifiedAt,
    this.sourceIpAddress,
    this.sourceServerInfo,
    required this.isActive,
    required this.mfaIsActive,
    this.userTypeId,
    this.countryId,
    this.languageId,
    this.lastOtpRequest,
    this.createdAt,
    this.updatedAt,
    this.country,
    this.language,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName => '$firstName $lastName';
  bool get isMerchant => role == 'MERCHANT';
  bool get isVerified => verifiedAt != null;

  @override
  String toString() => fullName;
}