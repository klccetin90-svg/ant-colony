import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/turkey_cities.dart';

class BranchManagementScreen extends StatefulWidget {
  final String companyId;
  final String companyName;

  const BranchManagementScreen({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends State<BranchManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _branchNameController = TextEditingController();
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _branches = [];
  String _selectedCity = 'İstanbul';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Şubeleri Supabase'den Çekme ve A-Z Alfabetik Sıralama
  Future<void> _fetchBranches() async {
    try {
      final response = await Supabase.instance.client
          .from('company_branches')
          .select()
          .eq('company_id', widget.companyId);

      List<Map<String, dynamic>> fetchedBranches = List<Map<String, dynamic>>.from(response);

      // Şube adlarına göre A-Z alfabetik sıralama (Türkçe karakter uyumlu)
      fetchedBranches.sort((a, b) {
        String nameA = (a['branch_name'] ?? '').toString().toLowerCase();
        String nameB = (b['branch_name'] ?? '').toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      setState(() {
        _branches = fetchedBranches;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Şube çekme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  // Yeni Şube Kaydetme
  Future<void> _saveBranch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.from('company_branches').insert({
        'company_id': widget.companyId,
        'city': _selectedCity,
        'branch_name': _branchNameController.text.trim(),
      });

      _branchNameController.clear();
      _formKey.currentState!.reset();
      
      await _fetchBranches();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Şube başarıyla eklendi!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Hata: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  // Şube Silme İşlemi
  Future<void> _deleteBranch(String branchId) async {
    try {
      await Supabase.instance.client
          .from('company_branches')
          .delete()
          .eq('id', branchId);

      await _fetchBranches();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Şube silindi.'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Silme hatası: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Şehir Seçim Dialogu (Otomatik İmleç Odaklı - Autofocus)
  void _showCitySelectionDialog({required Function(String) onCitySelected}) {
    String searchQuery = '';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filteredCities = TurkeyCities.cities
              .where((c) => c.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();
          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            title: const Text('Şehir Seçin', style: TextStyle(color: Colors.white, fontSize: 16)),
            content: SizedBox(
              width: 300,
              height: 350,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.amber,
                    decoration: InputDecoration(
                      hintText: 'Şehir ara (Örn: Anka)...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      prefixIcon: const Icon(Icons.search, color: Colors.amber),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (val) => setDialogState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        final c = filteredCities[index];
                        return ListTile(
                          title: Text(c, style: const TextStyle(color: Colors.white)),
                          onTap: () {
                            onCitySelected(c);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal', style: TextStyle(color: Colors.white54)),
              ),
            ],
          );
        },
      ),
    );
  }
  // Şube Düzenleme Dialogu
  void _showEditBranchDialog(Map<String, dynamic> branch) {
    String editCity = branch['city'] ?? 'İstanbul';
    final editNameController = TextEditingController(text: branch['branch_name'] ?? '');
    final editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            title: const Text('Şubeyi Düzenle', style: TextStyle(color: Colors.white, fontSize: 16)),
            content: Form(
              key: editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Şehir Seçim Butonu
                  InkWell(
                    onTap: () {
                      _showCitySelectionDialog(
                        onCitySelected: (selected) {
                          setDialogState(() => editCity = selected);
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Şehir: $editCity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const Icon(Icons.arrow_drop_down, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: editNameController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.amber,
                    decoration: InputDecoration(
                      labelText: 'Şube Adı',
                      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Şube adı boş olamaz' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
                onPressed: () async {
                  if (!editFormKey.currentState!.validate()) return;
                  try {
                    await Supabase.instance.client
                        .from('company_branches')
                        .update({
                          'city': editCity,
                          'branch_name': editNameController.text.trim(),
                        })
                        .eq('id', branch['id']);

                    Navigator.pop(context);
                    await _fetchBranches();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✏️ Şube güncellendi.'), backgroundColor: Colors.blue),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Güncelleme hatası: $e'), backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBranches = _branches.where((branch) {
      final name = (branch['branch_name'] ?? '').toLowerCase();
      final city = (branch['city'] ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || city.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        title: Text('${widget.companyName} - Şube Yönetimi', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. BÖLÜM: YENİ ŞUBE EKLEME KARTI (Sabit) ---
                  Container(
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
                          const Text('Yeni Şube Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          // Şehir Seçim Butonu
                          InkWell(
                            onTap: () {
                              _showCitySelectionDialog(
                                onCitySelected: (selected) {
                                  setState(() => _selectedCity = selected);
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_city, color: Colors.amber, size: 20),
                                      const SizedBox(width: 10),
                                      Text('Şehir: $_selectedCity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: Colors.white70),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _branchNameController,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.amber,
                            decoration: InputDecoration(
                              labelText: 'Şube Adı (Örn: Merkez AVM)',
                              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                              filled: true,
                              fillColor: const Color(0xFF1E293B),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.store, color: Colors.amber),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Şube adı boş olamaz' : null,
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 45,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveBranch,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade800,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.add_business),
                              label: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Şubeyi Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- 2. BÖLÜM BAŞLIĞI VE ARAMA ÇUBUĞU ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kayıtlı Şubeler (A-Z)',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '(${_branches.length} Şube)',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.amber,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Şube veya şehir ara...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- 3. BÖLÜM: AMBER SCROLLBAR & EXPANDED ŞUBE LİSTESİ ---
                  Expanded(
                    child: filteredBranches.isEmpty
                        ? Center(
                            child: Text(
                              _branches.isEmpty ? 'Henüz kayıtlı şube yok.' : 'Aranan kritere uygun şube bulunamadı.',
                              style: const TextStyle(color: Colors.white54),
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
                                itemCount: filteredBranches.length,
                                itemBuilder: (context, index) {
                                  final branch = filteredBranches[index];
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8, right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                branch['branch_name'] ?? '',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Şehir: ${branch['city'] ?? '-'}',
                                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: Colors.amber, size: 18),
                                              onPressed: () => _showEditBranchDialog(branch),
                                              tooltip: 'Düzenle',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                              onPressed: () => _deleteBranch(branch['id']),
                                              tooltip: 'Sil',
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
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('GERİ DÖN', style: TextStyle(fontWeight: FontWeight.bold)),
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