import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// API 관련 로직만을 전문적으로 담당하는 파일

// GET: 거래 내역 조회
Future<List<Map<String, dynamic>>> fetchTransactions({DateTime? date}) async {
  var url = 'http://127.0.0.1:8000/transactions';

  if (date != null) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    url += '?date=$formattedDate';
  }

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

// DELETE: 특정 ID의 거래 내역 삭제
Future<void> deleteTransaction(int id) async {
  final url = 'http://127.0.0.1:8000/transactions/$id';

  try {
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('데이터 삭제에 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('서버에 삭제 요청을 보낼 수 없습니다: $e');
  }
}

// UPDATED: 거래내역 수정
Future<Map<String, dynamic>> updateTransaction(
  int id,
  Map<String, dynamic> transactionData,
) async {
  final url = 'http://127.0.0.1:8000/transactions/$id';

  try {
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(transactionData), // 수정할 내용을 body에 담아 보냅니다.
    );

    if (response.statusCode == 200) {
      // 성공적으로 수정되었다면, 서버가 돌려주는 업데이트된 데이터를 반환합니다.
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('데이터 수정에 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('서버에 수정 요청을 보낼 수 없습니다: $e');
  }
}
