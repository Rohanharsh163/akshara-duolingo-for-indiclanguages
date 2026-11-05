import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../supabase_config.dart';

class SettingsScreen extends StatelessWidget {
  final void Function(Locale locale) setLocale;

  const SettingsScreen({super.key, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = SupabaseConfig.auth.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        title: Text(loc.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepOrange),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.email, color: Colors.deepOrange),
            title: Text(loc.email),
            subtitle: Text(user?.email ?? loc.profile),
          ),
          const SizedBox(height: 16),
          Text(
            loc.language,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _languageTile(context, const Locale('en'), 'English'),
          _languageTile(context, const Locale('te'), 'తెలుగు'),
          _languageTile(context, const Locale('hi'), 'हिन्दी'),
          _languageTile(context, const Locale('ta'), 'தமிழ்'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: Text(loc.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              await SupabaseConfig.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _languageTile(BuildContext context, Locale locale, String label) {
    final selected = Localizations.localeOf(context).languageCode == locale.languageCode;
    return ListTile(
      title: Text(label),
      trailing: selected ? const Icon(Icons.check, color: Colors.deepOrange) : null,
      onTap: () => setLocale(locale),
    );
  }
}
