import 'package:json_annotation/json_annotation.dart';
import 'country.dart';
import 'language.dart';
import 'role.dart';

part 'user.g.dart';

// Helper functions for safe parsing
String _parseString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return value.toString();
}

DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}

double? _parseNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    try {
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return false;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      return 0;
    }
  }
  return 0;
}

// Helper function for parsing roles list
List<Role> _parseRoles(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    try {
      return value.map((item) => Role.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }
  return [];
}

@JsonSerializable()
class User {
  @JsonKey(fromJson: _parseInt)
  final int id;
  @JsonKey(name: 'first_name', fromJson: _parseString)
  final String firstName;
  @JsonKey(name: 'last_name', fromJson: _parseString)
  final String lastName;
  @JsonKey(fromJson: _parseString)
  final String email;
  @JsonKey(fromJson: _parseNullableString)
  final String? phone;
  @JsonKey(fromJson: _parseNullableString)
  final String? address;
  @JsonKey(fromJson: _parseNullableString)
  final String? city;
  @JsonKey(fromJson: _parseNullableDouble)
  final double? latitude;
  @JsonKey(fromJson: _parseNullableDouble)
  final double? longitude;
  @JsonKey(name: 'business_name', fromJson: _parseNullableString)
  final String? businessName;
  @JsonKey(name: 'business_email', fromJson: _parseNullableString)
  final String? businessEmail;
  @JsonKey(name: 'business_description', fromJson: _parseNullableString)
  final String? businessDescription;
  @JsonKey(name: 'can_sell', fromJson: _intToBool, toJson: _boolToInt)
  final bool? canSell;
  @JsonKey(name: 'can_buy', fromJson: _intToBool, toJson: _boolToInt)
  final bool? canBuy;
  @JsonKey(fromJson: _parseNullableString)
  final String? rating;
  @JsonKey(name: 'rating_count', fromJson: _parseNullableInt)
  final int? ratingCount;
  @JsonKey(name: 'facebook_id', fromJson: _parseNullableString)
  final String? facebookId;
  @JsonKey(name: 'google_id', fromJson: _parseNullableString)
  final String? googleId;
  @JsonKey(name: 'apple_id', fromJson: _parseNullableString)
  final String? appleId;
  @JsonKey(name: 'email_notifications', fromJson: _intToBool, toJson: _boolToInt)
  final bool? emailNotifications;
  @JsonKey(name: 'sms_notifications', fromJson: _intToBool, toJson: _boolToInt)
  final bool? smsNotifications;
  @JsonKey(name: 'push_notifications', fromJson: _intToBool, toJson: _boolToInt)
  final bool? pushNotifications;
  @JsonKey(fromJson: _parseRoles)
  final List<Role> roles;
  @JsonKey(name: 'account_type', fromJson: _parseNullableString)
  final String? accountType;
  @JsonKey(name: 'last_login_date', fromJson: _parseNullableDateTime)
  final DateTime? lastLoginDate;
  @JsonKey(name: 'verified_at', fromJson: _parseNullableDateTime)
  final DateTime? verifiedAt;
  @JsonKey(name: 'source_ip_address', fromJson: _parseNullableString)
  final String? sourceIpAddress;
  @JsonKey(name: 'source_server_info', fromJson: _parseNullableString)
  final String? sourceServerInfo;
  @JsonKey(name: 'is_active', fromJson: _parseBool)
  final bool isActive;
  @JsonKey(name: 'mfa_is_active', fromJson: _parseBool)
  final bool mfaIsActive;
  @JsonKey(name: 'user_type_id', fromJson: _parseNullableInt)
  final int? userTypeId;
  @JsonKey(name: 'country_id', fromJson: _parseNullableInt)
  final int? countryId;
  @JsonKey(name: 'language_id', fromJson: _parseNullableInt)
  final int? languageId;
  @JsonKey(name: 'last_otp_request', fromJson: _parseNullableDateTime)
  final DateTime? lastOtpRequest;
  @JsonKey(name: 'created_at', fromJson: _parseNullableDateTime)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _parseNullableDateTime)
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
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.businessName,
    this.businessEmail,
    this.businessDescription,
    this.canSell,
    this.canBuy,
    this.rating,
    this.ratingCount,
    this.facebookId,
    this.googleId,
    this.appleId,
    this.emailNotifications,
    this.smsNotifications,
    this.pushNotifications,
    this.roles = const [],
    this.accountType,
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
  // Méthodes pour la gestion des rôles (nouvelle architecture)
  bool hasRole(String roleName) {
    return roles.any((role) => role.name == roleName);
  }

  // Rôles clients (autorisés dans l'app mobile)
  bool get isCustomer => hasRole('Particulier');
  bool get isMerchant => hasRole('Business Individual') || hasRole('Business Enterprise');
  bool get isBusinessIndividual => hasRole('Business Individual');
  bool get isBusinessEnterprise => hasRole('Business Enterprise');

  // Rôles admin (NON autorisés dans l'app mobile)
  bool get isManager => hasRole('Agent') || hasRole('Admin') || hasRole('Super Admin');
  bool get isAdmin => hasRole('Admin') || hasRole('Super Admin');
  bool get isSuperAdmin => hasRole('Super Admin');

  // Vérifier si l'utilisateur est autorisé à utiliser l'app mobile
  bool get isAllowedInMobileApp {
    // L'app mobile est réservée aux clients (user_type_id = 2)
    // Vérifie que l'utilisateur a un rôle client ET n'a PAS de rôle admin
    return (isCustomer || isMerchant) && !isManager;
  }

  String get primaryRole {
    if (roles.isNotEmpty) {
      // Ordre de priorité des rôles
      if (hasRole('Super Admin')) return 'Super Admin';
      if (hasRole('Admin')) return 'Admin';
      if (hasRole('Agent')) return 'Agent';
      if (hasRole('Business Enterprise')) return 'Business Enterprise';
      if (hasRole('Business Individual')) return 'Business Individual';
      if (hasRole('Particulier')) return 'Particulier';
      return roles.first.name;
    }
    // Fallback basé sur canSell (ancienne logique)
    if (canSell == true) return 'Business Individual';
    return 'Particulier';
  }
  
  List<String> get roleNames {
    return roles.map((role) => role.name).toList();
  }
  bool get isVerified => verifiedAt != null;

  @override
  String toString() => fullName;

  // Convertisseurs pour les booléens stockés comme int (0/1)
  static bool? _intToBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return null;
  }

  static int? _boolToInt(bool? value) {
    if (value == null) return null;
    return value ? 1 : 0;
  }
}