class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  
  // Main Routes
  static const String home = '/home';
  static const String splash = '/';
  
  // Organization Routes
  static const String orgDashboard = '/org-dashboard';
  static const String createTournament = '/create-tournament';
  static const String editTournament = '/edit-tournament';
  static const String orgTournamentList = '/org-tournament-list';
  static const String tournamentPreview = '/tournament-preview';
  static const String orgProfile = '/org-profile';
  
  // Player Routes
  static const String playerDashboard = '/player-dashboard';
  static const String playerTournamentList = '/player-tournament-list';
  static const String tournamentDetails = '/tournament-details';
  static const String playerProfile = '/player-profile';
  
  // Payment Routes
  static const String payment = '/payment';
  static const String subscriptionPayment = '/subscription-payment';
  
  // Redirect Routes
  static const String initialRoute = splash;
}

