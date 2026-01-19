import 'package:flutter/material.dart';
import '../models/food.dart';
import '../widgets/food_card.dart';
import '../widgets/nutrition_pie.dart';
import '../services/nutrition_service.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final Map<String, List<FoodEntry>> _meals = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
    'Snacks': [],
  };

  bool _isLoading = true;
  final int _dailyGoal = 2000;

  // Premium green color theme
  static const Color _primaryGreen = Color(0xFF10B981); // emerald-500
  static const Color _darkGreen = Color(0xFF059669); // emerald-600
  static const Color _lightGreen = Color(0xFF34D399); // emerald-400
  static const Color _bgGreen = Color(0xFFECFDF5); // emerald-50
  static const Color _textGreen = Color(0xFF047857); // emerald-700

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  Future<void> _loadNutritionData() async {
    setState(() => _isLoading = true);
    try {
      final meals = await NutritionService.instance.loadDailyNutrition(DateTime.now());
      setState(() {
        _meals.clear();
        _meals.addAll(meals);
      });
    } catch (e) {
      // Handle error silently or show snackbar
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNutritionData() async {
    try {
      await NutritionService.instance.saveDailyNutrition(DateTime.now(), _meals);
    } catch (e) {
      // Handle error
    }
  }

  int get _totalCalories => _meals.values.expand((e) => e).fold(0, (s, e) => s + e.calories);
  int get _totalProtein => _meals.values.expand((e) => e).fold(0, (s, e) => s + e.protein);
  int get _totalCarbs => _meals.values.expand((e) => e).fold(0, (s, e) => s + e.carbs);
  int get _totalFat => _meals.values.expand((e) => e).fold(0, (s, e) => s + e.fat);

  void _addEntry(String meal, FoodEntry entry) {
    setState(() {
      _meals[meal]!.insert(0, entry);
    });
    _saveNutritionData();
  }

  void _removeEntry(String meal, int index) {
    setState(() {
      _meals[meal]!.removeAt(index);
    });
    _saveNutritionData();
  }

  Future<void> _showAddFoodDialog() async {
    final _name = TextEditingController();
    final _qty = TextEditingController(text: '1 serving');
    final _cal = TextEditingController(text: '100');
    final _p = TextEditingController(text: '0');
    final _c = TextEditingController(text: '0');
    final _f = TextEditingController(text: '0');
    String selectedMeal = 'Snacks';

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
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
                      'Add Food',
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
                  controller: _name,
                    decoration: InputDecoration(
                      labelText: 'Food Name',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: _bgGreen,
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
                        borderSide: BorderSide(color: _primaryGreen, width: 2),
                      ),
                    ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _qty,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: _bgGreen,
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
                        borderSide: BorderSide(color: _primaryGreen, width: 2),
                      ),
                    ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _cal,
                  keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Calories',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: _bgGreen,
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
                        borderSide: BorderSide(color: _primaryGreen, width: 2),
                      ),
                    ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _p,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Protein (g)',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: _bgGreen,
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
                            borderSide: BorderSide(color: _primaryGreen, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _c,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Carbs (g)',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: _bgGreen,
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
                            borderSide: BorderSide(color: _primaryGreen, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _f,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Fat (g)',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: _bgGreen,
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
                            borderSide: BorderSide(color: _primaryGreen, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedMeal,
                  items: _meals.keys.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() {
                        selectedMeal = v;
                      });
                    }
                  },
                    decoration: InputDecoration(
                      labelText: 'Meal',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: _bgGreen,
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
                        borderSide: BorderSide(color: _primaryGreen, width: 2),
                      ),
                    ),
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
                        onPressed: () {
                          final name = _name.text.trim();
                          if (name.isEmpty) return;
                          final calories = int.tryParse(_cal.text.trim()) ?? 0;
                          final p = int.tryParse(_p.text.trim()) ?? 0;
                          final c = int.tryParse(_c.text.trim()) ?? 0;
                          final f = int.tryParse(_f.text.trim()) ?? 0;
                          final entry = FoodEntry(
                            name: name,
                            quantity: _qty.text.trim(),
                            calories: calories,
                            protein: p,
                            carbs: c,
                            fat: f,
                          );
                          _addEntry(selectedMeal, entry);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add Food',
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
        backgroundColor: _bgGreen,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'Food',
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

    final progress = (_totalCalories / _dailyGoal).clamp(0, 1).toDouble();
    final remaining = (_dailyGoal - _totalCalories).clamp(0, _dailyGoal);

    return Scaffold(
      backgroundColor: _bgGreen,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Food',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: _darkGreen),
            tooltip: 'Search',
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.person_outline, color: _darkGreen),
            tooltip: 'Profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily Summary Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Daily Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _bgGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_totalCalories',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'of $_dailyGoal kcal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (remaining > 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                '$remaining remaining',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      NutritionPie(protein: _totalProtein, carbs: _totalCarbs, fat: _totalFat, size: 120),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MacroStat(label: 'Protein', value: _totalProtein, color: _primaryGreen),
                      _MacroStat(label: 'Carbs', value: _totalCarbs, color: _lightGreen),
                      _MacroStat(label: 'Fat', value: _totalFat, color: _darkGreen),
                    ],
                  ),
                ],
              ),
            ),
            // Meal Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (final meal in _meals.keys)
                    _buildMealSection(meal, _meals[meal]!),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFoodDialog,
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Food',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildMealSection(String meal, List<FoodEntry> items) {
    final mealCalories = items.fold(0, (sum, e) => sum + e.calories);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Text(
                meal,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              if (mealCalories > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _bgGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$mealCalories kcal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textGreen,
                    ),
                  ),
                ),
            ],
          ),
          children: items.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.restaurant_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'No items added',
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
                ]
              : items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final food = entry.value;
                  return FoodCard(
                    entry: food,
                    onDelete: () => _removeEntry(meal, index),
                    onEdit: () => _showEditDialog(meal, index, food),
                  );
                }).toList(),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(String meal, int index, FoodEntry entry) async {
    final _name = TextEditingController(text: entry.name);
    final _qty = TextEditingController(text: entry.quantity);
    final _cal = TextEditingController(text: entry.calories.toString());
    final _p = TextEditingController(text: entry.protein.toString());
    final _c = TextEditingController(text: entry.carbs.toString());
    final _f = TextEditingController(text: entry.fat.toString());

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
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
                      'Edit Food',
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
                  controller: _name,
                    decoration: InputDecoration(
                      labelText: 'Food Name',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: _bgGreen,
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
                        borderSide: BorderSide(color: _primaryGreen, width: 2),
                      ),
                    ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _qty,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: _bgGreen,
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
                        borderSide: BorderSide(color: _primaryGreen, width: 2),
                      ),
                    ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _cal,
                  keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Calories',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: _bgGreen,
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
                        borderSide: BorderSide(color: _primaryGreen, width: 2),
                      ),
                    ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _p,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Protein (g)',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: _bgGreen,
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
                            borderSide: BorderSide(color: _primaryGreen, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _c,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Carbs (g)',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: _bgGreen,
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
                            borderSide: BorderSide(color: _primaryGreen, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _f,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Fat (g)',
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: _bgGreen,
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
                            borderSide: BorderSide(color: _primaryGreen, width: 2),
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
                        onPressed: () {
                          final name = _name.text.trim();
                          if (name.isEmpty) return;
                          final calories = int.tryParse(_cal.text.trim()) ?? 0;
                          final p = int.tryParse(_p.text.trim()) ?? 0;
                          final c = int.tryParse(_c.text.trim()) ?? 0;
                          final f = int.tryParse(_f.text.trim()) ?? 0;
                          setState(() {
                            _meals[meal]![index] = FoodEntry(
                              name: name,
                              quantity: _qty.text.trim(),
                              calories: calories,
                              protein: p,
                              carbs: c,
                              fat: f,
                              time: entry.time,
                            );
                          });
                          _saveNutritionData();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
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
    );
  }
}

class _MacroStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MacroStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${value}g',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
      ],
    );
  }
}
