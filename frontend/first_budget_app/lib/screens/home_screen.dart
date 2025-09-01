import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'package:first_budget_app/services/api_service.dart';
import 'add_transaction_screen.dart';

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
      appBar: AppBar(title: const Text('나의 가계부')),
      body: _widgetOptions.elementAt(_selectedIndex),
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
    _futureTransactions = fetchTransactions();
  }

  void refreshTransactions() {
    setState(() {
      _futureTransactions = fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureTransactions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        } else if (snapshot.hasData) {
          final transactions = snapshot.data!;
          if (transactions.isEmpty) {
            return const Center(child: Text('거래 내역이 없습니다.'));
          }
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final bool isIncome = transaction['amount'] > 0;
              return ListTile(
                leading: Icon(
                  isIncome ? Icons.add_circle : Icons.remove_circle,
                  color: isIncome ? Colors.blue : Colors.red,
                ),
                title: Text(transaction['description'] ?? '내역 없음'),
                subtitle: Text(transaction['category'] ?? '카테고리 없음'),
                trailing: Text(
                  '${isIncome ? '+' : ''}${transaction['amount'] ?? 0}원',
                  style: TextStyle(
                    color: isIncome ? Colors.blue : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('데이터가 없습니다.'));
        }
      },
    );
  }
}
