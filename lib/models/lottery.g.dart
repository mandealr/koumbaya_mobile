// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lottery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Lottery _$LotteryFromJson(Map<String, dynamic> json) => Lottery(
  id: (json['id'] as num).toInt(),
  lotteryNumber: json['lottery_number'] as String,
  productId: (json['product_id'] as num).toInt(),
  totalTickets: (json['total_tickets'] as num).toInt(),
  soldTickets: (json['sold_tickets'] as num).toInt(),
  remainingTicketsCount: (json['remaining_tickets'] as num).toInt(),
  ticketPrice: (json['ticket_price'] as num).toDouble(),
  startDate: DateTime.parse(json['start_date'] as String),
  endDate: DateTime.parse(json['end_date'] as String),
  status: json['status'] as String,
  isDrawn: json['is_drawn'] as bool,
  isExpired: json['is_expired'] as bool,
  canDraw: json['can_draw'] as bool,
  progressPercentage: (json['progress_percentage'] as num).toDouble(),
  participationRate: (json['participation_rate'] as num).toDouble(),
  isEndingSoon: json['is_ending_soon'] as bool,
  totalRevenue: (json['total_revenue'] as num).toDouble(),
  drawDate:
      json['draw_date'] == null
          ? null
          : DateTime.parse(json['draw_date'] as String),
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
  'lottery_number': instance.lotteryNumber,
  'product_id': instance.productId,
  'total_tickets': instance.totalTickets,
  'sold_tickets': instance.soldTickets,
  'remaining_tickets': instance.remainingTicketsCount,
  'ticket_price': instance.ticketPrice,
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate.toIso8601String(),
  'draw_date': instance.drawDate?.toIso8601String(),
  'status': instance.status,
  'is_drawn': instance.isDrawn,
  'is_expired': instance.isExpired,
  'can_draw': instance.canDraw,
  'progress_percentage': instance.progressPercentage,
  'participation_rate': instance.participationRate,
  'is_ending_soon': instance.isEndingSoon,
  'winner_ticket_number': instance.winnerTicketNumber,
  'winner_user_id': instance.winnerUserId,
  'total_revenue': instance.totalRevenue,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'product': instance.product,
};
