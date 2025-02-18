import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/detailpenjualan/cetakpdf.dart';

class IndexDetail extends StatefulWidget {
  final int penjualanID;

  const IndexDetail({super.key, required this.penjualanID});

  @override
  _IndexDetailState createState() => _IndexDetailState();
}

class _IndexDetailState extends State<IndexDetail> {
  late Future<List<Map<String, dynamic>>> _detailPenjualanFuture;

  @override
  void initState() {
    super.initState();
    // Memulai pengambilan data saat halaman dimuat
    _detailPenjualanFuture = fetchDetailPenjualan();
  }

  // Fungsi untuk mengambil detail penjualan berdasarkan PenjualanID
  Future<List<Map<String, dynamic>>> fetchDetailPenjualan() async {
    try {
      final response = await Supabase.instance.client
          .from('detailpenjualan')
          .select('DetailID, ProdukID, JumlahProduk, Subtotal, PenjualanID')
          .eq('PenjualanID', widget.penjualanID);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching detail penjualan: $e');
      return []; // Mengembalikan list kosong jika ada error
    }
  }

  // Fungsi untuk mengambil nama produk berdasarkan ProdukID
  Future<String> getNamaProduk(int produkID) async {
    try {
      final response = await Supabase.instance.client
          .from('produk')
          .select('NamaProduk')
          .eq('ProdukID', produkID)
          .single();
      return response['NamaProduk'] ?? 'Nama Tidak Ditemukan';
    } catch (e) {
      return 'Error mendapatkan nama produk';
    }
  }

  // Fungsi untuk mencetak struk
  void navigateToCetakPdf(List<Map<String, dynamic>> details) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => cetakpdf(
        cetak: details,  // Kirimkan data yang relevan
        PenjualanID: widget.penjualanID.toString(),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Detail Penjualan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _detailPenjualanFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Menunggu data
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // Menangani error
            }

            if (snapshot.data!.isEmpty) {
              return Center(child: Text("Tidak ada detail penjualan")); // Jika data kosong
            }

            // Menampilkan list detail penjualan jika data ada
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var detail = snapshot.data![index];
                      return FutureBuilder<String>(
                        future: getNamaProduk(detail['ProdukID']),
                        builder: (context, snapshotProduk) {
                          if (snapshotProduk.connectionState == ConnectionState.waiting) {
                            return Center(child: Text("Memuat nama produk...")); // Menunggu nama produk
                          }

                          if (snapshotProduk.hasError) {
                            return Center(child: Text('Error: ${snapshotProduk.error}'));
                          }

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Produk: ${snapshotProduk.data ?? 'Tidak ditemukan'}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('Jumlah: ${detail['JumlahProduk']}'),
                                  Text('Subtotal: Rp ${detail['Subtotal']}'),
                                  Text('Penjualan ID: ${detail['PenjualanID']}'),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Tombol untuk mencetak struk
                ElevatedButton(
                  onPressed: () {
                    navigateToCetakPdf(snapshot.data!);  // Navigasi ke halaman cetakpdf
                  },
                  child: Text('Cetak Struk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
