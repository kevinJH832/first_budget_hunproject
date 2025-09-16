import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//오늘 날짜 / 총액 계산
class TodaySummaryCard extends StatelessWidget {
  final DateTime date;
  final num totalExpense;

  const TodaySummaryCard({
    super.key,
    required this.date,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.20,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withAlpha(51), width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                height: 35,
                width: double.infinity,
                color: const Color(0xFFFF3B30), // 애플 시스템 빨강
                child: Center(
                  child: Text(
                    DateFormat('MMMM', 'en_US').format(date).toUpperCase(),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('d').format(date),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                    // 총 지출액이 0이 아닐 때만 표시
                    if (totalExpense != 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          NumberFormat('#,###').format(totalExpense),
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
            ],
          ),
        ),
      ),
    );
  }
}
