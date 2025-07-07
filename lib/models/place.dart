class Place {
  final String id;
  String tableId;
  final String guestId;
  String guestName;

  Place({
    required this.id,
    required this.tableId,
    required this.guestId,
    required this.guestName,
  });

  Map<String, dynamic> toMap() {
    return {
      'guestId': guestId,
      'tableId': tableId,
      'guestName': guestName,
    };
  }

  factory Place.fromMap(Map<String, dynamic> map, String documentId) {
    return Place(
      id: documentId,
      tableId: map['tableId'] as String,
      guestId: map['guestId'] as String,
      guestName: map['guestName'] as String,
    );
  }

  @override
  String toString() {
    return 'Place(id: $id, guestId: $guestId, guestName: $guestName)';
  }
}
