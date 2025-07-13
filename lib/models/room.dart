class Room {
  final int id;
  final String name;
  final String description;
  final int deviceCount;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.deviceCount,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      deviceCount: json['deviceCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deviceCount': deviceCount,
    };
  }
}
