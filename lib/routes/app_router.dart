import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home.dart';
import '../screens/splash_screen.dart';
import '../screens/organization/org_dashboard.dart';
import '../screens/organization/org_tournament_list.dart';
import '../screens/organization/create_tournament.dart';
import '../screens/organization/tournament_preview.dart';
import '../screens/organization/org_profile.dart';
import '../screens/player/player_dashboard.dart';
import '../screens/player/player_tournament_list.dart';
import '../screens/player/tournament_details.dart';
import '../screens/player/player_profile.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/payment/subscription_payment.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );
      
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      
      // Organization Routes
      case AppRoutes.orgDashboard:
        return MaterialPageRoute(
          builder: (_) => const OrgDashboard(),
        );
      
      case AppRoutes.orgTournamentList:
        return MaterialPageRoute(
          builder: (_) => const OrgTournamentList(),
        );
      
      case AppRoutes.createTournament:
        return MaterialPageRoute(
          builder: (_) => const CreateTournament(),
        );
      
      case AppRoutes.editTournament:
        final tournament = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (_) => CreateTournament(tournament: tournament),
        );
      
      case AppRoutes.tournamentPreview:
        return MaterialPageRoute(
          builder: (_) => const TournamentPreview(),
        );
      
      case AppRoutes.orgProfile:
        return MaterialPageRoute(
          builder: (_) => const OrgProfile(),
        );
      
      // Player Routes
      case AppRoutes.playerDashboard:
        return MaterialPageRoute(
          builder: (_) => const PlayerDashboard(),
        );
      
      case AppRoutes.playerTournamentList:
        return MaterialPageRoute(
          builder: (_) => const PlayerTournamentList(),
        );
      
      case AppRoutes.tournamentDetails:
        return MaterialPageRoute(
          builder: (_) => const TournamentDetails(),
        );
      
      case AppRoutes.playerProfile:
        return MaterialPageRoute(
          builder: (_) => const PlayerProfile(),
        );
      
      // Payment Routes
      case AppRoutes.payment:
        return MaterialPageRoute(
          builder: (_) => const PaymentScreen(),
        );
      
      case AppRoutes.subscriptionPayment:
        return MaterialPageRoute(
          builder: (_) => const SubscriptionPayment(),
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
  
  static Route<dynamic>? onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
