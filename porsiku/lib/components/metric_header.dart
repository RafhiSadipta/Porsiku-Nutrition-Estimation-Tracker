import 'package:flutter/material.dart';
import '../constants/constants.dart';

class MetricHeader extends StatelessWidget {
  final String title;
  final String unit;
  final Color barColor;
  final IconData icon;
  final double currentValue;
  final double changePercent;

  const MetricHeader({
    super.key,
    required this.title,
    required this.unit,
    required this.barColor,
    required this.icon,
    required this.currentValue,
    required this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercent >= 0;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: barColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: barColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.black,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${currentValue.toInt()} $unit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: barColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isPositive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          size: 12,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${changePercent.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
