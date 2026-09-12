import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VipApprovalCard extends StatefulWidget {
  final List<Map<String, dynamic>> openAdverts;
  final VoidCallback refreshData;

  const VipApprovalCard({
    super.key,
    required this.openAdverts,
    required this.refreshData,
  });

  @override
  State<VipApprovalCard> createState() => _VipApprovalCardState();
}

class _VipApprovalCardState extends State<VipApprovalCard> {
  String? _selectedJobId;
  final Set<String> _selectedStaffIds = {};
  bool _isLoading = false;

  // Sayımı Tamamla ve Puantaja (Ödemelere) Aktar
  Future<void> _approveAndTransferToPuantaj() async {
    if (_selectedJobId == null || _selectedStaffIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir ilan ve sayıma katılan en az 1 personel seçin.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Seçili İlanı Bul
      final advert = widget.openAdverts.firstWhere((a) => a['id'] == _selectedJobId);
      final List applications = advert['sayim_basvurulari'] ?? [];

      final List<Map<String, dynamic>> puantajInserts = [];

      for (var app in applications) {
        final staffId = app['staff_id'];
        if (_selectedStaffIds.contains(staffId)) {
          final role = app['applied_role'] ?? 'Sayman';
          final fee = role == 'Yönetici' ? advert['manager_fee'] : advert['sayman_fee'];

          puantajInserts.add({
            'job_id': advert['id'],
            'staff_id': staffId,
            'firm_name': advert['firm_name'],
            'city': advert['city'],
            'work_date': advert['job_date'],
            'role': role,
            'daily_fee': fee,
            'status': 'Bekliyor',
          });
        }
      }

      if (puantajInserts.isNotEmpty) {
        // 1. Puantaj Tablosuna Ekle
        await Supabase.instance.client.from('puantaj').insert(puantajInserts);

        // 2. İlan Durumunu Tamamlandı Yap
        await Supabase.instance.client
            .from('sayim_ilanlari')
            .update({'status': 'Tamamlandı'})
            .eq('id', _selectedJobId!);

        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(
            content: Text('✅ Sayım onaylandı! Hakedişler Ödeme Tablosuna aktarıldı.'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _selectedJobId = null;
          _selectedStaffIds.clear();
        });
        widget.refreshData();
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('❌ Onay hatası: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? selectedAdvert;
    if (_selectedJobId != null) {
      try {
        selectedAdvert = widget.openAdverts.firstWhere((a) => a['id'] == _selectedJobId);
      } catch (_) {
        selectedAdvert = null;
      }
    }

    final List approvedApplications = selectedAdvert != null
        ? (selectedAdvert['sayim_basvurulari'] as List? ?? [])
            .where((app) => app['status'] == 'Onaylandı')
            .toList()
        : [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '⭐ VIP Saha Onayı & Puantaja Aktarım',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // İlan Seçimi Dropdown
          DropdownButtonFormField<String>(
            value: _selectedJobId,
            dropdownColor: const Color(0xFF0F172A),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Sayıma Geçilecek İlanı Seçin',
              labelStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Color(0xFF0F172A),
              border: OutlineInputBorder(),
            ),
            items: widget.openAdverts.map((adv) {
              return DropdownMenuItem<String>(
                value: adv['id'].toString(),
                child: Text('${adv['firm_name']} - ${adv['city']} (${adv['job_date']})'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedJobId = val;
                _selectedStaffIds.clear();
              });
            },
          ),
          const SizedBox(height: 12),

          // Katılan Personeller
          if (selectedAdvert != null) ...[
            const Text(
              'Sayıma Katılan Kadro (Onaylanacaklar):',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            approvedApplications.isEmpty
                ? const Text(
                    'Bu ilana henüz onaylanmış bir personel kadrosu yok.',
                    style: TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
                  )
                : Column(
                    children: approvedApplications.map<Widget>((app) {
                      final staffId = app['staff_id'].toString();
                      final staffName = app['staff']?['full_name'] ?? 'Personel';
                      final role = app['applied_role'] ?? 'Sayman';
                      final isSelected = _selectedStaffIds.contains(staffId);

                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('$staffName ($role)', style: const TextStyle(color: Colors.white, fontSize: 13)),
                        activeColor: Colors.amber,
                        checkColor: Colors.black,
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedStaffIds.add(staffId);
                            } else {
                              _selectedStaffIds.remove(staffId);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _isLoading ? null : _approveAndTransferToPuantaj,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Sayımı Tamamla ve Ödeme Listesine Düşür',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}