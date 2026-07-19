import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Summary card for a worker shown in search/browse lists.
class WorkerCard extends StatelessWidget {
  final String name;
  final String skill;
  final String location;
  final String availability;
  final String rating;
  final String summary;
  final VoidCallback onTap;

  const WorkerCard({
    super.key,
    required this.name,
    required this.skill,
    required this.location,
    required this.availability,
    required this.rating,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Icon(Icons.handyman, color: Colors.white),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        '$skill • $location • $availability\n⭐ $rating  $summary',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
