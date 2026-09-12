import 'package:flutter/material.dart';
import 'stok_sayim_home_screen.dart';

class StokSayimLoginScreen extends StatefulWidget {
  const StokSayimLoginScreen({super.key});

  @override
  State<StokSayimLoginScreen> createState() => _StokSayimLoginScreenState();
}

class _StokSayimLoginScreenState extends State<StokSayimLoginScreen> {
  // VIP Kurucu bilgileri otomatik dolu gelir
  final TextEditingController _usernameController = TextEditingController(text: 'VIP_ADMIN');
  final TextEditingController _passwordController = TextEditingController(text: '********');
  bool _rememberMe = true;

  void _handleLogin() {
    // VIP Tam Yetki ile doğrudan ana sayfaya yönlendirir
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const StokSayimHomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF263238), // Koyu arka plan
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Başlık
                const Text(
                  'ANT STOK SAYIM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF00A8CC),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '👑 VIP Kurucu Yönetici Paneli',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF00A8CC),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // 👑 HIZLI VIP GİRİŞ BUTONU (Sürekli form doldurmamak için tek tık geçiş)
                ElevatedButton.icon(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A8CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.verified_user),
                  label: const Text(
                    '👑 VIP Yetki ile Direkt Gir',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Ayraç
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('veya klasik form', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 20),

                // Kullanıcı Adı Kutusu
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF00A8CC)),
                    hintText: 'Kullanıcı Adı',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF00A8CC), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Şifre Kutusu
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00A8CC)),
                    hintText: 'Şifre',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF00A8CC), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Beni Hatırla ve Şifremi Unuttum
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Beni Hatırla (VIP Kalıcı)',
                          style: TextStyle(color: Colors.black87, fontSize: 13),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Şifremi Unuttum?',
                        style: TextStyle(
                          color: Color(0xFF00A8CC),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Giriş Yap Butonu
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF263238),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Alt Bilgiler / Footer (Özel Notun Korundu)
                const Text(
                  'ants are nature\'s oldest stock controllers. Ç.K.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'v1.0.0 • Enterprise Edition • VIP Modu Aktif',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
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