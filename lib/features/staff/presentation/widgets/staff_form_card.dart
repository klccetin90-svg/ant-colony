import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/staff_model.dart';
import '../../utils/staff_utils.dart';

class StaffFormCard extends StatefulWidget {
  final VoidCallback onSuccess;

  const StaffFormCard({super.key, required this.onSuccess});

  @override
  State<StaffFormCard> createState() => _StaffFormCardState();
}

class _StaffFormCardState extends State<StaffFormCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _tcController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();

  String _selectedRole = 'Sayman';
  String _selectedIbanOwner = 'Kendisi';
  DateTime? _selectedBirthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ibanController.addListener(() => setState(() {}));
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

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Lütfen doğum tarihi seçiniz!'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!StaffUtils.validateTC(_tcController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Geçersiz TC Kimlik Numarası!'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!StaffUtils.validateIBAN(_ibanController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('❌ Geçersiz IBAN! TR ile başlamalı ve toplam 26 karakter olmalıdır.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newStaff = StaffModel(
        fullName: _nameController.text.trim().toUpperCase(),
        role: _selectedRole,
        phone: _phoneController.text.trim(),
        tcNo: _tcController.text.trim(),
        birthDate: _selectedBirthDate!.toIso8601String().split('T').first,
        city: _cityController.text.trim(),
        iban: _ibanController.text.trim().toUpperCase(),
        ibanOwnerType: _selectedIbanOwner,
      );

      // 1. Personel Kaydı
      final response = await Supabase.instance.client.from('staff').insert(newStaff.toJson()).select().single();

      // 2. ANT COLONY LEAGUE için Hoş Geldin Puanı (100 ANT XP) Tanımlama
      if (response != null && response['id'] != null) {
        await Supabase.instance.client.from('user_xp').upsert({
          'user_id': response['id'],
          'xp_points': 100,
          'rank_title': 'Çaylak Karınca',
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Personel başarıyla kaydedildi! (+100 ANT XP Puan Eklendi)'), backgroundColor: Colors.green),
      );

      _nameController.clear();
      _phoneController.clear();
      _tcController.clear();
      _cityController.clear();
      _ibanController.clear();
      setState(() {
        _selectedBirthDate = null;
        _selectedIbanOwner = 'Kendisi';
      });

      // Tetikleyiciyi çalıştır
      widget.onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Kayıt hatası: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ibanCleanLen = _ibanController.text.replaceAll(' ', '').length;
    final ibanRemaining = 26 - ibanCleanLen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Yeni Saha Personeli Kaydı',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.amber,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZçÇğĞıİöÖşŞüÜ\s]')),
              ],
              decoration: InputDecoration(
                labelText: 'Ad Soyad (Rakam yazılamaz)',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person_outline, color: Colors.amber),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Ad soyad giriniz' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              dropdownColor: const Color(0xFF0F172A),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Görev / Rol',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.badge_outlined, color: Colors.amber),
              ),
              items: ['Sayman', 'Ekip Amiri', 'Sayım Yöneticisi'].map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.amber,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              decoration: InputDecoration(
                labelText: 'Telefon Numarası (05XXXXXXXXX)',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.phone_outlined, color: Colors.amber),
              ),
              validator: (val) => val == null || val.length < 10 ? 'Geçerli telefon giriniz' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _tcController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.amber,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
              decoration: InputDecoration(
                labelText: 'TC Kimlik No (11 Hane)',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.fingerprint, color: Colors.amber),
              ),
              validator: (val) => val == null || val.length != 11 ? '11 hane olmalıdır' : null,
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, ibanConstraints) {
                bool isNarrow = ibanConstraints.maxWidth < 320;
                if (isNarrow) {
                  return Column(
                    children: [
                      TextFormField(
                        controller: _ibanController,
                        inputFormatters: [IbanInputFormatter(), LengthLimitingTextInputFormatter(26)],
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        cursorColor: Colors.amber,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'IBAN (TR... )',
                          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          helperText: 'Kalan karakter: $ibanRemaining / 26',
                          helperStyle: TextStyle(
                              color: ibanRemaining == 0 ? Colors.greenAccent : Colors.amber.shade300, fontSize: 11),
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.account_balance_outlined, color: Colors.amber),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'IBAN giriniz';
                          if (!StaffUtils.validateIBAN(val)) return 'TR ile başlayan 26 hane olmalı';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedIbanOwner,
                        dropdownColor: const Color(0xFF0F172A),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'IBAN Sahibi',
                          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: ['Kendisi', 'Eşi', 'Çocuğu', 'Annesi/Babası', 'Diğer'].map((owner) {
                          return DropdownMenuItem(value: owner, child: Text(owner));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedIbanOwner = val!),
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _ibanController,
                        inputFormatters: [IbanInputFormatter(), LengthLimitingTextInputFormatter(26)],
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        cursorColor: Colors.amber,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'IBAN (TR... )',
                          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          helperText: 'Kalan karakter: $ibanRemaining / 26',
                          helperStyle: TextStyle(
                              color: ibanRemaining == 0 ? Colors.greenAccent : Colors.amber.shade300, fontSize: 11),
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.account_balance_outlined, color: Colors.amber),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'IBAN giriniz';
                          if (!StaffUtils.validateIBAN(val)) return 'TR ile başlayan 26 hane olmalı';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedIbanOwner,
                        dropdownColor: const Color(0xFF0F172A),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'IBAN Sahibi',
                          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: ['Kendisi', 'Eşi', 'Çocuğu', 'Annesi/Babası', 'Diğer'].map((owner) {
                          return DropdownMenuItem(value: owner, child: Text(owner));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedIbanOwner = val!),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              '⚠️ Not: WhatsApp\'tan kopyalanan IBAN\'lardaki boşluklar otomatik silinir.',
              style: TextStyle(color: Colors.amber.shade300, fontSize: 11),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000, 1, 1),
                  firstDate: DateTime(1950, 1, 1),
                  lastDate: DateTime.now(),
                  builder: (context, child) => Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(primary: Colors.amber, surface: Color(0xFF0F172A)),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _selectedBirthDate = picked);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Doğum Tarihi',
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.cake_outlined, color: Colors.amber),
                ),
                child: Text(
                  _selectedBirthDate == null
                      ? 'Tarih Seç'
                      : '${_selectedBirthDate!.day}.${_selectedBirthDate!.month}.${_selectedBirthDate!.year}',
                  style: TextStyle(color: _selectedBirthDate == null ? Colors.white54 : Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return StaffUtils.cities.where((String city) {
                  return city.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _cityController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.amber,
                  onChanged: (val) => _cityController.text = val,
                  decoration: InputDecoration(
                    labelText: 'Çalışacağı Şehir (Yazarak Ara)',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.location_city, color: Colors.amber),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 45,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveStaff,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Personeli Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}