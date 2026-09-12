import 'package:flutter/material.dart';

class BadgeShowcaseWidget extends StatelessWidget {
  final List<String> unlockedBadgeIds;

  const BadgeShowcaseWidget({
    super.key,
    required this.unlockedBadgeIds,
  });

  static final List<Map<String, String>> allBadges = [
    {'id': 'badge_welcome', 'title': 'İlk Adım', 'icon': '🎯', 'desc': 'ANT Colony ailesine katıldın.'},
    {'id': 'badge_first_audit', 'title': 'İlk Sayım', 'icon': '📦', 'desc': 'İlk stok sayım görevini tamamladın.'},
    {'id': 'badge_night_owl', 'title': 'Gece Kuşu', 'icon': '🌙', 'desc': 'Gece vardiyası sayımını tamamladın.'},
    {'id': 'badge_speedy', 'title': 'Hızlı Karınca', 'icon': '⚡', 'desc': 'Saatte 500+ barkod okutma hızına ulaştın.'},
    {'id': 'badge_perfect', 'title': 'Sıfır Hata', 'icon': '💎', 'desc': '%100 doğrulukla sayım gerçekleştirdin.'},
    {'id': 'badge_5_audits', 'title': '5 Sayım', 'icon': '🏆', 'desc': 'Toplam 5 farklı mağaza sayımına katıldın.'},
    {'id': 'badge_10_audits', 'title': '10 Sayım', 'icon': '🥇', 'desc': 'Toplam 10 mağaza sayımını geride bıraktın.'},
    {'id': 'badge_master', 'title': 'Sayım Ustası', 'icon': '👑', 'desc': '50.000 adet ürün barkodladın.'},
    {'id': 'badge_team_player', 'title': 'Takım Oyuncusu', 'icon': '🤝', 'desc': 'Ekip arkadaşların tarafından tam puan aldın.'},
    {'id': 'badge_early_bird', 'title': 'Erken Kuş', 'icon': '🌅', 'desc': 'Sabah sayımına ilk sen giriş yaptın.'},
    {'id': 'badge_iron_ant', 'title': 'Demir Karınca', 'icon': '🛡️', 'desc': 'Üst üste 5 gün sayım görevine çıktın.'},
    {'id': 'badge_legend', 'title': 'Efsane Sayman', 'icon': '🌟', 'desc': 'Sezonu ilk 3 sıralamada tamamladın.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Rozet Vitrini (12 Rozet)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: allBadges.length,
          itemBuilder: (context, index) {
            final badge = allBadges[index];
            final isUnlocked = unlockedBadgeIds.contains(badge['id']);

            return Container(
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.amber.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUnlocked ? Colors.amber : Colors.grey.shade300,
                  width: isUnlocked ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: isUnlocked ? 1.0 : 0.3,
                    child: Text(
                      badge['icon']!,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    badge['title']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                      color: isUnlocked ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}