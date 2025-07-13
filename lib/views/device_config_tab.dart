import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/api_service.dart';

class DeviceConfigTab extends StatefulWidget {
  const DeviceConfigTab({Key? key}) : super(key: key);

  @override
  _DeviceConfigTabState createState() => _DeviceConfigTabState();
}

class _DeviceConfigTabState extends State<DeviceConfigTab> {
  final ApiService _apiService = ApiService();
  List<Device> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      // For demo, loading devices from room 1
      final devices = await _apiService.getDevices(1);
      setState(() {
        _devices = devices;
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
      appBar: AppBar(
        title: const Text('Device Configuration'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.devices,
                      color: device.isActive ? Colors.green : Colors.grey,
                    ),
                    title: Text(device.name),
                    subtitle: Text(device.type),
                    trailing: Switch(
                      value: device.isActive,
                      onChanged: (value) {
                        // Toggle device state
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new device
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
