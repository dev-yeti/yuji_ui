import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/api_service.dart';

class RoomsTab extends StatefulWidget {
  const RoomsTab({Key? key}) : super(key: key);

  @override
  _RoomsTabState createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  final ApiService _apiService = ApiService();
  late Future<List<Room>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _apiService.getRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms'),
      ),
      body: FutureBuilder<List<Room>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No rooms found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final room = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.room, size: 32),
                  title: Text(room.name),
                  subtitle: Text('${room.deviceCount} devices'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to room details
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new room
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
