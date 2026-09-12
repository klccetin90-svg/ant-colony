import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'branch_management_screen.dart';
import 'company_rates_screen.dart'; // 📌 YENİ EKLENDİ: Tarife ekranı importu

class CompanyAddScreen extends StatefulWidget {
  const CompanyAddScreen({super.key});

  @override
  State<CompanyAddScreen> createState() => _CompanyAddScreenState();
}

class _CompanyAddScreenState extends State<CompanyAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _corporateNameController = TextEditingController();
  final _tabelaNameController = TextEditingController();
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // Amber Scrollbar için denetleyici
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _companies = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  @override
  void dispose() {
    _corporateNameController.dispose();
    _tabelaNameController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Firmaları Supabase'den Çekme ve A-Z Alfabetik Sıralama
  Future<void> _fetchCompanies() async {
    try {
      final response = await Supabase.instance.client
          .from('companies')
          .select('*, company_branches(id)');

      List<Map<String, dynamic>> fetchedList = List<Map<String, dynamic>>.from(response);

      // Alfabetik Sıralama (A'dan Z'ye Türkçe karakter duyarlı)
      fetchedList.sort((a, b) {
        String nameA = (a['corporate_name'] ?? '').toString().toLowerCase();
        String nameB = (b['corporate_name'] ?? '').toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      setState(() {
        _companies = fetchedList;
      });
    } catch (e) {
      debugPrint('Firma çekme hatası: $e');
    }
  }

  // Yeni Firma Kaydetme
  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.from('companies').insert({
        'corporate_name': _corporateNameController.text.trim(),
        'tabela_name': _tabelaNameController.text.trim().isEmpty 
            ? null 
            : _tabelaNameController.text.trim(),
      });

      _corporateNameController.clear();
      _tabelaNameController.clear();
      _formKey.currentState!.reset();
      
      await _fetchCompanies();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Firma başarıyla eklendi!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Firma Düzenleme Dialogu
  void _showEditCompanyDialog(Map<String, dynamic> company) {
    final editCorporateController = TextEditingController(text: company['corporate_name'] ?? '');
    final editTabelaController = TextEditingController(text: company['tabela_name'] ?? '');
    final editFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Firmayı Düzenle', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Form(
          key: editFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: editCorporateController,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.amber,
                decoration: InputDecoration(
                  labelText: 'Firma Unvanı',
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Unvan boş olamaz' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: editTabelaController,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.amber,
                decoration: InputDecoration(
                  labelText: 'Tabela Adı',
                  labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
            onPressed: () async {
              if (!editFormKey.currentState!.validate()) return;
              try {
                await Supabase.instance.client
                    .from('companies')
                    .update({
                      'corporate_name': editCorporateController.text.trim(),
                      'tabela_name': editTabelaController.text.trim().isEmpty 
                          ? null 
                          : editTabelaController.text.trim(),
                    })
                    .eq('id', company['id']);

                Navigator.pop(context);
                await _fetchCompanies();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✏️ Firma güncellendi.'), backgroundColor: Colors.blue),
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
      ),
    );
  }

  // Firma Silme İşlemi
  Future<void> _deleteCompany(String companyId) async {
    try {
      await Supabase.instance.client
          .from('companies')
          .delete()
          .eq('id', companyId);

      await _fetchCompanies();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Firma silindi.'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Silme hatası: $e'), backgroundColor: Colors.red),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final filteredCompanies = _companies.where((company) {
      final corporate = (company['corporate_name'] ?? '').toLowerCase();
      final tabela = (company['tabela_name'] ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return corporate.contains(query) || tabela.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        title: const Text('ANT Stok Sayım - Firma ve Şube', style: TextStyle(color: Colors.white70, fontSize: 16)),
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
                  // --- 1. BÖLÜM: FİRMA EKLEME KARTI (Sabit) ---
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
                          TextFormField(
                            controller: _corporateNameController,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.amber,
                            decoration: InputDecoration(
                              labelText: 'Firma Unvanı (Resmi / Fatura Adı)',
                              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                              filled: true,
                              fillColor: const Color(0xFF1E293B),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.business, color: Colors.amber),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Unvan boş bırakılamaz' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _tabelaNameController,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.amber,
                            decoration: InputDecoration(
                              labelText: 'Firma Kısa Adı / Tabela Adı',
                              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                              filled: true,
                              fillColor: const Color(0xFF1E293B),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.store, color: Colors.amber),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 45,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveCompany,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade800,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.save),
                              label: _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Firma Ekle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                        'Kayıtlı Firmalar (A-Z)',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '(${_companies.length} Firma)',
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
                      hintText: 'Unvan veya tabela adı ara...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- 3. BÖLÜM: AMBER SCROLLBAR & EXPANDED FİRMA LİSTESİ ---
                  Expanded(
                    child: filteredCompanies.isEmpty
                        ? Center(
                            child: Text(
                              _companies.isEmpty ? 'Henüz kayıtlı firma yok.' : 'Aranan kritere uygun firma bulunamadı.',
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
                                itemCount: filteredCompanies.length,
                                itemBuilder: (context, index) {
                                  final company = filteredCompanies[index];
                                  final branches = company['company_branches'] as List? ?? [];
                                  
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
                                        // Sol Taraf: Firma Bilgileri
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                company['corporate_name'] ?? '',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Tabela: ${company['tabela_name'] ?? '-'}',
                                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      '${branches.length} Şube',
                                                      style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Sağ Taraf: Aksiyon Butonları
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.storefront, color: Colors.blueAccent, size: 20),
                                              onPressed: () async {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => BranchManagementScreen(
                                                      companyId: company['id'],
                                                      companyName: company['corporate_name'],
                                                    ),
                                                  ),
                                                );
                                                _fetchCompanies();
                                              },
                                              tooltip: 'Şubeleri Yönet',
                                            ),
                                            // 📌 BAĞLANAN YER: Ücretler / Tarifeler Butonu
                                            IconButton(
                                              icon: const Icon(Icons.monetization_on_outlined, color: Colors.greenAccent, size: 20),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => CompanyRatesScreen(
                                                      companyId: company['id'],
                                                      companyName: company['corporate_name'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              tooltip: 'Ücretler ve Ant Coin Tarifesi',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: Colors.amber, size: 18),
                                              onPressed: () => _showEditCompanyDialog(company),
                                              tooltip: 'Düzenle',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                              onPressed: () => _deleteCompany(company['id']),
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