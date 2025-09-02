class LotteryTicket {
  final int id;
  final String ticketNumber;
  final int lotteryId;
  final int userId;
  final int? orderId;
  final int? paymentId;
  final int? transactionId;
  final double pricePaid;
  final String currency;
  final String? paymentReference;
  final String status;
  final bool isWinner;
  final DateTime? purchasedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LotteryTicket({
    required this.id,
    required this.ticketNumber,
    required this.lotteryId,
    required this.userId,
    this.orderId,
    this.paymentId,
    this.transactionId,
    required this.pricePaid,
    required this.currency,
    this.paymentReference,
    required this.status,
    required this.isWinner,
    this.purchasedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LotteryTicket.fromJson(Map<String, dynamic> json) {
    return LotteryTicket(
      id: _parseInt(json['id']),
      ticketNumber: _parseString(json['ticket_number']),
      lotteryId: _parseInt(json['lottery_id']),
      userId: _parseInt(json['user_id']),
      orderId: _parseNullableInt(json['order_id']),
      paymentId: _parseNullableInt(json['payment_id']),
      transactionId: _parseNullableInt(json['transaction_id']),
      pricePaid: _parseDouble(json['price'] ?? json['price_paid']),
      currency: _parseString(json['currency'] ?? 'XAF'),
      paymentReference: _parseNullableString(json['payment_reference']),
      status: _parseString(json['status']),
      isWinner: _parseBool(json['is_winner']),
      purchasedAt: _parseNullableDateTime(json['purchased_at']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  // Helper functions for safe parsing
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    return value.toString();
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'lottery_id': lotteryId,
      'user_id': userId,
      'order_id': orderId,
      'payment_id': paymentId,
      'transaction_id': transactionId,
      'price': pricePaid,
      'currency': currency,
      'payment_reference': paymentReference,
      'status': status,
      'is_winner': isWinner,
      'purchased_at': purchasedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPaid => status == 'paid';
  bool get isReserved => status == 'reserved';
  bool get isCancelled => status == 'cancelled';

  String get statusText {
    switch (status) {
      case 'paid':
        return 'Payé';
      case 'reserved':
        return 'Réservé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  @override
  String toString() {
    return 'LotteryTicket(id: $id, ticketNumber: $ticketNumber, status: $status, isWinner: $isWinner)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LotteryTicket && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}