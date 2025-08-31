import 'package:flutter/material.dart';
import 'package:first_budget_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _futureTransactions;

  @override
  void initState() {
    super.initState();
    _futureTransactions = fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('나의 가계부')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
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
      ),
    );
  }
}
