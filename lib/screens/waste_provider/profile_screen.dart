import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../auth/login_screen.dart';
import '../../widgets/translated_text.dart';
import '../../widgets/language_selector.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF10B981),
              Color(0xFF059669),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.currentUser;
                    return Column(
                      children: [
                        // Top Row with Language Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            LanguageSelector(
                              iconColor: Colors.white,
                              backgroundColor: theme.cardColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: user?.profileImageUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    user!.profileImageUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Text(
                                  user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.level ?? 'Beginner',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(context, 'Points', '${user?.points ?? 0}'),
                            _buildStatItem(context, 'Level', user?.level ?? 'Beginner'),
                            _buildStatItem(context, 'Reports', '${user?.achievements.length ?? 0}'),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              // Profile Options
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildProfileOption(
                        context,
                        Provider.of<LanguageProvider>(context).translate('Edit Profile'),
                        Provider.of<LanguageProvider>(context).translate('Update your personal information'),
                        Icons.person_outline,
                        () => _showEditProfile(context),
                      ),
                      _buildProfileOption(
                        context,
                        Provider.of<LanguageProvider>(context).translate('My Reports'),
                        Provider.of<LanguageProvider>(context).translate('View your waste reports history'),
                        Icons.history,
                        () => _showMyReports(context),
                      ),
                      _buildProfileOption(
                        context,
                        Provider.of<LanguageProvider>(context).translate('Achievements'),
                        Provider.of<LanguageProvider>(context).translate('View your earned badges and certificates'),
                        Icons.emoji_events,
                        () => _showAchievements(context),
                      ),
                      _buildProfileOption(
                        context,
                        Provider.of<LanguageProvider>(context).translate('Rewards Store'),
                        Provider.of<LanguageProvider>(context).translate('Redeem points for eco-friendly rewards'),
                        Icons.card_giftcard,
                        () => _showRewardsStore(context),
                      ),
                      _buildProfileOption(
                        context,
                        Provider.of<LanguageProvider>(context).translate('Settings'),
                        Provider.of<LanguageProvider>(context).translate('App preferences and notifications'),
                        Icons.settings,
                        () => _showSettings(context),
                      ),
                      _buildProfileOption(
                        context,
                        Provider.of<LanguageProvider>(context).translate('Help & Support'),
                        Provider.of<LanguageProvider>(context).translate('Get help and contact support'),
                        Icons.help_outline,
                        () => _showHelp(context),
                      ),
                      const SizedBox(height: 24),
                      
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleLogout(context),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const TranslatedText(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        TranslatedText(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: theme.textTheme.bodySmall?.color,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: theme.cardColor,
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    // Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Profile feature coming soon!')),
    );
  }

  void _showMyReports(BuildContext context) {
    // Navigate to my reports screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('My Reports feature coming soon!')),
    );
  }

  void _showAchievements(BuildContext context) {
    // Navigate to achievements screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Achievements feature coming soon!')),
    );
  }

  void _showRewardsStore(BuildContext context) {
    // Navigate to rewards store screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rewards Store feature coming soon!')),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => const SettingsBottomSheet(),
    );
  }

  void _showHelp(BuildContext context) {
    // Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support feature coming soon!')),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const TranslatedText('Logout'),
        content: const TranslatedText('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const TranslatedText('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const TranslatedText(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: theme.textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                leading: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: theme.primaryColor,
                ),
                title: const TranslatedText('Dark Mode'),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                  activeColor: theme.primaryColor,
                ),
                contentPadding: EdgeInsets.zero,
                titleTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
              );
            },
          ),
          
          ListTile(
            leading: Icon(
              Icons.notifications,
              color: theme.primaryColor,
            ),
            title: const TranslatedText('Notifications'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: theme.primaryColor,
            ),
            contentPadding: EdgeInsets.zero,
            titleTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
          ),
          
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return ListTile(
                leading: Icon(
                  Icons.language,
                  color: theme.primaryColor,
                ),
                title: const TranslatedText('Language'),
                subtitle: Text(
                  languageProvider.currentLanguageName,
                  style: TextStyle(color: theme.textTheme.bodySmall?.color),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                contentPadding: EdgeInsets.zero,
                titleTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
                onTap: () => _showLanguageSelection(context),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageSelection(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              'Language',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 20),
            
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Column(
                  children: languageProvider.supportedLanguages.map((language) {
                    final isSelected = language == languageProvider.currentLanguage;
                    final languageName = TranslationService().getLanguageName(language);
                    
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? theme.primaryColor : theme.iconTheme.color,
                        ),
                        title: Text(
                          languageName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        onTap: () async {
                          await languageProvider.changeLanguage(language);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Language changed to $languageName'),
                                backgroundColor: theme.primaryColor,
                              ),
                            );
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tileColor: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}