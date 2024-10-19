import 'package:app_penjualan_elektronik/pages/transactionPages/history_detail.dart';
import 'package:app_penjualan_elektronik/providers/user_provider.dart';
import 'package:app_penjualan_elektronik/utils/fontsFactory.dart';
import 'package:app_penjualan_elektronik/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});
  @override
  State<TransactionHistory> createState() {
    return _TransactionHistory();
  }
}

class _TransactionHistory extends State<TransactionHistory> {
  List? transactionHistory;

  @override
  void initState() {
    super.initState();
    initPage();
  }

  void initPage() async {
    final uuid = Provider.of<Userproviders>(context, listen: false).user.uuid!;
    try {} catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Peringatan'),
              content: Text('Terjadi Kesalahan, penjelasan: $e'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Tutup Dialog'))
              ],
            );
          });
    }
    final salesInstance = await Supabase.instance.client
        .from('transactions')
        .select('transactionId, total, transaction_date')
        .eq('userId', uuid);
    setState(() {
      transactionHistory = salesInstance;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (transactionHistory == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (transactionHistory!.isEmpty) {
      return Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: Text(
            'Tidak ada history transaksi disini',
            style: googleFont(
                fontsize: 16,
                fontweight: FontWeight.bold,
                colour: Colors.black54),
          ),
        ),
      );
    }

    return Container(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: transactionHistory!.length,
          itemBuilder: (context, index) {
            final transaction = transactionHistory![index];
            final date = toUTC7(transaction['transaction_date']);
            return Card(
                color: Colors.white,
                elevation: 3,
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      IconButton(
                        style: const ButtonStyle(
                            elevation: WidgetStatePropertyAll(3),
                            backgroundColor: WidgetStatePropertyAll(
                                Color.fromARGB(255, 153, 211, 245))),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HistoryDetail(
                                transactionId: transaction['transactionId']),
                          ));
                        },
                        icon: const Icon(Icons.description_outlined),
                        color: const Color.fromARGB(255, 77, 77, 77),
                      ),
                      const SizedBox(
                        height: 50,
                        child: VerticalDivider(
                          color: Colors.black,
                          thickness: 1,
                        ),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              transaction['transactionId'],
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.fade,
                            ),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    formatCurrency(transaction['total']),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  ClipRect(
                                    child: Text(
                                      '${date.year}-${date.month}-${date.day}, ${date.hour}:${date.minute}',
                                      style: const TextStyle(
                                          color: Color.fromARGB(96, 43, 43, 43),
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
          },
        ));
  }
}
