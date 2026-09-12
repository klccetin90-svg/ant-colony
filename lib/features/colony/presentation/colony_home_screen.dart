import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/colony_repository.dart';
import 'widgets/colony_job_card.dart';

class ColonyHomeScreen extends StatefulWidget {
  const ColonyHomeScreen({super.key});

  @override
  State<ColonyHomeScreen> createState() => _ColonyHomeScreenState();
}

class _ColonyHomeScreenState extends State<ColonyHomeScreen> {
  final ColonyRepository _repository = ColonyRepository();
  bool _isLoading = true;
  List<Map<String, dynamic>> _openJobs = [];
  List<String> _appliedJobIds = [];

  final String _currentStaffId =
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _fetchColonyData();
  }

  Future<void> _fetchColonyData() async {
    setState(() => _isLoading = true);
    try {
      final jobs = await _repository.fetchOpenJobs();
      final appliedIds = await _repository.fetchAppliedJobIds(_currentStaffId);

      setState(() {
        _openJobs = jobs;
        _appliedJobIds = appliedIds;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ İlanlar yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _applyAsSayman(String jobId) async {
    if (_currentStaffId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Lütfen önce giriş yapın!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _repository.applyAsSayman(
        jobId: jobId,
        staffId: _currentStaffId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sayman başvurunuz başarıyla alındı!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _fetchColonyData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Başvuru hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('ANT COLONY - Sayım Görevleri',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _fetchColonyData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : _openJobs.isEmpty
              ? const Center(
                  child: Text('Şu an açık sayım görevi bulunmuyor.',
                      style: TextStyle(color: Colors.white70)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _openJobs.length,
                  itemBuilder: (context, index) {
                    final job = _openJobs[index];
                    final jobId = job['id'].toString();
                    final hasApplied = _appliedJobIds.contains(jobId);

                    return ColonyJobCard(
                      job: job,
                      hasApplied: hasApplied,
                      onApply: _applyAsSayman,
                    );
                  },
                ),
    );
  }
}