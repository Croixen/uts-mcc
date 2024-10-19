import 'package:app_penjualan_elektronik/definitions/products.dart';

class Sales {
  String salesId;
  String transactionId;
  String date;
  Product product;
  String userId;
  int total;
  int amount;
  String alamat;

  Sales(
      {required this.salesId,
      required this.transactionId,
      required this.userId,
      required this.product,
      required this.date,
      required this.total,
      required this.amount,
      required this.alamat});

  Map<String, dynamic> toJson() {
    return {
      'salesId': salesId,
      'transactionId': transactionId,
      'userId': userId,
      'amount': amount
    };
  }
}
