import 'package:flutter/material.dart';
import '../session/session_manager.dart';
import '../services/schedule_service.dart';
import '../services/api_service.dart';
import '../models/room_devices.dart';

class ScheduleFormPage extends StatefulWidget {
  final String? initialRoom;
  final String? initialSwitch;
  final String? initialTime;
  final String? initialOnTime;
  final String? initialOffTime;
  final String? initialStartDays;
  final String? initialEndDays;
  final bool? initialEnabled;
  final int? scheduleId;

  const ScheduleFormPage({
    Key? key,
    this.initialRoom,
    this.initialSwitch,
    this.initialTime,
    this.initialOnTime,
    this.initialOffTime,
    this.initialStartDays,
    this.initialEndDays,
    this.initialEnabled,
    this.scheduleId,
  }) : super(key: key);

  @override
  State<ScheduleFormPage> createState() => _ScheduleFormPageState();
}

class _ScheduleFormPageState extends State<ScheduleFormPage> {
  String? _selectedRoom;
  String? _selectedSwitch;
  TimeOfDay _selectedTime = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _selectedOffTime = TimeOfDay(hour: 22, minute: 0);
  bool _isEnabled = true;

  // Days of week selection
  final List<String> days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  Set<String> _selectedDaysForOn = {'MON', 'TUE', 'WED', 'THU', 'FRI'};
  Set<String> _selectedDaysForOff = {'MON', 'TUE', 'WED', 'THU', 'FRI'};

  // Dynamic room and device data
  Map<String, List<RoomDevice>> _roomsWithDevices = {};
  List<String> _rooms = [];
  
  bool _isLoading = false;
  bool _isLoadingDevices = false;
  String? _deviceLoadError;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.initialRoom;
    _selectedSwitch = widget.initialSwitch;
    _isEnabled = widget.initialEnabled ?? true;
    
    // Fetch rooms and devices
    _fetchRoomsWithDevices();
    
    // Parse initial on time - prefer initialOnTime, fallback to initialTime for backward compatibility
    final onTimeStr = widget.initialOnTime ?? widget.initialTime;
    if (onTimeStr != null) {
      final timeParts = onTimeStr.split(RegExp(r'[: ]'));
      int hour = int.tryParse(timeParts[0]) ?? 7;
      int minute = int.tryParse(timeParts[1]) ?? 0;
      final isPM = onTimeStr.toLowerCase().contains('pm');
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    }
    
    // Parse initial off time
    if (widget.initialOffTime != null) {
      final timeParts = widget.initialOffTime!.split(RegExp(r'[: ]'));
      int hour = int.tryParse(timeParts[0]) ?? 22;
      int minute = int.tryParse(timeParts[1]) ?? 0;
      final isPM = widget.initialOffTime!.toLowerCase().contains('pm');
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      _selectedOffTime = TimeOfDay(hour: hour, minute: minute);
    }
    
    // Parse initial start days (on days)
    if (widget.initialStartDays != null && widget.initialStartDays!.isNotEmpty) {
      _selectedDaysForOn = _parseDaysString(widget.initialStartDays!);
    }
    
    // Parse initial end days (off days)
    if (widget.initialEndDays != null && widget.initialEndDays!.isNotEmpty) {
      _selectedDaysForOff = _parseDaysString(widget.initialEndDays!);
    }
  }

  /// Fetch rooms and devices from API
  Future<void> _fetchRoomsWithDevices() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingDevices = true;
      _deviceLoadError = null;
    });

    try {
      final roomDevices = await _apiService.getRoomsWithDevices();
      
      if (mounted) {
        setState(() {
          _roomsWithDevices = roomDevices;
          _rooms = roomDevices.keys.toList();
          _isLoadingDevices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _deviceLoadError = 'Failed to load devices: ${e.toString()}';
          _isLoadingDevices = false;
        });
      }
      debugPrint('Error fetching rooms with devices: $e');
    }
  }

  /// Helper method to parse days string and convert to Set<String>
  /// Handles formats like "MON,TUE,WED" or "MON, TUE, WED"
  Set<String> _parseDaysString(String daysString) {
    if (daysString.isEmpty) {
      return {'MON', 'TUE', 'WED', 'THU', 'FRI'};
    }
    
    final daysList = daysString
        .split(',')
        .map((day) => day.trim().toUpperCase())
        .where((day) => days.contains(day))
        .toSet();
    
    return daysList.isNotEmpty ? daysList : {'MON', 'TUE', 'WED', 'THU', 'FRI'};
  }

  /// Collect all schedule details and prepare for API call
  Future<Map<String, dynamic>> _getScheduleDetails() async {
    final userId = await SessionManager.getId();
    final userNumId = await SessionManager.getUserId();
    
    // Get switch ID from the RoomDevice object
    int? switchId;
    if (_selectedRoom != null && _selectedSwitch != null) {
      final devices = _roomsWithDevices[_selectedRoom];
      final selectedDevice = devices?.firstWhere(
        (device) => device.name == _selectedSwitch,
        orElse: () => RoomDevice(name: '', id: 0),
      );
      switchId = selectedDevice?.id;
    }
    
    return {
      'schedule_id': widget.scheduleId,
      'user_id': userId,
      'user_uuid': userNumId,
      'room': _selectedRoom,
      'switch': _selectedSwitch,
      'switchId': switchId,
      'onTime': {
        'hour': _selectedTime.hour,
        'minute': _selectedTime.minute,
        'formatted': _selectedTime.format(context),
        'days': _selectedDaysForOn.toList(),
      },
      'offTime': {
        'hour': _selectedOffTime.hour,
        'minute': _selectedOffTime.minute,
        'formatted': _selectedOffTime.format(context),
        'days': _selectedDaysForOff.toList(),
      },
      'isEnabled': _isEnabled,
    };
  }

  void _saveSchedule() async {
    if (_selectedRoom == null || _selectedSwitch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a room and switch'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Collect all schedule details
      final scheduleDetails = await _getScheduleDetails();
      
      // Debug: Print collected details
      debugPrint('=== Schedule Details ===');
      debugPrint('Schedule ID: ${scheduleDetails['schedule_id']}');
      debugPrint('User ID: ${scheduleDetails['user_id']}');
      debugPrint('User UUID: ${scheduleDetails['user_uuid']}');
      debugPrint('Room: ${scheduleDetails['room']}');
      debugPrint('Switch: ${scheduleDetails['switch']}');
      debugPrint('Switch ID: ${scheduleDetails['switchId']}');
      debugPrint('ON Time: ${scheduleDetails['onTime']['formatted']} on ${scheduleDetails['onTime']['days']}');
      debugPrint('OFF Time: ${scheduleDetails['offTime']['formatted']} on ${scheduleDetails['offTime']['days']}');
      debugPrint('Is Enabled: ${scheduleDetails['isEnabled']}');
      debugPrint('=======================');
      
      // Call API to save schedule
      final scheduleService = ScheduleService();
      final response = await scheduleService.saveSchedule(scheduleDetails);

      debugPrint('API Response: $response');
      
      // Extract success message from response
      String successMessage = 'Schedule saved successfully!';
      if (response.containsKey('message')) {
        successMessage = response['message'] ?? successMessage;
      } else if (response.containsKey('status')) {
        successMessage = 'Schedule ${response['status']}!';
      }
      
      // Show success message and navigate back
      if (mounted) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate back to the schedules tab with result
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context, {'success': true, 'message': successMessage, 'data': response});
          }
        });
      }
    } catch (e) {
      debugPrint('Error saving schedule: $e');
      
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialRoom == null ? 'Add Schedule' : 'Edit Schedule',
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.indigo,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              // Header with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.blue.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  children: [
                    Icon(
                      widget.initialRoom == null ? Icons.add_alarm : Icons.edit_calendar,
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.initialRoom == null ? 'Create New Schedule' : 'Edit Schedule',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.initialRoom == null 
                              ? 'Set up a new automation schedule'
                              : 'Modify existing schedule settings',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Room Selection
              Text(
                'Device Selection',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              // Show loading or error state
              if (_isLoadingDevices)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Loading rooms and devices...'),
                    ],
                  ),
                )
              else if (_deviceLoadError != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_deviceLoadError ?? '', style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Room',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.home, color: Colors.indigo),
                        filled: true,
                        fillColor: widget.initialRoom != null ? Colors.grey.shade200 : Colors.white,
                      ),
                      value: _selectedRoom,
                      items: _rooms.map((room) => DropdownMenuItem(
                        value: room,
                        child: Text(room),
                      )).toList(),
                      onChanged: widget.initialRoom != null ? null : (val) {
                        setState(() {
                          _selectedRoom = val;
                          _selectedSwitch = null;
                        });
                      },
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Please select a room' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Switch',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.toggle_on, color: Colors.indigo),
                        filled: true,
                        fillColor: widget.initialRoom != null ? Colors.grey.shade200 : Colors.white,
                      ),
                      value: _selectedSwitch,
                      items: (_selectedRoom != null
                          ? _roomsWithDevices[_selectedRoom] ?? []
                          : [])
                          .map<DropdownMenuItem<String>>((device) => DropdownMenuItem<String>(
                                value: device.name,
                                child: Text(device.name),
                              ))
                          .toList(),
                      onChanged: widget.initialRoom != null ? null : (val) {
                        setState(() {
                          _selectedSwitch = val;
                        });
                      },
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Please select a switch' : null,
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // ON Time Section
              Text(
                'Turn ON Schedule',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time, color: Colors.indigo),
                      title: Text('Time: ${_selectedTime.format(context)}'),
                      trailing: TextButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Change'),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                    Divider(color: Colors.grey.shade300, height: 1),
                    const SizedBox(height: 12),
                    const Text(
                      'Select Days:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: days.map((day) {
                        final isSelected = _selectedDaysForOn.contains(day);
                        return Flexible(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedDaysForOn.remove(day);
                                } else {
                                  _selectedDaysForOn.add(day);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.indigo : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.indigo : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // OFF Time Section
              Text(
                'Turn OFF Schedule',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time, color: Colors.indigo),
                      title: Text('Time: ${_selectedOffTime.format(context)}'),
                      trailing: TextButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Change'),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedOffTime,
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedOffTime = picked;
                            });
                          }
                        },
                      ),
                    ),
                    Divider(color: Colors.grey.shade300, height: 1),
                    const SizedBox(height: 12),
                    const Text(
                      'Select Days:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: days.map((day) {
                        final isSelected = _selectedDaysForOff.contains(day);
                        return Flexible(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedDaysForOff.remove(day);
                                } else {
                                  _selectedDaysForOff.add(day);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.indigo : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? Colors.indigo : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Enable/Disable Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Enable Schedule',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _isEnabled ? 'Schedule is active' : 'Schedule is inactive',
                    style: TextStyle(
                      color: _isEnabled ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  value: _isEnabled,
                  activeColor: Colors.indigo,
                  onChanged: (val) {
                    setState(() {
                      _isEnabled = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Sticky buttons at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              widget.initialRoom == null ? Icons.add : Icons.save,
                              color: Colors.white,
                            ),
                      label: Text(
                        _isLoading
                            ? 'Saving...'
                            : (widget.initialRoom == null ? 'Create Schedule' : 'Update'),
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      onPressed: _isLoading ? null : _saveSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
