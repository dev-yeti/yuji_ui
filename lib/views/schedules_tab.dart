import 'package:flutter/material.dart';

class SchedulesTab extends StatelessWidget {
  const SchedulesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Demo data for schedules
    final schedules = [
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
      ),
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                (schedule['isOn'] as bool) ? Icons.toggle_on : Icons.toggle_off,
                color: (schedule['isOn'] as bool) ? Colors.green : Colors.redAccent,
                size: 32,
              ),
              title: Text('${schedule['room']} - ${schedule['switch']}'),
              subtitle: Text('Scheduled at ${schedule['time']}'),
              trailing: Text(
                (schedule['isOn'] as bool) ? 'Enabled' : 'Disabled',
                style: TextStyle(
                  color: (schedule['isOn'] as bool) ? Colors.green : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: const ScheduleForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ScheduleForm extends StatefulWidget {
  const ScheduleForm({Key? key}) : super(key: key);

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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        children: [
          Text('Add Schedule', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Room'),
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
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Switch'),
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
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
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
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Enabled'),
            value: _isEnabled,
            onChanged: (val) {
              setState(() {
                _isEnabled = val;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Schedule'),
            onPressed: (_selectedRoom != null && _selectedSwitch != null)
                ? () {
              // Save logic here
              Navigator.pop(context);
            }
                : null,
          ),
        ],
      ),
    );
  }
}
