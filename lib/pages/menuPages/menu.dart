import 'package:app_penjualan_elektronik/definitions/users.dart';
import 'package:app_penjualan_elektronik/pages/businessPages/cart.dart';
import 'package:app_penjualan_elektronik/pages/menuPages/dashboard.dart';
import 'package:app_penjualan_elektronik/pages/menuPages/profile.dart';
import 'package:app_penjualan_elektronik/pages/transactionPages/transaction_history.dart';
import 'package:app_penjualan_elektronik/providers/user_provider.dart';
import 'package:app_penjualan_elektronik/utils/fontsFactory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainMenu();
  }
}

class _MainMenu extends State<MainMenu> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Map<String, Widget> _widgetOptions(index) {
    final List<Map<String, Widget>> options = <Map<String, Widget>>[
      {
        'Body': const Dashboard(),
        'AppBar': AppBar(
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(4.0),
              child: Container(
                height: 1,
                color: const Color.fromARGB(255, 211, 210, 210),
              )),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 2,
          actions: [
            IconButton(
                onPressed: () {
                  UserCreds userProvider =
                      Provider.of<Userproviders>(context, listen: false).user;
                  Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'cart'),
                    builder: (context) => Cart(uuid: userProvider.uuid!),
                  ));
                },
                icon: const Icon(Icons.shopping_cart,
                    color: Color.fromARGB(255, 70, 70, 70)))
          ],
          title: Title(
              color: Colors.white,
              child: Row(
                children: [
                  Text(
                    'Selamat Datang, \ndi Mih Electric, ${Provider.of<Userproviders>(context, listen: false).user.username.split(' ')[0]}',
                    style: googleFont(
                        fontweight: FontWeight.bold,
                        fontsize: 18,
                        colour: Colors.black45),
                  )
                ],
              )),
          automaticallyImplyLeading: false,
          leading: null,
        ),
      },
      {
        'Body': const TransactionHistory(),
        'AppBar': AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Container(
              color: const Color.fromARGB(255, 209, 209, 209),
              height: 1.0,
            ),
          ),
          automaticallyImplyLeading: false,
          title: Text(
            'History Pembelian',
            style: googleFont(fontweight: FontWeight.bold, fontsize: 24),
          ),
          centerTitle: true,
        ),
      },
      {
        'Body': const Profile(),
        'AppBar': const SizedBox.shrink(),
      }
    ];

    return options[index];
  }

  @override
  Widget build(BuildContext context) {
    context.watch<Userproviders>().user;
    return PopScope(
      canPop: false,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: _widgetOptions(_selectedIndex)['AppBar'] is AppBar
              ? _widgetOptions(_selectedIndex)['AppBar'] as AppBar
              : null,
          body: _widgetOptions(_selectedIndex)['Body'],
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Menu Utama',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.tab),
                label: 'Transaksi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_2_outlined),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color.fromARGB(255, 2, 110, 8),
            onTap: _onItemTapped,
          )),
    );
  }
}
