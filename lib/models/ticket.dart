class Ticket {
  final int ticketTypeId;
  final dynamic assetId;
  final dynamic userId;
  final List<Map<String, dynamic>> answers;

  Ticket({
    required this.ticketTypeId,
    this.assetId,
    this.userId,
    required this.answers,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'ticket_type_id': ticketTypeId,
      'user_id': userId,
      'answers': answers,
    };

    if (assetId != null && assetId.toString().isNotEmpty) {
      data['asset_id'] = assetId;
    }

    return data;
  }
}
