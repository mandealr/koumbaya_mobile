import 'package:json_annotation/json_annotation.dart';
import 'product.dart';
import 'lottery.dart';
import 'user.dart';

part 'order.g.dart';

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

DateTime? _parseNullableDateTime(dynamic value) {
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

@JsonSerializable()
class Order {
  final int id;
  @JsonKey(name: 'order_number')
  final String orderNumber;
  @JsonKey(name: 'user_id')
  final int userId;
  final String type; // 'lottery', 'direct'
  @JsonKey(name: 'product_id')
  final int? productId;
  @JsonKey(name: 'lottery_id')
  final int? lotteryId;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  final String currency;
  final String status; // 'pending', 'awaiting_payment', 'paid', 'shipping', 'failed', 'cancelled', 'fulfilled', 'refunded', 'expired'
  @JsonKey(name: 'payment_reference')
  final String? paymentReference;
  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;
  @JsonKey(name: 'fulfilled_at')
  final DateTime? fulfilledAt;
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;
  @JsonKey(name: 'refunded_at')
  final DateTime? refundedAt;
  final String? notes;
  final Map<String, dynamic>? meta;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  // Relations
  final Product? product;
  final Lottery? lottery;
  final User? user;
  final List<Payment>? payments;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.type,
    this.productId,
    this.lotteryId,
    required this.totalAmount,
    required this.currency,
    required this.status,
    this.paymentReference,
    this.paidAt,
    this.fulfilledAt,
    this.cancelledAt,
    this.refundedAt,
    this.notes,
    this.meta,
    required this.createdAt,
    required this.updatedAt,
    this.product,
    this.lottery,
    this.user,
    this.payments,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      return _$OrderFromJson(json);
    } catch (e) {
      // Fallback to safe parsing if JsonSerializable fails
      return Order.fromJsonSafe(json);
    }
  }
  
  factory Order.fromJsonSafe(Map<String, dynamic> json) {
    return Order(
      id: _parseInt(json['id']),
      orderNumber: _parseString(json['order_number']),
      userId: _parseInt(json['user_id']),
      type: _parseString(json['type']),
      productId: json['product_id'] != null ? _parseInt(json['product_id']) : null,
      lotteryId: json['lottery_id'] != null ? _parseInt(json['lottery_id']) : null,
      totalAmount: _parseDouble(json['total_amount']),
      currency: _parseString(json['currency']),
      status: _parseString(json['status']),
      paymentReference: _parseNullableString(json['payment_reference']),
      paidAt: _parseNullableDateTime(json['paid_at']),
      fulfilledAt: _parseNullableDateTime(json['fulfilled_at']),
      cancelledAt: _parseNullableDateTime(json['cancelled_at']),
      refundedAt: _parseNullableDateTime(json['refunded_at']),
      notes: _parseNullableString(json['notes']),
      meta: json['meta'] as Map<String, dynamic>?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      lottery: json['lottery'] != null ? Lottery.fromJson(json['lottery']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      payments: json['payments'] != null 
        ? (json['payments'] as List).map((p) => Payment.fromJson(p)).toList()
        : null,
    );
  }
  
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  // Getters utilitaires
  String get typeText {
    switch (type) {
      case 'lottery':
        return 'Achat de tickets';
      case 'direct':
        return 'Achat direct';
      default:
        return type;
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'awaiting_payment':
        return 'En attente de paiement';
      case 'paid':
        return 'Payé';
      case 'shipping':
        return 'En cours de livraison';
      case 'failed':
        return 'Échoué';
      case 'cancelled':
        return 'Annulé';
      case 'fulfilled':
        return 'Livré';
      case 'refunded':
        return 'Remboursé';
      case 'expired':
        return 'Expiré';
      default:
        return status;
    }
  }

  // Status checks
  bool get isPending => status == 'pending';
  bool get isAwaitingPayment => status == 'awaiting_payment';
  bool get isPaid => status == 'paid';
  bool get isShipping => status == 'shipping';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';
  bool get isFulfilled => status == 'fulfilled';
  bool get isRefunded => status == 'refunded';
  bool get isExpired => status == 'expired';

  // Vérifier si le paiement est réellement effectué (même si la commande n'est pas marquée comme payée)
  bool get actuallyPaid {
    // D'abord vérifier le statut de la commande
    if (isPaid || isShipping || isFulfilled) return true;
    
    // Ensuite vérifier le statut des paiements
    if (payments != null && payments!.isNotEmpty) {
      return payments!.any((payment) => payment.isPaid);
    }
    
    return false;
  }

  // Type checks
  bool get isLotteryOrder => type == 'lottery';
  bool get isDirectOrder => type == 'direct';

  // Peut être payé
  bool get canBePaid => isPending || isAwaitingPayment || isFailed;
  
  // Peut être annulé
  bool get canBeCancelled => isPending || isAwaitingPayment;

  // Titre d'affichage
  String get displayTitle {
    if (product != null) {
      return product!.name ?? 'Produit';
    } else if (lottery?.product != null) {
      return lottery!.product!.name ?? 'Produit tombola';
    } else if (isLotteryOrder) {
      return 'Achat de tickets de tombola';
    } else {
      return 'Achat direct';
    }
  }

  // Couleur du status
  String get statusColor {
    switch (status) {
      case 'paid':
      case 'shipping':
      case 'fulfilled':
        return 'green';
      case 'pending':
      case 'awaiting_payment':
        return 'orange';
      case 'failed':
      case 'cancelled':
      case 'expired':
        return 'red';
      case 'refunded':
        return 'blue';
      default:
        return 'gray';
    }
  }

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, type: $type, status: $status, amount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Modèle simplifié Payment pour les relations
@JsonSerializable()
class Payment {
  final int id;
  final String reference;
  final double amount;
  final String status;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;

  Payment({
    required this.id,
    required this.reference,
    required this.amount,
    required this.status,
    this.paymentMethod,
    required this.createdAt,
    this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    try {
      return _$PaymentFromJson(json);
    } catch (e) {
      return Payment.fromJsonSafe(json);
    }
  }
  
  factory Payment.fromJsonSafe(Map<String, dynamic> json) {
    return Payment(
      id: _parseInt(json['id']),
      reference: _parseString(json['reference']),
      amount: _parseDouble(json['amount']),
      status: _parseString(json['status']),
      paymentMethod: _parseNullableString(json['payment_method']),
      createdAt: _parseDateTime(json['created_at']),
      paidAt: _parseNullableDateTime(json['paid_at']),
    );
  }
  
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  String get statusText {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'payment_initiated':
        return 'Paiement initié';
      case 'paid':
        return 'Payé';
      case 'failed':
        return 'Échoué';
      case 'cancelled':
        return 'Annulé';
      case 'expired':
        return 'Expiré';
      default:
        return status;
    }
  }

  String get paymentMethodText {
    switch (paymentMethod) {
      case 'airtel_money':
        return 'Airtel Money';
      case 'moov_money':
        return 'Moov Money';
      case 'mobile_money':
        return 'Mobile Money';
      case 'bank_transfer':
        return 'Virement bancaire';
      case 'card':
        return 'Carte bancaire';
      default:
        return paymentMethod ?? 'Non spécifié';
    }
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending' || status == 'payment_initiated';
  bool get isFailed => status == 'failed' || status == 'cancelled' || status == 'expired';
}