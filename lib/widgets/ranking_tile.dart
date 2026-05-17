import 'package:flutter/material.dart';
import '../core/themes/app_theme.dart';

class RankingTile extends StatelessWidget {
  final int rank;
  final String flagUrl;
  final String name;
  final String value;
  final IconData medalIcon;

  const RankingTile({
    super.key,
    required this.rank,
    required this.flagUrl,
    required this.name,
    required this.value,
    required this.medalIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Medal or rank number
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppTheme.antiqueGold : AppTheme.mutedBeige,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(medalIcon, color: Colors.white, size: 20)
                  : Text(
                      '$rank',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Flag
          Image.network(flagUrl, width: 36, height: 24, fit: BoxFit.cover),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          // Value
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.dustyBrown,
            ),
          ),
        ],
      ),
    );
  }
}
