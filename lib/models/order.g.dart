// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: (json['id'] as num).toInt(),
  orderNumber: json['order_number'] as String,
  userId: (json['user_id'] as num).toInt(),
  type: json['type'] as String,
  productId: (json['product_id'] as num?)?.toInt(),
  lotteryId: (json['lottery_id'] as num?)?.toInt(),
  totalAmount: (json['total_amount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: json['status'] as String,
  paymentReference: json['payment_reference'] as String?,
  paidAt:
      json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
  fulfilledAt:
      json['fulfilled_at'] == null
          ? null
          : DateTime.parse(json['fulfilled_at'] as String),
  cancelledAt:
      json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
  refundedAt:
      json['refunded_at'] == null
          ? null
          : DateTime.parse(json['refunded_at'] as String),
  notes: json['notes'] as String?,
  meta: json['meta'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  product:
      json['product'] == null
          ? null
          : Product.fromJson(json['product'] as Map<String, dynamic>),
  lottery:
      json['lottery'] == null
          ? null
          : Lottery.fromJson(json['lottery'] as Map<String, dynamic>),
  user:
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
  payments:
      (json['payments'] as List<dynamic>?)
          ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'order_number': instance.orderNumber,
  'user_id': instance.userId,
  'type': instance.type,
  'product_id': instance.productId,
  'lottery_id': instance.lotteryId,
  'total_amount': instance.totalAmount,
  'currency': instance.currency,
  'status': instance.status,
  'payment_reference': instance.paymentReference,
  'paid_at': instance.paidAt?.toIso8601String(),
  'fulfilled_at': instance.fulfilledAt?.toIso8601String(),
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'refunded_at': instance.refundedAt?.toIso8601String(),
  'notes': instance.notes,
  'meta': instance.meta,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'product': instance.product,
  'lottery': instance.lottery,
  'user': instance.user,
  'payments': instance.payments,
};

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: (json['id'] as num).toInt(),
  reference: json['reference'] as String,
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String,
  paymentMethod: json['payment_method'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  paidAt:
      json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'reference': instance.reference,
  'amount': instance.amount,
  'status': instance.status,
  'payment_method': instance.paymentMethod,
  'created_at': instance.createdAt.toIso8601String(),
  'paid_at': instance.paidAt?.toIso8601String(),
};
