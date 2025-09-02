import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'package:first_budget_app/services/api_service.dart';
import 'add_transaction_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
      backgroundColor: Colors.grey[100],

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

// =================================================================

// TodayScreen 클래스 시작

// =================================================================

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

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case '식비':
        return Icons.restaurant;

      case '생활비':
        return Icons.shopping_cart;

      case '정기결제':
        return Icons.credit_card;

      case '유흥':
        return Icons.sports_esports;

      default:
        return Icons.receipt_long;
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,

      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),

          content: const Text('해당 내역을 삭제할까요?'),

          actions: <Widget>[
            TextButton(
              child: const Text('취소'),

              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),

            TextButton(
              child: const Text('삭제'),

              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureTransactions,

      builder: (context, snapshot) {
        // 총 지출 계산

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
            // =================================================================

            // 상단 달력 카드 영역 - 애플 캘린더 스타일

            // =================================================================
            Container(
              height: screenHeight * 0.20, // 약간 더 크게

              width: double.infinity,

              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

              child: AspectRatio(
                aspectRatio: 1.2, // 정사각형에 가까운 비율

                child: Card(
                  elevation: 0,

                  color: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),

                    side: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),

                      width: 0.5,
                    ),
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),

                    child: Column(
                      children: [
                        // 상단 빨간색 영역 - 애플 캘린더 색상
                        Container(
                          height: 35, // 고정 높이

                          width: double.infinity,

                          color: const Color(0xFFFF3B30), // 애플 시스템 빨강

                          child: Center(
                            child: Text(
                              DateFormat(
                                'MMMM',

                                'en_US',
                              ).format(DateTime.now()).toUpperCase(),

                              style: const TextStyle(
                                color: Colors.white,

                                fontSize: 13,

                                fontWeight: FontWeight.w600,

                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: Container(
                            color: Colors.white,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('d').format(DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight:
                                        FontWeight.w300, // 애플 캘린더는 얇은 폰트
                                    color: Colors.black,
                                    height: 1.0,
                                  ),
                                ),
                                if (totalExpense != 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      NumberFormat(
                                        '#,###',
                                      ).format(totalExpense),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

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

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureTransactions,

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final transactions = snapshot.data!;

                    if (transactions.isEmpty) {
                      return const Center(child: Text('거래 내역이 없습니다.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Slidable(
                            key: Key(transaction['id'].toString()),
                            closeOnScroll: true,
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.4,
                              children: [
                                SlidableAction(
                                  flex: 2,
                                  onPressed: (context) async {
                                    final result = await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return AddTransactionScreen(
                                          transaction: transaction,
                                          isEdit: true,
                                        );
                                      },
                                    );
                                    if (result == true) {
                                      setState(() {
                                        _futureTransactions = fetchTransactions(
                                          date: DateTime.now(),
                                        );
                                      });
                                    }
                                  },
                                  backgroundColor: const Color(0xFF007AFF),
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit_outlined,
                                  label: '수정',
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),

                                SlidableAction(
                                  flex: 2,
                                  onPressed: (context) async {
                                    final shouldDelete =
                                        await _showDeleteConfirmationDialog();
                                    if (shouldDelete == true) {
                                      deleteTransaction(transaction['id']);
                                      setState(() {
                                        transactions.removeAt(index);
                                      });
                                    }
                                  },
                                  backgroundColor: const Color(0xFFFF3B30),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_outlined,
                                  label: '삭제',
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getCategoryIcon(transaction['category']),
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 16),
                                    // 중앙 텍스트 (설명 + 카테고리)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction['description'] ??
                                                '내역 없음',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            transaction['category'] ??
                                                '카테고리 없음',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 오른쪽 금액
                                    Text(
                                      '${NumberFormat('#,###').format(transaction['amount'] ?? 0)}원',

                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
            ),
          ],
        );
      },
    );
  }
}
