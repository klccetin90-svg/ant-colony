import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobAdvertFormCard extends StatefulWidget {
  final VoidCallback onSuccess;

  const JobAdvertFormCard({super.key, required this.onSuccess});

  @override
  State<JobAdvertFormCard> createState() => _JobAdvertFormCardState();
}

class _JobAdvertFormCardState extends State<JobAdvertFormCard> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  List<Map<String, dynamic>> _companies = [];
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _managers = [];

  Map<String, dynamic>? _selectedCompany;
  String? _selectedBranch;
  String? _selectedCity;
  String? _selectedManagerId;

  final TextEditingController _saymanFeeController = TextEditingController();
  final TextEditingController _ekipAmiriFeeController = TextEditingController();
  final TextEditingController _yoneticiFeeController = TextEditingController();
  final TextEditingController _antPuanController = TextEditingController();
  final TextEditingController _personnelCountController = TextEditingController(text: '5');

  DateTime _selectedDate = DateTime.now();

  final List<String> _cities = const [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara', 'Antalya', 'Artvin',
    'Aydın', 'Balıkesir', 'Bilecik', 'Bingöl', 'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale',
    'Çankırı', 'Çorum', 'Denizli', 'Diyarbakır', 'Edirne', 'Elazığ', 'Erzincan', 'Erzurum',
    'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane', 'Hakkari', 'Hatay', 'Isparta', 'Mersin',
    'İstanbul', 'İzmir', 'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir', 'Kocaeli',
    'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş', 'Mardin', 'Muğla', 'Muş',
    'Nevşehir', 'Niğde', 'Ordu', 'Rize', 'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas',
    'Tekirdağ', 'Tokat', 'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak', 'Van', 'Yozgat', 'Zonguldak',
    'Aksaray', 'Bayburt', 'Karaman', 'Kırıkkale', 'Batman', 'Şırnak', 'Bartın', 'Ardahan',
    'Iğdır', 'Yalova', 'Karabük', 'Kilis', 'Osmaniye', 'Düzce'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _saymanFeeController.dispose();
    _ekipAmiriFeeController.dispose();
    _yoneticiFeeController.dispose();
    _antPuanController.dispose();
    _personnelCountController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final compResponse = await _supabase.from('companies').select('*');
      final managerResponse = await _supabase.from('staff').select('id, full_name, role');

      if (!mounted) return;
      setState(() {
        _companies = List<Map<String, dynamic>>.from(compResponse);
        _managers = List<Map<String, dynamic>>.from(managerResponse);
      });
    } catch (e) {
      debugPrint('Initial data load error: $e');
    }
  }

  Future<void> _onCompanySelected(Map<String, dynamic>? company) async {
    if (company == null) return;

    setState(() {
      _selectedCompany = company;
      _selectedBranch = null;
      _branches = [];
      _saymanFeeController.clear();
      _ekipAmiriFeeController.clear();
      _yoneticiFeeController.clear();
      _antPuanController.clear();
    });

    final companyId = company['id'];

    try {
      final branchResponse = await _supabase
          .from('company_branches')
          .select('*')
          .eq('company_id', companyId);

      final ratesResponse = await _supabase
          .from('company_role_rates')
          .select('*')
          .eq('company_id', companyId);

      double saymanFee = 0;
      double ekipAmiriFee = 0;
      double yoneticiFee = 0;
      int antPuan = 0;

      for (var rate in ratesResponse) {
        final roleName = (rate['role_name'] ?? rate['role'] ?? '').toString().toLowerCase();
        final fee = double.tryParse((rate['daily_rate'] ?? rate['fee'] ?? rate['rate'] ?? 0).toString()) ?? 0;
        final points = int.tryParse((rate['ant_puan'] ?? rate['points'] ?? 0).toString()) ?? 0;

        if (roleName.contains('sayman')) {
          saymanFee = fee;
          if (points > 0) antPuan = points;
        } else if (roleName.contains('amiri') || roleName.contains('ekip')) {
          ekipAmiriFee = fee;
        } else if (roleName.contains('yonetici') || roleName.contains('yönetici')) {
          yoneticiFee = fee;
        }
      }

      if (!mounted) return;
      setState(() {
        _branches = List<Map<String, dynamic>>.from(branchResponse);
        _saymanFeeController.text = saymanFee > 0 ? saymanFee.toStringAsFixed(0) : '1000';
        _ekipAmiriFeeController.text = ekipAmiriFee > 0 ? ekipAmiriFee.toStringAsFixed(0) : '1250';
        _yoneticiFeeController.text = yoneticiFee > 0 ? yoneticiFee.toStringAsFixed(0) : '1500';
        _antPuanController.text = antPuan > 0 ? antPuan.toString() : '50';
      });
    } catch (e) {
      debugPrint('Detay verileri çekilirken hata: $e');
    }
  }

  String _getCompanyName(Map<String, dynamic> c) {
    return c['tabela_name'] ?? c['corporate_name'] ?? 'İsimsiz Firma';
  }

  String _getBranchName(Map<String, dynamic> b) {
    return b['branch_name'] ?? b['name'] ?? b['tabela_name'] ?? 'Şube';
  }

  Future<void> _publishAdvert() async {
    if (_selectedCompany == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Lütfen Firma ve Şehir seçiniz!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final compName = _getCompanyName(_selectedCompany!);
      final branchTitle = _selectedBranch ?? '';
      final String fullFirmTitle = branchTitle.isNotEmpty ? '$compName - $branchTitle' : compName;

      await _supabase.from('sayim_ilanlari').insert({
        'firm_name': fullFirmTitle,
        'city': _selectedCity,
        'job_date': _selectedDate.toIso8601String().split('T')[0],
        'staff_needed': int.tryParse(_personnelCountController.text) ?? 5,
        'sayman_fee': double.tryParse(_saymanFeeController.text) ?? 0,
        'manager_fee': double.tryParse(_yoneticiFeeController.text) ?? 0,
        'manager_id': _selectedManagerId,
        'status': 'Açık',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ İlan başarıyla yayınlandı!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ İlan yayınlama hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.amber, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.campaign, color: Colors.amber),
                SizedBox(width: 8),
                Text('Yeni Sayım İlanı Aç', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Firma Seçimi
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedCompany,
              dropdownColor: const Color(0xFF0F172A),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Firma Seç',
                labelStyle: TextStyle(color: Colors.amber),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business, color: Colors.amber),
              ),
              items: _companies.map((c) => DropdownMenuItem(value: c, child: Text(_getCompanyName(c)))).toList(),
              onChanged: _onCompanySelected,
            ),
            const SizedBox(height: 12),

            // 2. Şube Seçimi
            DropdownButtonFormField<String>(
              value: _selectedBranch,
              dropdownColor: const Color(0xFF0F172A),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Şube / Mağaza Seç',
                labelStyle: TextStyle(color: Colors.amber),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store, color: Colors.amber),
              ),
              items: _branches.map((b) => DropdownMenuItem(value: _getBranchName(b), child: Text(_getBranchName(b)))).toList(),
              onChanged: (val) => setState(() => _selectedBranch = val),
            ),
            const SizedBox(height: 12),

            // Şehir & Tarih
            Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                      return _cities.where((city) => city.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (selection) => setState(() => _selectedCity = selection),
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Şehir Ara',
                          labelStyle: TextStyle(color: Colors.amber),
                          prefixIcon: Icon(Icons.location_city, color: Colors.amber),
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Sayım Tarihi', labelStyle: TextStyle(color: Colors.amber), border: OutlineInputBorder()),
                      child: Text('${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Kadro & ANT Puan
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _personnelCountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Aranan Kadro Sayısı', labelStyle: TextStyle(color: Colors.amber), border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _antPuanController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'ANT Puan', labelStyle: TextStyle(color: Colors.amber), border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Ücretler
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _saymanFeeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Sayman Ücreti (₺)', labelStyle: TextStyle(color: Colors.amber), border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _ekipAmiriFeeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Ekip Amiri Ücreti (₺)', labelStyle: TextStyle(color: Colors.amber), border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _yoneticiFeeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Yönetici Ücreti (₺)', labelStyle: TextStyle(color: Colors.amber), border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Yönetici Atama
            DropdownButtonFormField<String>(
              value: _selectedManagerId,
              dropdownColor: const Color(0xFF0F172A),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Sayım Yöneticisi Atayın',
                labelStyle: TextStyle(color: Colors.amberAccent),
                border: OutlineInputBorder(),
              ),
              items: _managers.map((m) => DropdownMenuItem(value: m['id'].toString(), child: Text('${m['full_name']} (${m['role'] ?? 'Personel'})'))).toList(),
              onChanged: (val) => setState(() => _selectedManagerId = val),
            ),
            const SizedBox(height: 16),

            // İlanı Yayınla
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: _isLoading ? null : _publishAdvert,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('İlanı Yayınla', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}