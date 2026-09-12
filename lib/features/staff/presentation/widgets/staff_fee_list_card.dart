import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffFeeListCard extends StatefulWidget {
  final List<Map<String, dynamic>> puantajList;
  final VoidCallback refreshData;

  const StaffFeeListCard({
    super.key,
    required this.puantajList,
    required this.refreshData,
  });

  @override
  State<StaffFeeListCard> createState() => _StaffFeeListCardState();
}

class _StaffFeeListCardState extends State<StaffFeeListCard> {
  Future<void> _togglePaymentStatus(String id, String currentStatus) async {
    final newStatus = currentStatus == 'Ödendi' ? 'Bekliyor' : 'Ödendi';
    final messenger = ScaffoldMessenger.of(context);

    try {
      await Supabase.instance.client
          .from('puantaj')
          .update({'status': newStatus})
          .eq('id', id);

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Status güncellendi: $newStatus'),
          backgroundColor: newStatus == 'Ödendi' ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 1),
        ),
      );
      widget.refreshData();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('❌ Güncelleme hatası: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deletePuantaj(String id) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Kayıt Silinsin mi?', style: TextStyle(color: Colors.amber)),
        content: const Text('Bu puantaj kaydını silmek istediğinize emin misiniz?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(false),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => navigator.pop(true),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client.from('puantaj').delete().eq('id', id);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('🗑️ Puantaj kaydı silindi!'), backgroundColor: Colors.orange),
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
    double totalAmount = 0;
    for (var item in widget.puantajList) {
      totalAmount += (item['daily_fee'] as num?)?.toDouble() ?? 0.0;
    }

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
                'Günlük Puantaj Listesi',
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Toplam: ₺${totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          widget.puantajList.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'Seçilen tarihte puantaj kaydı bulunamadı.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.puantajList.length,
                  itemBuilder: (context, index) {
                    final item = widget.puantajList[index];
                    final staffName = item['staff']?['full_name'] ?? 'Personel';
                    final role = item['role'] ?? '-';
                    final city = item['city'] ?? '-';
                    final fee = item['daily_fee']?.toString() ?? '0';
                    final status = item['status'] ?? 'Bekliyor';
                    final isPaid = status == 'Ödendi';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  staffName,
                                  style: const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '📍 $city  |  🏷️ $role',
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₺$fee',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _togglePaymentStatus(item['id'].toString(), status),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isPaid ? Colors.green : Colors.orange,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: isPaid ? Colors.green : Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                            onPressed: () => _deletePuantaj(item['id'].toString()),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
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