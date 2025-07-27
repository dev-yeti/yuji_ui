class Switch {
  final int id;
  final String name;
  bool isOn;
  int? fanSpeed; // Add this line
  String deviceType;

  Switch({
    required this.id,
    required this.name,
    required this.isOn,
    this.fanSpeed, // Add this line
    required this.deviceType,
  });

  factory Switch.fromJson(Map<String, dynamic> json) {
    return Switch(
      id: json['id'],
      name: json['name'],
      isOn: json['isOn'],
      fanSpeed: json['fanSpeed'],
      deviceType: json['deviceType'] // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isOn': isOn,
      'fanSpeed': fanSpeed, // Add this line
      'deviceType': deviceType, // Add this line
    };
  }
}
