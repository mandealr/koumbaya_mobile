import 'package:json_annotation/json_annotation.dart';

part 'language.g.dart';

@JsonSerializable()
class Language {
  final int id;
  final String name;
  final String code;
  @JsonKey(name: 'native_name')
  final String? nativeName;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Language({
    required this.id,
    required this.name,
    required this.code,
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