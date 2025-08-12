import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable(explicitToJson: true)
class Category {
  final int id;
  final String name;
  final String? description;
  final String? image;
  @JsonKey(name: 'parent_id')
  final int? parentId;
  @JsonKey(name: 'is_active', fromJson: _intToBool, toJson: _boolToInt)
  final bool isActive;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
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