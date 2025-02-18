import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/user/update.dart';
import 'package:ukk_2025/user/insert.dart';
import 'package:ukk_2025/homepage.dart';

class IndexUser extends StatefulWidget {
  const IndexUser({super.key});

  @override
  State<IndexUser> createState() => _IndexUserState();
}

class _IndexUserState extends State<IndexUser> {
  List<Map<String, dynamic>> user = [];

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final response = await Supabase.instance.client.from('user').select();

      if (response != null && response is List) {
        setState(() {
          user = List<Map<String, dynamic>>.from(response);
        });
      }

      print("Jumlah user dari Supabase: ${user.length}");
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await Supabase.instance.client.from('user').delete().eq('id', id);
      fetchUser();
    } catch (e) {
      print('Error menghapus user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[800],
        title: const Text('Data User', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
      ),
      body: user.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada user',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: user.length,
              itemBuilder: (context, index) {
                final userData = user[index];
                final userId = userData['id'];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      userData['username'] ?? 'Username tidak tersedia',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle:
                        Text("Role: ${userData['role'] ?? 'Tidak tersedia'}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.brown),
                          onPressed: () {
                            if (userId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateUser(id: userId),
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.brown),
                          onPressed: () {
                            if (userId != null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus User'),
                                  content: const Text(
                                      'Apakah Anda yakin ingin menghapus user ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteUser(userId);
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(
                                          backgroundColor: Color(0xFF4E342E),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const InsertUser()));
        },
        backgroundColor: Colors.brown[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}