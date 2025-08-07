import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'lottery.g.dart';

@JsonSerializable()
class Lottery {
  final int id;
  @JsonKey(name: 'lottery_number')
  final String lotteryNumber;
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'total_tickets')
  final int totalTickets;
  @JsonKey(name: 'sold_tickets')
  final int soldTickets;
  @JsonKey(name: 'remaining_tickets')
  final int remainingTicketsCount;
  @JsonKey(name: 'ticket_price')
  final double ticketPrice;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @JsonKey(name: 'draw_date')
  final DateTime? drawDate;
  final String status;
  @JsonKey(name: 'is_drawn')
  final bool isDrawn;
  @JsonKey(name: 'is_expired')
  final bool isExpired;
  @JsonKey(name: 'can_draw')
  final bool canDraw;
  @JsonKey(name: 'progress_percentage')
  final double progressPercentage;
  @JsonKey(name: 'participation_rate')
  final double participationRate;
  @JsonKey(name: 'is_ending_soon')
  final bool isEndingSoon;
  @JsonKey(name: 'winner_ticket_number')
  final String? winnerTicketNumber;
  @JsonKey(name: 'winner_user_id')
  final int? winnerUserId;
  @JsonKey(name: 'total_revenue')
  final double totalRevenue;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Relations (optional, loaded when needed)
  final Product? product;

  Lottery({
    required this.id,
    required this.lotteryNumber,
    required this.productId,
    required this.totalTickets,
    required this.soldTickets,
    required this.remainingTicketsCount,
    required this.ticketPrice,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.isDrawn,
    required this.isExpired,
    required this.canDraw,
    required this.progressPercentage,
    required this.participationRate,
    required this.isEndingSoon,
    required this.totalRevenue,
    this.drawDate,
    this.winnerTicketNumber,
    this.winnerUserId,
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  factory Lottery.fromJson(Map<String, dynamic> json) => _$LotteryFromJson(json);
  Map<String, dynamic> toJson() => _$LotteryToJson(this);

  // Getters pour compatibilité et utilité
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  int get remainingTickets => remainingTicketsCount;
  double get completionPercentage => progressPercentage;
  
  bool get hasWinner => winnerTicketNumber != null && winnerUserId != null;
  String get formattedTicketPrice => '${ticketPrice.toStringAsFixed(0)} FCFA';
  String get formattedTotalRevenue => '${totalRevenue.toStringAsFixed(0)} FCFA';

  @override
  String toString() => 'Lottery #$id';
}