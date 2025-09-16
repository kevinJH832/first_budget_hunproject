import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:first_budget_app/services/api_service.dart';
import 'package:first_budget_app/widgets/transaction_list_item.dart';

class MonthlySummaryScreen extends StatefulWidget {
  final DateTime focusedDate;
  const MonthlySummaryScreen({super.key, required this.focusedDate});

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  late DateTime _currentDate;
  List<Map<String, dynamic>> _monthlyTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.focusedDate;
    _fetchMonthlyData();
  }

  Future<void> _fetchMonthlyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await fetchMonthlyTransactions(
        _currentDate.year,
        _currentDate.month,
      );
      setState(() {
        _monthlyTransactions = transactions;
      });
    } catch (e) {
      print('월별 데이터 로딩 에러: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDatePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _YearMonthPicker(
          initialDate: _currentDate,
          onMonthSelected: (year, month) {
            setState(() {
              _currentDate = DateTime(year, month);
            });
            Navigator.pop(context);
            _fetchMonthlyData();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in _monthlyTransactions) {
      String dateKey = transaction['date'];
      if (groupedTransactions[dateKey] == null) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }
    List<String> dateKeys = groupedTransactions.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: _showDatePickerDialog,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('yyyy년 MMMM', 'ko_KR').format(_currentDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedTransactions.isEmpty
          ? const Center(child: Text('해당 월에 지출 내역이 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: dateKeys.length,
              itemBuilder: (context, index) {
                String dateKey = dateKeys[index];
                List<Map<String, dynamic>> transactionsOnDate =
                    groupedTransactions[dateKey]!;

                DateTime date = DateTime.parse(dateKey);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        DateFormat('MM.dd EEEE', 'ko_KR').format(date),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true, // Column 안에서 스크롤이 되도록 설정
                      physics:
                          const NeverScrollableScrollPhysics(), // 부모 스크롤과 충돌 방지
                      itemCount: transactionsOnDate.length,
                      itemBuilder: (context, itemIndex) {
                        final transaction = transactionsOnDate[itemIndex];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: TransactionListItem(
                            transaction: transaction,
                            onEdit: () {
                              /* TODO */
                            },
                            onDelete: () async {
                              await deleteTransaction(transaction['id']);
                              _fetchMonthlyData();
                            },
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _YearMonthPicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(int year, int month) onMonthSelected;
  const _YearMonthPicker({
    required this.initialDate,
    required this.onMonthSelected,
  });

  @override
  State<_YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<_YearMonthPicker> {
  late int _selectedYear; //선택된 연도,월 기억하는 변수
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350, // 팝업 높이를 조금 더 넉넉하게
      child: Column(
        children: [
          // ======== 연도 선택 헤더 ========
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이전 연도로 가는 버튼
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedYear--;
                    });
                  },
                ),
                // 현재 선택된 연도 표시
                Text(
                  '$_selectedYear년',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 다음 연도로 가는 버튼
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedYear++;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == _selectedMonth;

                  return TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.grey
                          : Colors.transparent,
                      foregroundColor: isSelected ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedMonth = month;
                      });
                      widget.onMonthSelected(_selectedYear, _selectedMonth);
                    },
                    child: Text('$month', style: const TextStyle(fontSize: 16)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
