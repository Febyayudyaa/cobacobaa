import 'package:flutter/material.dart';
import 'package:ukk_2025/pelanggan/insert.dart';
import 'package:ukk_2025/pelanggan/update.dart';
import 'package:ukk_2025/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IndexPelanggan extends StatefulWidget {
  @override
  _IndexPelangganState createState() => _IndexPelangganState();
}

class _IndexPelangganState extends State<IndexPelanggan> {
  List<Map<String, dynamic>> pelanggan = [];
  List<Map<String, dynamic>> filteredPelanggan = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  Future<void> fetchPelanggan() async {
    try {
      final response =
          await Supabase.instance.client.from('pelanggan').select();
      setState(() {
        pelanggan = List<Map<String, dynamic>>.from(response);
        filteredPelanggan = pelanggan;
      });
    } catch (e) {
      print('Error fetching pelanggan: $e');
    }
  }

  void filterSearch(String query) {
    setState(() {
      filteredPelanggan = pelanggan
          .where((item) =>
              item['NamaPelanggan'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deletePelanggan(int PelangganID) async {
    try {
      print('Menghapus pelanggan dengan ID: $PelangganID');

      await Supabase.instance.client
          .from('pelanggan')
          .delete()
          .eq('PelangganID', PelangganID);

      print('Pelanggan berhasil dihapus.');

      setState(() {
        pelanggan.removeWhere((item) => item['PelangganID'] == PelangganID);
        filteredPelanggan = List.from(pelanggan);
      });
    } catch (e) {
      print('Error menghapus pelanggan: $e');
    }
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
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari Pelanggan...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => filterSearch(value),
              )
            : const Text(
                'Daftar Pelanggan',
                style: TextStyle(color: Colors.white),
              ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  filteredPelanggan = pelanggan;
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: filteredPelanggan.isEmpty
            ? const Center(
                child: Text(
                  'Tidak ada pelanggan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filteredPelanggan.length,
                itemBuilder: (context, index) {
                  final langgan = filteredPelanggan[index];
                  return Card(
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
                            langgan['NamaPelanggan'] ??
                                'Pelanggan tidak tersedia',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            langgan['Alamat'] ?? 'Alamat tidak tersedia',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            langgan['NomorTelepon'] ?? 'Tidak tersedia',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Color(0xFF8D6E63)),
                                onPressed: () {
                                  final pelangganID =
                                      langgan['PelangganID'] as int?;
                                  if (pelangganID != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditPelanggan(
                                            PelangganID: pelangganID),
                                      ),
                                    ).then((value) {
                                      if (value == true) {
                                        fetchPelanggan();
                                      }
                                    });
                                  } else {
                                    print('ID pelanggan tidak valid');
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Color(0xFF8D6E63)),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Hapus Pelanggan'),
                                        content: const Text(
                                            'Apakah Anda yakin ingin menghapus pelanggan ini?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await deletePelanggan(
                                                  langgan['PelangganID']);
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Hapus',
                                              style: TextStyle(
                                                backgroundColor:
                                                    Color(0xFF4E342E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InsertPelangganPage()),
          );
          fetchPelanggan();
        },
        backgroundColor: Colors.brown[800],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}