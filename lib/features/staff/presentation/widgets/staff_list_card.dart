import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/staff_model.dart';
import '../../utils/staff_utils.dart';
import 'staff_edit_dialog.dart';

class StaffListCard extends StatefulWidget {
  final List<StaffModel> staffList;
  final bool isMobile;
  final VoidCallback refreshData;

  const StaffListCard({
    super.key,
    required this.staffList,
    required this.isMobile,
    required this.refreshData,
  });

  @override
  State<StaffListCard> createState() => _StaffListCardState();
}

class _StaffListCardState extends State<StaffListCard> {
  String _searchQuery = '';
  final ScrollController _listScrollController = ScrollController();

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  Future<void> _deleteStaff(String? id) async {
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Personeli Sil', style: TextStyle(color: Colors.amber)),
        content: const Text('Bu personeli silmek istediğinize emin misiniz?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client.from('staff').delete().eq('id', id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Personel silindi!'), backgroundColor: Colors.orange),
      );
      widget.refreshData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Silme hatası: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditDialog(StaffModel staff) {
    showDialog(
      context: context,
      builder: (context) => StaffEditDialog(
        staff: staff,
        onSuccess: widget.refreshData,
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 IBAN panoya kopyalandı!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = widget.staffList.where((staff) {
      final query = _searchQuery.toLowerCase();
      return staff.fullName.toLowerCase().contains(query) ||
          staff.tcNo.toLowerCase().contains(query) ||
          staff.city.toLowerCase().contains(query) ||
          staff.phone.toLowerCase().contains(query) ||
          staff.role.toLowerCase().contains(query);
    }).toList();

    Widget listContent = filteredList.isEmpty
        ? const Center(child: Text('Kayıt bulunamadı.', style: TextStyle(color: Colors.white54)))
        : ListView.builder(
            controller: widget.isMobile ? null : _listScrollController,
            shrinkWrap: widget.isMobile,
            physics: widget.isMobile
                ? const NeverScrollableScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final staff = filteredList[index];

              String registrationYear = '-';
              if (staff.createdAt != null && staff.createdAt!.isNotEmpty) {
                try {
                  registrationYear = staff.createdAt!.split('-').first;
                } catch (_) {}
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      staff.fullName,
                                      style: const TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      staff.role,
                                      style: const TextStyle(
                                          color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kayıt Yılı: $registrationYear',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 18),
                              onPressed: () => _showEditDialog(staff),
                              tooltip: 'Düzenle',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                              onPressed: () => _deleteStaff(staff.id),
                              tooltip: 'Sil',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('📍 Şehir: ${staff.city.isEmpty ? '-' : staff.city}  |  📱 Tel: ${staff.phone}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'TC: ${staff.tcNo.isEmpty ? '-' : staff.tcNo}  |  IBAN: ${staff.iban} (${staff.ibanOwnerType})',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (staff.iban.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Tooltip(
                            message: 'IBAN\'ı Kopyala',
                            child: InkWell(
                              onTap: () => _copyToClipboard(staff.iban),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.copy, color: Colors.amber, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (staff.phone.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => StaffUtils.makePhoneCall(staff.phone),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              textStyle: const TextStyle(fontSize: 11),
                            ),
                            icon: const Icon(Icons.call, size: 14),
                            label: const Text('Ara'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => StaffUtils.openWhatsApp(staff.phone),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              textStyle: const TextStyle(fontSize: 11),
                            ),
                            icon: const Icon(Icons.chat, size: 14),
                            label: const Text('WhatsApp'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
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
                'Kayıtlı Saha Personelleri',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '(${filteredList.length} / ${widget.staffList.length} Personel)',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            cursorColor: Colors.amber,
            decoration: InputDecoration(
              hintText: 'Tüm alanlarda ara...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              prefixIcon: const Icon(Icons.search, color: Colors.amber, size: 20),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
          const SizedBox(height: 10),
          widget.isMobile
              ? listContent
              : Expanded(
                  child: Scrollbar(
                    controller: _listScrollController,
                    thumbVisibility: true,
                    radius: const Radius.circular(8),
                    child: listContent,
                  ),
                ),
        ],
      ),
    );
  }
}