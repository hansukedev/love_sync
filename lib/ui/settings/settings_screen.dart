import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:love_sync/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = "";
  bool _notificationsEnabled = true; // Local state for demo

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = "${info.version} (${info.buildNumber})";
    });
  }

  void _showEditNameDialog(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: auth.user?.displayName ?? "",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editName),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.yourName),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await auth.updateName(controller.text.trim());
                if (mounted) Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showUnpairDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unpair),
        content: Text(l10n.unpairWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.unpair();
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: Text(l10n.unpair),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final user = auth.user;
    final l10n = AppLocalizations.of(context)!;

    String initials = "?";
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      initials = user.displayName![0].toUpperCase();
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      initials = user.email![0].toUpperCase();
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          // --- PROFILE HEADER ---
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.displayName ?? l10n.editName, // Fallback if no name
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? "",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- SECTIONS ---
          _buildSectionHeader(context, l10n.account),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(l10n.editName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEditNameDialog(context),
          ),

          const Divider(),
          _buildSectionHeader(context, l10n.appearance),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: Text(l10n.darkMode),
            value: theme.isDarkMode,
            onChanged: (val) => theme.toggleTheme(val),
          ),

          const Divider(),
          _buildSectionHeader(context, l10n.general),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: Text(l10n.notifications),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: theme.locale.languageCode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: "vi", child: Text("Tiếng Việt")),
                DropdownMenuItem(value: "en", child: Text("English")),
              ],
              onChanged: (val) {
                if (val != null) {
                  theme.setLocale(Locale(val));
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(l10n.locationSharing),
            subtitle: Text(l10n.comingSoon),
            enabled: false,
          ),

          const Divider(),
          _buildSectionHeader(context, l10n.dangerZone, isDanger: true),
          ListTile(
            leading: const Icon(Icons.heart_broken, color: Colors.red),
            title: Text(l10n.unpair, style: const TextStyle(color: Colors.red)),
            onTap: () => _showUnpairDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
            onTap: () async {
              await auth.signOut();
              // Auto navigated by main.dart
            },
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              "Phiên bản $_version",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: isDanger ? Colors.red : Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
