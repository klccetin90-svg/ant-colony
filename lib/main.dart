import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/stok_sayim/presentation/stok_sayim_login_screen.dart';
import 'features/colony/presentation/colony_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase bağlantısını başlatıyoruz
  await Supabase.initialize(
    url: 'https://uqvckygcybnefixqzhhd.supabase.co',
    anonKey: 'sb_publishable_hF81p3E5m1_9LfpHM-3vSg_9splyFA2',
  );

  runApp(const AntEcosystemApp());
}

class AntEcosystemApp extends StatelessWidget {
  const AntEcosystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANT COLONY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // Doğrudan ANT COLONY Ana Ekranı / Giriş Sayfası ile başlatıyoruz
      home: const ColonyHomeScreen(),
      
      // İleride test paneline erişmek istersen üstteki satırı yorum yapıp alttakini açabilirsin:
      // home: const EcosystemTestNavigator(),
    );
  }
}

class EcosystemTestNavigator extends StatelessWidget {
  const EcosystemTestNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ANT Ekosistemi - Modül Test Paneli')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hub, size: 80, color: AppTheme.turkuaz),
              const SizedBox(height: 20),
              const Text(
                'Hangi Modülü Test Etmek İstersin?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // ANT Stok Sayım Modülü (Giriş Ekranına Yönlendirir)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.koyuSiyah,
                    foregroundColor: AppTheme.turkuaz,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StokSayimLoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.warehouse),
                  label: const Text('📦 ANT Stok Sayım Modülü', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              // ANT Colony Modülü
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.antKirmizisi,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ColonyHomeScreen()),
                    );
                  },
                  icon: const Icon(Icons.sports_esports),
                  label: const Text('🐜 ANT Colony Modülü', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}