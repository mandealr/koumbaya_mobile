import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

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

// Helper function for parsing nullable int
int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

@JsonSerializable(explicitToJson: true)
class Category {
  final int id;
  @JsonKey(fromJson: _parseString)
  final String name;
  @JsonKey(fromJson: _parseNullableString)
  final String? description;
  @JsonKey(fromJson: _parseNullableString)
  final String? image;
  @JsonKey(name: 'parent_id', fromJson: _parseNullableInt)
  final int? parentId;
  @JsonKey(name: 'is_active', fromJson: _intToBool, toJson: _boolToInt)
  final bool isActive;
  @JsonKey(name: 'sort_order', fromJson: _parseNullableInt)
  final int? sortOrder;
  @JsonKey(name: 'created_at', fromJson: _parseNullableDateTime)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _parseNullableDateTime)
  final DateTime? updatedAt;

  // Relations (optional, loaded when needed)
  final List<Category>? children;
  final Category? parent;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.parentId,
    required this.isActive,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
    this.children,
    this.parent,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  bool get hasChildren => children != null && children!.isNotEmpty;
  bool get isParent => parentId == null;

  static bool _intToBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  static int _boolToInt(bool value) => value ? 1 : 0;

  @override
  String toString() => name;
}