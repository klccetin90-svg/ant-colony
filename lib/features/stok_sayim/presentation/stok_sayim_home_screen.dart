import 'package:flutter/material.dart';
import 'package:ant_ecosystem/core/theme/app_theme.dart';
import 'company_add_screen.dart';
import 'package:ant_ecosystem/features/staff/presentation/staff_add_screen.dart';
import 'package:ant_ecosystem/features/staff/presentation/staff_fee_screen.dart';

class StokSayimHomeScreen extends StatelessWidget {
  const StokSayimHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        title: const Text(
          'ANT STOK SAYIM - Ana Ekran',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              // Üst VIP Bilgi Şeridi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF332900),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber, width: 1.2),
                ),
                child: Column(
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('★ ', style: TextStyle(color: Colors.amber, fontSize: 16)),
                        Text(
                          'VIP Kullanıcı: Çetin Kılıç (Tam Yetkili)',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Lütfen İşlem Yapmak İstediğiniz Bölümü Seçin',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Responsive Grid Yapısı
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isDesktop = constraints.maxWidth > 700;

                    return GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isDesktop ? 1.35 : 0.98,
                      children: [
                        _buildDashboardCard(
                          isDesktop: isDesktop,
                          color: const Color(0xFF1D4ED8),
                          icon: Icons.business,
                          title: 'Firma Bilgileri',
                          subtitle: 'Pozisyon ve birim ücretleri',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CompanyAddScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          isDesktop: isDesktop,
                          color: const Color(0xFFD97706),
                          icon: Icons.calendar_month,
                          title: 'Sayım Programı',
                          subtitle: 'Aylık tarih, firma ve kişi',
                          onTap: () => _showComingSoon(context, 'Sayım Programı'),
                        ),
                        _buildDashboardCard(
                          isDesktop: isDesktop,
                          color: const Color(0xFFB45309),
                          icon: Icons.assignment_outlined,
                          title: 'Sayım Tutanakları',
                          subtitle: 'Tutanak giriş ve listesi',
                          onTap: () => _showComingSoon(context, 'Sayım Tutanakları'),
                        ),
                        _buildDashboardCard(
                          isDesktop: isDesktop,
                          color: const Color(0xFF047857),
                          icon: Icons.archive_outlined,
                          title: 'Gelen Raporlar',
                          subtitle: 'Arşiv, filtre ve mail atma',
                          onTap: () => _showComingSoon(context, 'Gelen Raporlar'),
                        ),
                        _buildDashboardCard(
                          isDesktop: isDesktop,
                          color: const Color(0xFF0E7490),
                          icon: Icons.receipt_long,
                          title: 'Masraf Yönetimi',
                          subtitle: 'Seyahat ve harcama takibi',
                          onTap: () => _showComingSoon(context, 'Masraf Yönetimi'),
                        ),
                        _buildDashboardCard(
                          isDesktop: isDesktop,
                          color: const Color(0xFF7E22CE),
                          icon: Icons.badge_outlined,
                          title: 'Personel Kayıt',
                          subtitle: 'Ad, soyad, TC, IBAN',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const StaffAddScreen(),
                              ),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          isDesktop: isDesktop,
                          color: const Color(0xFF3730A3),
                          icon: Icons.payments_outlined,
                          title: 'Personel Ödeme',
                          subtitle: 'Hakediş ve katılım',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StaffFeeScreen()),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          isDesktop: isDesktop,
                          color: const Color(0xFF15803D),
                          icon: Icons.bar_chart,
                          title: 'Özet Rapor',
                          subtitle: 'Genel sayım raporları',
                          onTap: () => _showComingSoon(context, 'Özet Rapor'),
                        ),
                        _buildDashboardCard(
                          isDesktop: isDesktop,
                          color: const Color(0xFFBE185D),
                          icon: Icons.admin_panel_settings_outlined,
                          title: 'Kullanıcı Yönetimi',
                          subtitle: 'Yeni kullanıcı & yetki',
                          onTap: () => _showComingSoon(context, 'Kullanıcı Yönetimi'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required bool isDesktop,
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: EdgeInsets.all(isDesktop ? 16 : 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: isDesktop ? 42 : 28,
              ),
              SizedBox(height: isDesktop ? 10 : 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 18 : 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isDesktop ? 6 : 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: isDesktop ? 12.5 : 9.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$moduleName modülü yakında aktif olacak.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}