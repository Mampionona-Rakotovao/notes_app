import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ypsegxulwqpwwqezwqzw.supabase.co',
    anonKey: 'sb_publishable_jf48HkdnuaaOrw91TSlXSw_VpFjynyW', // ta clé complète
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// Ce widget écoute l'état de connexion et redirige automatiquement
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? supabase.auth.currentSession;

        if (session != null) {
          // Utilisateur connecté → on ira vers la liste des notes
          // (pour l'instant, écran temporaire, on la crée à l'étape suivante)
          return const Scaffold(
            body: Center(child: Text('Connecté ! Liste des notes à venir 📝')),
          );
        }

        // Utilisateur non connecté → page de login
        return const LoginPage();
      },
    );
  }
}