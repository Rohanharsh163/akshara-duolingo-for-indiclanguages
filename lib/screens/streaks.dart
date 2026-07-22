import 'package:flutter/material.dart';
import '../supabase_config.dart';

class StreaksScreen extends StatefulWidget {
  const StreaksScreen({super.key});

  @override
  State<StreaksScreen> createState() => _StreaksScreenState();
}

class _StreaksScreenState extends State<StreaksScreen> {
  @override
  void initState() {
    super.initState();
    _updateStreak();
  }

  Future<void> _updateStreak() async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) return;
    
    try {
      final response = await SupabaseConfig.client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int streak = 1;
      DateTime? lastActive;

      if (response.isNotEmpty) {
        if (response['last_active'] != null) {
          lastActive = DateTime.parse(response['last_active']);
          final last = DateTime(lastActive.year, lastActive.month, lastActive.day);
          final diff = today.difference(last).inDays;
          if (diff == 1) {
            streak = (response['streak'] ?? 0) + 1;
          } else if (diff > 1) {
            streak = 1;
          } else if (diff == 0) {
            streak = response['streak'] ?? 1;
          }
        }
        await SupabaseConfig.client
            .from('users')
            .update({
              'streak': streak,
              'last_active': today.toIso8601String(),
            })
            .eq('id', user.id);
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Streaks')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        title: const Text('🔥 Streaks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepOrange),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: SupabaseConfig.client
            .from('users')
            .select()
            .eq('id', user.id)
            .single(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading streak data'));
          }

          final userData = snapshot.data!;
          final streak = userData['streak'] ?? 0;
          final lastActive = userData['last_active'] != null 
              ? DateTime.parse(userData['last_active'])
              : DateTime.now();

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Current streak card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        '$streak',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const Text(
                        'Current Streak',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Last active: ${_formatDate(lastActive)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Streak tips
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Keep Your Streak Alive!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('Practice daily to maintain your streak'),
                      _buildTip('Complete at least one lesson per day'),
                      _buildTip('Set reminders to stay consistent'),
                      _buildTip('Challenge yourself with new modules'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.orange[600])),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
