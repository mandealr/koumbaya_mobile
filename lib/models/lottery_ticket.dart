class LotteryTicket {
  final int id;
  final String ticketNumber;
  final int lotteryId;
  final int userId;
  final int? transactionId;
  final double pricePaid;
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
    this.transactionId,
    required this.pricePaid,
    this.paymentReference,
    required this.status,
    required this.isWinner,
    this.purchasedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LotteryTicket.fromJson(Map<String, dynamic> json) {
    return LotteryTicket(
      id: json['id'] as int,
      ticketNumber: json['ticket_number'] as String,
      lotteryId: json['lottery_id'] as int,
      userId: json['user_id'] as int,
      transactionId: json['transaction_id'] as int?,
      pricePaid: (json['price_paid'] as num).toDouble(),
      paymentReference: json['payment_reference'] as String?,
      status: json['status'] as String,
      isWinner: json['is_winner'] as bool? ?? false,
      purchasedAt: json['purchased_at'] != null 
          ? DateTime.parse(json['purchased_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'lottery_id': lotteryId,
      'user_id': userId,
      'transaction_id': transactionId,
      'price_paid': pricePaid,
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