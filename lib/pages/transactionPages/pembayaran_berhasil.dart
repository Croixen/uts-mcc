import 'package:app_penjualan_elektronik/utils/fontsFactory.dart';
import 'package:app_penjualan_elektronik/utils/formatter.dart';
import 'package:flutter/material.dart';

class PembayaranBerhasil extends StatefulWidget {
  final Map<String, dynamic> resultPembyaran;

  const PembayaranBerhasil({super.key, required this.resultPembyaran});

  @override
  State<PembayaranBerhasil> createState() {
    return _PembyaranBerhasil();
  }
}

class _PembyaranBerhasil extends State<PembayaranBerhasil> {
  @override
  void initState() {
    super.initState();
    print(widget.resultPembyaran);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime date = toUTC7(widget.resultPembyaran['transaction_date']);
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(40, 80, 40, 90),
            child: Center(
              child: SizedBox(
                height: 130,
                width: 130,
                child: CircleAvatar(
                    radius: 100,
                    backgroundImage: AssetImage('assets/success.gif')),
                // '
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    'Detail Transaksi',
                    style: googleFont(
                        colour: Colors.black,
                        fontweight: FontWeight.bold,
                        fontsize: 32),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Text(
                        'Transaction ID:',
                        overflow: TextOverflow.ellipsis,
                        style: googleFont(
                            fontweight: FontWeight.bold, fontsize: 16),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: Text(
                          widget.resultPembyaran['transactionId'],
                          overflow: TextOverflow.ellipsis,
                          style: googleFont(
                              colour: const Color.fromARGB(255, 158, 158, 158),
                              fontsize: 16),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        'Tanggal Pembayaran:',
                        style: googleFont(
                            fontweight: FontWeight.bold, fontsize: 16),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: Text(
                          "${date.year} - ${date.month} - ${date.day}, ${date.hour}:${date.minute}",
                          overflow: TextOverflow.ellipsis,
                          style: googleFont(
                              colour: const Color.fromARGB(255, 158, 158, 158),
                              fontsize: 16),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        'Total Pembayaran:',
                        style: googleFont(
                            fontweight: FontWeight.bold, fontsize: 16),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Flexible(
                        child: Text(
                          formatCurrency(widget.resultPembyaran['total']),
                          style: googleFont(
                              colour: const Color.fromARGB(255, 158, 158, 158),
                              fontsize: 16),
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                      style: ButtonStyle(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                          elevation: const WidgetStatePropertyAll(3),
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.red.shade400)),
                      onPressed: () {
                        Navigator.popUntil(
                            context, ModalRoute.withName('home'));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Kembali Ke Beranda',
                          style: googleFont(
                              colour: Colors.white,
                              fontsize: 18,
                              fontweight: FontWeight.bold),
                        ),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
