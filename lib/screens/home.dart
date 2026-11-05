import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../services/guest_session.dart';
import '../supabase_config.dart';

class HomeScreen extends StatefulWidget {
  final void Function(Locale locale)? setLocale;

  const HomeScreen({super.key, this.setLocale});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streak = 0;
  bool _loading = true;

  User? _user;

  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();

    _user = GuestSession.isGuest ? null : SupabaseConfig.auth.currentUser;

    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    // Guest users don't need database-based streak calculations.
    if (GuestSession.isGuest || _user == null) {
      if (mounted) {
        setState(() {
          _streak = 0;
          _loading = false;
        });
      }
      return;
    }

    try {
      await _calculateStreak();
    } catch (e) {
      debugPrint('User initialization error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _calculateStreak() async {
    try {
      if (_user == null) return;

      final response = await SupabaseConfig.client
          .from('users')
          .select()
          .eq('id', _user!.id)
          .single();

      final lastActive = DateTime.parse(response['last_active']);

      final now = DateTime.now();

      if (!_isSameDay(lastActive, now)) {
        final newStreak = (response['streak'] as int) + 1;

        await SupabaseConfig.client
            .from('users')
            .update({'streak': newStreak, 'last_active': now.toIso8601String()})
            .eq('id', _user!.id);

        if (mounted) {
          setState(() {
            _streak = newStreak;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _streak = response['streak'] as int;
          });
        }
      }
    } catch (e) {
      debugPrint('Streak calculation error: $e');
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String get _userName {
    if (GuestSession.isGuest) {
      return 'Guest';
    }

    if (_user?.userMetadata?['full_name']?.isNotEmpty ?? false) {
      return _user!.userMetadata!['full_name'];
    }

    if (_user?.email?.isNotEmpty ?? false) {
      return _user!.email!.split('@')[0];
    }

    return AppLocalizations.of(context)!.profile;
  }

  Future<void> _logout() async {
    if (GuestSession.isGuest) {
      GuestSession.end();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);

      return;
    }

    await SupabaseConfig.auth.signOut();
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });

    widget.setLocale?.call(locale);
  }

  Future<String> fetchWordOfTheDay(String language) async {
    return 'పుస్తక (Book)';
  }

  Future<double> fetchProgress(String language) async {
    return 0.6;
  }

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: _locale,
      child: Builder(
        builder: (context) {
          final loc = AppLocalizations.of(context)!;

          return Scaffold(
            backgroundColor: const Color(0xFFFDF6E3),

            appBar: AppBar(
              title: Text(
                loc.appTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                  letterSpacing: 2,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,

              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.deepOrange),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),

              actions: [
                PopupMenuButton<Locale>(
                  icon: const Icon(Icons.language, color: Colors.deepOrange),
                  tooltip: loc.language,
                  onSelected: _changeLanguage,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                    const PopupMenuItem(
                      value: Locale('te'),
                      child: Text('తెలుగు'),
                    ),
                    const PopupMenuItem(
                      value: Locale('hi'),
                      child: Text('हिन्दी'),
                    ),
                    const PopupMenuItem(
                      value: Locale('ta'),
                      child: Text('தமிழ்'),
                    ),
                  ],
                ),

                IconButton(
                  icon: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                      Text(
                        '$_streak',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  tooltip: loc.streaks,
                  onPressed: () {
                    Navigator.pushNamed(context, '/streaks');
                  },
                ),

                IconButton(
                  icon: const Icon(
                    Icons.account_circle_rounded,
                    color: Colors.deepOrange,
                  ),
                  tooltip: loc.profile,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.alreadyOnProfile)),
                    );
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.deepOrange),
                  tooltip: loc.logout,
                  onPressed: _logout,
                ),
              ],
            ),

            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.deepOrange),
                    child: Text(
                      loc.navigation,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.home),
                    title: Text(loc.home),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.school),
                    title: Text(loc.modules),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/languages');
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.leaderboard),
                    title: Text(loc.leaderboard),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/leaderboard');
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text(loc.settings),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                ],
              ),
            ),

            body: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.deepOrange),
                    ),
                  )
                : Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),

                            Text(
                              _userName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrange,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Streak card
                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 350),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withValues(
                                      alpha: 0.13,
                                    ),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '🔥',
                                    style: TextStyle(fontSize: 38),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    '$_streak',
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange,
                                    ),
                                  ),

                                  Text(
                                    loc.dayStreak,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      _streak == 0
                                          ? loc.startJourney
                                          : loc.keepItUp,
                                      style: const TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Progress bar
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                loc.yourProgress,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            FutureBuilder<double>(
                              future: fetchProgress('Hindi'),
                              builder: (context, snapshot) {
                                final progress = snapshot.data ?? 0.0;

                                return LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 12,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.green,
                                );
                              },
                            ),

                            const SizedBox(height: 32),

                            // Word of the day
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                loc.wordOfTheDay,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            FutureBuilder<String>(
                              future: fetchWordOfTheDay('Hindi'),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const LinearProgressIndicator();
                                }

                                if (snapshot.hasError) {
                                  return Text(loc.noQuestions);
                                }

                                return Text(
                                  snapshot.data ?? '',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 28),

                            // User information
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email,
                                    color: Colors.orange[700],
                                    size: 18,
                                  ),

                                  const SizedBox(width: 6),

                                  Flexible(
                                    child: Text(
                                      '${loc.loggedInAs}: ${_user?.email ?? "Guest"}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/languages',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                loc.startLearning,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
