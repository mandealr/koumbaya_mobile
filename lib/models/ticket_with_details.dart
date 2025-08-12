import 'lottery_ticket.dart';
import 'lottery.dart';
import 'product.dart';

class TicketWithDetails {
  final LotteryTicket ticket;
  final Lottery? lottery;
  final Product? product;

  TicketWithDetails({
    required this.ticket,
    this.lottery,
    this.product,
  });

  factory TicketWithDetails.fromJson(Map<String, dynamic> json) {
    return TicketWithDetails(
      ticket: LotteryTicket.fromJson(json['ticket'] ?? json),
      lottery: json['lottery'] != null 
          ? Lottery.fromJson(json['lottery'])
          : null,
      product: json['product'] != null 
          ? Product.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket': ticket.toJson(),
      if (lottery != null) 'lottery': lottery!.toJson(),
      if (product != null) 'product': product!.toJson(),
    };
  }

  String get productName => product?.name ?? 'Produit inconnu';
  String get productImage => product?.displayImage ?? '';
  String get lotteryStatus => lottery?.status ?? 'unknown';
  DateTime? get drawDate => lottery?.drawDate;
  bool get isLotteryActive => lottery?.status == 'active';
  bool get isLotteryCompleted => lottery?.status == 'completed';
  
  String get ticketStatusText {
    if (ticket.isWinner && isLotteryCompleted) {
      return 'Gagnant 🎉';
    } else if (isLotteryCompleted && !ticket.isWinner) {
      return 'Non gagnant';
    } else if (isLotteryActive) {
      return 'En cours';
    }
    return ticket.statusText;
  }

  @override
  String toString() {
    return 'TicketWithDetails(ticket: $ticket, productName: $productName)';
  }
}