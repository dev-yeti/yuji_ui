import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../models/switch.dart' as Switch;
import '../models/room_devices.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../session/session_manager.dart';
import '../models/dashboard_card.dart';
import 'dart:async'; 
import 'dart:io';
import 'package:flutter/material.dart';
import '../globals.dart';

class ApiService {
  // Use the baseUrl from your AppConfig or define it here
  static final String baseUrl = AppConfig.baseUrl;
  User user = User("", "");

// Future<List<Room>> getRooms() async {
//     // Mock response JSON
//     final mockJson = '''
//     [
//       {
//         "id": 1,
//         "name": "Living Room",
//         "description": "Main family area",
//         "deviceCount": 0,
//         "device_addr": "abc_abc",
//         "user_id": "user_123",
//         "switches": [
//          ]
//       },
//       {
//         "id": 2,
//         "name": "Bedroom",
//         "description": "Master bedroom",
//         "deviceCount": 1,
//         "device_addr": "xyz_xyz",
//         "user_id": "user_456",
//         "switches": [
//           { "id": 201, "name": "Bed Lamp", "isOn": true }
//         ]
//       },
//       {
//         "id": 3,
//         "name": "Kitchen",
//         "description": "Master bedroom",
//         "deviceCount": 1,
//         "device_addr": "kitchen_123",
//         "user_id": "user_789",
//         "switches": [
          
//         ]
//       },
//       {
//         "id": 4,
//         "name": "Bathroom",
//         "description": "Master bedroom",
//         "deviceCount": 1,
//         "device_addr": "bathroom_123",
//         "user_id": "user_789",
//         "switches": [
        
//         ]
//       }
//     ]
//     ''';
//     await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
//     List<dynamic> roomsJson = json.decode(mockJson);
//     return roomsJson.map((json) => Room.fromJson(json)).toList();
//   }

  Future<List<Room>> getRooms() async {
    // Fetch rooms from the API
    int? id = await SessionManager.getId();
    final response = await http.get(Uri.parse('$baseUrl/rooms?userId=$id'));
    print("Fetching rooms from API: $baseUrl/rooms?userId=$id");
    if (response.statusCode == 200) {
      List<dynamic> roomsJson = json.decode(response.body);
      return roomsJson.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<List<DashboardCardData>> fetchDashboardCards() async {
    int? userId = await SessionManager.getId();
    if (userId == null) {
      throw Exception('No user id in session');
    }

    final uri = Uri.parse('$baseUrl/dashboard/$userId');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load dashboard summary');
    }

    final Map<String, dynamic> data = json.decode(response.body);

    final int numberOfRooms = (data['numberOfRooms'] ?? 0) as int;
    final int totalSwitches = (data['totalSwitches'] ?? 0) as int;
    final int totalSchedules = (data['totalSchedules'] ?? 0) as int;

    return [
      DashboardCardData(
        title: 'Rooms',
        icon: Icons.home,
        subtitle: '$numberOfRooms Rooms',
        color: Colors.blue,
      ),
      DashboardCardData(
        title: 'Devices',
        icon: Icons.devices,
        subtitle: '$totalSwitches Devices',
        color: Colors.green,
      ),
      DashboardCardData(
        title: 'Schedules',
        icon: Icons.schedule,
        subtitle: '$totalSchedules Schedules',
        color: Colors.purple,
      ),
    ];
  }

  Future<List<Room>> getDevices(int roomId) async {
   return getRooms();
    // final response = await http.get(Uri.parse('$baseUrl/rooms/$roomId/devices'));
    // if (response.statusCode == 200) {
    //   List<dynamic> devicesJson = json.decode(response.body);
    //   return devicesJson.map((json) => Device.fromJson(json)).toList();
    // } else {
    //   throw Exception('Failed to load devices');
    // }
  }

  Future<RoomDeviceMap> getRoomsWithDevices() async {
    int? userId = await SessionManager.getId();
    if (userId == null) {
      throw Exception('User ID not found. Please login first.');
    }

    final url = Uri.parse('$baseUrl/rooms/user/$userId');
    print("Fetching rooms with devices from API: $url");

    try {
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final RoomDeviceMap roomDevices = {};

        jsonData.forEach((roomName, devicesList) {
          if (devicesList is List) {
            roomDevices[roomName] = devicesList
                .map((device) => RoomDevice.fromJson(device as Map<String, dynamic>))
                .toList();
          }
        });

        print('Fetched ${roomDevices.length} rooms with devices');
        return roomDevices;
      } else {
        throw Exception('Failed to load rooms with devices. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      print('getRoomsWithDevices timeout: server did not respond within 10s');
      rethrow;
    } on SocketException catch (e) {
      print('Socket error: $e — device cannot reach server');
      rethrow;
    } catch (e) {
      print('Error fetching rooms with devices: $e');
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    print("baseUrl: $baseUrl");
    user = User(email, password);
     final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_uuid': user.userUUId, 'password': user.password}),); 
    print(response);
    if(response.statusCode == 200) {
      // Assuming the API returns a token or some user data on successful login
      final data = json.decode(response.body);
      print(data);
      try {
        final userId = data['user_id']?.toString() ?? '';
        final id = int.tryParse(data['id'].toString()) ?? 0;
        await SessionManager.saveUserSession(userId, id);
      } 
      catch (e) {
        print('Session save error: $e');
      }

    }
    return response.statusCode == 200;
    //return true;
  }

  Future<bool> register(String firstName, String lastName, String email, String mobile, String userId, String password) async {
    print('Registering user with email: $email');
    print('baseUrl: $baseUrl');

    // Build URL and request body
    final url = Uri.parse('$baseUrl/auth/registerUser');
    final phoneValue = int.tryParse(mobile.toString()) ?? mobile;
    final requestBody = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneValue,
      'user_uuid': userId,
      'password': password,
    };

    print('POST $url');
    print('Request body: $requestBody');

    try {
      // Add a timeout and handle network errors explicitly so the app doesn't crash
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 10));
          
      if (response.statusCode == 200 || response.statusCode == 201) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Registration completed successfully, please login"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Registration failed: ${response.body}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } on TimeoutException {
      print('Register timeout: server did not respond within 10s');
      return false;
    } on SocketException catch (e) {
      print('Socket error: $e — device cannot reach server. Check mobile network, server firewall, and that the server is bound to 0.0.0.0.');
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
   }

  Future<Room> getRoomByName(String name) async {
    int? id = await SessionManager.getId();
    print("Fetching room by name: $name for user ID: $id");
    final response = await http.get(Uri.parse('$baseUrl/getSwitches?topicName=esp/test&roomName=$name&user_id=$id'));
    if (response.statusCode == 200) {
      dynamic roomJson = json.decode(response.body);
      print(roomJson);
      if(roomJson == null || roomJson.isEmpty) {
        throw Exception('Room not found');
      }
      if(roomJson['status'] != null && roomJson['status'] == 'success') {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Registration completed successfully, please login"),
            backgroundColor: Colors.green,
          ),
        );
      }
      return Room.fromJson(roomJson);
    } else {
      throw Exception('Failed to load devices');
    }
    
  }

  Future<void> updateSwitch(Switch.Switch roomSwitch, Room room) async {
    int? id = await SessionManager.getId();
    print(roomSwitch);
    final url = Uri.parse('$baseUrl/deviceCommand?roomName=${room.name}&switchId=${roomSwitch.id}&command=${roomSwitch.isOn ? "ON" : "OFF"}&deviceType=${roomSwitch.deviceType}&fanSpeed=${roomSwitch.fanSpeed}&user_id=${id}');
    print("url: $url");
    
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update switch');
    }
  }

  Future<void> addRoom({
    required String name,
    required String description,
    required String macAddress,
    required String moduleType,
  }) async {
    final url = Uri.parse('$baseUrl/addRoom');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_uuid': await SessionManager.getUserId(),
        'user_id': await SessionManager.getId(),
        'roomName': name,
        'device_addr': macAddress,
        'channel_type': moduleType,
      }),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add room');
    }
  }

  Future<void> updateRoom({
    required String name,
    required String description,
    required String macAddress,
    required String moduleType,
  }) async {
    final url = Uri.parse('$baseUrl/rooms/$name');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'description': description,
        'macAddress': macAddress,
        'moduleType': moduleType,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update room');
    }
  }

  Future<void> deleteOrUpdateRoom(Room roomName, bool confirmConnectivity) async {
    final url = Uri.parse('$baseUrl/updateOrDeleteRoom?roomName=${roomName.name}&device_addr=${roomName.device_addr}&channel_type=${roomName.channel_type}&actionType=Delete&user_id=${await SessionManager.getId()}&device_status_check=$confirmConnectivity');
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete room');
    }
  }
}
