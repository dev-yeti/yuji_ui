import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    // Map string names to IconData as needed
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
    // Parse color from hex string, e.g. "#4285F4"
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class HomeTab extends StatelessWidget {
  final TabController tabController;
  final Function(int) onTabSelect; // Add this line

  const HomeTab({
    Key? key,
    required this.tabController,
    required this.onTabSelect, // Add this line
  }) : super(key: key);

  Future<List<DashboardCardData>> fetchDashboardCards() async {
    // Replace with your API endpoint
    final response = await http.get(Uri.parse('https://your.api/endpoint/cards'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DashboardCardData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load dashboard cards');
    }
  }

  // Mock data for dashboard cards
  Future<List<DashboardCardData>> fetchMockDashboardCards() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return [
      DashboardCardData(
        title: 'Rooms',
        icon: Icons.home,
        subtitle: '5 Rooms',
        color: Colors.blue,
      ),
      DashboardCardData(
        title: 'Devices',
        icon: Icons.devices,
        subtitle: '12 Devices',
        color: Colors.green,
      ),
      DashboardCardData(
        title: 'Active',
        icon: Icons.power,
        subtitle: '8 Active',
        color: Colors.orange,
      ),
      DashboardCardData(
        title: 'Schedules',
        icon: Icons.schedule,
        subtitle: '3 Schedules',
        color: Colors.purple,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: FutureBuilder<List<DashboardCardData>>(
        future: fetchMockDashboardCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }
          final cards = snapshot.data!;
          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: cards.map((card) => _buildDashboardCard(
              context,
              card.title,
              card.icon,
              card.subtitle,
              card.color,
            )).toList(),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon,
      String subtitle, Color color) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          if (title == 'Rooms') {
            onTabSelect(1); // Use the callback instead of direct TabController manipulation
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

