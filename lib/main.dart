import 'package:flutter/material.dart';

import './transaction.dart';
import './transaction_dialog.dart';
import './transaction_list.dart';
import './chart.dart';
import './database.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Personal Expenses App",
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru', "RU")],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseApp? db;
  List<UserTransaction> _userTransactions = [];

  bool _showChart = true;
  StateSum _st = StateSum.sevenDaysSum;

  Future<bool> readDatabase() async {
    if (db == null) {
      db = DatabaseApp();
      await db!.connectDB();
      FlutterNativeSplash.remove();
    }

    dynamic userTransactions = await db!.getAllTransactions();

    late bool isSuccess;
    if (userTransactions != null) {
      _userTransactions = userTransactions;
      isSuccess = true;
    } else {
      isSuccess = false;
    }

    return isSuccess;
  }

  void _showModalBottomSheetForNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: const NewTransaction(),
        );
      },
    ).then((dataNewTransaction) => {
          if (dataNewTransaction != null) _insertTransaction(dataNewTransaction)
        });
  }

  void _deleteTransaction(String id) {
    db!.deleteTransaction(id);

    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  Future<void> _insertTransaction(tr) async {
    var newId = await db!.insertTransaction(tr);

    UserTransaction newTrans = UserTransaction(
        title: tr["title"],
        amount: tr["amount"],
        date: tr["date"],
        category: tr["category"],
        id: newId);

    setState(() {
      _userTransactions.add(newTrans);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Мои расходы'),
        actions: [
          PopupMenuButton(onSelected: (value) {
            setState(() {
              if (value == "changeStateDiagram")
                _showChart = !_showChart;
              else {
                if (_st == StateSum.allSum)
                  _st = StateSum.sevenDaysSum;
                else
                  _st = StateSum.allSum;
              }
            });
          }, itemBuilder: (BuildContext bc) {
            return [
              PopupMenuItem(
                value: "changeStateDiagram",
                child: Text("${_showChart ? "Скрыть" : "Показать"} диаграмму"),
              ),
              const PopupMenuItem(
                value: "changeSumDiagram",
                child: Text("Переключить диаграмму"),
              ),
            ];
          })
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        // elevation: 5,
        color: Colors.green,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: AppBar().preferredSize.height,
        ),
      ),
      body: FutureBuilder<bool>(
        future: readDatabase(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            final mediaQuery = MediaQuery.of(context);

            if (_showChart) {
              children.add(Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                      _st == StateSum.sevenDaysSum
                          ? "Расходы за последние 7 дней"
                          : "Расходы за все время по дням недели",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500))));
              children.add(SizedBox(
                // width: 500,
                height: isLandscape
                    ? (mediaQuery.size.height -
                            AppBar().preferredSize.height -
                            mediaQuery.padding.top) *
                        0.9
                    : (mediaQuery.size.height -
                            AppBar().preferredSize.height -
                            mediaQuery.padding.top) *
                        0.28,
                child: Chart(_userTransactions, _st),
              ));
            }
            if (_userTransactions.isNotEmpty) {
              children.add(const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Список расходов за все время",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500))));
            }
            !isLandscape
                ? children.add(Expanded(
                    child:
                        TransactionList(_userTransactions, _deleteTransaction)))
                : children.add(
                    TransactionList(_userTransactions, _deleteTransaction));
            // children
            //     .add(TransactionList(_userTransactions, _deleteTransaction));
          } else if (snapshot.hasError) {
            children = [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Ошибка: ${snapshot.error}'),
              )
            ];
          } else {
            children = [const CircularProgressIndicator()];
          }

          return isLandscape
              ? SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: children))
              : Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: children));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showModalBottomSheetForNewTransaction(context),
        tooltip: 'Добавить расход',
        child: const Icon(Icons.add),
      ),
    );
  }
}
