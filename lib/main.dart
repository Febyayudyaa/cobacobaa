
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_2025/splashscreen.dart';
import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fcvrmwfkacfqoehcrpwu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZjdnJtd2ZrYWNmcW9laGNycHd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0OTA5MTcsImV4cCI6MjA1NTA2NjkxN30.NWLuPpT7bZ1wp54umy4134b_HqyscOQ5kofDJDWNXZQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _usernameError;
  String? _passwordError;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _usernameError = username.isEmpty ? 'Harap Isi Username' : null;
      _passwordError = password.isEmpty ? 'Harap Masukan Password' : null;
    });

    try {
      final response = await supabase
          .from('user')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        setState(() {
          _usernameError = 'Harap Benahi Username';
        });
      } else if (response['password'] != password) {
        setState(() {
          _passwordError = 'Harap Benahi Password';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login berhasil sebagai $username!')),
        );

        Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => SplashScreen()),
);

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[50],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'asset/image/cookies logo.png',
                    height: 250,
                    width: 500,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Username',
                      errorText: _usernameError,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _usernameError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      hintText: 'Password',
                      errorText: _passwordError,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _passwordError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[800],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('LOGIN',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:crypto/crypto.dart'; // Paket untuk MD5
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:ukk_2025/splashscreen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Supabase.initialize(
//     url: 'https://fcvrmwfkacfqoehcrpwu.supabase.co',
//     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBh...',
//   );

//   final supabase = Supabase.instance.client;

//   // 🔹 Masukkan Data Dummy ke dalam Database
//   await insertDummyData(supabase);

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Login Page',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const LoginPage(),
//     );
//   }
// }

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isPasswordVisible = false;
//   bool _isLoading = false;
//   String? _usernameError;
//   String? _passwordError;

//   final SupabaseClient supabase = Supabase.instance.client;

//   // 🔹 Fungsi untuk Hash Password dengan MD5
//   String hashPasswordMD5(String password) {
//     return md5.convert(utf8.encode(password)).toString();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     final username = _usernameController.text.trim();
//     final password = _passwordController.text;
//     final hashedPassword = hashPasswordMD5(password); // 🔹 Hash password

//     setState(() {
//       _usernameError = username.isEmpty ? 'Harap Isi Username' : null;
//       _passwordError = password.isEmpty ? 'Harap Masukan Password' : null;
//     });

//     try {
//       final response = await supabase
//           .from('user')
//           .select()
//           .eq('username', username)
//           .maybeSingle();

//       if (response == null) {
//         setState(() {
//           _usernameError = 'Username tidak ditemukan';
//         });
//       } else if (response['password'] != hashedPassword) {
//         setState(() {
//           _passwordError = 'Password salah';
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Login berhasil sebagai $username!')),
//         );

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => SplashScreen()),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Terjadi kesalahan: $e')),
//       );
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(backgroundColor: Colors.brown[800]),
//       backgroundColor: Colors.brown[50],
//       body: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset('asset/image/cookies logo.png', height: 250, width: 500),
//                   const SizedBox(height: 20),
//                   TextFormField(
//                     controller: _usernameController,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Colors.white,
//                       prefixIcon: const Icon(Icons.person),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                       hintText: 'Username',
//                       errorText: _usernameError,
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         _usernameError = null;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 15),
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: !_isPasswordVisible,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Colors.white,
//                       prefixIcon: const Icon(Icons.lock),
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                       suffixIcon: IconButton(
//                         icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
//                         onPressed: () {
//                           setState(() {
//                             _isPasswordVisible = !_isPasswordVisible;
//                           });
//                         },
//                       ),
//                       hintText: 'Password',
//                       errorText: _passwordError,
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         _passwordError = null;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.brown[800],
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       ),
//                       onPressed: _isLoading ? null : _login,
//                       child: _isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text('LOGIN', style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // 🔹 Fungsi untuk Menambahkan Data Dummy ke Database
// Future<void> insertDummyData(SupabaseClient supabase) async {
//   final List<Map<String, dynamic>> dummyUsers = [
//     {
//       'id': 1,
//       'username': 'admin',
//       'password': '21232f297a57a5a743894a0e4a801fc3' // MD5 dari 'admin'
//     },
//     {
//       'id': 2,
//       'username': 'user123',
//       'password': 'ee11cbb19052e40b07aac0ca060c23ee' // MD5 dari 'password'
//     },
//     {
//       'id': 3,
//       'username': 'test',
//       'password': '098f6bcd4621d373cade4e832627b4f6' // MD5 dari 'test'
//     }
//   ];

//   for (var user in dummyUsers) {
//     final existingUser = await supabase
//         .from('user')
//         .select()
//         .eq('username', user['username'])
//         .maybeSingle();

//     if (existingUser == null) {
//       await supabase.from('user').insert(user);
//     }
//   }
// }
