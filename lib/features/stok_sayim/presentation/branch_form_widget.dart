import 'package:flutter/material.dart';
import '../../../core/constants/turkey_cities.dart';

class BranchFormWidget extends StatefulWidget {
  final Function(String city, String branchName) onSubmit;
  final bool isLoading;

  const BranchFormWidget({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<BranchFormWidget> createState() => _BranchFormWidgetState();
}

class _BranchFormWidgetState extends State<BranchFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _branchNameController = TextEditingController();
  String _selectedCity = 'İstanbul';

  @override
  void dispose() {
    _branchNameController.dispose();
    super.dispose();
  }

  // Şehir Seçim Dialogu (Otomatik İmleç Odaklı - Autofocus)
  void _showCitySelectionDialog() {
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
                    autofocus: true, // <-- İMLEÇ OTOMATİK BURADA YANIP SÖNECEK
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
                            setState(() => _selectedCity = c);
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

  @override
  Widget build(BuildContext context) {
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
            const Text('Yeni Şube Ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            // Şehir Seçim Butonu
            InkWell(
              onTap: _showCitySelectionDialog,
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
                onPressed: widget.isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSubmit(_selectedCity, _branchNameController.text.trim());
                          _branchNameController.clear();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add_business),
                label: widget.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Şubeyi Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}