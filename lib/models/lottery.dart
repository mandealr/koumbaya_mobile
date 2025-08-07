import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'lottery.g.dart';

@JsonSerializable()
class Lottery {
  final int id;
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'total_tickets')
  final int totalTickets;
  @JsonKey(name: 'sold_tickets')
  final int soldTickets;
  @JsonKey(name: 'ticket_price')
  final double ticketPrice;
  @JsonKey(name: 'draw_date')
  final DateTime drawDate;
  final String status;
  @JsonKey(name: 'winner_ticket_number')
  final String? winnerTicketNumber;
  @JsonKey(name: 'winner_user_id')
  final int? winnerUserId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Relations (optional, loaded when needed)
  final Product? product;

  Lottery({
    required this.id,
    required this.productId,
    required this.totalTickets,
    required this.soldTickets,
    required this.ticketPrice,
    required this.drawDate,
    required this.status,
    this.winnerTicketNumber,
    this.winnerUserId,
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  factory Lottery.fromJson(Map<String, dynamic> json) => _$LotteryFromJson(json);
  Map<String, dynamic> toJson() => _$LotteryToJson(this);

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  int get remainingTickets => totalTickets - soldTickets;
  double get completionPercentage => (soldTickets / totalTickets) * 100;
  
  bool get hasWinner => winnerTicketNumber != null && winnerUserId != null;
  String get formattedTicketPrice => '${ticketPrice.toStringAsFixed(0)} FCFA';

  @override
  String toString() => 'Lottery #$id';
}