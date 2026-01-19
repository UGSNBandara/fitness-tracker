import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise_card.dart';
import '../models/exercise_log.dart';
import '../models/user_level.dart';
import '../services/firebase_exercise_service.dart';

// Energetic Blue Theme Colors
const Color primaryBlue = Color(0xFF0066FF); // Vibrant blue
const Color lightBlue = Color(0xFFE0F0FF); // Light blue background
const Color darkBlue = Color(0xFF0052CC); // Dark blue
const Color accentBlue = Color(0xFF00B4FF); // Cyan accent

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    final provider = context.read<ExerciseProvider>();

    // Load from local storage first (faster, works offline)
    await provider.loadLogsFromLocalStorage();

    // Then try to sync with Firebase in background
    _loadWorkoutLogsFromFirebase();
  }

  Future<void> _loadWorkoutLogsFromFirebase() async {
    try {
      final provider = context.read<ExerciseProvider>();
      final logsData = await FirebaseExerciseService.instance.getWorkoutLogs();

      // Get today's date for filtering
      final today = DateTime.now();
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      // Filter logs for current week and convert to ExerciseLog objects
      for (final logData in logsData) {
        try {
          // Find the exercise by exerciseId from Firebase data
          final exerciseId = logData['exerciseId'] as String?;
          final exerciseName = logData['exerciseName'] as String?;

          Exercise? exercise;
          if (exerciseId != null) {
            exercise = provider.exercises.firstWhere(
              (ex) => ex.exerciseId == exerciseId,
              orElse: () => Exercise(
                exerciseId: exerciseId,
                name: exerciseName ?? 'Unknown',
                muscleGroup: 'Unknown',
                steps: [],
                targetReps: 0,
                targetSets: 0,
                caloriesPerSet: 0,
              ),
            );
          }

          if (exercise != null) {
            final log = ExerciseLog.fromFirestore(logData, exercise);
            if (log.start.isAfter(startOfWeek) &&
                log.start.isBefore(endOfWeek.add(const Duration(days: 1)))) {
              provider.addLogFromFirebase(log);
            }
          }
        } catch (e) {
          debugPrint('Error converting log: $e');
        }
      }

      // Notify listeners once after all logs are added
      provider.notifyFirebaseLogsLoaded();
    } catch (e) {
      debugPrint('Error loading workout logs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Auto-calculate current day (0=Monday, 6=Sunday)
    final currentDay = (DateTime.now().weekday - 1) % 7;

    return Consumer<ExerciseProvider>(
      builder: (context, provider, _) {
        final exercises = provider.currentWeekExercises;
        final progress = provider.weekProgress;

        return Scaffold(
          backgroundColor: lightBlue,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              'Exercise',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showHistoryDialog(context),
                icon: const Icon(Icons.bar_chart, color: primaryBlue),
                tooltip: 'Workout History',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_outline, color: primaryBlue),
                tooltip: 'Profile',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Merged Level & Progress Card (Compact)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Level info (left)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getLevelName(provider.userLevel),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Week ${provider.currentWeek + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // Progress bar and percentage (center-right)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: const AlwaysStoppedAnimation(
                                    primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Advance button (right)
                      if (provider.canAdvanceLevel())
                        SizedBox(
                          width: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              provider.advanceLevel();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🚀 Advanced to ${_getLevelName(provider.userLevel)}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  backgroundColor: primaryBlue,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Level Up',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Exercises list for today
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Exercises (${days[currentDay]})",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: exercises.length,
                        itemBuilder: (context, i) {
                          final ex = exercises[i];
                          final today = DateTime.now();
                          final startOfToday = DateTime(
                            today.year,
                            today.month,
                            today.day,
                          );
                          final endOfToday = startOfToday.add(
                            const Duration(days: 1),
                          );

                          // Check if exercise was completed TODAY
                          final isCompleted =
                              Provider.of<ExerciseProvider>(
                                context,
                                listen: false,
                              ).logs.any(
                                (log) =>
                                    log.exercise.exerciseId == ex.exerciseId &&
                                    log.start.isAfter(startOfToday) &&
                                    log.start.isBefore(endOfToday),
                              );

                          return ExerciseCard(
                            exercise: ex,
                            onTap: () => _showLogDialog(
                              context,
                              provider,
                              ex,
                              currentDay,
                            ),
                            onViewSteps: () => _showStepsDialog(context, ex),
                            isCompleted: isCompleted,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStepsDialog(BuildContext context, Exercise ex) {
    if (ex.steps.isEmpty) return;

    final videoId = _extractYouTubeId(ex.steps.first);
    if (videoId == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ex.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: videoId,
                    flags: const YoutubePlayerFlags(autoPlay: false),
                  ),
                  showVideoProgressIndicator: true,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Target: ${ex.targetReps} reps × ${ex.targetSets} sets',
                          style: const TextStyle(
                            fontSize: 14,
                            color: darkBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
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

  void _showLogDialog(
    BuildContext context,
    ExerciseProvider provider,
    Exercise ex,
    int dayIndex,
  ) {
    showDialog(
      context: context,
      builder: (context) => _ExerciseMarkingDialog(
        exercise: ex,
        dayIndex: dayIndex,
        provider: provider,
      ),
    );
  }

  String? _extractYouTubeId(String url) {
    try {
      return YoutubePlayer.convertUrlToId(url);
    } catch (_) {
      return null;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Get fitness level name
  String _getLevelName(UserLevel level) {
    switch (level) {
      case UserLevel.beginner:
        return 'Beginner';
      case UserLevel.intermediate:
        return 'Intermediate';
      case UserLevel.advanced:
        return 'Advanced';
    }
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
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
                      'Workout History',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats Cards
                FutureBuilder<Map<String, dynamic>>(
                  future: _getWorkoutStats(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final stats = snapshot.data!;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Total Workouts',
                                value: '${stats['totalWorkouts']}',
                                icon: Icons.fitness_center,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Total Calories',
                                value: '${stats['totalCalories']}',
                                unit: 'cal',
                                icon: Icons.local_fire_department,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Total Time',
                                value: '${stats['totalMinutes']}',
                                unit: 'min',
                                icon: Icons.schedule,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Avg Calories',
                                value: '${stats['averageCaloriesPerWorkout']}',
                                unit: 'per',
                                icon: Icons.show_chart,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Recent Workouts
                const Text(
                  'Recent Workouts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _getRecentWorkouts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final logs = snapshot.data!;
                    if (logs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No workouts yet. Start exercising!',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: logs.length.clamp(0, 10),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryBlue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log['exerciseName'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'RPE: ${log['rpe']} | Reps: ${log['repsDone']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '🔥 ${log['caloriesBurned']} cal',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryBlue,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${log['duration']} min',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getWorkoutStats() async {
    try {
      final stats = await FirebaseExerciseService.instance.getWorkoutStats();
      return stats;
    } catch (e) {
      return {
        'totalWorkouts': 0,
        'totalCalories': 0,
        'totalMinutes': 0,
        'averageCaloriesPerWorkout': 0,
      };
    }
  }

  Future<List<Map<String, dynamic>>> _getRecentWorkouts() async {
    try {
      final logs = await FirebaseExerciseService.instance.getWorkoutLogs();
      return logs;
    } catch (e) {
      return [];
    }
  }
}

// Exercise Marking Dialog with Set Trackers
class _ExerciseMarkingDialog extends StatefulWidget {
  final Exercise exercise;
  final int dayIndex;
  final ExerciseProvider provider;

  const _ExerciseMarkingDialog({
    required this.exercise,
    required this.dayIndex,
    required this.provider,
  });

  @override
  State<_ExerciseMarkingDialog> createState() => _ExerciseMarkingDialogState();
}

class _ExerciseMarkingDialogState extends State<_ExerciseMarkingDialog> {
  late List<bool> _completedSets;
  double _rpeValue = 5.0;

  @override
  void initState() {
    super.initState();
    _completedSets = List.filled(widget.exercise.targetSets, false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool get _allSetsCompleted => _completedSets.every((completed) => completed);
  int get _completedCount => _completedSets.where((c) => c).length;

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ex.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ex.muscleGroup,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Exercise Image
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primaryBlue.withOpacity(0.3)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/exercises/exercise_${ex.exerciseId}.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: primaryBlue.withOpacity(0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Exercise Image',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Target info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Target Reps',
                          style: TextStyle(fontSize: 12, color: darkBlue),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ex.targetReps}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: primaryBlue.withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        const Text(
                          'Total Sets',
                          style: TextStyle(fontSize: 12, color: darkBlue),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ex.targetSets}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Set markers
              const Text(
                'Mark Completed Sets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(ex.targetSets, (index) {
                  final isCompleted = _completedSets[index];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _completedSets[index] = !isCompleted),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isCompleted ? primaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCompleted
                              ? primaryBlue
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isCompleted
                                ? Colors.white
                                : Colors.grey.shade400,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Set ${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // RPE Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RPE (Rate of Perceived Exertion)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _rpeValue,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _rpeValue.round().toString(),
                    activeColor: primaryBlue,
                    inactiveColor: Colors.grey.shade300,
                    onChanged: (value) {
                      setState(() {
                        _rpeValue = value;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1 (Easy)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${_rpeValue.round()}',
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '10 (Max Effort)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Complete All Button (shows when all sets are checked)
              if (_allSetsCompleted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final rpe = _rpeValue.round();
                      widget.provider.completeExerciseWithLog(
                        exerciseId: ex.exerciseId,
                        dayIndex: widget.dayIndex,
                        repsDone: ex.targetReps * ex.targetSets,
                        rpe: rpe,
                        setsDone: _completedCount,
                      );

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✅ ${ex.name} completed! 🔥 ${ex.calculateTotalCalories(_completedCount)} cal',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: primaryBlue,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: const Text(
                      'Mark All Done',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                )
              else
                Text(
                  'Complete $_completedCount/${ex.targetSets} sets',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color color;

  const _StatCard({
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
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
                color: color.withOpacity(0.7),
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
