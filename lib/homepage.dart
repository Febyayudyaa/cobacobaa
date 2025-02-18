
import 'package:flutter/material.dart';
import 'package:ukk_2025/detailpenjualan/index.dart';
import 'package:ukk_2025/pelanggan/index.dart';
import 'package:ukk_2025/penjualan/index.dart';
import 'package:ukk_2025/produk/index.dart';
import 'package:ukk_2025/user/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(
        child: Text(
      'Produk',
      style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
    )),
    Center(
        child: Text(
      'Pelanggan',
      style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
    )),
    Center(
        child: Text(
      'Penjualan',
      style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
    )),
    Center(
        child: Text(
      'Detail Penjualan',
      style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
    )),
    Center(
        child: Text(
      'User',
      style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
    )),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Cookielicious'),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF4E342E),
              ),
              child: Text(
                'Dashboard Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Produk'),
              textColor: Colors.black,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IndexProduk()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Pelanggan'),
              textColor: Colors.black,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IndexPelanggan()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Penjualan'),
              textColor: Colors.black,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IndexPenjualan()),
                );
              },
            ),
           ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Detail Penjualan'),
            textColor: Colors.black,
            onTap: () {
              int penjualanID = 123; 
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IndexDetail(penjualanID: penjualanID),
            ),
          );

  },
),


            ListTile(
              leading: const Icon(Icons.person_2_outlined),
              title: const Text('Data User'),
              textColor: Colors.black,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IndexUser()),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}