import 'package:flutter/material.dart';

// Model for dashboard card
class DashboardCardData {
  final String title;
  final IconData icon;
  final String subtitle;
  final Color color;

  DashboardCardData({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.color,
  });

  // Example factory from JSON (adjust keys/types as per your API)
  factory DashboardCardData.fromJson(Map<String, dynamic> json) {
    return DashboardCardData(
      title: json['title'],
      icon: _iconFromString(json['icon']),
      subtitle: json['subtitle'],
      color: _colorFromHex(json['color']),
    );
  }

  static IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'devices':
        return Icons.devices;
      case 'power':
        return Icons.power;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  static Color _colorFromHex(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
