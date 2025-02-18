import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InsertPelangganPage extends StatefulWidget {
  @override
  _InsertPelangganPageState createState() => _InsertPelangganPageState();
}

class _InsertPelangganPageState extends State<InsertPelangganPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _nomorTeleponController = TextEditingController();

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final nama = _namaController.text;
    final alamat = _alamatController.text;
    final nomorTelepon = _nomorTeleponController.text;

    try {
      final response = await supabase.from('pelanggan').insert({
        'NamaPelanggan': nama,
        'Alamat': alamat,
        'NomorTelepon': nomorTelepon,
      }).select();

      if (response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil disimpan!')),
        );
        Navigator.pop(context, {
          'Nama': nama,
          'Alamat': alamat,
          'Nomor Telepon': nomorTelepon,
        });
      } else {
        throw Exception('Gagal menyimpan data.');
      }
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
        title: Text('Tambah Pelanggan'),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama Pelanggan'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama tidak boleh kosong'
                    : null,
              ),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Alamat tidak boleh kosong'
                    : null,
              ),
              TextFormField(
                controller: _nomorTeleponController,
                decoration: InputDecoration(labelText: 'Nomor Telepon'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor Telepon tidak boleh kosong';
                  } else if (value.length < 5) {
                    return 'Nomor telepon tidak valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[800],
                  foregroundColor: Colors.white,
                ),
                child: Text('SIMPAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}