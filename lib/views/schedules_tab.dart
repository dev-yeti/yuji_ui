import 'package:flutter/material.dart';

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
    // Replace this with your actual API call and parsing logic
    // Here is a mock example:
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'room': 'Living Room',
        'switch': 'Ceiling Light',
        'time': '07:00 AM',
        'isOn': true,
      },
      {
        'room': 'Bedroom',
        'switch': 'Bed Lamp',
        'time': '08:00 AM',
        'isOn': false,
      },
      {
        'room': 'Kitchen',
        'switch': 'Bulb',
        'time': '09:00 AM',
        'isOn': true,
      },
    ];
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
                    trailing: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: ScheduleForm(
                            initialRoom: schedule['room'] as String,
                            initialSwitch: schedule['switch'] as String,
                            initialTime: schedule['time'] as String,
                            initialEnabled: schedule['isOn'] as bool,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: const ScheduleForm(),
            ),
          );
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add_alarm, size: 32, color: Colors.white), // Best design icon for add schedule
      ),
    );
  }
}

class ScheduleForm extends StatefulWidget {
  final String? initialRoom;
  final String? initialSwitch;
  final String? initialTime;
  final bool? initialEnabled;

  const ScheduleForm({
    Key? key,
    this.initialRoom,
    this.initialSwitch,
    this.initialTime,
    this.initialEnabled,
  }) : super(key: key);

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  String? _selectedRoom;
  String? _selectedSwitch;
  TimeOfDay _selectedTime = TimeOfDay(hour: 7, minute: 0);
  bool _isEnabled = true;

  final List<String> rooms = ['Living Room', 'Bedroom', 'Kitchen'];
  final Map<String, List<String>> switches = {
    'Living Room': ['Ceiling Light', 'Fan'],
    'Bedroom': ['Bed Lamp'],
    'Kitchen': ['Bulb'],
  };

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.initialRoom;
    _selectedSwitch = widget.initialSwitch;
    _isEnabled = widget.initialEnabled ?? true;
    if (widget.initialTime != null) {
      final timeParts = (widget.initialTime as String).split(RegExp(r'[: ]'));
      int hour = int.tryParse(timeParts[0]) ?? 7;
      int minute = int.tryParse(timeParts[1]) ?? 0;
      final isPM = widget.initialTime!.toLowerCase().contains('pm');
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.blue.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      widget.initialRoom == null ? 'Add Schedule' : 'Edit Schedule',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Room',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.home),
                ),
                value: _selectedRoom,
                items: rooms.map((room) => DropdownMenuItem(
                  value: room,
                  child: Text(room),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedRoom = val;
                    _selectedSwitch = null;
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please select a room' : null,
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Switch',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.toggle_on),
                ),
                value: _selectedSwitch,
                items: (_selectedRoom != null
                    ? switches[_selectedRoom] ?? []
                    : [])
                    .map<DropdownMenuItem<String>>((sw) => DropdownMenuItem<String>(
                          value: sw,
                          child: Text(sw),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSwitch = val;
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please select a switch' : null,
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time, color: Colors.indigo),
                title: Text('Scheduled Time: ${_selectedTime.format(context)}'),
                trailing: TextButton(
                  child: const Text('Pick Time'),
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
              const SizedBox(height: 18),
              SwitchListTile(
                title: const Text('Enabled'),
                value: _isEnabled,
                activeColor: Colors.indigo,
                onChanged: (val) {
                  setState(() {
                    _isEnabled = val;
                  });
                },
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.cancel, color: Colors.redAccent),
                    label: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(widget.initialRoom == null ? 'Save Schedule' : 'Update'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: (_selectedRoom != null && _selectedSwitch != null)
                        ? () {
                            // Save or update logic here
                            Navigator.pop(context);
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
