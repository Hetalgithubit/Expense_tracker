import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/constants.dart';

class AppCard extends StatelessWidget {
  final Widget child;

  final EdgeInsets padding;

  final VoidCallback? onTap;

  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding =
    const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color:
          AppColors.border.withOpacity(.8),
        ),
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(16),
      child: content,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  final String? action;

  final VoidCallback? onAction;

  const SectionTitle(
      this.title, {
        super.key,
        this.action,
        this.onAction,
      });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        const Spacer(),

        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final String category;

  final double size;

  const CategoryIcon(
      this.category, {
        super.key,
        this.size = 40,
      });

  @override
  Widget build(BuildContext context) {
    final info =
    categoryInfo(category);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
        Colors.black.withOpacity(.35),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Text(
        info.emoji,
        style: TextStyle(
          fontSize: size * .48,
        ),
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  final double value;

  final Color color;

  const ProgressLine({
    super.key,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(5),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 5,
        backgroundColor:
        const Color(0xFF20283B),
        valueColor:
        AlwaysStoppedAnimation(color),
      ),
    );
  }
}

String money(double value) {
  final isInteger =
      value.truncateToDouble() == value;

  return '₹${value.toStringAsFixed(
    isInteger ? 0 : 2,
  )}';
}

String shortDate(DateTime date) {
  return '${date.day} ${_month(date.month)} ${date.year}';
}

String _month(int month) {
  return const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}

String dateTimeLabel(DateTime date) {
  final hour =
  date.hour % 12 == 0
      ? 12
      : date.hour % 12;

  final minute =
  date.minute.toString().padLeft(
    2,
    '0',
  );

  final suffix =
  date.hour >= 12 ? 'PM' : 'AM';

  return '${shortDate(date)}, '
      '$hour:$minute $suffix';
}