class AboutService {
  String id;
  String name;
  String imageUrl;
  String description;
  List<String> imageUrls;

  AboutService({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.imageUrls,
  });

  // Method to create a Service object from a map (if you're fetching the data in a JSON format)
  static AboutService fromMap(String id, Map<String, dynamic> json) {
    return AboutService(
      id: id,
      name: json['name'] ?? "",
      imageUrl: json['image_url'] ?? "",
      description: json['description'] ?? "",
      imageUrls: List<String>.from(json['image_urls'] ?? []),
    );
  }

  // Method to convert the Service object to a map (useful for serialization)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image_url': imageUrl,
      'description': description,
      'image_urls': imageUrls,
    };
  }
}
