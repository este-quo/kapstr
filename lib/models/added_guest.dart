class AddedGuest {
  String id;
  String name;

  AddedGuest({
    required this.id,
    required this.name,
  });

  // Convertir un AddedGuest en Map pour stockage dans Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
    };
  }

  // Créer un AddedGuest à partir d'une Map (utilisé pour la récupération depuis Firestore)
  factory AddedGuest.fromMap(Map<String, dynamic> map) {
    return AddedGuest(
      name: map['name'] ?? '',
      id: map['id'],
    );
  }
}

List<AddedGuest> fromMapList(List<dynamic> maps) {
  return maps.map((map) => AddedGuest.fromMap(map as Map<String, dynamic>)).toList();
}

List<Map<String, dynamic>> toMapList(List<AddedGuest> guests) {
  return guests.map((guest) => guest.toMap()).toList();
}
