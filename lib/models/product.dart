import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'category.dart' as cat;
import 'lottery.dart';

part 'product.g.dart';

// Helper function to parse double from either string or number, with null safety
double _parseDouble(dynamic value) {
  if (value == null) {
    return 0.0; // Valeur par défaut pour null
  }
  if (value is String) {
    if (value.isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  } else if (value is num) {
    return value.toDouble();
  } else if (value is bool) {
    return value ? 1.0 : 0.0;
  }
  return 0.0; // Valeur par défaut pour autres types
}

// Helper function for nullable double parsing
double? _parseNullableDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    if (value.isEmpty) return null;
    return double.tryParse(value);
  } else if (value is num) {
    return value.toDouble();
  } else if (value is bool) {
    return value ? 1.0 : 0.0;
  }
  return null;
}

// Helper function for nullable string parsing
String? _parseNullableString(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value.isEmpty ? null : value;
  }
  return value.toString();
}

// Helper function for nullable boolean parsing
bool? _parseNullableBool(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is bool) {
    return value;
  }
  if (value is int) {
    return value == 1;
  }
  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }
  return null;
}

// Helper function for nullable int parsing  
int? _parseNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

// Helper function for parsing image list
List<String>? _parseImageList(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is List) {
    return value.map((e) => e?.toString()).where((s) => s != null).cast<String>().toList();
  }
  return null;
}

// Helper function for parsing DateTime
DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}

// Helper function for parsing User relation
User? _parseUser(dynamic value) {
  if (value == null) {
    return null;
  }
  try {
    if (value is Map<String, dynamic>) {
      return User.fromJson(value);
    }
  } catch (e) {
    return null;
  }
  return null;
}

// Helper function for parsing Category relation
cat.Category? _parseCategory(dynamic value) {
  if (value == null) {
    return null;
  }
  try {
    if (value is Map<String, dynamic>) {
      return cat.Category.fromJson(value);
    }
  } catch (e) {
    return null;
  }
  return null;
}

// Helper function for parsing Lottery relation
Lottery? _parseLottery(dynamic value) {
  if (value == null) {
    return null;
  }
  try {
    if (value is Map<String, dynamic>) {
      return Lottery.fromJson(value);
    }
  } catch (e) {
    return null;
  }
  return null;
}

@JsonSerializable()
class Product {
  final int id;
  @JsonKey(fromJson: _parseNullableString)
  final String? name;
  @JsonKey(fromJson: _parseNullableString)
  final String? title; // Alias pour compatibilité
  @JsonKey(fromJson: _parseNullableString)
  final String? description;
  @JsonKey(fromJson: _parseDouble)
  final double price;
  @JsonKey(name: 'ticket_price', fromJson: _parseDouble)
  final double ticketPrice;
  @JsonKey(name: 'min_participants', fromJson: _parseNullableInt)
  final int? minParticipants;
  @JsonKey(fromJson: _parseImageList)
  final List<String>? images;
  @JsonKey(name: 'image_url', fromJson: _parseNullableString)
  final String? imageUrl;
  @JsonKey(name: 'main_image', fromJson: _parseNullableString)
  final String? mainImage;
  @JsonKey(name: 'merchant_id', fromJson: _parseNullableInt)
  final int? merchantId;
  @JsonKey(name: 'category_id', fromJson: _parseNullableInt)
  final int? categoryId;
  @JsonKey(fromJson: _parseNullableString)
  final String? status;
  @JsonKey(name: 'is_featured', fromJson: _parseNullableBool)
  final bool? isFeatured;
  @JsonKey(name: 'has_active_lottery', fromJson: _parseNullableBool)
  final bool? hasActiveLottery;
  @JsonKey(name: 'lottery_ends_soon', fromJson: _parseNullableBool)
  final bool? lotteryEndsSoon;
  @JsonKey(name: 'popularity_score', fromJson: _parseNullableDouble)
  final double? popularityScore;
  @JsonKey(name: 'created_at', fromJson: _parseDateTime)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _parseDateTime)
  final DateTime? updatedAt;

  // Relations (optional, loaded when needed)
  @JsonKey(fromJson: _parseUser)
  final User? merchant;
  @JsonKey(fromJson: _parseCategory)
  final cat.Category? category;
  @JsonKey(name: 'active_lottery', fromJson: _parseLottery)
  final Lottery? activeLottery;

  Product({
    required this.id,
    this.name,
    this.title,
    this.description,
    required this.price,
    required this.ticketPrice,
    this.merchantId,
    this.categoryId,
    this.status,
    this.isFeatured,
    this.hasActiveLottery,
    this.lotteryEndsSoon,
    this.popularityScore,
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

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return _$ProductFromJson(json);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Product JSON parsing error: $e');
        print('📋 Product data causing error: $json');
      }
      
      // Fallback parsing with safe extraction
      return Product(
        id: json['id'] as int,
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
    }
  }
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // Getters pour compatibilité et utilité
  String get displayName => name ?? title ?? 'Produit sans nom';
  String get displayDescription => description ?? '';

  String get displayImage {
    final imageUrl = mainImage ?? this.imageUrl ?? (images?.isNotEmpty == true ? images!.first : '');

    // Si l'URL commence par /, ajouter le domaine
    if (imageUrl.startsWith('/')) {
      return 'https://koumbaya.com$imageUrl';
    }

    // Si l'URL est vide ou nulle, retourner un placeholder
    if (imageUrl.isEmpty) {
      return 'https://via.placeholder.com/400x400?text=No+Image';
    }

    return imageUrl;
  }

  bool get hasImages => images?.isNotEmpty ?? false;
  bool get isActive => status == 'active';
  bool get isFeatureProduct => isFeatured ?? false;
  bool get hasLottery => hasActiveLottery ?? false;
  bool get endsLotterySoon => lotteryEndsSoon ?? false;
  double get displayPopularityScore => popularityScore ?? 0.0;
  String get formattedPrice => '${price.toStringAsFixed(0)} FCFA';
  String get formattedTicketPrice => '${ticketPrice.toStringAsFixed(0)} FCFA';

  @override
  String toString() => displayName;
}