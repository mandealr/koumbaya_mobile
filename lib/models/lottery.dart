import 'package:flutter/foundation.dart';
import 'product.dart';

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

// Helper function for parsing int
int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is String) {
    if (value.isEmpty) return 0;
    return int.tryParse(value) ?? 0;
  } else if (value is num) {
    return value.toInt();
  }
  return 0;
}

class Lottery {
  final int id;
  final String lotteryNumber;
  final String title;
  final String description;
  final double ticketPrice;
  final int maxTickets;
  final int soldTickets;
  final String status;
  final DateTime? drawDate;
  final DateTime? endDate;
  final String? winnerTicketNumber;

  // Relations (optional, loaded when needed)
  final Product? product;

  Lottery({
    required this.id,
    required this.lotteryNumber,
    required this.title,
    required this.description,
    required this.ticketPrice,
    required this.maxTickets,
    required this.soldTickets,
    required this.status,
    this.drawDate,
    this.endDate,
    this.winnerTicketNumber,
    this.product,
  });

  factory Lottery.fromJson(Map<String, dynamic> json) {
    try {
      return Lottery(
        id: json['id'] as int,
        lotteryNumber: _parseString(json['lottery_number']),
        title: _parseString(json['title'] ?? json['name'] ?? ''),
        description: _parseString(json['description'] ?? ''),
        ticketPrice: _parseDouble(json['ticket_price']),
        maxTickets: json['max_tickets'] as int? ?? json['total_tickets'] as int? ?? 0,
        soldTickets: json['sold_tickets'] as int? ?? 0,
        status: _parseString(json['status'] ?? 'active'),
        drawDate: _parseNullableDateTime(json['draw_date'] ?? json['start_date']),
        endDate: _parseNullableDateTime(json['end_date']),
        winnerTicketNumber: _parseNullableString(json['winner_ticket_number']),
        product: json['product'] != null ? Product.fromJson(json['product']) : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Lottery JSON parsing error: $e');
        print('📋 Lottery data causing error: $json');
      }
      
      // Fallback to safe parsing with minimal required fields
      return Lottery(
        id: _parseInt(json['id']),
        lotteryNumber: _parseString(json['lottery_number'] ?? json['id']?.toString() ?? ''),
        title: _parseString(json['title'] ?? json['name'] ?? 'Tombola'),
        description: _parseString(json['description'] ?? ''),
        ticketPrice: _parseDouble(json['ticket_price'] ?? 0),
        maxTickets: _parseInt(json['max_tickets'] ?? json['total_tickets'] ?? 0),
        soldTickets: _parseInt(json['sold_tickets'] ?? 0),
        status: _parseString(json['status'] ?? 'active'),
        drawDate: _parseNullableDateTime(json['draw_date'] ?? json['start_date']),
        endDate: _parseNullableDateTime(json['end_date']),
        winnerTicketNumber: _parseNullableString(json['winner_ticket_number']),
        product: null, // Avoid recursive parsing issues in fallback
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lottery_number': lotteryNumber,
      'title': title,
      'description': description,
      'ticket_price': ticketPrice,
      'max_tickets': maxTickets,
      'sold_tickets': soldTickets,
      'status': status,
      'draw_date': drawDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'winner_ticket_number': winnerTicketNumber,
      if (product != null) 'product': product!.toJson(),
    };
  }

  // Getters pour compatibilité et utilité
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  int get remainingTickets => maxTickets - soldTickets;
  double get completionPercentage => maxTickets > 0 ? (soldTickets / maxTickets) * 100 : 0;
  
  bool get hasWinner => winnerTicketNumber != null;
  String get formattedTicketPrice => '${ticketPrice.toStringAsFixed(0)} FCFA';
  String get formattedTotalRevenue => '${(soldTickets * ticketPrice).toStringAsFixed(0)} FCFA';

  // Getters pour rétrocompatibilité avec l'ancien code
  int get totalTickets => maxTickets;
  int get productId => product?.id ?? 0;

  @override
  String toString() => 'Lottery #$id';
}