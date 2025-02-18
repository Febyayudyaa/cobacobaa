import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:ukk_2025/produk/index.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InsertProduk extends StatefulWidget {
  @override
  _InsertProdukState createState() => _InsertProdukState();
}

class _InsertProdukState extends State<InsertProduk> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _saveData() async {
  if (!_formKey.currentState!.validate()) return;

  final nama = _namaController.text;
  double? harga;
  int? stok;

  try {
    harga = double.tryParse(_hargaController.text);
    stok = int.tryParse(_stokController.text);

    if (harga == null || stok == null) {
      throw Exception("Harga atau stok tidak valid!");
    }

    final response = await supabase.from('produk').insert({
      'NamaProduk': nama,
      'Harga': harga,
      'Stok': stok,
    }).select(); 

    if (response.isEmpty) {
      throw Exception("Gagal menyimpan data ke database.");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil disimpan!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => IndexProduk()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk', style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.brown[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Nama Produk tidak boleh kosong' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _hargaController,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  validator: (value) => value == null || value.isEmpty ? 'Harga tidak boleh kosong' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _stokController,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number, 
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) => value == null || value.isEmpty ? 'Stok tidak boleh kosong' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveData,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.brown[800],
                      borderRadius: BorderRadius.circular(30)
                    ),
                    child: const Text(
                      'SIMPAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}