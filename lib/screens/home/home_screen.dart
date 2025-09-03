import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../waste_provider/provider_dashboard.dart';
import '../waste_collector/collector_dashboard.dart';
import '../waste_provider/enhanced_provider_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Route to appropriate dashboard based on user role
        switch (user.role) {
          case UserRole.wasteProvider:
            return const EnhancedProviderDashboard();
          case UserRole.wasteCollector:
            return const CollectorDashboard();
          case UserRole.admin:
            return const EnhancedProviderDashboard(); // Admin uses provider dashboard for now
        }
      },
    );
  }
}