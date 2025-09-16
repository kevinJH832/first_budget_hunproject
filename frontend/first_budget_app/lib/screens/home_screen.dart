import 'package:flutter/material.dart';
import 'package:first_budget_app/services/api_service.dart';
import 'calendar_screen.dart';
import 'add_transaction_screen.dart';
import 'package:first_budget_app/widgets/today_summary_card.dart';
import 'package:first_budget_app/widgets/transaction_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<_TodayScreenState> _todayScreenKey = GlobalKey();

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      TodayScreen(key: _todayScreenKey),
      const CalendarScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTransactionSheet() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const AddTransactionScreen();
      },
    );

    if (result == true) {
      _todayScreenKey.currentState?.refreshTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[100],
      body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.today), label: '오늘'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '캘린더',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionSheet,
        backgroundColor: Colors.amber[800],
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late Future<List<Map<String, dynamic>>> _futureTransactions;

  @override
  void initState() {
    super.initState();
    _futureTransactions = fetchTransactions(date: DateTime.now());
  }

  void refreshTransactions() {
    setState(() {
      _futureTransactions = fetchTransactions(date: DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureTransactions,
      builder: (context, snapshot) {
        num totalExpense = 0;
        if (snapshot.hasData) {
          for (var transaction in snapshot.data!) {
            if (transaction['amount'] < 0) {
              totalExpense += transaction['amount'];
            }
          }
        }

        return Column(
          children: [
            TodaySummaryCard(date: DateTime.now(), totalExpense: totalExpense),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '오늘 지출',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            TransactionList(
              futureTransactions: _futureTransactions,
              onRefresh: refreshTransactions,
            ),
          ],
        );
      },
    );
  }
}
