import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/nutrition_service.dart';
import '../services/profile_picture_service.dart';
import '../services/firebase_exercise_service.dart';

// Blue Theme Colors
const Color primaryBlue = Color(0xFF0066FF);
const Color lightBlue = Color(0xFFE0F0FF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;

  // Activity stats from exercise logs
  Future<Map<String, dynamic>> _getWorkoutStats() async {
    try {
      // Get workout logs from Firebase (same as exercise screen)
      final logsData = await FirebaseExerciseService.instance.getWorkoutLogs();

      int totalWorkouts = logsData.length;
      int totalCalories = 0;
      int totalMinutes = 0;

      for (final log in logsData) {
        totalCalories += (log['caloriesBurned'] as num?)?.toInt() ?? 0;
        final duration = log['duration'] as int? ?? 0;
        totalMinutes += (duration / 60000).round();
      }

      int averageCaloriesPerWorkout = totalWorkouts > 0
          ? (totalCalories / totalWorkouts).round()
          : 0;

      return {
        'totalWorkouts': totalWorkouts,
        'totalCalories': totalCalories,
        'totalMinutes': totalMinutes,
        'averageCaloriesPerWorkout': averageCaloriesPerWorkout,
      };
    } catch (e) {
      return {
        'totalWorkouts': 0,
        'totalCalories': 0,
        'totalMinutes': 0,
        'averageCaloriesPerWorkout': 0,
      };
    }
  }

  // Nutrition summary data
  Map<String, dynamic>? _nutritionSummary;
  bool _nutritionLoading = false;

  // Profile picture
  String? _profilePictureUrl;
  bool _profilePictureLoading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadNutritionSummary();
    _loadProfilePicture();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await UserService.instance.getCurrentUserProfile();
      setState(() => _user = user);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNutritionSummary() async {
    setState(() => _nutritionLoading = true);
    try {
      final summary = await NutritionService.instance.getNutritionSummary();
      setState(() => _nutritionSummary = summary);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _nutritionLoading = false);
    }
  }

  Future<void> _loadProfilePicture() async {
    try {
      final url = await ProfilePictureService.instance.getProfilePictureUrl();
      setState(() => _profilePictureUrl = url);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickAndUploadProfilePicture() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (image == null) return;

      setState(() => _profilePictureLoading = true);

      String url;
      if (kIsWeb) {
        // For web platform, use bytes
        final bytes = await image.readAsBytes();
        url = await ProfilePictureService.instance
            .uploadProfilePictureFromBytes(bytes, image.name);
      } else {
        // For mobile platforms, use File
        final file = File(image.path);
        url = await ProfilePictureService.instance.uploadProfilePicture(file);
      }

      setState(() {
        _profilePictureUrl = url;
        _profilePictureLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _profilePictureLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload profile picture: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  int get _age {
    if (_user == null) return 0;
    return UserService.instance.calculateAge(_user!.dob);
  }

  double get _height => _user?.height ?? 0.0;
  double get _weight => _user?.weight ?? 0.0;
  String get _name => _user?.name ?? 'User';

  double get _bmi {
    final heightInMeters = _height / 100;
    return _weight / (heightInMeters * heightInMeters);
  }

  String get _bmiCategory {
    if (_bmi < 18.5) return 'Underweight';
    if (_bmi < 25) return 'Normal';
    if (_bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiCategoryColor {
    if (_bmi < 18.5) return Colors.grey[600]!;
    if (_bmi < 25) return Colors.grey[900]!;
    if (_bmi < 30) return Colors.grey[700]!;
    return Colors.grey[800]!;
  }

  Future<void> _showEditProfileDialog() async {
    if (_user == null) return;

    final _nameController = TextEditingController(text: _name);
    final _heightController = TextEditingController(
      text: _height.toStringAsFixed(1),
    );
    final _weightController = TextEditingController(
      text: _weight.toStringAsFixed(1),
    );
    DateTime? _selectedDate = _user!.dob;
    final _dateController = TextEditingController(
      text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[600]),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: lightBlue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          _selectedDate = picked;
                          _dateController.text =
                              '${picked.day}/${picked.month}/${picked.year}';
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: lightBlue,
                      suffixIcon: Icon(
                        Icons.calendar_today,
                        color: primaryBlue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryBlue.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            filled: true,
                            fillColor: lightBlue,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryBlue.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryBlue.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryBlue,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            filled: true,
                            fillColor: lightBlue,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryBlue.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryBlue.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryBlue,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: primaryBlue.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_user == null || _selectedDate == null) return;

                            final updatedUser = User(
                              userId: _user!.userId,
                              name: _nameController.text.trim(),
                              email: _user!.email,
                              level: _user!.level,
                              height:
                                  double.tryParse(
                                    _heightController.text.trim(),
                                  ) ??
                                  _user!.height,
                              weight:
                                  double.tryParse(
                                    _weightController.text.trim(),
                                  ) ??
                                  _user!.weight,
                              dob: _selectedDate!,
                              gender: _user!.gender,
                            );

                            try {
                              await UserService.instance.saveUserProfile(
                                updatedUser,
                              );
                              if (mounted) {
                                Navigator.of(context).pop();
                                await _loadUserProfile();
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error saving profile: ${e.toString()}',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: lightBlue,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: lightBlue,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _profilePictureLoading
                            ? null
                            : _pickAndUploadProfilePicture,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: lightBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryBlue, width: 3),
                          ),
                          child: ClipOval(
                            child: _profilePictureLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _profilePictureUrl != null
                                ? Image.network(
                                    _profilePictureUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/profile_pic/chad.jpg',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/profile_pic/chad.jpg',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _profilePictureLoading
                              ? null
                              : _pickAndUploadProfilePicture,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Name with Edit Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _showEditProfileDialog,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Age',
                          value: '$_age',
                          unit: 'years',
                          icon: Icons.cake_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Height',
                          value: '${_height.toStringAsFixed(0)}',
                          unit: 'cm',
                          icon: Icons.height_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Weight',
                          value: '${_weight.toStringAsFixed(1)}',
                          unit: 'kg',
                          icon: Icons.monitor_weight_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // BMI Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: lightBlue,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryBlue.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _bmi.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _bmiCategoryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _bmiCategory,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Activity Summary Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _getWorkoutStats(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final stats = snapshot.data!;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _ProfileStatCard(
                                  label: 'Total Workouts',
                                  value: '${stats['totalWorkouts']}',
                                  icon: Icons.fitness_center,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ProfileStatCard(
                                  label: 'Total Calories',
                                  value: '${stats['totalCalories']}',
                                  unit: 'cal',
                                  icon: Icons.local_fire_department,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ProfileStatCard(
                                  label: 'Total Time',
                                  value: '${stats['totalMinutes']}',
                                  unit: 'min',
                                  icon: Icons.schedule,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ProfileStatCard(
                                  label: 'Avg Calories',
                                  value:
                                      '${stats['averageCaloriesPerWorkout']}',
                                  unit: 'per',
                                  icon: Icons.show_chart,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Nutrition Summary Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nutrition Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_nutritionLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_nutritionSummary != null) ...[
                    // Average Daily Calories
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: primaryBlue.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Avg Daily Calories',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_nutritionSummary!['avgCalories']}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'kcal/day',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_nutritionSummary!['daysWithData']} days',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Macro Breakdown
                    Row(
                      children: [
                        Expanded(
                          child: _NutritionMacroCard(
                            label: 'Protein',
                            value: _nutritionSummary!['avgProtein'],
                            unit: 'g',
                            icon: Icons.fitness_center_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NutritionMacroCard(
                            label: 'Carbs',
                            value: _nutritionSummary!['avgCarbs'],
                            unit: 'g',
                            icon: Icons.energy_savings_leaf_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NutritionMacroCard(
                            label: 'Fat',
                            value: _nutritionSummary!['avgFat'],
                            unit: 'g',
                            icon: Icons.water_drop_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Total Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _TotalStat(
                            label: 'Total Calories',
                            value: _nutritionSummary!['totalCalories'],
                            icon: Icons.local_fire_department_outlined,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          _TotalStat(
                            label: 'Days Tracked',
                            value: _nutritionSummary!['daysWithData'],
                            icon: Icons.calendar_today_outlined,
                          ),
                        ],
                      ),
                    ),
                  ] else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.restaurant_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No nutrition data available',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: primaryBlue),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;

  const _ProfileStatCard({
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (unit != null)
            Text(
              unit!,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionMacroCard extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final IconData icon;

  const _NutritionMacroCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: primaryBlue),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalStat extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _TotalStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: primaryBlue),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
