import 'product.dart';

class Transaction {
  final int id;
  final int userId;
  final String type; // 'lottery_ticket', 'product_purchase', 'refund'
  final double amount;
  final String status; // 'pending', 'completed', 'failed', 'cancelled'
  final String? paymentMethod;
  final String? reference;
  final String? paymentReference;
  final Map<String, dynamic>? metadata;
  final int? productId;
  final int? lotteryId;
  final int? quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product? product;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.reference,
    this.paymentReference,
    this.metadata,
    this.productId,
    this.lotteryId,
    this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String?,
      reference: json['reference'] as String?,
      paymentReference: json['payment_reference'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      productId: json['product_id'] as int?,
      lotteryId: json['lottery_id'] as int?,
      quantity: json['quantity'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      product: json['product'] != null 
          ? Product.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'amount': amount,
      'status': status,
      'payment_method': paymentMethod,
      'reference': reference,
      'payment_reference': paymentReference,
      'metadata': metadata,
      'product_id': productId,
      'lottery_id': lotteryId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (product != null) 'product': product!.toJson(),
    };
  }

  String get typeText {
    switch (type) {
      case 'lottery_ticket':
        return 'Achat de billets';
      case 'product_purchase':
        return 'Achat direct';
      case 'refund':
        return 'Remboursement';
      default:
        return type;
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'completed':
        return 'Terminé';
      case 'failed':
        return 'Échoué';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';
  
  bool get isLotteryTicketPurchase => type == 'lottery_ticket';
  bool get isProductPurchase => type == 'product_purchase';
  bool get isRefund => type == 'refund';

  String get displayTitle {
    if (product != null) {
      return isRefund ? 'Remboursement - ${product!.name}' : product!.name;
    } else if (type == 'lottery_ticket') {
      return 'Achat de billets de tombola';
    }
    return typeText;
  }

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}