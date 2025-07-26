import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../models/switch.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../session/session_manager.dart';

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

  Future<bool> login(String email, String password) async {
    print("Logging in with email: $email, password: $password");
    user = User(email, password);
     final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_uuid': user.userUUId, 'password': user.password}),); 
    
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
    final response = await http.post(
      Uri.parse('$baseUrl/auth/registerUser'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'phone_number': mobile,
            'user_uuid': userId,
            'password': password}),
    );
    return response.statusCode == 200;
  }

  Future<Room> getRoomByName(String name) async {
    int? id = await SessionManager.getId();
    print("Fetching room by name: $name for user ID: $id");
    final response = await http.get(Uri.parse('$baseUrl/getSwitches?topicName=esp/test&roomName=$name&user_id=$id'));
    if (response.statusCode == 200) {
      dynamic roomJson = json.decode(response.body);
      print(roomJson);
      return Room.fromJson(roomJson);
    } else {
      throw Exception('Failed to load devices');
    }
    
  }
}
