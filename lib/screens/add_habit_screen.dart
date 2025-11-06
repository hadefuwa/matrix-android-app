import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? habit;

  const AddHabitScreen({super.key, this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIcon = 'check_circle'; // Default icon

  bool _isLoading = false;

  // Available icons
  final List<Map<String, String>> _availableIcons = [
    {'name': 'check_circle', 'label': 'Check Circle'},
    {'name': 'fasting', 'label': 'Fasting'},
    {'name': 'youtube', 'label': 'YouTube'},
    {'name': 'fitness_center', 'label': 'Fitness'},
    {'name': 'book', 'label': 'Reading'},
    {'name': 'meditation', 'label': 'Meditation'},
    {'name': 'water_drop', 'label': 'Water'},
    {'name': 'bedtime', 'label': 'Sleep'},
    {'name': 'savings', 'label': 'Savings'},
    {'name': 'school', 'label': 'Learning'},
    {'name': 'self_improvement', 'label': 'Self Care'},
    {'name': 'volunteer_activism', 'label': 'Volunteer'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _selectedIcon = widget.habit!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fasting':
        return Icons.favorite;
      case 'youtube':
        return Icons.play_circle;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'book':
        return Icons.book;
      case 'meditation':
        return Icons.self_improvement;
      case 'water_drop':
        return Icons.water_drop;
      case 'bedtime':
        return Icons.bedtime;
      case 'savings':
        return Icons.savings;
      case 'school':
        return Icons.school;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'check_circle':
      default:
        return Icons.check_circle;
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final habitProvider = context.read<HabitProvider>();
      final name = _nameController.text.trim();

      if (widget.habit != null) {
        // Update existing habit
        final updatedHabit = widget.habit!.copyWith(
          name: name,
          icon: _selectedIcon,
        );
        await habitProvider.updateHabit(updatedHabit);
      } else {
        // Create new habit
        final newHabit = Habit(
          id: habitProvider.generateId(),
          name: name,
          icon: _selectedIcon,
          isActive: true,
        );
        await habitProvider.addHabit(newHabit);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.habit != null
                  ? 'Habit updated successfully!'
                  : 'Habit created successfully!',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving habit: $e'),
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
        title: Text(widget.habit != null ? 'Edit Habit' : 'New Habit'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Habit Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'e.g., Exercise, Reading, Meditation',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Icon Selection
              Text(
                'Select Icon',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final iconData = _availableIcons[index];
                  final isSelected = _selectedIcon == iconData['name'];
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconData['name']!;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getIconData(iconData['name']!),
                            size: 32,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            iconData['label']!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Info Card
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How it works',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Each habit you complete earns the same reward amount. Track multiple habits individually, and all their rewards combine toward your goal!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              FilledButton(
                onPressed: _isLoading ? null : _saveHabit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.habit != null ? 'Update Habit' : 'Create Habit',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





