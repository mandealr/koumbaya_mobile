// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  image: json['image'] as String?,
  parentId: (json['parent_id'] as num?)?.toInt(),
  isActive: Category._intToBool(json['is_active']),
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  children:
      (json['children'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
  parent:
      json['parent'] == null
          ? null
          : Category.fromJson(json['parent'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'image': instance.image,
  'parent_id': instance.parentId,
  'is_active': Category._boolToInt(instance.isActive),
  'sort_order': instance.sortOrder,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'children': instance.children?.map((e) => e.toJson()).toList(),
  'parent': instance.parent?.toJson(),
};
