import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/staff_model.dart';
import '../../utils/staff_utils.dart';

class StaffEditDialog extends StatefulWidget {
  final StaffModel staff;
  final VoidCallback onSuccess;

  const StaffEditDialog({
    super.key,
    required this.staff,
    required this.onSuccess,
  });

  @override
  State<StaffEditDialog> createState() => _StaffEditDialogState();
}

class _StaffEditDialogState extends State<StaffEditDialog> {
  final _editFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _tcController;
  late TextEditingController _cityController;
  late TextEditingController _ibanController;

  late String _selectedRole;
  late String _selectedIbanOwner;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff.fullName);
    _phoneController = TextEditingController(text: widget.staff.phone);
    _tcController = TextEditingController(text: widget.staff.tcNo);
    _cityController = TextEditingController(text: widget.staff.city);
    _ibanController = TextEditingController(text: widget.staff.iban);
    _selectedRole = widget.staff.role;
    _selectedIbanOwner = widget.staff.ibanOwnerType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _tcController.dispose();
    _cityController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      title: Text('Personel Düzenle: ${widget.staff.fullName}',
          style: const TextStyle(color: Colors.amber, fontSize: 16)),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Ad Soyad',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Boş olamaz' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Görev',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['Sayman', 'Ekip Amiri', 'Sayım Yöneticisi']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Telefon',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _tcController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'TC No',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ibanController,
                  inputFormatters: [IbanInputFormatter(), LengthLimitingTextInputFormatter(26)],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'IBAN (TR... )',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedIbanOwner,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'IBAN Sahibi',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['Kendisi', 'Eşi', 'Çocuğu', 'Annesi/Babası', 'Diğer']
                      .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedIbanOwner = val!),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Şehir',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
          onPressed: () async {
            if (!_editFormKey.currentState!.validate()) return;
            try {
              await Supabase.instance.client.from('staff').update({
                'full_name': _nameController.text.trim().toUpperCase(),
                'role': _selectedRole,
                'phone': _phoneController.text.trim(),
                'tc_no': _tcController.text.trim(),
                'city': _cityController.text.trim(),
                'iban': _ibanController.text.trim().toUpperCase(),
                'iban_owner_type': _selectedIbanOwner,
              }).eq('id', widget.staff.id!);

              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Personel güncellendi!'), backgroundColor: Colors.green),
              );
              widget.onSuccess();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('❌ Güncelleme hatası: $e'), backgroundColor: Colors.red),
              );
            }
          },
          child: const Text('Güncelle', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}