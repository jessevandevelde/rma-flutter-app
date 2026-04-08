class Ticket {
  final int ticketTypeId;
  final String? assetId;
  final List<Map<String, dynamic>> answers;

  Ticket({
    required this.ticketTypeId,
    this.assetId,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticket_type_id': ticketTypeId,
      'asset_id': assetId,
      'answers': answers,
    };
  }
}
