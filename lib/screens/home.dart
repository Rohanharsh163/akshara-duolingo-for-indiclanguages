import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../supabase_config.dart';

class HomeScreen extends StatefulWidget {
  final void Function(Locale locale)? setLocale; // For language switching

  const HomeScreen({super.key, this.setLocale});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streak = 0;
  bool _loading = true;
  late User _user;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _user = SupabaseConfig.auth.currentUser!;
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      // User creation is handled by Supabase trigger
      // Just calculate streak
      await _calculateStreak();
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _calculateStreak() async {
    try {
      final response = await SupabaseConfig.client
          .from('users')
          .select()
          .eq('id', _user.id)
          .single();
      
      if (response.isNotEmpty) {
        final lastActive = DateTime.parse(response['last_active']);
        final now = DateTime.now();
        if (!_isSameDay(lastActive, now)) {
          final newStreak = (response['streak'] as int) + 1;
          await SupabaseConfig.client
              .from('users')
              .update({
                'streak': newStreak,
                'last_active': now.toIso8601String(),
              })
              .eq('id', _user.id);
          setState(() => _streak = newStreak);
        } else {
          setState(() => _streak = response['streak'] as int);
        }
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String get _userName {
    if (_user.userMetadata?['full_name']?.isNotEmpty ?? false) {
      return _user.userMetadata!['full_name'];
    }
    if (_user.email?.isNotEmpty ?? false) return _user.email!.split('@')[0];
    return AppLocalizations.of(context)!.profile;
  }

  Future<void> _logout() async {
    await SupabaseConfig.auth.signOut();
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
    widget.setLocale?.call(locale);
  }

  // Dummy function for word of the day; replace with your backend/Supabase logic
  Future<String> fetchWordOfTheDay(String language) async {
    // Replace with actual logic
    return 'పుస్తక (Book)';
  }

  // Dummy function for progress; replace with your logic
  Future<double> fetchProgress(String language) async {
    // Replace with actual logic
    return 0.6;
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with Localizations.override to allow runtime locale change
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
                // Language selection button
                PopupMenuButton<Locale>(
                  icon: const Icon(Icons.language, color: Colors.deepOrange),
                  tooltip: loc.language,
                  onSelected: _changeLanguage,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: const Locale('en'),
                      child: Text('English'),
                    ),
                    PopupMenuItem(
                      value: const Locale('te'),
                      child: Text('తెలుగు'),
                    ),
                    PopupMenuItem(
                      value: const Locale('hi'),
                      child: Text('हिन्दी'),
                    ),
                    PopupMenuItem(
                      value: const Locale('ta'),
                      child: Text('தமிழ்'),
                    ),
                  ],
                ),
                IconButton(
                  icon: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange),
                      Text('$_streak', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                  tooltip: loc.streaks,
                  onPressed: () {
                    Navigator.pushNamed(context, '/streaks');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle_rounded, color: Colors.deepOrange),
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
                      Navigator.pushNamed(context, '/modules');
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
                                    color: Colors.orange.withValues(alpha: 0.13),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 38)),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      _streak == 0 ? loc.startJourney : loc.keepItUp,
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
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[900]),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FutureBuilder<double>(
                              future: fetchProgress("Hindi"), // Replace with actual language
                              builder: (context, snapshot) {
                                double progress = snapshot.data ?? 0.0;
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
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange[900]),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder<String>(
                              future: fetchWordOfTheDay("Hindi"), // Replace with actual language
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const LinearProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text(loc.noQuestions);
                                }
                                return Text(
                                  snapshot.data ?? '',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                                );
                              },
                            ),
                            const SizedBox(height: 28),
                            // User info
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.email, color: Colors.orange[700], size: 18),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      '${loc.loggedInAs}: ${_user.email ?? "Guest"}',
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
                              onPressed: () => Navigator.pushReplacementNamed(context, '/languages'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                loc.startLearning,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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