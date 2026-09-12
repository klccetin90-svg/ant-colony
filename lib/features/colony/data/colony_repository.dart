import 'package:supabase_flutter/supabase_flutter.dart';

class ColonyRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Açık İlanları Getir
  Future<List<Map<String, dynamic>>> fetchOpenJobs() async {
    final response = await _supabase
        .from('sayim_ilanlari')
        .select('*, staff:manager_id(full_name)')
        .eq('status', 'Açık')
        .order('job_date', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  // 2. Personelin Başvurduğu İlan ID'lerini Getir
  Future<List<String>> fetchAppliedJobIds(String staffId) async {
    if (staffId.isEmpty) return [];

    final response = await _supabase
        .from('sayim_basvurulari')
        .select('job_id')
        .eq('staff_id', staffId);

    return (response as List).map((e) => e['job_id'].toString()).toList();
  }

  // 3. Sayman Olarak Başvuru Yap
  Future<void> applyAsSayman({
    required String jobId,
    required String staffId,
  }) async {
    await _supabase.from('sayim_basvurulari').insert({
      'job_id': jobId,
      'staff_id': staffId,
      'applied_role': 'Sayman',
      'status': 'Bekliyor',
    });
  }
}