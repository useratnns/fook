import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';
import '../services/alarm_service.dart';
import 'package:intl/intl.dart';
import '../utils/permission_utils.dart';

class CreateTaskScreen extends StatefulWidget {
  final Task? task;
  const CreateTaskScreen({super.key, this.task});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = 'University';
  TaskPriority _priority = TaskPriority.medium;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _defaultCategories = ['University', 'Home', 'Personal', 'Friends', 'Other'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _category = widget.task!.category;
      _priority = widget.task!.priority;
      _selectedDate = widget.task!.date;
      _selectedTime = TimeOfDay(
        hour: int.parse(widget.task!.time.split(':')[0]),
        minute: int.parse(widget.task!.time.split(':')[1]),
      );
    }
  }

  void _submitTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final taskProvider = context.read<TaskProvider>();
      final isEditing = widget.task != null;

      final task = isEditing 
        ? widget.task!.copyWith(
            title: _title,
            category: _category,
            priority: _priority,
            date: _selectedDate,
            time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
          )
        : Task(
            title: _title,
            category: _category,
            priority: _priority,
            date: _selectedDate,
            time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
            createdAt: DateTime.now(),
          );

      // Request permissions before saving if a reminder is likely to be set
      // (In this app, all tasks seem to have alarms)
      if (context.mounted) {
        final hasPermission = await PermissionUtils.requestAlarmPermissions(context);
        if (!hasPermission) return;
      }

      if (isEditing) {
        await taskProvider.updateTask(task);
      } else {
        await taskProvider.addTask(task);
      }
      
      // Note: Alarm and Notification scheduling is now handled by TaskProvider

      if (mounted) {
        if (isEditing) {
          Navigator.of(context).pop();
        } else {
          _showPostSaveDialog();
        }
      }
    }
  }

  void _showPostSaveDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Task Added!'),
        content: const Text('Would you like to add another task or go back to the dashboard?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back
            },
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _resetForm();
            },
            child: const Text('Add Another'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _title = '';
      _formKey.currentState?.reset();
      // Keep category and date for faster entry
    });
  }

  void _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && widget.task?.id != null) {
      await context.read<TaskProvider>().deleteTask(widget.task!.id!);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task != null ? 'Edit Task' : 'Create New Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Task Title / Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category == _defaultCategories.last ? _defaultCategories.last : (_defaultCategories.contains(_category) ? _category : 'Other'),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _defaultCategories.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                )).toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              if (_category == 'Other') ...[
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Custom Category Name & Emoji',
                    hintText: 'e.g., 🛒 Shopping',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  onChanged: (value) => _category = value,
                ),
              ],
              const SizedBox(height: 16),
              const Text('Priority'),
              SegmentedButton<TaskPriority>(
                segments: const [
                  ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                  ButtonSegment(value: TaskPriority.medium, label: Text('Medium')),
                  ButtonSegment(value: TaskPriority.high, label: Text('High')),
                ],
                selected: {_priority},
                onSelectionChanged: (selected) => setState(() => _priority = selected.first),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                leading: const Icon(Icons.calendar_today),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              ListTile(
                title: Text('Time: ${_selectedTime.format(context)}'),
                leading: const Icon(Icons.access_time),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (picked != null) setState(() => _selectedTime = picked);
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(widget.task != null ? 'Update Task' : 'Save Task', style: const TextStyle(fontSize: 18)),
                ),
              ),
              if (widget.task != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _deleteTask,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Delete Task', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
