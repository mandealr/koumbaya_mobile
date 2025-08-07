import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'category.dart';
import 'lottery.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  @JsonKey(name: 'ticket_quantity')
  final int ticketQuantity;
  final String image;
  @JsonKey(name: 'merchant_id')
  final int merchantId;
  @JsonKey(name: 'category_id')
  final int categoryId;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'draw_date')
  final DateTime? drawDate;
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
    required this.title,
    required this.description,
    required this.price,
    required this.ticketQuantity,
    required this.image,
    required this.merchantId,
    required this.categoryId,
    required this.isActive,
    required this.isFeatured,
    this.drawDate,
    this.createdAt,
    this.updatedAt,
    this.merchant,
    this.category,
    this.activeLottery,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  bool get hasActiveLottery => activeLottery != null;
  bool get isDrawScheduled => drawDate != null;
  String get formattedPrice => '${price.toStringAsFixed(0)} FCFA';

  @override
  String toString() => title;
}