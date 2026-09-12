import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SayimChatDialog extends StatefulWidget {
  final String jobId;
  final String jobTitle; // Örn: BLUEMINT Akmerkez AVM
  final String senderName; // Örn: Çetin Kılıç (Yönetici) veya Personel Adı
  final String senderRole; // Örn: 'VIP Yönetici', 'Sayım Yöneticisi', 'Sayman'

  const SayimChatDialog({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.senderName,
    required this.senderRole,
  });

  @override
  State<SayimChatDialog> createState() => _SayimChatDialogState();
}

class _SayimChatDialogState extends State<SayimChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _chatStream;

  @override
  void initState() {
    super.initState();
    // Supabase Realtime: İlgili ilana ait mesajları anlık dinle
    _chatStream = _supabase
        .from('sayim_mesajlari')
        .stream(primaryKey: ['id'])
        .eq('job_id', widget.jobId)
        .order('created_at', ascending: true);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    try {
      await _supabase.from('sayim_mesajlari').insert({
        'job_id': widget.jobId,
        'sender_name': widget.senderName,
        'sender_role': widget.senderRole,
        'message': text,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Mesaj gönderilemedi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 450,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Başlık Alanı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '💬 ${widget.jobTitle} Ekip Grubu',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.amber, height: 16),

            // Canlı Mesaj Listesi
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _chatStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.amber));
                  }
                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('Henüz mesaj yok. İlk mesajı siz yazın!', style: TextStyle(color: Colors.white54)),
                    );
                  }

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['sender_name'] == widget.senderName;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.amber.withValues(alpha: 0.2) : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isMe ? Colors.amber : Colors.white24,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${msg['sender_name']} (${msg['sender_role']})',
                                style: TextStyle(
                                  color: isMe ? Colors.amberAccent : Colors.cyanAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg['message'] ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Mesaj Yazma Kutusu
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Mesajınızı yazın...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(backgroundColor: Colors.amber),
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}