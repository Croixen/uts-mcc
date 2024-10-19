import 'package:intl/intl.dart';

String formatCurrency(int price) {
  final formatter =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
  return formatter.format(price);
}

DateTime toUTC7(String date) {
  DateTime toConvert =
      DateTime.parse(date).toUtc().add(const Duration(hours: 7));
  return toConvert;
}
