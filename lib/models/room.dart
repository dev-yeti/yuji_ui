import 'switch.dart';

class Room {
  final int id;
  final String name;
  final String description;
  final int deviceCount;
  final String device_addr;
  final int user_id;
  final String channel_type;
  final List<Switch>? switches;

  Room({
    required this.id,
    required this.name,
    required this.description,
    required this.deviceCount,
    required this.device_addr,
    required this.user_id,
    required this.switches,
    required this.channel_type,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      deviceCount: json['deviceCount'],
      device_addr: json['device_addr'],
      user_id: json['user_id'],
      channel_type: json['channel_type'], // Default value if not present
      switches: (json['switches'] as List?)
          ?.map((item) => Switch.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'deviceCount': deviceCount,
      'device_addr': device_addr,
      'user_id': user_id,
      'channel_type': channel_type,
      'switches': switches?.map((item) => item.toJson()).toList(),
    };
  }
}
