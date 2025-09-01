import 'package:http/http.dart' as http;
import 'dart:convert';

// API 관련 로직만을 전문적으로 담당하는 파일

// GET: 거래 내역 조회
Future<List<Map<String, dynamic>>> fetchTransactions() async {
  final url = 'http://127.0.0.1:8000/transactions';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
        'API로부터 데이터를 가져오는데 실패했습니다. 상태 코드: ${response.statusCode}',
      );
    }
  } catch (e) {
    throw Exception('서버에 연결할 수 없습니다: $e');
  }
}

// POST: 새로운 거래 추가
Future<Map<String, dynamic>> createTransaction(
  Map<String, dynamic> transactionData,
) async {
  final url = 'http://127.0.0.1:8000/transactions';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transactionData),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return jsonResponse;
    } else {
      throw Exception('거래 생성에 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('서버에 연결할 수 없습니다: $e');
  }
}
