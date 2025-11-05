import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import '../services/image_service.dart';

class AddGoalScreen extends StatefulWidget {
  final Goal? goal;

  const AddGoalScreen({super.key, this.goal});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _baseRewardController = TextEditingController();
  final _growthPercentageController = TextEditingController();

  bool _isLoading = false;
  String? _selectedImagePath; // Current image path (for display)
  File? _pickedImageFile; // Newly picked image file

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _nameController.text = widget.goal!.name;
      _targetAmountController.text = widget.goal!.targetAmount.toStringAsFixed(2);
      _baseRewardController.text = widget.goal!.baseRewardPerDay.toStringAsFixed(2);
      _growthPercentageController.text = widget.goal!.growthPercentage.toStringAsFixed(1);
      _selectedImagePath = widget.goal!.imagePath;
    } else {
      // Default values
      _baseRewardController.text = '5.00';
      _growthPercentageController.text = '10.0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _baseRewardController.dispose();
    _growthPercentageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImageFile = File(image.path);
          _selectedImagePath = image.path; // Show picked image immediately
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final goalProvider = context.read<GoalProvider>();
      final name = _nameController.text.trim();
      final targetAmount = double.tryParse(_targetAmountController.text) ?? 0.0;
      final baseReward = double.tryParse(_baseRewardController.text) ?? 0.0;
      final growthPercentage = double.tryParse(_growthPercentageController.text) ?? 0.0;

      // Handle image: save new image if picked, or keep existing
      String? finalImagePath = _selectedImagePath;
      if (_pickedImageFile != null) {
        // Save new image to app directory
        final savedPath = await ImageService.saveImageToAppDirectory(_pickedImageFile!.path);
        if (savedPath != null) {
          finalImagePath = savedPath;
          
          // Delete old image if updating
          if (widget.goal != null && widget.goal!.imagePath != null) {
            await ImageService.deleteImageFile(widget.goal!.imagePath);
          }
        }
      }

      if (widget.goal != null) {
        // Update existing goal
        final updatedGoal = widget.goal!.copyWith(
          name: name,
          targetAmount: targetAmount,
          baseRewardPerDay: baseReward,
          growthPercentage: growthPercentage,
          imagePath: finalImagePath,
        );
        await goalProvider.updateGoal(updatedGoal);
      } else {
        // Create new goal
        final newGoal = Goal(
          id: goalProvider.generateId(),
          name: name,
          targetAmount: targetAmount,
          baseRewardPerDay: baseReward,
          growthPercentage: growthPercentage,
          isActive: true,
          imagePath: finalImagePath,
        );
        await goalProvider.addGoal(newGoal);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.goal != null
                  ? 'Goal updated successfully!'
                  : 'Goal created successfully!',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving goal: $e'),
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
        title: Text(widget.goal != null ? 'Edit Goal' : 'New Goal'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Goal Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  hintText: 'e.g., 50" TV',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a goal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Goal Image
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goal Image',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      // Image Preview
                      if (_selectedImagePath != null)
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 200,
                              maxWidth: double.infinity,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_selectedImagePath!),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Theme.of(context).colorScheme.surfaceVariant,
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 48),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.image, size: 48, color: Colors.grey),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Pick Image'),
                            ),
                          ),
                          if (_selectedImagePath != null) ...[
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedImagePath = null;
                                  _pickedImageFile = null;
                                });
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Remove', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Target Amount
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount (£)',
                  hintText: '250.00',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  prefixText: '£ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a target amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Base Reward Per Day
              TextFormField(
                controller: _baseRewardController,
                decoration: const InputDecoration(
                  labelText: 'Base Reward Per Day (£)',
                  hintText: '5.00',
                  prefixIcon: Icon(Icons.trending_up),
                  border: OutlineInputBorder(),
                  prefixText: '£ ',
                  helperText: 'Starting reward amount per fasting day',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a base reward amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Growth Percentage
              TextFormField(
                controller: _growthPercentageController,
                decoration: const InputDecoration(
                  labelText: 'Growth Percentage (%)',
                  hintText: '10.0',
                  prefixIcon: Icon(Icons.percent),
                  border: OutlineInputBorder(),
                  suffixText: '%',
                  helperText: 'Daily percentage increase in reward amount',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a growth percentage';
                  }
                  final percentage = double.tryParse(value);
                  if (percentage == null || percentage < 0) {
                    return 'Please enter a valid percentage (0 or greater)';
                  }
                  return null;
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
                        'Each day you fast, you earn the reward amount. The reward grows by the specified percentage each consecutive day. If you miss a day, your streak resets but your reward rate stays the same until you surpass your previous longest streak.',
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
                onPressed: _isLoading ? null : _saveGoal,
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
                        widget.goal != null ? 'Update Goal' : 'Create Goal',
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

