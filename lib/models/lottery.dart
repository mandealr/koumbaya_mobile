import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'lottery.g.dart';

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

// Helper function for parsing String
String _parseString(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString();
}

// Helper function for parsing nullable String
String? _parseNullableString(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value.isEmpty ? null : value;
  }
  return value.toString();
}

// Helper function for parsing DateTime
DateTime _parseDateTime(dynamic value) {
  if (value == null) {
    return DateTime.now();
  }
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return DateTime.now();
    }
  }
  return DateTime.now();
}

// Helper function for parsing nullable DateTime
DateTime? _parseNullableDateTime(dynamic value) {
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

@JsonSerializable()
class Lottery {
  final int id;
  @JsonKey(name: 'lottery_number', fromJson: _parseString)
  final String lotteryNumber;
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'total_tickets')
  final int totalTickets;
  @JsonKey(name: 'sold_tickets')
  final int soldTickets;
  @JsonKey(name: 'remaining_tickets')
  final int remainingTicketsCount;
  @JsonKey(name: 'ticket_price', fromJson: _parseDouble)
  final double ticketPrice;
  @JsonKey(name: 'start_date', fromJson: _parseDateTime)
  final DateTime startDate;
  @JsonKey(name: 'end_date', fromJson: _parseDateTime)
  final DateTime endDate;
  @JsonKey(name: 'draw_date', fromJson: _parseNullableDateTime)
  final DateTime? drawDate;
  @JsonKey(fromJson: _parseString)
  final String status;
  @JsonKey(name: 'is_drawn')
  final bool isDrawn;
  @JsonKey(name: 'is_expired')
  final bool isExpired;
  @JsonKey(name: 'can_draw')
  final bool canDraw;
  @JsonKey(name: 'progress_percentage', fromJson: _parseDouble)
  final double progressPercentage;
  @JsonKey(name: 'participation_rate', fromJson: _parseDouble)
  final double participationRate;
  @JsonKey(name: 'is_ending_soon')
  final bool isEndingSoon;
  @JsonKey(name: 'winner_ticket_number', fromJson: _parseNullableString)
  final String? winnerTicketNumber;
  @JsonKey(name: 'winner_user_id')
  final int? winnerUserId;
  @JsonKey(name: 'total_revenue', fromJson: _parseDouble)
  final double totalRevenue;
  @JsonKey(name: 'created_at', fromJson: _parseNullableDateTime)
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _parseNullableDateTime)
  final DateTime? updatedAt;

  // Relations (optional, loaded when needed)
  final Product? product;

  Lottery({
    required this.id,
    required this.lotteryNumber,
    required this.productId,
    required this.totalTickets,
    required this.soldTickets,
    required this.remainingTicketsCount,
    required this.ticketPrice,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isDrawn,
    required this.isExpired,
    required this.canDraw,
    required this.progressPercentage,
    required this.participationRate,
    required this.isEndingSoon,
    required this.totalRevenue,
    this.drawDate,
    this.winnerTicketNumber,
    this.winnerUserId,
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  factory Lottery.fromJson(Map<String, dynamic> json) => _$LotteryFromJson(json);
  Map<String, dynamic> toJson() => _$LotteryToJson(this);

  // Getters pour compatibilité et utilité
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  int get remainingTickets => remainingTicketsCount;
  double get completionPercentage => progressPercentage;
  
  bool get hasWinner => winnerTicketNumber != null && winnerUserId != null;
  String get formattedTicketPrice => '${ticketPrice.toStringAsFixed(0)} FCFA';
  String get formattedTotalRevenue => '${totalRevenue.toStringAsFixed(0)} FCFA';

  @override
  String toString() => 'Lottery #$id';
}