import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './chart_bar.dart';
import './transaction.dart';

enum StateSum {
  allSum,
  sevenDaysSum,
}

class Chart extends StatelessWidget {
  final List<UserTransaction> recentTransactions;
  StateSum st = StateSum.sevenDaysSum;

  Chart(this.recentTransactions, this.st, {super.key});

  List<Map<String, Object>> get allTransactionsValues {
    Map<String, double> weekDaysSum = {
      "пн": 0.0,
      "вт": 0.0,
      "ср": 0.0,
      "чт": 0.0,
      "пт": 0.0,
      "сб": 0.0,
      "вс": 0.0,
    };

    for (var i = 0; i < recentTransactions.length; ++i) {
      String nameDay =
          DateFormat.E('ru').format(recentTransactions[i].date).substring(0, 2);
      weekDaysSum[nameDay] =
          recentTransactions[i].amount + weekDaysSum[nameDay]!;
    }

    List<Map<String, Object>> listWeekDaysSum = [];
    for (final key in weekDaysSum.keys) {
      Map<String, Object> tmp = {'day': key, 'amount': weekDaysSum[key]!};

      listWeekDaysSum.add(tmp);
    }

    return listWeekDaysSum;
  }

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
    List<Map<String, Object>> tmpLst = (st == StateSum.allSum)
        ? allTransactionsValues
        : groupedTransactionsValues;

    return tmpLst.fold(0.0, (sum, item) {
      return sum + (item['amount'] as double);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, Object>> tmpLst = (st == StateSum.allSum)
        ? allTransactionsValues
        : groupedTransactionsValues;
    return Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tmpLst.map((data) {
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
