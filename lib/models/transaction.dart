import 'package:flutter/foundation.dart';
import 'product.dart';

// Helper functions for safe JSON parsing
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is String) {
    if (value.isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  } else if (value is num) {
    return value.toDouble();
  }
  return 0.0;
}

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

String _parseString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

String? _parseNullableString(dynamic value) {
  if (value == null) return null;
  if (value is String && value.isEmpty) return null;
  return value.toString();
}

DateTime _parseDateTime(dynamic value) {
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

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    if (value.isEmpty) return null;
    return int.tryParse(value);
  } else if (value is num) {
    return value.toInt();
  }
  return null;
}

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
    try {
      return Transaction(
        id: _parseInt(json['id']),
        userId: _parseInt(json['user_id']),
        type: _parseString(json['type']),
        amount: _parseDouble(json['amount']),
        status: _parseString(json['status']),
        paymentMethod: _parseNullableString(json['payment_method']),
        reference: _parseNullableString(json['reference']),
        paymentReference: _parseNullableString(json['payment_reference']),
        metadata: json['metadata'] as Map<String, dynamic>?,
        productId: _parseNullableInt(json['product_id']),
        lotteryId: _parseNullableInt(json['lottery_id']),
        quantity: _parseNullableInt(json['quantity']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
        product: json['product'] != null 
            ? Product.fromJson(json['product'])
            : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Transaction JSON parsing error: $e');
        print('📋 Transaction data causing error: $json');
      }
      
      // Fallback parsing with minimal required fields
      return Transaction(
        id: _parseInt(json['id']),
        userId: _parseInt(json['user_id']),
        type: _parseString(json['type']),
        amount: _parseDouble(json['amount']),
        status: _parseString(json['status']),
        paymentMethod: _parseNullableString(json['payment_method']),
        reference: _parseNullableString(json['reference']),
        paymentReference: _parseNullableString(json['payment_reference']),
        metadata: null, // Avoid parsing issues in fallback
        productId: _parseNullableInt(json['product_id']),
        lotteryId: _parseNullableInt(json['lottery_id']),
        quantity: _parseNullableInt(json['quantity']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
        product: null, // Avoid recursive parsing issues in fallback
      );
    }
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
        return 'Achat de tickets';
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
      return isRefund ? 'Remboursement - ${product!.displayName}' : product!.displayName;
    } else if (type == 'lottery_ticket') {
      return 'Achat de tickets de tirage spécial';
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