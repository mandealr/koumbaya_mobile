import '../config/environment.dart';

class ApiConstants {
  // Base URL dynamically set based on environment
  static String get baseUrl => Environment.baseUrl;
  
  // Authentication endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get logout => '$baseUrl/auth/logout';
  static String get refresh => '$baseUrl/auth/refresh';
  static String get me => '$baseUrl/auth/me';
  
  // Countries endpoints
  static String get countries => '$baseUrl/countries';
  static String country(int id) => '$baseUrl/countries/$id';
  
  // Languages endpoints
  static String get languages => '$baseUrl/languages';
  static String language(int id) => '$baseUrl/languages/$id';
  static String get defaultLanguage => '$baseUrl/languages/default';
  
  // Categories endpoints
  static String get categories => '$baseUrl/categories';
  static String category(int id) => '$baseUrl/categories/$id';
  static String categoryProducts(int id) => '$baseUrl/categories/$id/products';
  
  // Products endpoints
  static String get products => '$baseUrl/products';
  static String get featuredProducts => '$baseUrl/products/featured';
  static String product(int id) => '$baseUrl/products/$id';
  
  // Lotteries endpoints
  static String get lotteries => '$baseUrl/lotteries';
  static String get activeLotteries => '$baseUrl/lotteries/active';
  static String lottery(int id) => '$baseUrl/lotteries/$id';
  static String buyLotteryTicket(int id) => '$baseUrl/lotteries/$id/buy-ticket';
  static String myLotteryTickets(int id) => '$baseUrl/lotteries/$id/my-tickets';
  static String drawLottery(int id) => '$baseUrl/lotteries/$id/draw';
  
  // Payments endpoints
  static String get initiatePayment => '$baseUrl/payments/initiate';
  static String paymentStatus(int id) => '$baseUrl/payments/$id/status';
  static String get paymentCallback => '$baseUrl/payments/callback';
  static String get paymentSuccess => '$baseUrl/payments/success';
  
  // User endpoint
  static String get user => '$baseUrl/user';
  
  // Tickets endpoints  
  static String get userTickets => '$baseUrl/tickets/my-tickets';
}