// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  ticketPrice: (json['ticket_price'] as num).toDouble(),
  merchantId: (json['merchant_id'] as num).toInt(),
  categoryId: (json['category_id'] as num).toInt(),
  status: json['status'] as String,
  isFeatured: json['is_featured'] as bool,
  hasActiveLottery: json['has_active_lottery'] as bool,
  lotteryEndsSoon: json['lottery_ends_soon'] as bool,
  popularityScore: (json['popularity_score'] as num).toDouble(),
  minParticipants: (json['min_participants'] as num?)?.toInt(),
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
  imageUrl: json['image_url'] as String?,
  mainImage: json['main_image'] as String?,
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
