import 'package:flutter/material.dart';
import 'dart:math';

// Blue Theme Colors
const Color primaryBlue = Color(0xFF0066FF);
const Color darkBlue = Color(0xFF0052CC);
const Color lightBlue = Color(0xFF4D94FF);

class NutritionPie extends StatelessWidget {
  final int protein;
  final int carbs;
  final int fat;
  final double size;

  const NutritionPie({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final total = (protein + carbs + fat).toDouble();
    final p = total == 0 ? 0.0 : protein / total;
    final c = total == 0 ? 0.0 : carbs / total;
    final f = total == 0 ? 0.0 : fat / total;

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _PiePainter(p, c, f),
              ),
              if (total > 0)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${total.toInt()}g',
                      style: TextStyle(
                        fontSize: size * 0.15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: size * 0.08,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Legend(color: darkBlue, label: 'P', value: protein),
            const SizedBox(width: 12),
            _Legend(color: primaryBlue, label: 'C', value: carbs),
            const SizedBox(width: 12),
            _Legend(color: lightBlue, label: 'F', value: fat),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: primaryBlue.withOpacity(0.3), width: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
        Text(
          '${value}g',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  final double p;
  final double c;
  final double f;
  _PiePainter(this.p, this.c, this.f);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    double start = -pi / 2;

    // Draw protein (darkest blue)
    if (p > 0) {
      paint.color = darkBlue;
      final sweep = p * 2 * pi;
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
    }

    // Draw carbs (primary blue)
    if (c > 0) {
      paint.color = primaryBlue;
      final sweep = c * 2 * pi;
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
    }

    // Draw fat (light blue)
    if (f > 0) {
      paint.color = lightBlue;
      final sweep = f * 2 * pi;
      canvas.drawArc(rect, start, sweep, true, paint);
    }

    // Draw inner circle for donut effect
    if (p + c + f > 0) {
      paint.color = Colors.white;
      canvas.drawCircle(center, radius * 0.65, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
