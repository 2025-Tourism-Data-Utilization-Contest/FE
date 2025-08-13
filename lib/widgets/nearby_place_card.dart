import 'package:flutter/material.dart';

class NearbyPlaceCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String? distanceString;

  const NearbyPlaceCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.distanceString,
  });

  String get displayDistance {
    final meters = double.tryParse(distanceString ?? '');
    if (meters == null) return '-';
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    } else {
      return '${meters.toStringAsFixed(0)}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagePath,
              height: 180,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 40),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            displayDistance,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
