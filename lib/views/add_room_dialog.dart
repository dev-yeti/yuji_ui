import 'package:flutter/material.dart';

class AddRoomDialog extends StatefulWidget {
  final String initialRoomName;
  final String? initialDescription;
  final String? initialMacAddress;

  const AddRoomDialog({
    Key? key,
    required this.initialRoomName,
    this.initialDescription,
    this.initialMacAddress,
  }) : super(key: key);

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRoomName;
  late TextEditingController _descController;
  late TextEditingController _macController;

  final List<String> roomNames = [
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Bathroom',
    'Office',
    'Garage',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRoomName = widget.initialRoomName.isNotEmpty ? widget.initialRoomName : null;
    _descController = TextEditingController(text: widget.initialDescription ?? '');
    _macController = TextEditingController(text: widget.initialMacAddress ?? '');
  }

  @override
  void dispose() {
    _descController.dispose();
    _macController.dispose();
    super.dispose();
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
          child: Form(
            key: _formKey,
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
                      Icon(Icons.room_preferences, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        widget.initialRoomName.isEmpty ? 'Add New Room' : 'Edit Room',
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
                    labelText: 'Room Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.home),
                  ),
                  value: _selectedRoomName,
                  items: roomNames
                      .map((name) => DropdownMenuItem(
                            value: name,
                            child: Text(name),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedRoomName = val;
                    });
                  },
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Please select a room name' : null,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _macController,
                  decoration: InputDecoration(
                    labelText: 'MAC Address',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.memory),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Please enter MAC address' : null,
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
                      icon: Icon(widget.initialRoomName.isEmpty ? Icons.add : Icons.save,
                        color: Colors.white),
                        label: Text(
                        widget.initialRoomName.isEmpty ? 'Add Room' : 'Update',
                        style: const TextStyle(color: Colors.white),
                        ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          // Save or update logic here
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
