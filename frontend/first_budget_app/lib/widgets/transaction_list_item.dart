import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  final Map<String, dynamic> transaction; // 표시할 거래 데이터
  final VoidCallback onEdit; // 수정 버튼 눌렀을 때 실행될 함수
  final VoidCallback onDelete; // 삭제 버튼 눌렀을 때 실행될 함수

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  //카테고리
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

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(transaction['id'].toString()),
      closeOnScroll: true,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.4,
        children: [
          SlidableAction(
            flex: 2,
            onPressed: (context) => onEdit(), // 수정 함수 호출
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
            onPressed: (context) => onDelete(), // 삭제 함수 호출
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['description'] ?? '내역 없음',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction['category'] ?? '카테고리 없음',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '${NumberFormat('#,###').format(transaction['amount'] ?? 0)}원',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
