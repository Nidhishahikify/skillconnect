import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// 1–10 rating slider used on the feedback screen.
class RatingBar extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const RatingBar({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Rate this worker: ${value.toStringAsFixed(1)} / 10'),
        Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: AppColors.primary,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
