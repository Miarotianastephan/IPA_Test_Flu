import 'dart:math';

import 'package:flutter/material.dart';

class WaveformSlider extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final List<double>? amplitudes;
  final ValueChanged<double>? onSeek;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final int? seed; // Seed unique pour générer des waveforms différentes

  const WaveformSlider({
    super.key,
    required this.progress,
    this.amplitudes,
    this.onSeek,
    this.height = 40,
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white24,
    this.seed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (onSeek != null) {
          final box = context.findRenderObject() as RenderBox;
          final localPos = box.globalToLocal(details.globalPosition);
          final seekProgress = (localPos.dx / box.size.width).clamp(0.0, 1.0);
          onSeek!(seekProgress);
        }
      },
      onTapDown: (details) {
        if (onSeek != null) {
          final box = context.findRenderObject() as RenderBox;
          final localPos = box.globalToLocal(details.localPosition);
          final seekProgress = (localPos.dx / box.size.width).clamp(0.0, 1.0);
          onSeek!(seekProgress);
        }
      },
      child: CustomPaint(
        size: Size(double.infinity, height),
        painter: WaveformPainter(
          progress: progress,
          amplitudes: amplitudes ?? _generatePlaceholderAmplitudes(),
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        ),
      ),
    );
  }

  List<double> _generatePlaceholderAmplitudes() {
    final random = Random(seed);
    return List.generate(60, (index) {
      final t = index / 60.0;
      final frequency = 8 + (random.nextDouble() * 4);
      final amplitude = 0.15 + (random.nextDouble() * 0.15);
      final baseline = 0.65 + (random.nextDouble() * 0.2);

      final sineWave = (sin(t * frequency) * amplitude + baseline);
      final noise = (random.nextDouble() - 0.5) * 0.2;
      return (sineWave + noise).clamp(0.2, 1.0);
    });
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;
  final List<double> amplitudes;
  final Color activeColor;
  final Color inactiveColor;

  WaveformPainter({
    required this.progress,
    required this.amplitudes,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barPadding = 2.0;
    final totalBars = amplitudes.length;
    final barWidth = (size.width - (totalBars - 1) * barPadding) / totalBars;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth.clamp(1.5, 3.0);

    for (int i = 0; i < totalBars; i++) {
      final barHeight = size.height * amplitudes[i] * 0.7;
      final x = i * (barWidth + barPadding) + barWidth / 2;
      final centerY = size.height / 2;

      final isPlayed = (i / totalBars) <= progress;
      paint.color = isPlayed ? activeColor : inactiveColor;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.amplitudes != amplitudes ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
