class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Authentication endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String refresh = '$baseUrl/auth/refresh';
  static const String me = '$baseUrl/auth/me';
  
  // Countries endpoints
  static const String countries = '$baseUrl/countries';
  static String country(int id) => '$baseUrl/countries/$id';
  
  // Languages endpoints
  static const String languages = '$baseUrl/languages';
  static String language(int id) => '$baseUrl/languages/$id';
  static const String defaultLanguage = '$baseUrl/languages/default';
  
  // Categories endpoints
  static const String categories = '$baseUrl/categories';
  static String category(int id) => '$baseUrl/categories/$id';
  static String categoryProducts(int id) => '$baseUrl/categories/$id/products';
  
  // Products endpoints
  static const String products = '$baseUrl/products';
  static const String featuredProducts = '$baseUrl/products/featured';
  static String product(int id) => '$baseUrl/products/$id';
  
  // Lotteries endpoints
  static const String lotteries = '$baseUrl/lotteries';
  static const String activeLotteries = '$baseUrl/lotteries/active';
  static String lottery(int id) => '$baseUrl/lotteries/$id';
  static String buyLotteryTicket(int id) => '$baseUrl/lotteries/$id/buy-ticket';
  static String myLotteryTickets(int id) => '$baseUrl/lotteries/$id/my-tickets';
  static String drawLottery(int id) => '$baseUrl/lotteries/$id/draw';
  
  // Payments endpoints
  static const String initiatePayment = '$baseUrl/payments/initiate';
  static String paymentStatus(int id) => '$baseUrl/payments/$id/status';
  static const String paymentCallback = '$baseUrl/payments/callback';
  static const String paymentSuccess = '$baseUrl/payments/success';
  
  // User endpoint
  static const String user = '$baseUrl/user';
}