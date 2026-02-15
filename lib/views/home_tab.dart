import 'package:flutter/material.dart';
import '../models/dashboard_card.dart';
import '../services/api_service.dart';

// Model for dashboard card

class HomeTab extends StatelessWidget {
  final TabController tabController;
  final Function(int) onTabSelect; // Add this line

  const HomeTab({
    Key? key,
    required this.tabController,
    required this.onTabSelect, // Add this line
  }) : super(key: key);

  // Uses ApiService.fetchDashboardCards() for dynamic content

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
        future: ApiService().fetchDashboardCards(),
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

