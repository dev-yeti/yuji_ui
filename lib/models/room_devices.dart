class RoomDevice {
  final String name;
  final int id;

  RoomDevice({
    required this.name,
    required this.id,
  });

  factory RoomDevice.fromJson(Map<String, dynamic> json) {
    return RoomDevice(
      name: json['name'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}

typedef RoomDeviceMap = Map<String, List<RoomDevice>>;
