import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartBar extends StatelessWidget {
  final String label;
  final double spendingAmount;
  final double spendingPctOfTotal;

  const ChartBar(this.label, this.spendingAmount, this.spendingPctOfTotal,
      {super.key});

  TextStyle _getHighlightLabel() {
    TextStyle weekDayStyle = const TextStyle();
    var isCurrentWeekDay =
        DateFormat('EE', 'ru').format(DateTime.now()) == label;

    if (label == "вс" || label == "сб") {
      if (isCurrentWeekDay) {
        weekDayStyle = const TextStyle(
            color: Colors.red, decoration: TextDecoration.underline);
      } else {
        weekDayStyle = const TextStyle(color: Colors.red);
      }
    } else if (isCurrentWeekDay) {
      weekDayStyle = const TextStyle(decoration: TextDecoration.underline);
    }
    return weekDayStyle;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Column(
          children: [
            SizedBox(
              height: constraints.maxHeight * 0.15,
              child: FittedBox(
                child: Text('${spendingAmount.toStringAsFixed(0)}₽'),
              ),
            ),
            SizedBox(
              height: constraints.maxHeight * 0.05,
            ),
            SizedBox(
              height: constraints.maxHeight * 0.6,
              width: 10,
              child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      color: const Color.fromRGBO(220, 220, 220, 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    heightFactor: spendingPctOfTotal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: constraints.maxHeight * 0.05,
            ),
            SizedBox(
              height: constraints.maxHeight * 0.15,
              child: FittedBox(child: Text(label, style: _getHighlightLabel())),
            ),
          ],
        );
      },
    );
  }
}
