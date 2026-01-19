import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;
  
  // Activity stats (would come from exercise logs in a real app)
  int _workoutsThisWeek = 5;
  int _caloriesBurned = 2450;
  int _activeDays = 6;
  int _streak = 12;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
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
    final _ageController = TextEditingController(text: _age.toString());
    final _heightController = TextEditingController(text: _height.toStringAsFixed(1));
    final _weightController = TextEditingController(text: _weight.toStringAsFixed(1));
    DateTime? _selectedDate = _user!.dob;
    final _dateController = TextEditingController(
      text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[900]!, width: 2),
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
                          _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
                        });
                      }
                    },
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[900]!, width: 2),
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
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[900]!, width: 2),
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
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[900]!, width: 2),
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
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[700],
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
                            height: double.tryParse(_heightController.text.trim()) ?? _user!.height,
                            weight: double.tryParse(_weightController.text.trim()) ?? _user!.weight,
                            dob: _selectedDate!,
                            gender: _user!.gender,
                          );
                          
                          try {
                            await UserService.instance.saveUserProfile(updatedUser);
                            if (mounted) {
                              Navigator.of(context).pop();
                              await _loadUserProfile();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error saving profile: ${e.toString()}')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[900],
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
        backgroundColor: Colors.grey[50],
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
        backgroundColor: Colors.grey[50],
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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 0),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/profile_pic/chad.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
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
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.grey[700],
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
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  Row(
                    children: [
                      Expanded(
                        child: _ActivityCard(
                          icon: Icons.fitness_center,
                          label: 'Workouts',
                          value: '$_workoutsThisWeek',
                          unit: 'this week',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActivityCard(
                          icon: Icons.local_fire_department_outlined,
                          label: 'Calories',
                          value: '$_caloriesBurned',
                          unit: 'burned',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActivityCard(
                          icon: Icons.calendar_today_outlined,
                          label: 'Active Days',
                          value: '$_activeDays',
                          unit: 'this week',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActivityCard(
                          icon: Icons.whatshot_outlined,
                          label: 'Streak',
                          value: '$_streak',
                          unit: 'days',
                        ),
                      ),
                    ],
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey[700]),
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

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _ActivityCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.grey[700]),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

