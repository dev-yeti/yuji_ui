import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../session/session_manager.dart';
import '../models/schedule.dart';

class ScheduleService {
  static final String baseUrl = AppConfig.baseUrl;

  /// Helper method to clean up schedule details before encoding
  Map<String, dynamic> _cleanScheduleDetails(Map<String, dynamic> scheduleDetails) {
    return {
      'schedule_id': scheduleDetails['schedule_id'],
      'user_id': scheduleDetails['user_id'] ?? '',
      'user_uuid': scheduleDetails['user_uuid'] ?? 0,
      'room': scheduleDetails['room'] ?? '',
      'switchName': scheduleDetails['switch'] ?? '',
      'switchId': scheduleDetails['switchId'] ?? 0,
      'onTime': {
        'hour': scheduleDetails['onTime']['hour'] ?? 0,
        'minute': scheduleDetails['onTime']['minute'] ?? 0,
        'formatted': scheduleDetails['onTime']['formatted'] ?? '',
        'days': List<String>.from(scheduleDetails['onTime']['days'] ?? []),
      },
      'offTime': {
        'hour': scheduleDetails['offTime']['hour'] ?? 0,
        'minute': scheduleDetails['offTime']['minute'] ?? 0,
        'formatted': scheduleDetails['offTime']['formatted'] ?? '',
        'days': List<String>.from(scheduleDetails['offTime']['days'] ?? []),
      },
      'active': scheduleDetails['isEnabled'] == true,
    };
  }

  /// Save a new schedule
  Future<Map<String, dynamic>> saveSchedule(Map<String, dynamic> scheduleDetails) async {
    final url = Uri.parse('$baseUrl/scheduler/save');
    
    print('Saving schedule to API: $url');
    print('Original schedule details: $scheduleDetails');
    
    try {
      // Clean up the schedule details to ensure proper data types
      final cleanedDetails = _cleanScheduleDetails(scheduleDetails);
      print('Cleaned schedule details: $cleanedDetails');
      
      final encodedBody = jsonEncode(cleanedDetails);
      print('Encoded body: $encodedBody');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: encodedBody,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Try to parse as JSON, if it fails, return a success response with the body as message
        try {
          final responseData = json.decode(response.body);
          print('Schedule saved successfully: $responseData');
          return responseData;
        } catch (e) {
          // If response is plain text, wrap it in a map
          print('Response is not JSON, wrapping as text response');
          return {
            'status': 'success',
            'message': response.body,
            'statusCode': response.statusCode,
          };
        }
      } else {
        throw Exception('Failed to save schedule: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error saving schedule: $e');
      rethrow;
    }
  }

  /// Update an existing schedule
  Future<Map<String, dynamic>> updateSchedule(
    String scheduleId,
    Map<String, dynamic> scheduleDetails,
  ) async {
    final url = Uri.parse('$baseUrl/schedules/update/$scheduleId');
    
    print('Updating schedule to API: $url');
    print('Original schedule details: $scheduleDetails');
    
    try {
      // Clean up the schedule details to ensure proper data types
      final cleanedDetails = _cleanScheduleDetails(scheduleDetails);
      print('Cleaned schedule details: $cleanedDetails');
      
      final encodedBody = jsonEncode(cleanedDetails);
      print('Encoded body: $encodedBody');
      
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: encodedBody,
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          print('Schedule updated successfully: $responseData');
          return responseData;
        } catch (e) {
          print('Response is not JSON, wrapping as text response');
          return {
            'status': 'success',
            'message': response.body,
            'statusCode': response.statusCode,
          };
        }
      } else {
        throw Exception('Failed to update schedule: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating schedule: $e');
      rethrow;
    }
  }

  /// Delete a schedule
  Future<void> deleteSchedule(String scheduleId, String userId) async {
    final url = Uri.parse('$baseUrl/scheduler/user/$userId/delete/$scheduleId');

    print('Deleting schedule from API: $url');
    
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Schedule deleted successfully');
      } else {
        throw Exception('Failed to delete schedule: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error deleting schedule: $e');
      rethrow;
    }
  }

  /// Fetch all schedules for a specific user
  Future<List<Schedule>> getSchedulesByUserID(int userId) async {
    final url = Uri.parse('$baseUrl/scheduler/user/$userId');

    print('Fetching schedules from API: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print('Schedules fetched successfully: $responseData');
        
        // Parse the response into Schedule objects
        final schedules = responseData
            .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return schedules;
      } else {
        throw Exception(
          'Failed to fetch schedules: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching schedules: $e');
      rethrow;
    }
  }

  /// Fetch schedule details by user ID and schedule ID
  Future<Schedule> getScheduleDetails(int userId, int scheduleId) async {
    final url = Uri.parse('$baseUrl/scheduler/user/$userId/schedule/$scheduleId');

    print('Fetching schedule details from API: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Schedule details fetched successfully: $responseData');
        
        // Parse the response into a Schedule object
        final schedule = Schedule.fromJson(responseData);
        
        return schedule;
      } else {
        throw Exception(
          'Failed to fetch schedule details: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching schedule details: $e');
      rethrow;
    }
  }

  /// Fetch schedules for the current logged-in user
  Future<List<Schedule>> getCurrentUserSchedules() async {
    final userId = await SessionManager.getId();
    if (userId == null) {
      throw Exception('User ID not found in session');
    }
    return getSchedulesByUserID(userId);
  }

  /// Fetch all schedules for the current user (legacy method name)
  Future<List<Map<String, dynamic>>> getSchedules() async {
    final userId = await SessionManager.getId();
    final url = Uri.parse('$baseUrl/schedules?userId=$userId');
    
    print('Fetching schedules from API: $url');
    
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print('Schedules fetched successfully: $responseData');
        return responseData.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch schedules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching schedules: $e');
      rethrow;
    }
  }
}
