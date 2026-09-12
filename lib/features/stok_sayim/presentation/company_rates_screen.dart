import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyRatesScreen extends StatefulWidget {
  final String companyId;
  final String companyName;

  const CompanyRatesScreen({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<CompanyRatesScreen> createState() => _CompanyRatesScreenState();
}

class _CompanyRatesScreenState extends State<CompanyRatesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rateController = TextEditingController();
  final _coinController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Sabit Rol Seçenekleri
  final List<String> _roleOptions = [
    'Sayman',
    'Ekip Amiri',
    'Sayım Yöneticisi',
  ];
  String? _selectedRole;

  bool _isLoading = false;
  List<Map<String, dynamic>> _ratesList = [];

  @override
  void initState() {
    super.initState();
    _selectedRole = _roleOptions.first; // Varsayılan ilk rolü seçili getir
    _fetchRates();
  }

  @override
  void dispose() {
    _rateController.dispose();
    _coinController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Bu firmaya ait tarifeleri çekme
  Future<void> _fetchRates() async {
    try {
      final response = await Supabase.instance.client
          .from('company_role_rates')
          .select('*')
          .eq('company_id', widget.companyId);

      setState(() {
        _ratesList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Tarife çekme hatası: $e');
    }
  }

  // Yeni Rol ve Fiyat Tarifesi Ekleme / Güncelleme
  Future<void> _saveRate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) return;

    setState(() => _isLoading = true);

    try {
      double rate = double.tryParse(_rateController.text.replaceAll(',', '.')) ?? 0.0;
      int coin = int.tryParse(_coinController.text.trim()) ?? 0;

      // Supabase upsert (varsa güncelle, yoksa ekle)
      await Supabase.instance.client.from('company_role_rates').upsert({
        'company_id': widget.companyId,
        'role_name': _selectedRole,
        'daily_rate': rate,
        'ant_coin_reward': coin,
      }, onConflict: 'company_id,role_name');

      _rateController.clear();
      _coinController.clear();
      _formKey.currentState!.reset();
      setState(() {
        _selectedRole = _roleOptions.first;
      });

      await _fetchRates();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Firma tarifesi kaydedildi!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Tarifeyi Düzenlemek Üzere Form Alanlarına Aktarma
  void _editRate(Map<String, dynamic> rateItem) {
    setState(() {
      String roleName = rateItem['role_name'] ?? '';
      if (_roleOptions.contains(roleName)) {
        _selectedRole = roleName;
      }
      _rateController.text = (rateItem['daily_rate'] ?? '').toString();
      _coinController.text = (rateItem['ant_coin_reward'] ?? '').toString();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✏️ Tarife düzenleme moduna alındı. Bilgileri değiştirip kaydedebilirsiniz.'), backgroundColor: Colors.amber, duration: Duration(seconds: 2)),
    );
  }

  // Tarife Silme
  Future<void> _deleteRate(String rateId) async {
    try {
      await Supabase.instance.client.from('company_role_rates').delete().eq('id', rateId);
      await _fetchRates();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Tarife silindi.'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Silme hatası: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        title: Text('${widget.companyName} - Ücret & Ant Coin Tarifesi', style: const TextStyle(color: Colors.white70, fontSize: 14)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- YENİ TARİFE EKLEME FORMU ---
                  Container(
                    padding: const EdgeInsets.all(14),
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
                            'Yeni Rol ve Ücret Tarifesi Tanımla',
                            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          
                          // ŞIK AÇILIR KAPANIR ROL SEÇİMİ
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
                            items: _roleOptions.map((String role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role, style: const TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            },
                            validator: (v) => v == null || v.isEmpty ? 'Rol seçimi zorunludur' : null,
                          ),
                          
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _rateController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.amber,
                                  decoration: InputDecoration(
                                    labelText: 'Günlük Ücret (₺)',
                                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                                    filled: true,
                                    fillColor: const Color(0xFF1E293B),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Ücret girin' : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _coinController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  cursorColor: Colors.amber,
                                  decoration: InputDecoration(
                                    labelText: 'Ant Coin Ödülü',
                                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                                    filled: true,
                                    fillColor: const Color(0xFF1E293B),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Coin girin' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveRate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade800,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.add_circle_outline, size: 18),
                              label: _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Tarifeyi Kaydet / Güncelle', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- MEVCUT TARİFELER LİSTESİ ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bu Firmanın Rol & Ücret Tarifeleri',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '(${_ratesList.length} Rol)',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: _ratesList.isEmpty
                        ? const Center(
                            child: Text(
                              'Bu firma için henüz ücret tarifesi girilmemiş.',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            thickness: 8.0,
                            radius: const Radius.circular(4),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                scrollbarTheme: ScrollbarThemeData(
                                  thumbColor: WidgetStateProperty.all(Colors.amber),
                                  trackColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05)),
                                  trackVisibility: WidgetStateProperty.all(true),
                                ),
                              ),
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: _ratesList.length,
                                itemBuilder: (context, index) {
                                  final rateItem = _ratesList[index];
                                  final roleName = rateItem['role_name'] ?? '';
                                  final dailyRate = rateItem['daily_rate'] ?? 0;
                                  final coinReward = rateItem['ant_coin_reward'] ?? 0;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8, right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Sol: Rol Adı ve Ücretler
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                roleName,
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Günlük: ₺$dailyRate',
                                                    style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '$coinReward Ant Coin',
                                                        style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Sağ: Düzenle ve Sil Butonları
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: Colors.amberAccent, size: 20),
                                              onPressed: () => _editRate(rateItem),
                                              tooltip: 'Tarifeyi Düzenle',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                              onPressed: () => _deleteRate(rateItem['id']),
                                              tooltip: 'Tarifeyi Sil',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}