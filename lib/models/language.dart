import 'package:json_annotation/json_annotation.dart';

part 'language.g.dart';

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
class Language {
  final int id;
  @JsonKey(fromJson: _parseString)
  final String name;
  @JsonKey(fromJson: _parseString)
  final String code;
  @JsonKey(fromJson: _parseNullableString)
  final String? flag;
  @JsonKey(name: 'native_name', fromJson: _parseNullableString)
  final String? nativeName;
  @JsonKey(name: 'is_active', fromJson: _parseBool)
  final bool isActive;
  @JsonKey(name: 'is_default', fromJson: _parseBool)
  final bool isDefault;
  @JsonKey(name: 'created_at', fromJson: _parseNullableDateTime)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _parseNullableDateTime)
  final DateTime? updatedAt;

  Language({
    required this.id,
    required this.name,
    required this.code,
    this.flag,
    this.nativeName,
    required this.isActive,
    required this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory Language.fromJson(Map<String, dynamic> json) => _$LanguageFromJson(json);
  Map<String, dynamic> toJson() => _$LanguageToJson(this);

  @override
  String toString() => nativeName ?? name;
}