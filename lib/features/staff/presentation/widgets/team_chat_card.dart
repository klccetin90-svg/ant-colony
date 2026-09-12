import 'package:flutter/material.dart';
import '../../../../features/colony/presentation/widgets/sayim_chat_dialog.dart';

class TeamChatCard extends StatelessWidget {
  final List<Map<String, dynamic>> openAdverts;

  const TeamChatCard({
    super.key,
    required this.openAdverts,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.amber, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.forum_outlined, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Ekip Sohbet Portalları',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            openAdverts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Aktif sayım grubu bulunmuyor.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: openAdverts.length,
                    itemBuilder: (context, index) {
                      final advert = openAdverts[index];
                      final firmName = advert['firm_name'] ?? 'Firma';
                      final city = advert['city'] ?? 'Şehir';
                      final managerName =
                          advert['staff']?['full_name'] ?? 'Atanmadı';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$firmName ($city)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '👤 Yönetici: $managerName',
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              icon: const Icon(Icons.chat_bubble_outline,
                                  size: 16, color: Colors.black),
                              label: const Text(
                                'Sohbet',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => SayimChatDialog(
                                    jobId: advert['id'].toString(),
                                    jobTitle: '$firmName ($city)',
                                    senderName: 'Çetin Kılıç',
                                    senderRole: 'VIP Yönetici',
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}