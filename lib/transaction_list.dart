import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../transaction.dart';
import './transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<UserTransaction> transactions;
  final Function deleteTransaction;

  const TransactionList(this.transactions, this.deleteTransaction, {super.key});

  Future<void> _showSimpleDialog(context, index) async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Информация о расходе'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Row(children: [
                    const Text(
                      "Название: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(transactions[index].title)
                  ]),
                  Row(children: [
                    const Text(
                      "Категория: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(transactions[index].category)
                  ]),
                  const Text(
                    "Дата и время: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(children: [
                    // const Text(
                    //   "Дата и время: ",
                    //   style: TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    Expanded(
                        child: Text(
                      DateFormat('dd MMMM yyyy, EEEE, kk:mm', 'ru')
                          .format(transactions[index].date),
                      softWrap: true,
                      maxLines: 10,
                    ))
                  ]),
                  Row(children: [
                    const Text(
                      "Стоимость: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ('${transactions[index].amount.toStringAsFixed(transactions[index].amount.truncateToDouble() == transactions[index].amount ? 0 : 2)}₽'),
                    )
                  ]),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('ОК'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return transactions.isEmpty
        ? LayoutBuilder(builder: (ctx, constraints) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_grocery_store_outlined,
                  size: 200,
                  color: Color.fromARGB(255, 199, 196, 196),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text('Список расходов пуст!',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(
                  height: 10,
                )
              ],
            );
          })
        : ListView.builder(
            shrinkWrap: true,
            physics: isLandscape ? const NeverScrollableScrollPhysics() : null,
            itemBuilder: (ctx, index) {
              return GestureDetector(
                  onTap: () {
                    _showSimpleDialog(context, index);
                  },
                  child: TransactionItem(
                      transaction: transactions[index],
                      deleteTransaction: deleteTransaction));
            },
            itemCount: transactions.length,
          );
  }
}
