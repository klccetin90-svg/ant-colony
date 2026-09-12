import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobAdvertListCard extends StatefulWidget {
  final List<Map<String, dynamic>> adverts;
  final VoidCallback refreshData;

  const JobAdvertListCard({
    super.key,
    required this.adverts,
    required this.refreshData,
  });

  @override
  State<JobAdvertListCard> createState() => _JobAdvertListCardState();
}

class _JobAdvertListCardState extends State<JobAdvertListCard> {
  // Başvuru Durumunu Güncelle (Onayla / Reddet)
  Future<void> _updateApplicationStatus(String applicationId, String newStatus) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Supabase.instance.client
          .from('sayim_basvurulari')
          .update({'status': newStatus})
          .eq('id', applicationId);

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Başvuru durumu: $newStatus'),
          backgroundColor: newStatus == 'Onaylandı' ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 1),
        ),
      );
      widget.refreshData();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('❌ İşlem hatası: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // İlanı Kapat / Sil
  Future<void> _deleteAdvert(String advertId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Supabase.instance.client.from('sayim_ilanlari').delete().eq('id', advertId);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('🗑️ Sayım ilanı kaldırıldı!'), backgroundColor: Colors.orange),
      );
      widget.refreshData();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('❌ Silme hatası: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📋 Aktif Sayım İlanları & Başvurular',
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Toplam: ${widget.adverts.length}',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          widget.adverts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'Henüz aktif sayım ilanı bulunmuyor.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.adverts.length,
                  itemBuilder: (context, index) {
                    final advert = widget.adverts[index];
                    final firmName = advert['firm_name'] ?? 'Firma';
                    final city = advert['city'] ?? '-';
                    final date = advert['job_date'] ?? '-';
                    final staffNeeded = advert['staff_needed']?.toString() ?? '1';
                    final saymanFee = advert['sayman_fee']?.toString() ?? '0';
                    final managerFee = advert['manager_fee']?.toString() ?? '0';
                    
                    final List applications = advert['sayim_basvurulari'] ?? [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Başlık & İptal Butonu
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$firmName ($city)',
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                onPressed: () => _deleteAdvert(advert['id']),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // Detay Etiketleri
                          Text(
                            '📅 Tarih: $date  |  👥 Kadro: $staffNeeded Kisi',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            '💰 Sayman: ₺$saymanFee  |  Yönetici: ₺$managerFee',
                            style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const Divider(color: Colors.white12, height: 16),

                          // Başvuran Personel Listesi
                          const Text(
                            'Gelen Başvurular:',
                            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),

                          applications.isEmpty
                              ? const Text(
                                  'Henüz başvuru yapılmadı.',
                                  style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
                                )
                              : Column(
                                  children: applications.map<Widget>((app) {
                                    final appId = app['id'];
                                    final staffName = app['staff']?['full_name'] ?? 'Personel';
                                    final role = app['applied_role'] ?? 'Sayman';
                                    final status = app['status'] ?? 'Beklemede';
                                    final isApproved = status == 'Onaylandı';

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '$staffName ($role)',
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ),
                                          Text(
                                            status,
                                            style: TextStyle(
                                              color: isApproved ? Colors.green : Colors.orange,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (!isApproved)
                                            IconButton(
                                              icon: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                              onPressed: () => _updateApplicationStatus(appId, 'Onaylandı'),
                                              constraints: const BoxConstraints(),
                                              padding: EdgeInsets.zero,
                                              tooltip: 'Kadroya Al (Onayla)',
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}