import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:first_budget_app/services/api_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final DateTime? date;
  final Map<String, dynamic>? transaction;
  final bool isEdit;

  const AddTransactionScreen({
    super.key,
    this.date,
    this.transaction,
    this.isEdit = false,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date ?? DateTime.now();

    if (widget.isEdit && widget.transaction != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final transaction = widget.transaction!;

    // 금액 (음수를 양수로 변환하여 표시)
    final amount = (transaction['amount'] as num).abs();
    _amountController.text = '${NumberFormat('#,###').format(amount)}원';

    // 설명
    _descriptionController.text = transaction['description'] ?? '';

    // 카테고리
    _selectedCategory = transaction['category'];

    // 날짜
    if (transaction['date'] != null) {
      _selectedDate = DateTime.parse(transaction['date']);
    }
  }

  final int _amount = 0; //초깃값

  String? _selectedCategory;
  final List<String> _categories = ['식비', '생활비', '정기결제', '유흥'];

  String? _selectedPaymentMethod;
  final List<String> _PaymentMethod = ['농협카드', '국민카드', '카카오페이'];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _selectedDate,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _selectedDate = newDate;
              });
            },
          ),
        );
      },
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _categories.length,
          itemBuilder: (BuildContext context, int index) {
            final category = _categories[index];
            return ListTile(
              title: Text(category),
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _showPaymentPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _PaymentMethod.length,
          itemBuilder: (BuildContext context, int index) {
            final payment = _PaymentMethod[index];
            return ListTile(
              title: Text(payment),
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = payment;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  //저장함수
  void _saveTransaction() async {
    //1. 입력값 검증
    if (_amountController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedPaymentMethod == null ||
        _descriptionController.text.isEmpty) {
      print("모든 필드를 입력해주세요.");
      return;
    }
    // 2. 데이터 수집 및 가공
    final String amountString = _amountController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final int amount = int.parse(amountString);

    // 3. 백엔드로 보낼 데이터를 Map 형태로 만들기
    final Map<String, dynamic> transactionData = {
      "description": _descriptionController.text,
      "amount": -amount, // 지출이므로 음수로 변환
      "category": _selectedCategory!,
      "date": DateFormat('yyyy-MM-dd').format(_selectedDate), // yyyy-MM-dd 형식
    };
    // TODO: 백엔드 모델에 payment_method 필드를 추가하고 전송해야 합니다. 지금은 일단 제외.
    try {
      if (widget.isEdit && widget.transaction != null) {
        await updateTransaction(widget.transaction!['id'], transactionData);
      } else {
        await createTransaction(transactionData);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('저장 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,###');
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('취소'),
                ),
                const Text(
                  '지출',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _saveTransaction,
                  child: const Text('저장'),
                ),
              ],
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _amountController, // 컨트롤러 연결
              textAlign: TextAlign.center, // 텍스트를 중앙 정렬
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '0원', // 입력값이 없을 때 보여줄 힌트 텍스트
                border: InputBorder.none, // 밑줄 없애기
                hintStyle: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey, // 힌트 텍스트는 회색으로
                ),
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  return;
                }
                String plainNumber = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (plainNumber.isEmpty) {
                  _amountController.clear();
                  return;
                }
                int number = int.parse(plainNumber);
                String formattedNumber = NumberFormat('#,###').format(number);
                String newText = '$formattedNumber원';

                _amountController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(
                    offset: newText.length - 1,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: _showDatePicker,
                    leading: const Text('날짜', style: TextStyle(fontSize: 17)),
                    trailing: Text(
                      DateFormat(
                        'yyyy.MM.dd',
                      ).format(_selectedDate), // intl 패키지로 날짜 포맷팅
                      style: const TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Divider(height: 1, color: Colors.grey[300]),
                  ),
                  ListTile(
                    onTap: _showCategoryPicker,
                    leading: const Text('카테고리', style: TextStyle(fontSize: 17)),
                    trailing: Text(
                      _selectedCategory ?? '선택',
                      style: TextStyle(
                        fontSize: 17,
                        color: _selectedCategory == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Divider(height: 1, color: Colors.grey[300]),
                  ),

                  ListTile(
                    onTap: _showPaymentPicker,
                    leading: const Text('결제', style: TextStyle(fontSize: 17)),
                    trailing: Text(
                      _selectedPaymentMethod ?? '카드',
                      style: TextStyle(
                        fontSize: 17,
                        color: _selectedPaymentMethod == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Divider(height: 1, color: Colors.grey[300]),
                  ),

                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '내용',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
