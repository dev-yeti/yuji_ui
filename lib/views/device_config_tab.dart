import 'package:flutter/material.dart';
import 'package:yuji_ui/models/room.dart';
import '../models/device.dart';
import '../services/api_service.dart';

class DeviceConfigTab extends StatefulWidget {
  const DeviceConfigTab({Key? key}) : super(key: key);

  @override
  _DeviceConfigTabState createState() => _DeviceConfigTabState();
}

class _DeviceConfigTabState extends State<DeviceConfigTab> {
  final ApiService _apiService = ApiService();
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      // For demo, loading devices from room 1
      final rooms = await _apiService.getDevices(1);
      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load devices')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Device Configuration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Dashboard cards section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildDashboardCard(
                        context,
                        'All Devices',
                        Icons.devices,
                        '12 Devices',
                        Colors.indigo,
                      ),
                      _buildDashboardCard(
                        context,
                        'Active Devices',
                        Icons.power,
                        '8 Active',
                        Colors.green,
                      ),
                      _buildDashboardCard(
                        context,
                        'Offline',
                        Icons.cloud_off,
                        '2 Offline',
                        Colors.redAccent,
                      ),
                      _buildDashboardCard(
                        context,
                        'Add Device',
                        Icons.add_circle,
                        'Add New',
                        Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
                // ...existing code for device list or other content...
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new device
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon,
      String subtitle, Color color) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Add navigation or actions here if needed
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
             