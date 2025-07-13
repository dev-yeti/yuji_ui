import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  final TabController tabController;
  final Function(int) onTabSelect; // Add this line

  const HomeTab({
    Key? key,
    required this.tabController,
    required this.onTabSelect, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardCard(
            context,
            'Rooms',
            Icons.room,
            '5 Rooms',
            Colors.blue,
          ),
          _buildDashboardCard(
            context,
            'Devices',
            Icons.devices,
            '12 Devices',
            Colors.green,
          ),
          _buildDashboardCard(
            context,
            'Active',
            Icons.power,
            '8 Active',
            Colors.orange,
          ),
          _buildDashboardCard(
            context,
            'Schedules',
            Icons.schedule,
            '3 Schedules',
            Colors.purple,
          ),
        ],
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

