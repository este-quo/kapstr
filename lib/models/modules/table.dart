class UniqueTable {
  String id;
  String eventId;
  String name;
  List<String> guestsId;

  UniqueTable({
    required this.id,
    required this.eventId,
    required this.name,
    required this.guestsId,
  });

  factory UniqueTable.fromMap(String id, Map<String, dynamic> json) {
    return UniqueTable(
      id: id,
      eventId: json['event_id'],
      name: json['name'],
      guestsId: List<String>.from(json['guests'] ?? []),
    );
  }
}
