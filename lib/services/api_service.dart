import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../models/device.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android Emulator localhost

  Future<List<Room>> getRooms() async {
    final response = await http.get(Uri.parse('$baseUrl/rooms'));
    if (response.statusCode == 200) {
      List<dynamic> roomsJson = json.decode(response.body);
      return roomsJson.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<List<Device>> getDevices(int roomId) async {
    final response = await http.get(Uri.parse('$baseUrl/rooms/$roomId/devices'));
    if (response.statusCode == 200) {
      List<dynamic> devicesJson = json.decode(response.body);
      return devicesJson.map((json) => Device.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load devices');
    }
  }

  Future<bool> login(String email, String password) async {
    /* final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    ); */
    //return response.statusCode == 200;
    return true;
  }

  Future<bool> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );
    return response.statusCode == 201;
  }
}
