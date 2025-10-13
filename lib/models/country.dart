import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

// Helper function for parsing String
String _parseString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

// Helper function for parsing nullable String
String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return value.toString();
}

// Helper function for parsing nullable DateTime
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

// Helper function for parsing boolean
bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return false;
}

@JsonSerializable()
class Country {
  final int id;
  @JsonKey(fromJson: _parseString)
  final String name;
  @JsonKey(name: 'iso_code_2', fromJson: _parseString)
  final String isoCode2;
  @JsonKey(name: 'iso_code_3', fromJson: _parseString)
  final String isoCode3;
  @JsonKey(name: 'phone_code', fromJson: _parseNullableString)
  final String? phoneCode;
  @JsonKey(name: 'currency_code', fromJson: _parseNullableString)
  final String? currencyCode;
  @JsonKey(name: 'currency_symbol', fromJson: _parseNullableString)
  final String? currencySymbol;
  @JsonKey(fromJson: _parseNullableString)
  final String? flag;
  @JsonKey(name: 'flag_emoji', fromJson: _parseNullableString)
  final String? flagEmoji;
  @JsonKey(name: 'is_active', fromJson: _parseBool)
  final bool isActive;
  @JsonKey(name: 'created_at', fromJson: _parseNullableDateTime)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _parseNullableDateTime)
  final DateTime? updatedAt;

  Country({
    required this.id,
    required this.name,
    required this.isoCode2,
    required this.isoCode3,
    this.phoneCode,
    this.currencyCode,
    this.currencySymbol,
    this.flag,
    this.flagEmoji,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);
  Map<String, dynamic> toJson() => _$CountryToJson(this);

  @override
  String toString() => name;
}