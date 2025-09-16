import 'package:flutter/material.dart';
import 'package:first_budget_app/screens/add_transaction_screen.dart';
import 'package:first_budget_app/services/api_service.dart';
import 'package:first_budget_app/widgets/transaction_list_item.dart';

class TransactionList extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> futureTransactions;
  final Function() onRefresh;

  const TransactionList({
    super.key,
    required this.futureTransactions,
    required this.onRefresh,
  });

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('삭제 확인'),
          content: const Text('해당 내역을 삭제할까요?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('거래 내역이 없습니다.'));
          } else {
            final transactions = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TransactionListItem(
                    transaction: transaction,
                    onEdit: () async {
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
                        onRefresh();
                      }
                    },
                    onDelete: () async {
                      final shouldDelete = await _showDeleteConfirmationDialog(
                        context,
                      );
                      if (shouldDelete == true) {
                        try {
                          await deleteTransaction(transaction['id']);
                          onRefresh();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('삭제되었습니다.')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('삭제 실패: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
