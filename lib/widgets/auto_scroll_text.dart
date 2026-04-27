import 'package:marquee/marquee.dart';
import 'package:flutter/material.dart';

class AutoScrollText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const AutoScrollText({super.key, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: double.infinity);
        final textWidth = textPainter.width;
        final boxWidth = constraints.maxWidth;
        if (textWidth > boxWidth) {
          return SizedBox(
            height: style.fontSize! * 1.4,
            child: Marquee(
              text: text,
              style: style,
              scrollAxis: Axis.horizontal,
              blankSpace: 50.0,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 1),
            ),
          );
        }
        return Text(text, style: style, overflow: TextOverflow.ellipsis);
      },
    );
  }
}
