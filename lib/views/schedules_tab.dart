import 'package:flutter/material.dart';
import 'schedule_form_page.dart';
import '../services/schedule_service.dart';
import '../session/session_manager.dart';

class SchedulesTab extends StatefulWidget {
  const SchedulesTab({Key? key}) : super(key: key);

  @override
  State<SchedulesTab> createState() => _SchedulesTabState();
}

class _SchedulesTabState extends State<SchedulesTab> {

  late Future<List<Map<String, dynamic>>> _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _schedulesFuture = _fetchSchedules();
  }

  Future<List<Map<String, dynamic>>> _fetchSchedules() async {
    try {
      // Get the current user ID from session
      final userId = await SessionManager.getId();
      if (userId == null) {
        throw Exception('User ID not found in session');
      }

      // Fetch schedules using the ScheduleService
      final scheduleService = ScheduleService();
      final schedules = await scheduleService.getSchedulesByUserID(userId);

      // Convert Schedule objects to map format for display
      return schedules
          .map((schedule) => {
                'scheduleId': schedule.scheduleId,
                'room': schedule.roomName,
                'switch': schedule.switchName,
                'time': schedule.startTime,
                'isOn': schedule.status.toLowerCase() == 'active',
              })
          .toList();
    } catch (e) {
      print('Error fetching schedules: $e');
      rethrow;
    }
  }

  /// Refresh the schedules list
  void _refreshSchedules() {
    setState(() {
      _schedulesFuture = _fetchSchedules();
    });
  }

  /// Delete a schedule
  void _deleteSchedule(int scheduleId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed || !mounted) return;

    try {
      final scheduleService = ScheduleService();
      final userId = await SessionManager.getId();
      await scheduleService.deleteSchedule(scheduleId.toString(), userId.toString());

      if (mounted) {
        _refreshSchedules();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule deleted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting schedule: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Navigate to schedule form and handle the result
  void _navigateToScheduleForm({
    String? initialRoom,
    String? initialSwitch,
    String? initialTime,
    String? initialOnTime,
    String? initialOffTime,
    String? initialStartDays,
    String? initialEndDays,
    bool? initialEnabled,
    int? scheduleId,
  }) async {
    // If scheduleId is provided, fetch the schedule details from API
    if (scheduleId != null) {
      try {
        final userId = await SessionManager.getId();
        if (userId == null) {
          throw Exception('User ID not found in session');
        }
        
        final scheduleService = ScheduleService();
        final scheduleDetails = await scheduleService.getScheduleDetails(userId, scheduleId);
        
        // Update initial values with fetched details
        initialRoom = scheduleDetails.roomName;
        initialSwitch = scheduleDetails.switchName;
        initialTime = scheduleDetails.startTime;
        initialOnTime = scheduleDetails.startTime;
        initialOffTime = scheduleDetails.endTime;
        initialStartDays = scheduleDetails.startDays;
        initialEndDays = scheduleDetails.endDays;
        initialEnabled = scheduleDetails.status.toLowerCase() == 'active';
      } catch (e) {
        print('Error fetching schedule details: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading schedule details: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleFormPage(
          initialRoom: initialRoom,
          initialSwitch: initialSwitch,
          initialTime: initialTime,
          initialOnTime: initialOnTime,
          initialOffTime: initialOffTime,
          initialStartDays: initialStartDays,
          initialEndDays: initialEndDays,
          initialEnabled: initialEnabled,
          scheduleId: scheduleId,
        ),
      ),
    );

    // If we received a successful result, refresh the list
    if (result != null && result['success'] == true && mounted) {
      _refreshSchedules();
      
      // Show the response message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Schedule updated successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
      ),
      body: Container(
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [Color(0xFF283E51), Color(0xFF485563), Color(0xFF2b5876)],
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //   ),
        // ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _schedulesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No schedules found', style: TextStyle(color: Colors.white)));
            }
            final schedules = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: schedules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: schedule['isOn'] as bool
                          ? [Colors.indigo.shade400, Colors.blue.shade200]
                          : [Colors.grey.shade600, Colors.grey.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white,
                      child: Icon(
                      Icons.schedule,
                      color: Colors.indigo,
                      size: 32,
                      ),
                    ),
                    title: Text(
                      '${schedule['room']} - ${schedule['switch']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.white70, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'At ${schedule['time']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          (schedule['isOn'] as bool) ? Icons.check_circle : Icons.cancel,
                          color: (schedule['isOn'] as bool) ? Colors.greenAccent : Colors.redAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (schedule['isOn'] as bool) ? 'Enabled' : 'Disabled',
                          style: TextStyle(
                            color: (schedule['isOn'] as bool) ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            _navigateToScheduleForm(
                              initialRoom: schedule['room'] as String,
                              initialSwitch: schedule['switch'] as String,
                              initialTime: schedule['time'] as String,
                              initialEnabled: schedule['isOn'] as bool,
                              scheduleId: schedule['scheduleId'] as int,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            _deleteSchedule(schedule['scheduleId'] as int);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToScheduleForm();
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add_alarm, size: 32, color: Colors.white),
      ),
    );
  }
}
