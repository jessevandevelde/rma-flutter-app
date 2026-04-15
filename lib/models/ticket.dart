class Ticket {
  final int ticketTypeId;
  final dynamic assetId;
  final int? userId;
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
    
    // Alleen toevoegen als assetId een geldige waarde heeft
    if (assetId != null) {
      final String assetStr = assetId.toString().trim();
      if (assetStr.isNotEmpty && assetStr.toLowerCase() != 'null') {
        // Probeer het als getal te sturen, anders als string
        final int? numericId = int.tryParse(assetStr);
        data['asset_id'] = numericId ?? assetStr;
      }
    }
    // Als assetId leeg is, wordt 'asset_id' NIET opgenomen in de JSON.
    // De backend zal dit dan als NULL behandelen.
    
    return data;
  }
}
