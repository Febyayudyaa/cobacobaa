import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/detailpenjualan/index.dart'; // Pastikan untuk mengimpor halaman DetailPenjualan

class IndexPenjualan extends StatefulWidget {
  const IndexPenjualan({super.key});

  @override
  _IndexPenjualanState createState() => _IndexPenjualanState();
}

class _IndexPenjualanState extends State<IndexPenjualan> {
  List<Map<String, dynamic>> penjualan = [];

  @override
  void initState() {
    super.initState();
    fetchPenjualan();
  }

  Future<void> fetchPenjualan() async {
    try {
      final response = await Supabase.instance.client
          .from('penjualan')
          .select('PenjualanID, TanggalPenjualan, TotalHarga, PelangganID')
          .order('TanggalPenjualan', ascending: false);

      setState(() {
        penjualan = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching penjualan: $e');
    }
  }

  Future<String> getPelangganName(int pelangganID) async {
    try {
      final response = await Supabase.instance.client
          .from('pelanggan')
          .select('NamaPelanggan')
          .eq('PelangganID', pelangganID)
          .single();
      return response['NamaPelanggan'] ?? 'Nama Tidak Ditemukan';
    } catch (e) {
      return 'Error mendapatkan nama pelanggan';
    }
  }

  Future<void> deletePenjualan(int penjualanID) async {
    try {
      // Menghapus detail penjualan terlebih dahulu
      await Supabase.instance.client
          .from('detailpenjualan')
          .delete()
          .eq('PenjualanID', penjualanID);

      // Menghapus data penjualan utama
      await Supabase.instance.client
          .from('penjualan')
          .delete()
          .eq('PenjualanID', penjualanID);

      // Setelah berhasil menghapus, refresh data penjualan
      fetchPenjualan();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Penjualan berhasil dihapus'),
        backgroundColor: Colors.brown.shade800,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $e'),
        backgroundColor: Colors.brown.shade800,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Index Penjualan', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: penjualan.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: penjualan.length,
                itemBuilder: (context, index) {
                  var sale = penjualan[index];
                  return FutureBuilder<String>(
                    future: getPelangganName(sale['PelangganID']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
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
                                'Pelanggan ID: ${sale['PelangganID']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Nama Pelanggan: ${snapshot.data ?? 'Loading...'}'),
                              Text('Tanggal: ${sale['TanggalPenjualan']}'),
                              Text('Total Harga: Rp ${sale['TotalHarga']}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.brown),
                                    onPressed: () {
                                      // Konfirmasi penghapusan
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Konfirmasi Hapus'),
                                          content: Text('Apakah Anda yakin ingin menghapus penjualan ini?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                deletePenjualan(sale['PenjualanID']);
                                              },
                                              child: Text(
                                                'Hapus',
                                                style: TextStyle(
                                                  backgroundColor: Colors.brown.shade800,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Checkout'),
                                      content: Text('Anda akan melakukan checkout untuk penjualan ini.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            // Menavigasi ke halaman DetailPenjualan
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => IndexDetail(penjualanID: sale['PenjualanID']),
                                              ),
                                            ).then((value) {
                                              // Memperbarui data setelah kembali
                                              fetchPenjualan();
                                            });
                                          },
                                          child: Text('Lanjutkan'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text('Checkout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
