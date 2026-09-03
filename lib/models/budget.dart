class Budget {

  final double monthly;

  final Map<String, double> categoryBudgets;

  const Budget({
    this.monthly = 50000,
    this.categoryBudgets = const{},
});

  Map<String, dynamic> toJson() {
    return {
      'monthly': monthly,
      'categoryBudgets': categoryBudgets,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      monthly: (json['monthly'] as num?)?.toDouble() ?? 50000,
      categoryBudgets: Map<String, double>.from(
        (json['categoryBudgets'] as Map?)?.map(
              (key, value) => MapEntry(
            key.toString(),
            (value as num).toDouble(),
          ),
        ) ??
            {},
      ),
    );
  }
}

