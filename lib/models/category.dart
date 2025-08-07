import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String? description;
  final String? image;
  @JsonKey(name: 'parent_id')
  final int? parentId;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
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
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
    this.children,
    this.parent,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  bool get hasChildren => children != null && children!.isNotEmpty;
  bool get isParent => parentId == null;

  @override
  String toString() => name;
}