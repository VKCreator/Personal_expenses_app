import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './transaction.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    Key? key,
    required this.transaction,
    required this.deleteTransaction,
  }) : super(key: key);

  final UserTransaction transaction;
  final Function deleteTransaction;

  void _delete(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Подтверждение'),
            content: const Text('Вы хотите удалить расход?'),
            actions: [
              TextButton(
                  onPressed: () {
                    deleteTransaction(transaction.id);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Да')),
              TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: const Text('Нет'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(
              child: Text(
                  '${transaction.amount.toStringAsFixed(transaction.amount.truncateToDouble() == transaction.amount ? 0 : 2)}₽'),
            ),
          ),
        ),
        title: Text(
          transaction.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(
          DateFormat('dd MMMM yyyy, EEEE, kk:mm', 'ru')
              .format(transaction.date),
        ),
        trailing: MediaQuery.of(context).size.width > 460
            ? TextButton.icon(
                onPressed: () {
                  _delete(context);
                },
                icon: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                label: Text(
                  'Удалить',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ))
            : IconButton(
                onPressed: () => _delete(context),
                icon: const Icon(Icons.delete),
                color: Theme.of(context).colorScheme.error,
              ),
      ),
    );
  }
}
