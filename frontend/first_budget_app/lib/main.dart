import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> fetchTransactions() async {
  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/transactions'),
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load transactions from API');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Map<String, dynamic>>> _futureTransactions;

  @override
  void initState() {
    super.initState();
    _futureTransactions = fetchTransactions(); // 위젯이 생성될 때 데이터를 가져오는 함수를 호출합니다.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('나의 가계부')),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureTransactions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final transactions = snapshot.data!;
              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final isIncome = transaction['amount'] > 0;
                  return ListTile(
                    title: Text(transaction['description']),
                    subtitle: Text(transaction['category']),
                    trailing: Text(
                      '${isIncome ? '+' : ''}${transaction['amount']}원',
                      style: TextStyle(
                        color: isIncome ? Colors.blue[600] : Colors.red[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('거래 내역이 없습니다.'));
            }
          },
        ),
      ),
    );
  }
}
