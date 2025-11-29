import 'package:flutter/material.dart';
import '../models/room.dart' as room_model;
import '../services/api_service.dart';

class RoomsTab extends StatefulWidget {
  const RoomsTab({Key? key}) : super(key: key);

  @override
  _RoomsTabState createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  final ApiService _apiService = ApiService();
  late Future<List<room_model.Room>> _roomsFuture;
  room_model.Room? _selectedRoom;
  // id of the room currently being refreshed from API (shows loading indicator)
  dynamic _loadingRoomId;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _apiService.getRooms().then((rooms) async {
      print('Fetched ${rooms.length} rooms');
      if (rooms.isNotEmpty) {
        final latestRoom = await _apiService.getRoomByName(rooms[0].name);
        setState(() {
          _selectedRoom = latestRoom;
        });
      }
      return rooms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
      ),
      body: FutureBuilder<List<room_model.Room>>(
        future: _roomsFuture,
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
              SizedBox(
                height: 120,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final isSelected = _selectedRoom?.id == room.id;
                      // Choose an icon based on room name or index for demo
                      IconData automationIcon;
                      switch (room.name.toLowerCase()) {
                        case 'living room':
                          automationIcon = Icons.tv;
                          break;
                        case 'bedroom':
                          automationIcon = Icons.bed;
                          break;
                        case 'kitchen':
                          automationIcon = Icons.kitchen;
                          break;
                        case 'bathroom':
                          automationIcon = Icons.bathtub;
                          break;
                        default:
                          automationIcon = Icons.home;
                      }
                      return GestureDetector(
                        onTap: () {
                          // Immediately select the tapped room for instant UI feedback
                          setState(() {
                            _selectedRoom = room;
                            _loadingRoomId = room.id;
                          });

                          // Refresh latest data in background and update selection when available
                          _apiService.getRoomByName(room.name).then((latestRoom) {
                            if (!mounted) return;
                            setState(() {
                              _selectedRoom = latestRoom;
                              _loadingRoomId = null;
                            });
                          }).catchError((e) {
                            if (!mounted) return;
                            setState(() {
                              _loadingRoomId = null;
                            });
                            debugPrint('Failed to refresh room ${room.name}: $e');
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Material(
                            elevation: isSelected ? 8 : 2,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? [Colors.indigo.shade400, Colors.blue.shade200]
                                      : [Colors.grey.shade200, Colors.white],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: Colors.indigo.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // reduced padding
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // prevent overflow
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 20, // reduced radius
                                    backgroundColor: isSelected ? Colors.white : Colors.indigo.shade50,
                                    child: _loadingRoomId == room.id
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(isSelected ? Colors.indigo : Colors.grey.shade700),
                                            ),
                                          )
                                        : Icon(
                                            automationIcon,
                                            size: 22, // reduced icon size
                                            color: isSelected ? Colors.indigo : Colors.grey.shade700,
                                          ),
                                  ),
                                  const SizedBox(height: 6), // reduced spacing
                                  Text(
                                    room.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15, // slightly reduced font
                                      color: isSelected ? Colors.indigo : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.sensors, size: 14, color: Colors.orangeAccent), // reduced icon size
                                      const SizedBox(width: 2),
                                      Text(
                                        '${room.deviceCount} devices',
                                        style: TextStyle(
                                          fontSize: 12, // reduced font size
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: _selectedRoom == null
                  ? Center(child: Text('Select a room to view switches'))
                  : (_loadingRoomId == _selectedRoom?.id)
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Loading room...'),
                          ],
                        ),
                      )
                    : _selectedRoom!.switches == null || _selectedRoom!.switches!.isEmpty
                    ? Center(child: Text('No switches found in this room'))
                    : ListView.builder(
                        itemCount: _selectedRoom!.switches!.length,
                        itemBuilder: (context, index) {
                          final sw = _selectedRoom!.switches![index];
                          final isFan = sw.name.toLowerCase().contains('fan');
                          if (isFan) {
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(Icons.toggle_on, size: 32, color: sw.isOn ? Colors.green : Colors.redAccent),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sw.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Row(
                                            children: [
                                              Text('Speed: ${sw.fanSpeed ?? 0}%'),
                                              Expanded(
                                                child: Slider(
                                                  value: (sw.fanSpeed ?? 0).toDouble(),
                                                  min: 0,
                                                  max: 100,
                                                  divisions: 20,
                                                  label: '${sw.fanSpeed ?? 0}%',
                                                  onChanged: sw.isOn
                                                      ? (value) {
                                                          setState(() {
                                                            sw.fanSpeed = value.toInt();
                                                          });
                                                          // Optionally call API to update fan speed
                                                        }
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: sw.isOn,
                                      onChanged: (val) {
                                        setState(() {
                                          sw.isOn = val;
                                        });

                                        // Optionally call API to update fan on/off
                                        _apiService.updateSwitch(sw, _selectedRoom!);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: Icon(Icons.toggle_on, size: 32, color: sw.isOn ? Colors.green : Colors.redAccent),
                                title: Text(sw.name),
                                subtitle: Text(sw.isOn ? 'On' : 'Off'),
                                trailing: Switch(
                                  value: sw.isOn,
                                  onChanged: (val) {
                                    setState(() {
                                      sw.isOn = val;
                                    });
                                    _apiService.updateSwitch(sw, _selectedRoom!);
                                    // Optionally call API to update switch state
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}


