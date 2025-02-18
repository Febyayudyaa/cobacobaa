import 'package:flutter/material.dart';
import 'package:ukk_2025/produk/index.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProduk extends StatefulWidget {
  final int ProdukID;

  const UpdateProduk({super.key, required this.ProdukID});

  @override
  State<UpdateProduk> createState() => _UpdateProdukState();
}

class _UpdateProdukState extends State<UpdateProduk> {
  final _nmprdk = TextEditingController();
  final _harga = TextEditingController();
  final _stok = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProdukData();
  }

  Future<void> _loadProdukData() async {
    try {
      final data = await Supabase.instance.client
          .from('produk')
          .select()
          .eq('ProdukID', widget.ProdukID)
          .single();

      setState(() {
        _nmprdk.text = data['NamaProduk'] ?? '';
        _harga.text = data['Harga']?.toString() ?? '';
        _stok.text = data['Stok']?.toString() ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data: $e')),
      );
    }
  }

  Future<void> updateProduk() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Supabase.instance.client.from('produk').update({
          'NamaProduk': _nmprdk.text,
          'Harga': double.tryParse(_harga.text) ?? 0,
          'Stok': int.tryParse(_stok.text) ?? 0,
        }).eq('ProdukID', widget.ProdukID);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diperbarui!')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => IndexProduk()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nmprdk,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _harga,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Harga tidak boleh kosong';
                  if (double.tryParse(value) == null)
                    return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stok,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Stok tidak boleh kosong';
                  if (int.tryParse(value) == null)
                    return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProduk,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.brown[800],
                ),
                child:
                    const Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}