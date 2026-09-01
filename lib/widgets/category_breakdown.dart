import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/constants.dart';
import 'common_widgets.dart';

class CategoryBreakdown
    extends StatelessWidget {
  final Map<String, double> totals;

  final bool compact;

  const CategoryBreakdown({
    super.key,
    required this.totals,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final entries =
    totals.entries.toList()
      ..sort(
            (a, b) =>
            b.value.compareTo(a.value),
      );

    final total = entries.fold(
      0.0,
          (sum, item) => sum + item.value,
    );

    return Column(
      children:
      entries.map((entry) {
        final info =
        categoryInfo(entry.key);

        final percent =
        total == 0
            ? 0
            : entry.value / total;

        return Padding(
          padding:
          const EdgeInsets.only(
            bottom: 10,
          ),
          child: Row(
            children: [
              CategoryIcon(
                entry.key,
                size:
                compact ? 28 : 34,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize:
                              compact
                                  ? 12
                                  : 13,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),

                        Text(
                          money(entry.value),
                          style: TextStyle(
                            fontSize:
                            compact
                                ? 11
                                : 12,
                            color:
                            compact
                                ? AppColors.muted
                                : AppColors.text,
                          ),
                        ),

                        if (!compact) ...[
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            '${(percent * 100).round()}%',
                            style:
                            const TextStyle(
                              color:
                              AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    ProgressLine(
                      value: percent.toDouble(),
                      color: info.color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}