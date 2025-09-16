import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; //투명 글래스 ui 추가부분!

import 'package:first_budget_app/services/api_service.dart';
import 'package:first_budget_app/widgets/transaction_list_item.dart';
import 'add_transaction_screen.dart';
import 'monthly_summary_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  List<Map<String, dynamic>> _selectedDayTransactions = []; //선택된 날짜
  List<Map<String, dynamic>> _monthlyTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR');
    _fetchMonthlyData(_focusedDay);
  }

  Future<void> _fetchMonthlyData(DateTime month) async {
    setState(() {
      _isLoading = true;
      _monthlyTransactions = [];
    });
    try {
      final transactions = await fetchMonthlyTransactions(
        month.year,
        month.month,
      );
      setState(() {
        _monthlyTransactions = transactions;
        _filterTransactionsForSelectedDay(_selectedDay);
      });
    } catch (e) {
      print('월별 데이터 로딩 에러: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterTransactionsForSelectedDay(DateTime day) {
    setState(() {
      _selectedDayTransactions = _monthlyTransactions.where((transaction) {
        return transaction['date'] == DateFormat('yyyy-MM-dd').format(day);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    //월간지출
    num monthlyTotalExpense = 0;
    for (var transaction in _monthlyTransactions) {
      if (transaction['amount'] < 0) {
        monthlyTotalExpense += transaction['amount'];
      }
    }

    DateTime startOfWeek = _selectedDay.subtract(
      Duration(days: _selectedDay.weekday % 7),
    );
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    //주간 지출
    num weeklyTotalExpense = 0;
    for (var transaction in _monthlyTransactions) {
      DateTime transactionDate = DateTime.parse(transaction['date']);
      // 거래 날짜가 이번 주의 시작일과 끝일 사이에 있는지 확인
      if (!transactionDate.isBefore(startOfWeek) &&
          !transactionDate.isAfter(endOfWeek)) {
        if (transaction['amount'] < 0) {
          weeklyTotalExpense += transaction['amount'];
        }
      }
    }

    final currencyFormat = NumberFormat('#,###원');

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // '주간 지출'을 표시할 부분
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '주간 지출',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(weeklyTotalExpense),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                // '월간 합계'를 표시할 부분
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '월간 합계',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(
                        monthlyTotalExpense,
                      ), // 계산된 월간 지출액 표시
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },

            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _fetchMonthlyData(focusedDay);
            },

            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _filterTransactionsForSelectedDay(selectedDay);
              }
            },
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),

            // UI를 직접 만드는 calendarBuilders
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, date) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.list_alt_outlined),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MonthlySummaryScreen(
                                focusedDate: _focusedDay,
                              ),
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            DateFormat.MMMM('ko_KR').format(date),
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.list_alt_outlined,
                          color: Colors.transparent,
                        ),
                        onPressed: null,
                      ),
                    ],
                  ),
                );
              },
              // 선택된 날짜 빌더 (투명 글래스 효과)
              selectedBuilder: (context, day, focusedDay) {
                return Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color: DefaultTextStyle.of(context).style.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),

              // 주말 글자 색상
              weekendTextStyle: const TextStyle(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 24.0),

          Expanded(
            child: _isLoading && _monthlyTransactions.isEmpty
                ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때
                : _selectedDayTransactions.isEmpty
                ? const Center(child: Text('지출 내역이 없습니다.')) // 내역이 없을 때
                : ListView.builder(
                    // 내역이 있을 때
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _selectedDayTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _selectedDayTransactions[index];
                      // '오늘' 탭에서 만들었던 TransactionListItem 위젯을 그대로 재사용합니다!
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TransactionListItem(
                          transaction: transaction,
                          onEdit: () async {
                            final result = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => AddTransactionScreen(
                                transaction: transaction,
                                isEdit: true,
                              ),
                            );
                            if (result == true) {
                              _fetchMonthlyData(_selectedDay);
                            }
                          },
                          onDelete: () async {
                            // TODO: 삭제 확인 다이얼로그 추가하면 더 좋습니다.
                            await deleteTransaction(transaction['id']);
                            _fetchMonthlyData(_selectedDay);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
