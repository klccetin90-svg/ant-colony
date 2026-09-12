import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Staff Modelleri ve Kartları (staff/presentation/ içinden erişim)
import '../models/staff_model.dart';
import 'widgets/staff_form_card.dart';
import 'widgets/staff_list_card.dart';

// LEAGUE İMPORTLARI (colony/presentation/league/ klasörüne tam yol)
import '../../colony/presentation/league/welcome_league_dialog.dart';
import '../../colony/presentation/league/ant_league_screen.dart';

class StaffAddScreen extends StatefulWidget {
  const StaffAddScreen({super.key});

  @override
  State<StaffAddScreen> createState() => _StaffAddScreenState();
}

class _StaffAddScreenState extends State<StaffAddScreen> {
  List<StaffModel> _staffList = [];

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    try {
      final response = await Supabase.instance
          .client
          .from('staff')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _staffList = (response as List)
            .map((json) => StaffModel.fromJson(json))
            .toList();
      });
    } catch (e) {
      debugPrint('Personel listeleme hatası: $e');
    }
  }

  // Yeni Kayıt Başarılı Olduğunda Kutlama Dialog'unu Açan Fonksiyon
  void _onStaffCreatedSuccess() async {
    await _fetchStaff();

    if (!mounted) return;

    final String lastAddedName = _staffList.isNotEmpty ? _staffList.first.fullName : 'Yeni Sayman';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WelcomeLeagueDialog(
        maskedName: maskLastNameOnly(lastAddedName),
        onGoToLeague: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AntLeagueScreen(currentUserId: ''),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      appBar: AppBar(
        leadingWidth: 90,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.amber, size: 16),
          label: const Text('Geri', style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        title: const Text('Ant Colony - Personel Yönetimi', style: TextStyle(color: Colors.white70, fontSize: 16)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 768;

            if (isMobile) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    StaffFormCard(onSuccess: _onStaffCreatedSuccess),
                    const SizedBox(height: 16),
                    StaffListCard(
                      staffList: _staffList,
                      isMobile: true,
                      refreshData: _fetchStaff,
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: StaffFormCard(onSuccess: _onStaffCreatedSuccess),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 6,
                    child: StaffListCard(
                      staffList: _staffList,
                      isMobile: false,
                      refreshData: _fetchStaff,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}