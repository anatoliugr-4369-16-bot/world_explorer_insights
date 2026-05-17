import 'package:flutter/material.dart';
import '../core/themes/app_theme.dart';

class RegionInsightCard extends StatelessWidget {
  final String regionName;
  final int countryCount;
  final String largestCountry;
  final String mostPopulatedCountry;
  final Color accentColor;

  const RegionInsightCard({
    super.key,
    required this.regionName,
    required this.countryCount,
    required this.largestCountry,
    required this.mostPopulatedCountry,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  regionName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.public, '$countryCount countries'),
            const SizedBox(height: 8),
            _infoRow(Icons.landscape, 'Largest: $largestCountry'),
            const SizedBox(height: 8),
            _infoRow(Icons.people, 'Populated: $mostPopulatedCountry'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.secondaryText),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}
