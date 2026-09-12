import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/puantaj_model.dart';

class StaffFeeFormCard extends StatefulWidget {
  final List<Map<String, dynamic>> staffList;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onSuccess;

  const StaffFeeFormCard({
    super.key,
    required this.staffList,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onSuccess,
  });

  @override
  State<StaffFeeFormCard> createState() => _StaffFeeFormCardState();
}

class _StaffFeeFormCardState extends State<StaffFeeFormCard> {
  String? _selectedStaffId;
  String _selectedRole = 'Sayman';
  late TextEditingController _cityController;
  final TextEditingController _feeController = TextEditingController(text: '1000');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: 'Çanakkale');
    if (widget.staffList.isNotEmpty) {
      _selectedStaffId = widget.staffList.first['id'].toString();
    }
  }

  @override
  void didUpdateWidget(covariant StaffFeeFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.staffList.isNotEmpty && _selectedStaffId == null) {
      _selectedStaffId = widget.staffList.first['id'].toString();
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _savePuantaj() async {
    if (_selectedStaffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Lütfen bir personel seçiniz!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateStr = widget.selectedDate.toIso8601String().split('T').first;
      final newPuantaj = PuantajModel(
        staffId: _selectedStaffId!,
        workDate: dateStr,
        role: _selectedRole,
        city: _cityController.text.trim(),
        dailyFee: double.tryParse(_feeController.text) ?? 1000,
      );

      await Supabase.instance.client.from('puantaj').insert(newPuantaj.toJson());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Puantaj başarıyla eklendi!'), backgroundColor: Colors.green),
      );
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Kayıt hatası: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          const Text(
            'Günlük Puantaj Girişi',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          
          // İşlem Tarihi
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: widget.selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) widget.onDateChanged(picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'İşlem Tarihi',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.amber),
              ),
              child: Text(
                '${widget.selectedDate.day}.${widget.selectedDate.month}.${widget.selectedDate.year}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Personel Seçimi
          DropdownButtonFormField<String>(
            value: _selectedStaffId,
            dropdownColor: const Color(0xFF0F172A),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Personel Seç',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.person, color: Colors.amber),
            ),
            items: widget.staffList.map((s) {
              return DropdownMenuItem<String>(
                value: s['id'].toString(),
                child: Text(s['full_name'] ?? '', overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedStaffId = val),
          ),
          const SizedBox(height: 10),

          // Saha Görevi
          DropdownButtonFormField<String>(
            value: _selectedRole,
            dropdownColor: const Color(0xFF0F172A),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Saha Görevi',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.badge, color: Colors.amber),
            ),
            items: ['Sayman', 'Ekip Amiri', 'Sayım Yöneticisi']
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (val) => setState(() => _selectedRole = val!),
          ),
          const SizedBox(height: 10),

          // Çalışılan Şehir
          TextFormField(
            controller: _cityController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Çalışılan Şehir',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.location_city, color: Colors.amber),
            ),
          ),
          const SizedBox(height: 10),

          // Günlük Yevmiye
          TextFormField(
            controller: _feeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Günlük Yevmiye (TL)',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.payments, color: Colors.amber),
            ),
          ),
          const SizedBox(height: 16),

          // Kaydet Butonu
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _savePuantaj,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: _isLoading 
                ? const SizedBox(
                    width: 18, 
                    height: 18, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : const Icon(Icons.add, color: Colors.white),
            label: Text(
              _isLoading ? 'Kaydediliyor...' : 'Puantaj Ekle',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}