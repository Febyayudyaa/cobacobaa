import 'package:flutter/material.dart';
import 'package:ukk_2025/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPelanggan extends StatefulWidget {
  final int PelangganID;

  const EditPelanggan({super.key, required this.PelangganID});

  @override
  State<EditPelanggan> createState() => _EditPelangganState();
}

class _EditPelangganState extends State<EditPelanggan> {
  final _nmplg = TextEditingController();
  final _alamat = TextEditingController();
  final _notlp = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadPelangganData();
  }

  Future<void> _loadPelangganData() async {
    try {
      final data = await Supabase.instance.client
          .from('pelanggan')
          .select()
          .eq('PelangganID', widget.PelangganID)
          .single();

      setState(() {
        _nmplg.text = data['NamaPelanggan'] ?? '';
        _alamat.text = data['Alamat'] ?? '';
        _notlp.text = data['NomorTelepon'] ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data pelanggan: $e')),
      );
    }
  }

  Future<void> updatePelanggan() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Supabase.instance.client.from('pelanggan').update({
          'NamaPelanggan': _nmplg.text,
          'Alamat': _alamat.text,
          'NomorTelepon': _notlp.text,
        }).eq('PelangganID', widget.PelangganID);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pelanggan berhasil diperbarui!')),
        );

        await Future.delayed(const Duration(seconds: 1));

        // Menggunakan Navigator.pop untuk kembali ke halaman sebelumnya dan memperbarui daftar pelanggan
        Navigator.pop(context,
            true); // Mengirimkan nilai true untuk menandakan data telah diperbarui
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui pelanggan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pelanggan'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nmplg,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamat,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notlp,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updatePelanggan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[800],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}