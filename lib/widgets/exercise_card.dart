import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise_log.dart';
import '../providers/exercise_provider.dart';

const Color primaryBlue = Color(0xFF0066FF);
const Color lightBlue = Color(0xFFE0F0FF);
const Color darkBlue = Color(0xFF0052CC);

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final VoidCallback? onViewSteps;
  final bool isCompleted;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.onViewSteps,
    this.isCompleted = false,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final isCompleted = widget.isCompleted;

    // Get the current user's fitness level from provider
    final userLevel = context.watch<ExerciseProvider>().userLevel;
    final levelName = _getLevelName(userLevel);
    final setsForLevel = ex.getSetsForLevel(levelName.toLowerCase());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? primaryBlue : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Exercise info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and completion badge
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isCompleted
                                        ? primaryBlue
                                        : Colors.black87,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ex.muscleGroup,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Target info row
                      Row(
                        children: [
                          _InfoChip(
                            label: 'Reps',
                            value: '${ex.targetReps}',
                            icon: Icons.repeat,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            label: 'Sets',
                            value: '$setsForLevel',
                            icon: Icons.layers,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // View Steps button
                      OutlinedButton.icon(
                        onPressed: widget.onViewSteps,
                        icon: const Icon(Icons.play_circle_outline, size: 16),
                        label: const Text('View Steps'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBlue,
                          side: const BorderSide(color: primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side: Square exercise image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryBlue.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/exercises/exercise_${ex.exerciseId}.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: primaryBlue.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLevelName(dynamic level) {
    final levelStr = level.toString();
    if (levelStr.contains('beginner')) return 'Beginner';
    if (levelStr.contains('intermediate')) return 'Intermediate';
    if (levelStr.contains('advanced')) return 'Advanced';
    return 'beginner';
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryBlue.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryBlue),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: darkBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
