import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/penjualan/index.dart'; // Import IndexPenjualan
import 'package:intl/intl.dart';

class insertpenjualan extends StatefulWidget {
  final List<Map<String, dynamic>> keranjang;

  const insertpenjualan({super.key, required this.keranjang});

  @override
  State<insertpenjualan> createState() => _InsertPenjualanAdminState();
}

class _InsertPenjualanAdminState extends State<insertpenjualan> {
  DateTime currentDate = DateTime.now();

  List<Map<String, dynamic>> pelanggan = [];
  List<Map<String, dynamic>> produk = [];
  List<Map<String, dynamic>> produkDipesan = [];
  Map<String, dynamic>? pilihPelanggan;
  Map<String, dynamic>? pilihProduk;

  TextEditingController quantityController = TextEditingController();
  double totalHarga = 0;

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
    fetchProduk();
  }

  Future<void> fetchPelanggan() async {
    final response = await Supabase.instance.client.from('pelanggan').select();
    setState(() {
      pelanggan = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> fetchPenjualan() async {
  final response = await Supabase.instance.client.from('penjualan').select();
  setState(() {
    // Menyimpan data penjualan terbaru
    // Sesuaikan dengan kebutuhan Anda
  });
}


  Future<void> fetchProduk() async {
    final response = await Supabase.instance.client.from('produk').select();
    setState(() {
      produk = List<Map<String, dynamic>>.from(response);
    });
  }

  void addProdukToOrder(Map<String, dynamic> produkTerpilih, int quantity) {
    if (quantity <= 0) {
      _showDialog('Jumlah produk harus lebih dari 0', Colors.brown.shade800);
      return;
    }

    if (produkTerpilih['Stok'] >= quantity) {
      setState(() {
        produkDipesan.add({
          'ProdukID': produkTerpilih['ProdukID'],
          'NamaProduk': produkTerpilih['NamaProduk'],
          'Harga': produkTerpilih['Harga'],
          'Jumlah': quantity,
          'Subtotal': produkTerpilih['Harga'] * quantity,
        });
        totalHarga += produkTerpilih['Harga'] * quantity;
      });
      _showDialog('Produk berhasil ditambahkan ke pesanan', Colors.brown.shade800);
    } else {
      _showDialog('Jumlah produk melebihi stok yang tersedia', Colors.brown.shade800);
    }
  }

  void _showDialog(String message, Color color) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: color,
          title: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Tutup',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> SubmitPenjualan() async {
    if (pilihPelanggan == null) {
      _showDialog('Pilih pelanggan terlebih dahulu!', Colors.brown.shade800);
      return;
    }

    if (produkDipesan.isEmpty) {
      _showDialog('Pesanan tidak boleh kosong!', Colors.brown.shade800);
      return;
    }

    try {
      final penjualanResponse = await Supabase.instance.client
          .from('penjualan')
          .insert({
            'TanggalPenjualan': DateFormat('yyyy-MM-dd').format(currentDate),
            'TotalHarga': totalHarga,
            'PelangganID': pilihPelanggan!['PelangganID']
          })
          .select()
          .single();

      if (penjualanResponse == null) {
        _showDialog('Gagal menyimpan transaksi', Colors.brown.shade800);
        return;
      }

      final PenjualanID = penjualanResponse['PenjualanID'];

      for (var produkItem in produkDipesan) {
        await Supabase.instance.client.from('detailpenjualan').insert({
          'PenjualanID': PenjualanID,
          'ProdukID': produkItem['ProdukID'],
          'JumlahProduk': produkItem['Jumlah'],
          'Subtotal': produkItem['Subtotal']
        });

        // Mengupdate stok produk dengan mengurangi jumlah produk yang dibeli
        await Supabase.instance.client.from('produk').update({
          'Stok': produkItem['Stok'] - produkItem['Jumlah']
        }).eq('ProdukID', produkItem['ProdukID']);
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaksi berhasil disimpan'),
        backgroundColor: Colors.brown[300],
      ));

      setState(() {
        totalHarga = 0;
        produkDipesan.clear();
      });

      // Kembali ke IndexPenjualan setelah berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IndexPenjualan()),
      ).then((value) {
        // Panggil kembali fetchPenjualan untuk refresh data
        fetchPenjualan();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $e'),
        backgroundColor: Colors.brown[300],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Halaman Pemesanan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown[800],
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'Pilih Pelanggan',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              items: pelanggan.map((customer) {
                return DropdownMenuItem(
                  value: customer,
                  child: Text(customer['NamaPelanggan']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  pilihPelanggan = value as Map<String, dynamic>;
                });
              },
            ),
            SizedBox(height: 16.0),
            Container(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: produk.length,
                itemBuilder: (context, index) {
                  var product = produk[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        pilihProduk = product;
                        quantityController.text = '';
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.all(8.0),
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['NamaProduk'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Harga: Rp ${product['Harga']}'),
                            Text('Stok: ${product['Stok']}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (pilihProduk != null) ...[
              SizedBox(height: 16.0),
              Text('Produk Terpilih: ${pilihProduk!['NamaProduk']}'),
              Text('Harga: Rp ${pilihProduk!['Harga']}'),
              Text('Stok Tersedia: ${pilihProduk!['Stok']}'),
            ],
            SizedBox(height: 16.0),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Jumlah Produk',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (pilihProduk != null && quantityController.text.isNotEmpty) {
                  int quantity = int.tryParse(quantityController.text) ?? 1;
                  addProdukToOrder(pilihProduk!, quantity);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[800], // Tombol dengan warna khusus
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tambah ke Pesanan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(),
            Text('Produk dalam Pesanan:', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: produkDipesan.length,
                itemBuilder: (context, index) {
                  var orderedProduct = produkDipesan[index];
                  return ListTile(
                    title: Text(orderedProduct['NamaProduk']),
                    subtitle: Text(
                        'Jumlah: ${orderedProduct['Jumlah']} - Subtotal: Rp ${orderedProduct['Subtotal']}'),
                  );
                },
              ),
            ),
            Divider(),
            Text('Total Harga: Rp $totalHarga', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (pilihPelanggan == null) {
                  // Menampilkan pesan jika pelanggan belum dipilih
                  _showDialog('Pilih pelanggan terlebih dahulu!', Colors.brown.shade800);
                } else if (produkDipesan.isNotEmpty) {
                  SubmitPenjualan();
                } else {
                  _showDialog('Pesanan tidak boleh kosong!', Colors.brown.shade800);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[800], // Tombol dengan warna khusus
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'SIMPAN PESANAN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
