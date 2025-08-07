import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

@JsonSerializable()
class Country {
  final int id;
  final String name;
  @JsonKey(name: 'iso_code_2')
  final String isoCode2;
  @JsonKey(name: 'iso_code_3')
  final String isoCode3;
  @JsonKey(name: 'phone_code')
  final String? phoneCode;
  @JsonKey(name: 'currency_code')
  final String? currencyCode;
  @JsonKey(name: 'currency_symbol')
  final String? currencySymbol;
  final String? flag;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
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
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);
  Map<String, dynamic> toJson() => _$CountryToJson(this);

  @override
  String toString() => name;
}