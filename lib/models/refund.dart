import 'product.dart';
import 'transaction.dart';

class Refund {
  final int id;
  final int userId;
  final int? transactionId;
  final int? productId;
  final double amount;
  final String reason;
  final String? description;
  final String status; // 'pending', 'approved', 'processed', 'completed', 'rejected'
  final String? rejectionReason;
  final String? verificationCode;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Transaction? transaction;
  final Product? product;

  Refund({
    required this.id,
    required this.userId,
    this.transactionId,
    this.productId,
    required this.amount,
    required this.reason,
    this.description,
    required this.status,
    this.rejectionReason,
    this.verificationCode,
    this.processedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.transaction,
    this.product,
  });

  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      transactionId: json['transaction_id'] as int?,
      productId: json['product_id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      verificationCode: json['verification_code'] as String?,
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      transaction: json['transaction'] != null 
          ? Transaction.fromJson(json['transaction'])
          : null,
      product: json['product'] != null 
          ? Product.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'transaction_id': transactionId,
      'product_id': productId,
      'amount': amount,
      'reason': reason,
      'description': description,
      'status': status,
      'rejection_reason': rejectionReason,
      'verification_code': verificationCode,
      'processed_at': processedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (transaction != null) 'transaction': transaction!.toJson(),
      if (product != null) 'product': product!.toJson(),
    };
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'approved':
        return 'Approuvé';
      case 'processed':
        return 'En traitement';
      case 'completed':
        return 'Terminé';
      case 'rejected':
        return 'Rejeté';
      default:
        return status;
    }
  }

  String get reasonText {
    switch (reason) {
      case 'product_not_received':
        return 'Produit non reçu';
      case 'product_defective':
        return 'Produit défectueux';
      case 'wrong_product':
        return 'Mauvais produit';
      case 'lottery_cancelled':
        return 'Tombola annulée';
      case 'duplicate_payment':
        return 'Paiement en double';
      case 'other':
        return 'Autre raison';
      default:
        return reason;
    }
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isProcessed => status == 'processed';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';
  
  bool get canBeCancelled => isPending;

  String get displayTitle {
    if (product != null) {
      return 'Remboursement - ${product!.name}';
    } else if (transaction != null) {
      return 'Remboursement - ${transaction!.displayTitle}';
    }
    return 'Demande de remboursement';
  }

  String get timelineStatus {
    if (isCompleted) return 'Remboursement effectué';
    if (isProcessed) return 'En cours de traitement';
    if (isApproved) return 'Demande approuvée';
    if (isRejected) return 'Demande rejetée';
    return 'Demande soumise';
  }

  @override
  String toString() {
    return 'Refund(id: $id, amount: $amount, status: $status, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Refund && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}