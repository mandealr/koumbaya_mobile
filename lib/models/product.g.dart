// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  ticketQuantity: (json['ticket_quantity'] as num).toInt(),
  image: json['image'] as String,
  merchantId: (json['merchant_id'] as num).toInt(),
  categoryId: (json['category_id'] as num).toInt(),
  isActive: json['is_active'] as bool,
  isFeatured: json['is_featured'] as bool,
  drawDate:
      json['draw_date'] == null
          ? null
          : DateTime.parse(json['draw_date'] as String),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  merchant:
      json['merchant'] == null
          ? null
          : User.fromJson(json['merchant'] as Map<String, dynamic>),
  category:
      json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
  activeLottery:
      json['active_lottery'] == null
          ? null
          : Lottery.fromJson(json['active_lottery'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'price': instance.price,
  'ticket_quantity': instance.ticketQuantity,
  'image': instance.image,
  'merchant_id': instance.merchantId,
  'category_id': instance.categoryId,
  'is_active': instance.isActive,
  'is_featured': instance.isFeatured,
  'draw_date': instance.drawDate?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'merchant': instance.merchant,
  'category': instance.category,
  'active_lottery': instance.activeLottery,
};
