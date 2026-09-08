import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ypsegxulwqpwwqezwqzw.supabase.co',
    anonKey: 'sb_publishable_jf48HkdnuaaOrw91TSlXSw_VpFjynyW', // ta clé complète
  );

  runApp(const MyApp());
}

// Petit raccourci pour accéder au client Supabase partout dans l'app
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,//pour masquer le ruban debug
      title: 'Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Connexion Supabase OK ✅'),
        ),
      ),
    );
  }
}