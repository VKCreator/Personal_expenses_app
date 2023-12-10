class UserTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  UserTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'category': category,
    };
  }
}
