class TableModel {
  final String? id;
  final String name;

  TableModel({
    this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory TableModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TableModel(
      id: documentId,
      name: map['name'] as String,
    );
  }

  @override
  String toString() {
    return 'TableModel(id: $id, name: $name)';
  }
}
