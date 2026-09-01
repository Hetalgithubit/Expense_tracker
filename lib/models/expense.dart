import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final String paymentMethod;
  final DateTime date;
  final String note;
  final bool isIncome;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.date,
    this.note = '',
    this.isIncome = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'note': note,
      'isIncome': isIncome,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(
      Map<String, dynamic> json,
      ) {
    final now = DateTime.now();

    return Expense(
      id: json['id']?.toString() ?? '',
      userId:
      (json['userId'] ??
          json['user_id'] ??
          '')
          .toString(),
      title:
      json['title']?.toString() ?? '',
      amount:
      (json['amount'] as num?)
          ?.toDouble() ??
          0,
      category:
      json['category']?.toString() ??
          '',
      paymentMethod:
      (json['paymentMethod'] ??
          json['payment'] ??
          'UPI')
          .toString(),
      date: _parseDate(
        json['date'],
        now,
      ),
      note:
      json['note']?.toString() ?? '',
      isIncome:
      json['isIncome'] == true ||
          json['isIncome'] == 1,
      createdAt: _parseDate(
        json['createdAt'],
        now,
      ),
      updatedAt: _parseDate(
        json['updatedAt'],
        now,
      ),
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'date': Timestamp.fromDate(date),
      'note': note,
      'isIncome': isIncome,
      'createdAt':
      Timestamp.fromDate(createdAt),
      'updatedAt':
      Timestamp.fromDate(updatedAt),
    };
  }

  factory Expense.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>>
      snapshot,
      ) {
    final data = snapshot.data();

    if (data == null) {
      throw Exception(
        'Expense data not found.',
      );
    }

    final now = DateTime.now();

    return Expense(
      id:
      data['id']?.toString() ??
          snapshot.id,
      userId:
      data['userId']?.toString() ??
          '',
      title:
      data['title']?.toString() ??
          '',
      amount:
      (data['amount'] as num?)
          ?.toDouble() ??
          0,
      category:
      data['category']?.toString() ??
          '',
      paymentMethod:
      data['paymentMethod']
          ?.toString() ??
          'UPI',
      date: _parseFirestoreDate(
        data['date'],
        now,
      ),
      note:
      data['note']?.toString() ?? '',
      isIncome:
      data['isIncome'] == true ||
          data['isIncome'] == 1,
      createdAt:
      _parseFirestoreDate(
        data['createdAt'],
        now,
      ),
      updatedAt:
      _parseFirestoreDate(
        data['updatedAt'],
        now,
      ),
    );
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'payment_method': paymentMethod,
      'date': date.toIso8601String(),
      'note': note,
      'is_income':
      isIncome ? 1 : 0,
      'created_at':
      createdAt.toIso8601String(),
      'updated_at':
      updatedAt.toIso8601String(),
    };
  }

  factory Expense.fromDatabaseMap(
      Map<String, dynamic> map,
      ) {
    final now = DateTime.now();

    return Expense(
      id: map['id'] as String,
      userId:
      map['user_id'] as String,
      title:
      map['title'] as String,
      amount:
      (map['amount'] as num)
          .toDouble(),
      category:
      map['category'] as String,
      paymentMethod:
      (map['payment_method'] ??
          'UPI')
      as String,
      date: DateTime.parse(
        map['date'] as String,
      ),
      note:
      (map['note'] ?? '')
      as String,
      isIncome:
      (map['is_income'] ?? 0) == 1,
      createdAt:
      map['created_at'] != null
          ? DateTime.parse(
        map['created_at']
        as String,
      )
          : now,
      updatedAt:
      map['updated_at'] != null
          ? DateTime.parse(
        map['updated_at']
        as String,
      )
          : now,
    );
  }

  Expense copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    String? category,
    String? paymentMethod,
    DateTime? date,
    String? note,
    bool? isIncome,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId:
      userId ?? this.userId,
      title:
      title ?? this.title,
      amount:
      amount ?? this.amount,
      category:
      category ?? this.category,
      paymentMethod:
      paymentMethod ??
          this.paymentMethod,
      date:
      date ?? this.date,
      note:
      note ?? this.note,
      isIncome:
      isIncome ?? this.isIncome,
      createdAt:
      createdAt ??
          this.createdAt,
      updatedAt:
      updatedAt ??
          this.updatedAt,
    );
  }

  static DateTime _parseDate(
      dynamic value,
      DateTime fallback,
      ) {
    if (value is DateTime) {
      return value;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value) ??
          fallback;
    }

    return fallback;
  }

  static DateTime _parseFirestoreDate(
      dynamic value,
      DateTime fallback,
      ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ??
          fallback;
    }

    return fallback;
  }
}