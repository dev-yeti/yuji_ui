class Device {
  final int id;
  final String name;
  final String type;
  final bool isActive;
  final int roomId;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.isActive,
    required this.roomId,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      isActive: json['isActive'],
      roomId: json['roomId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'isActive': isActive,
      'roomId': roomId,
    };
  }
}
