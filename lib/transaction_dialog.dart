import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:time_picker_widget/time_picker_widget.dart';

class NewTransaction extends StatefulWidget {
  const NewTransaction({super.key});

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  // final _amountController = TextEditingController();

  DateTime? _selectedDate;
  double _enteredAmount = 0;
  String _enteredCategory = "Продукты";

  bool _validateName = true;
  bool _firstOpen = true;

  final List<String> _categories = <String>[
    'Дом и быт',
    'Доставка',
    'Кафе и рестораны',
    'Медицина',
    'Образование',
    'Одежда',
    'Продукты'
  ];

  final _icons = {
    'Дом и быт': Icons.home,
    'Доставка': Icons.delivery_dining,
    'Кафе и рестораны': Icons.restaurant,
    'Медицина': Icons.health_and_safety,
    'Образование': Icons.cast_for_education,
    'Одежда': Icons.shopping_bag,
    'Продукты': Icons.store
  };

  void _submitData() {
    Navigator.of(context).pop({
      "title": _titleController.text,
      "category": _enteredCategory,
      "amount": _enteredAmount,
      "date": _selectedDate
    });
  }

  void _openDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      locale: const Locale("ru", "RU"),
    );

    if (pickedDate == null) return;

    var isEqualDate = DateFormat('yyyy-MM-dd').format(pickedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

// 1
    // TimeOfDay? pickedTime = await showCustomTimePicker(
    //     context: context,
    //     onFailValidation: (context) => _showMyDialog(),
    //     initialTime: TimeOfDay.now(),
    //     selectableTimePredicate: (time) =>
    //         isEqualDate &&
    //             (time!.hour < TimeOfDay.now().hour ||
    //                 time!.hour == TimeOfDay.now().hour &&
    //                     time!.minute <= TimeOfDay.now().minute) ||
    //         !isEqualDate);
// 2
    bool isValidTime = false;
    TimeOfDay? pickedTime;
    while (!isValidTime) {
      pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());

      if (pickedTime == null) return;

      isValidTime = isEqualDate &&
              (pickedTime.hour < TimeOfDay.now().hour ||
                  pickedTime.hour == TimeOfDay.now().hour &&
                      pickedTime.minute <= TimeOfDay.now().minute) ||
          !isEqualDate;

      if (!isValidTime) await _showMyDialog();
    }

    setState(() {
      _selectedDate = DateTime(pickedDate.year, pickedDate.month,
          pickedDate.day, pickedTime!.hour, pickedTime.minute);
    });
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Внимание'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Будущее время выбрать нельзя. Пожалуйста, повторите ввод.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ОК'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
            top: 10,
            left: 10,
            right: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const SizedBox(
                  child: Text(
                "Добавление нового расхода",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )),
              const Divider(
                height: 15,
                thickness: 1,
                indent: 20,
                endIndent: 20,
                color: Colors.grey,
              ),
              TextField(
                decoration: InputDecoration(
                    labelText: 'Название',
                    errorText:
                        !_validateName ? "Поле не может быть пустым!" : null),
                controller: _titleController,
                onChanged: (value) => {
                  setState(() {
                    _validateName = value.isNotEmpty;
                    _firstOpen = false;
                  })
                },
                maxLength: 100,
              ),
              const SizedBox(
                height: 20,
              ),
              InputDecorator(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 5.0),
                  labelText: 'Категория',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _enteredCategory,
                    icon: const Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    // style: const TextStyle(color: Colors.black),
                    onChanged: (String? newValue) {
                      setState(() {
                        _enteredCategory = newValue!;
                      });
                    },
                    items: _categories
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(children: [
                          Icon(_icons[value]),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(value)
                        ]),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SpinBox(
                max: 1000000000.0,
                min: 0.0,
                value: _enteredAmount,
                decimals: 2,
                step: 0.1,
                decoration: const InputDecoration(labelText: 'Стоимость'),
                onChanged: (value) => {_enteredAmount = value},
              ),
              SizedBox(
                height: 70,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Дата не установлена!'
                            : 'Дата транзакции: ${DateFormat('dd-MM-yyyy – kk:mm').format(_selectedDate!)}',
                      ),
                    ),
                    TextButton(
                      onPressed: _openDatePicker,
                      child: const Text('Выбрать дату'),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _validateName && !_firstOpen && _selectedDate != null
                    ? _submitData
                    : null,
                child: const Text('Добавить расход'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
