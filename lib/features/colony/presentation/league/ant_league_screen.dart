import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Soyadı maskeleme yardımcı fonksiyonu
String maskLastNameOnly(String fullName) {
  final parts = fullName.trim().split(' ');
  if (parts.length < 2) return fullName;
  
  final firstName = parts.sublist(0, parts.length - 1).join(' ');
  final lastName = parts.last;
  
  if (lastName.isEmpty) return fullName;
  return '$firstName ${lastName[0]}***';
}

class AntLeagueScreen extends StatefulWidget {
  final String currentUserId;

  const AntLeagueScreen({super.key, this.currentUserId = ''});

  @override
  State<AntLeagueScreen> createState() => _AntLeagueScreenState();
}

class _AntLeagueScreenState extends State<AntLeagueScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _leagueData = [];

  @override
  void initState() {
    super.initState();
    _fetchLeagueLeaderboard();
  }

  // Supabase'den Personel Puan Sıralamasını Çeken Fonksiyon
  Future<void> _fetchLeagueLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      // user_xp tablosundan puanları ve bağlanan staff detayını alıyoruz
      final response = await Supabase.instance.client
          .from('user_xp')
          .select('xp_points, rank_title, staff!inner(id, full_name, role, city)')
          .order('xp_points', ascending: false);

      final List<Map<String, dynamic>> loadedData = [];
      for (var item in (response as List)) {
        final staffData = item['staff'] ?? {};
        loadedData.add({
          'user_id': staffData['id'] ?? '',
          'full_name': staffData['full_name'] ?? 'İsimsiz Karınca',
          'role': staffData['role'] ?? 'Sayman',
          'city': staffData['city'] ?? 'Şehir Belirtilmedi',
          'xp_points': item['xp_points'] ?? 0,
          'rank_title': item['rank_title'] ?? 'Çaylak Karınca',
        });
      }

      setState(() {
        _leagueData = loadedData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lig sıralaması çekme hatası: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.amber, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ANT COLONY LEAGUE',
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _fetchLeagueLeaderboard,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _leagueData.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: Colors.amber,
                  onRefresh: _fetchLeagueLeaderboard,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _leagueData.length,
                    itemBuilder: (context, index) {
                      final item = _leagueData[index];
                      final int rank = index + 1;
                      final bool isTop3 = rank <= 3;

                      return Card(
                        color: isTop3 ? const Color(0xFF1E293B) : const Color(0xFF161F30),
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: rank == 1
                                ? Colors.amber
                                : rank == 2
                                    ? Colors.grey.shade400
                                    : rank == 3
                                        ? Colors.brown.shade300
                                        : Colors.white.withValues(alpha: 0.05),
                            width: isTop3 ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: rank == 1
                                ? Colors.amber
                                : rank == 2
                                    ? Colors.grey.shade400
                                    : rank == 3
                                        ? Colors.brown.shade300
                                        : const Color(0xFF0F172A),
                            child: Text(
                              '#$rank',
                              style: TextStyle(
                                color: isTop3 ? Colors.black : Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            maskLastNameOnly(item['full_name']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${item['role']} • ${item['city']}\nUnvan: ${item['rank_title']}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: ColorScheme.light == null ? MainAxisAlignment.center : MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item['xp_points']} XP',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'ANT Puanı',
                                style: TextStyle(color: Colors.white38, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 64, color: Colors.amber.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'Henüz ligde puanlı personel bulunmuyor.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}