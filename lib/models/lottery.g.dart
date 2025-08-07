// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lottery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lottery _$LotteryFromJson(Map<String, dynamic> json) => Lottery(
  id: (json['id'] as num).toInt(),
  productId: (json['product_id'] as num).toInt(),
  totalTickets: (json['total_tickets'] as num).toInt(),
  soldTickets: (json['sold_tickets'] as num).toInt(),
  ticketPrice: (json['ticket_price'] as num).toDouble(),
  drawDate: DateTime.parse(json['draw_date'] as String),
  status: json['status'] as String,
  winnerTicketNumber: json['winner_ticket_number'] as String?,
  winnerUserId: (json['winner_user_id'] as num?)?.toInt(),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  product:
      json['product'] == null
          ? null
          : Product.fromJson(json['product'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LotteryToJson(Lottery instance) => <String, dynamic>{
  'id': instance.id,
  'product_id': instance.productId,
  'total_tickets': instance.totalTickets,
  'sold_tickets': instance.soldTickets,
  'ticket_price': instance.ticketPrice,
  'draw_date': instance.drawDate.toIso8601String(),
  'status': instance.status,
  'winner_ticket_number': instance.winnerTicketNumber,
  'winner_user_id': instance.winnerUserId,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'product': instance.product,
};
