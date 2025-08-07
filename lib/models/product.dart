import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'category.dart';
import 'lottery.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final String title; // Alias pour compatibilité
  final String description;
  final double price;
  @JsonKey(name: 'ticket_price')
  final double ticketPrice;
  @JsonKey(name: 'min_participants')
  final int? minParticipants;
  final List<String>? images;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'main_image')
  final String? mainImage;
  @JsonKey(name: 'merchant_id')
  final int merchantId;
  @JsonKey(name: 'category_id')
  final int categoryId;
  final String status;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'has_active_lottery')
  final bool hasActiveLottery;
  @JsonKey(name: 'lottery_ends_soon')
  final bool lotteryEndsSoon;
  @JsonKey(name: 'popularity_score')
  final double popularityScore;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Relations (optional, loaded when needed)
  final User? merchant;
  final Category? category;
  @JsonKey(name: 'active_lottery')
  final Lottery? activeLottery;

  Product({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.price,
    required this.ticketPrice,
    required this.merchantId,
    required this.categoryId,
    required this.status,
    required this.isFeatured,
    required this.hasActiveLottery,
    required this.lotteryEndsSoon,
    required this.popularityScore,
    this.minParticipants,
    this.images,
    this.imageUrl,
    this.mainImage,
    this.createdAt,
    this.updatedAt,
    this.merchant,
    this.category,
    this.activeLottery,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // Getters pour compatibilité et utilité
  String get displayImage => mainImage ?? imageUrl ?? (images?.isNotEmpty == true ? images!.first : '');
  bool get hasImages => images?.isNotEmpty ?? false;
  bool get isActive => status == 'active';
  String get formattedPrice => '${price.toStringAsFixed(0)} FCFA';
  String get formattedTicketPrice => '${ticketPrice.toStringAsFixed(0)} FCFA';

  @override
  String toString() => name;
}