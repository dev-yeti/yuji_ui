import 'package:flutter/material.dart';

class SchedulesTab extends StatelessWidget {
  const SchedulesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
      ),
      body: ListView.builder(
        itemCount: 3, // Demo schedules
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: Text('Schedule ${index + 1}'),
              subtitle: Text('Daily at ${7 + index}:00 AM'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Toggle schedule
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new schedule
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
