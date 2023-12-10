import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './chart_bar.dart';
import './transaction.dart';

class Chart extends StatelessWidget {
  final List<UserTransaction> recentTransactions;

  const Chart(this.recentTransactions, {super.key});

  List<Map<String, Object>> get groupedTransactionsValues {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(
        Duration(days: index),
      );

      double totalSum = 0.0;

      for (var i = 0; i < recentTransactions.length; i++) {
        if (recentTransactions[i].date.day == weekDay.day &&
            recentTransactions[i].date.month == weekDay.month &&
            recentTransactions[i].date.year == weekDay.year) {
          totalSum += recentTransactions[i].amount;
        }
      }

      return {
        'day': DateFormat.E('ru').format(weekDay).substring(0, 2),
        'amount': totalSum,
      };
    }).reversed.toList();
  }

  double get totalSpending {
    return groupedTransactionsValues.fold(0.0, (sum, item) {
      return sum + (item['amount'] as double);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: groupedTransactionsValues.map((data) {
              return Flexible(
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: ChartBar(
                      data['day'].toString(),
                      (data['amount'] as double),
                      totalSpending == 0.0
                          ? 0.0
                          : (data['amount'] as double) / totalSpending,
                    ),
                  ));
            }).toList(),
          ),
        ));
  }
}
