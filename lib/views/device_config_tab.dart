import 'package:flutter/material.dart';
import 'package:yuji_ui/models/room.dart';
import '../models/device.dart';
import '../services/api_service.dart';
import 'add_room_dialog.dart'; // Import the AddRoomDialog

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
          : FutureBuilder<List<Room>>(
              future: _apiService.getRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No rooms found'));
                }
                final rooms = snapshot.data!;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          for (final room in rooms)
                            _buildDashboardCard(
                              context,
                              room.name,
                              _getRoomIcon(room.name),
                              '${room.deviceCount} Devices',
                              Colors.indigo,
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
                );
              },
            ),
    );
  }

  IconData _getRoomIcon(String roomName) {
    switch (roomName.toLowerCase()) {
      case 'living room':
        return Icons.tv;
      case 'bedroom':
        return Icons.bed;
      case 'kitchen':
        return Icons.kitchen;
      case 'bathroom':
        return Icons.bathtub;
      default:
        return Icons.home;
    }
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon,
      String subtitle, Color color) {
    return Card(
      elevation: 4,
      child: Stack(
        children: [
          InkWell(
            onTap: () async {
              if (title == 'Add Device') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: SingleChildScrollView(
                      child: AddRoomDialog(initialRoomName: title == 'Add Device' ? '' : title),
                    ),
                  ),
                );
              } else {
                // Fetch room details to populate dialog
                final rooms = await _apiService.getRooms();
                final room = rooms.firstWhere((r) => r.name == title, orElse: () => Room(
                  id: 0,
                  name: title,
                  description: '',
                  deviceCount: 0,
                  switches: [],
                ));
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: SingleChildScrollView(
                      child: AddRoomDialog(
                        initialRoomName: room.name,
                        //initialDescription: room.description,
                        // Add more fields if needed
                      ),
                    ),
                  ),
                );
              }
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade900,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sensors, size: 18, color: Colors.orangeAccent),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (title != 'Add Device')
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 22),
                tooltip: 'Delete Room',
                onPressed: () async {
                  bool confirmConnectivity = false;
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) => AlertDialog(
                          title: const Text('Delete Room'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Are you sure you want to delete "$title"?'),
                              const SizedBox(height: 12),
                              CheckboxListTile(
                                value: confirmConnectivity,
                                onChanged: (val) {
                                  setState(() {
                                    confirmConnectivity = val ?? false;
                                  });
                                },
                                title: const Text('I confirm the device is disconnected from power/network'),
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: confirmConnectivity
                                  ? () => Navigator.pop(context, true)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                  if (confirm == true) {
                    // TODO: Call API to delete room here if available
                    setState(() {
                      // Remove from UI (for demo, you may want to refresh from API)
                      // _rooms.removeWhere((r) => r.name == title);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Room "$title" deleted')),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
