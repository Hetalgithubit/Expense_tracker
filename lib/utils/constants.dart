import 'package:flutter/material.dart';

class CategoryInfo {
  final String name;
  final String emoji;
  final Color color;

  const CategoryInfo(
      this.name,
      this.emoji,
      this.color,
      );
}

const categories = <CategoryInfo>[
  CategoryInfo(
    'Food',
    '🍔',
    Color(0xFFFF4D55),
  ),

  CategoryInfo(
    'Fuel',
    '⛽',
    Color(0xFF4285F4),
  ),

  CategoryInfo(
    'Shopping',
    '🛍️',
    Color(0xFFE86AF2),
  ),

  CategoryInfo(
    'Bills',
    '🧾',
    Color(0xFFFFA000),
  ),

  CategoryInfo(
    'Health',
    '🩺',
    Color(0xFFFF4D55),
  ),

  CategoryInfo(
    'Entertainment',
    '🍿',
    Color(0xFF9B5DE5),
  ),

  CategoryInfo(
    'Travel',
    '✈️',
    Color(0xFF00B8D4),
  ),

  CategoryInfo(
    'Education',
    '📚',
    Color(0xFFFFC107),
  ),

  CategoryInfo(
    'Rent',
    '🏠',
    Color(0xFF8BC34A),
  ),

  CategoryInfo(
    'Other',
    '📦',
    Color(0xFF9E9E9E),
  ),
];

CategoryInfo categoryInfo(String name) {
  return categories.firstWhere(
      (category) => category.name == name,
    orElse: () => const CategoryInfo(
      'Other',
      '📦',
      Colors.grey,
    ),
  );
}