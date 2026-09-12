import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/job_advert_form_card.dart';
import 'widgets/job_advert_list_card.dart';
import 'widgets/vip_approval_card.dart';
import 'widgets/team_chat_card.dart';
import 'widgets/staff_fee_list_card.dart';

class StaffFeeScreen extends StatefulWidget {
  const StaffFeeScreen({super.key});

  @override
  State<StaffFeeScreen> createState() => _StaffFeeScreenState();
}

class _StaffFeeScreenState extends State<StaffFeeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _adverts = [];
  List<Map<String, dynamic>> _puantajList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final advertsResponse = await Supabase.instance.client
          .from('sayim_ilanlari')
          .select('*, staff:manager_id(full_name), sayim_basvurulari(*, staff(full_name))')
          .order('created_at', ascending: false);

      final puantajResponse = await Supabase.instance.client
          .from('puantaj')
          .select('*, staff:staff_id(full_name)')
          .eq('status', 'Bekliyor')
          .order('created_at', ascending: false);

      setState(() {
        _adverts = List<Map<String, dynamic>>.from(advertsResponse);
        _puantajList = List<Map<String, dynamic>>.from(puantajResponse);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Veri yükleme hatası: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Navigator.of(context).pop(),
    tooltip: 'Ana Ekrana Dön',
  ),
  title: const Text(
    'Sayım & Operasyon Yönetimi',
    style: TextStyle(color: Colors.white, fontSize: 16),
  ),
  backgroundColor: const Color(0xFF1E293B),
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh, color: Colors.amber),
      onPressed: _fetchData,
      tooltip: 'Yenile',
    ),
  ],
),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isDesktop = constraints.maxWidth > 800;

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 45,
                            child: Column(
                              children: [
                                JobAdvertFormCard(onSuccess: _fetchData),
                                const SizedBox(height: 16),
                                VipApprovalCard(
                                  openAdverts: _adverts,
                                  refreshData: _fetchData,
                                ),
                                const SizedBox(height: 16),
                                TeamChatCard(openAdverts: _adverts),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 55,
                            child: Column(
                              children: [
                                JobAdvertListCard(
                                  adverts: _adverts,
                                  refreshData: _fetchData,
                                ),
                                const SizedBox(height: 16),
                                StaffFeeListCard(
                                  puantajList: _puantajList,
                                  refreshData: _fetchData,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        JobAdvertFormCard(onSuccess: _fetchData),
                        const SizedBox(height: 16),
                        JobAdvertListCard(
                          adverts: _adverts,
                          refreshData: _fetchData,
                        ),
                        const SizedBox(height: 16),
                        VipApprovalCard(
                          openAdverts: _adverts,
                          refreshData: _fetchData,
                        ),
                        const SizedBox(height: 16),
                        TeamChatCard(openAdverts: _adverts),
                        const SizedBox(height: 16),
                        StaffFeeListCard(
                          puantajList: _puantajList,
                          refreshData: _fetchData,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}