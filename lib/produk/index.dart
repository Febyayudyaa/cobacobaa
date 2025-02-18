import 'package:flutter/material.dart';
import 'package:ukk_2025/penjualan/insert.dart';
import 'package:ukk_2025/produk/insert.dart'; // Import halaman insert produk
import 'package:ukk_2025/produk/update.dart';
import 'package:ukk_2025/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IndexProduk extends StatefulWidget {
  final bool showFAB;

  const IndexProduk({Key? key, this.showFAB = true}) : super(key: key);

  @override
  _IndexProdukState createState() => _IndexProdukState();
}

class _IndexProdukState extends State<IndexProduk> {
  List<Map<String, dynamic>> produk = [];
  List<Map<String, dynamic>> filteredProduk = [];
  List<Map<String, dynamic>> keranjang = []; // Menyimpan produk yang dipilih
  TextEditingController searchController = TextEditingController();
  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();
  bool isSearching = false;
  TextEditingController jumlahController = TextEditingController(); // Menambahkan kontroler untuk jumlah

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  // Fungsi untuk mengambil produk dari Supabase
  Future<void> fetchProduk() async {
    try {
      final response = await Supabase.instance.client.from('produk').select();
      setState(() {
        produk = List<Map<String, dynamic>>.from(response);
        filteredProduk = produk;
      });
    } catch (e) {
      print('Error fetching produk: $e');
    }
  }

  void addToKeranjang(Map<String, dynamic> produk, int quantity) {
    setState(() {
      keranjang.add({
        'ProdukID': produk['ProdukID'],
        'NamaProduk': produk['NamaProduk'],
        'Harga': produk['Harga'],
        'Jumlah': quantity,
        'Subtotal': produk['Harga'] * quantity,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
            );
          },
        ),
        title: const Text('Beranda Produk', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.white,
        child: filteredProduk.isEmpty
            ? const Center(
                child: Text(
                  'Tidak ada produk',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1 / 1,
                ),
                itemCount: filteredProduk.length,
                itemBuilder: (context, index) {
                  final langgan = filteredProduk[index];
                  return GestureDetector(
                    child: Container(
                      width: 160,
                      height: 200,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                langgan['NamaProduk'] ?? 'Produk tidak tersedia',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Harga: ${langgan['Harga'] ?? 'Tidak tersedia'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.brown,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stok: ${langgan['Stok'] ?? 'Tidak tersedia'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: Stack(
        children: [
          // FloatingActionButton untuk navigasi ke InsertProduk
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              backgroundColor: Colors.brown[800],
              onPressed: () {
                // Langsung navigasi ke halaman InsertProduk
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InsertProduk(), // Arahkan ke halaman InsertProduk
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white), // Ganti ikon dengan ikon tambah (+)
            ),
          ),
          // FloatingActionButton untuk keranjang
          Positioned(
            bottom: 70, // Mengatur jarak agar tidak bertumpuk
            right: 0,
            child: FloatingActionButton(
              backgroundColor: Colors.brown[800],
              onPressed: () {
                // Navigasi ke halaman insertpenjualan
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => insertpenjualan(keranjang: keranjang), // Kirimkan keranjang ke insertpenjualan
                  ),
                );
              },
              child: const Icon(Icons.shopping_cart, color: Colors.white), // Ikon keranjang belanja
            ),
          ),
        ],
      ),
    );
  }
}