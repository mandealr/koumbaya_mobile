// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: (json['id'] as num).toInt(),
  name: _parseNullableString(json['name']),
  title: _parseNullableString(json['title']),
  description: _parseNullableString(json['description']),
  price: _parseDouble(json['price']),
  ticketPrice: _parseDouble(json['ticket_price']),
  merchantId: _parseNullableInt(json['merchant_id']),
  categoryId: _parseNullableInt(json['category_id']),
  status: _parseNullableString(json['status']),
  isFeatured: _parseNullableBool(json['is_featured']),
  hasActiveLottery: _parseNullableBool(json['has_active_lottery']),
  lotteryEndsSoon: _parseNullableBool(json['lottery_ends_soon']),
  popularityScore: _parseNullableDouble(json['popularity_score']),
  minParticipants: _parseNullableInt(json['min_participants']),
  images: _parseImageList(json['images']),
  imageUrl: _parseNullableString(json['image_url']),
  mainImage: _parseNullableString(json['main_image']),
  createdAt: _parseDateTime(json['created_at']),
  updatedAt: _parseDateTime(json['updated_at']),
  merchant: _parseUser(json['merchant']),
  category: _parseCategory(json['category']),
  activeLottery: _parseLottery(json['active_lottery']),
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'title': instance.title,
  'description': instance.description,
  'price': instance.price,
  'ticket_price': instance.ticketPrice,
  'min_participants': instance.minParticipants,
  'images': instance.images,
  'image_url': instance.imageUrl,
  'main_image': instance.mainImage,
  'merchant_id': instance.merchantId,
  'category_id': instance.categoryId,
  'status': instance.status,
  'is_featured': instance.isFeatured,
  'has_active_lottery': instance.hasActiveLottery,
  'lottery_ends_soon': instance.lotteryEndsSoon,
  'popularity_score': instance.popularityScore,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'merchant': instance.merchant,
  'category': instance.category,
  'active_lottery': instance.activeLottery,
};
