import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/home/home_page.dart';
import '../pages/categories/categories_page.dart';
import '../pages/products/products_page.dart';
import '../pages/products/product_detail_page.dart';
import '../pages/profile/profile_page.dart';

class AppRouter {
  static GoRouter? _router;

  static GoRouter get router {
    return _router ??= GoRouter(
      navigatorKey: NavigatorKeys.rootNavigatorKey,
      initialLocation: '/login',
      routes: [
        // Authentication Routes
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),

        // Main App Routes (Protected)
        ShellRoute(
          navigatorKey: NavigatorKeys.shellNavigatorKey,
          builder: (context, state, child) {
            return MainScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/categories',
              name: 'categories',
              builder: (context, state) => const CategoriesPage(),
            ),
            GoRoute(
              path: '/products',
              name: 'products',
              builder: (context, state) {
                final categoryId = state.pathParameters['categoryId'];
                return ProductsPage(
                  categoryId: categoryId != null ? int.parse(categoryId) : null,
                );
              },
            ),
            GoRoute(
              path: '/category-products/:categoryId',
              name: 'category-products',
              builder: (context, state) {
                final categoryId = int.parse(state.pathParameters['categoryId']!);
                return ProductsPage(categoryId: categoryId);
              },
            ),
            GoRoute(
              path: '/product/:productId',
              name: 'product',
              builder: (context, state) {
                final productId = int.parse(state.pathParameters['productId']!);
                return ProductDetailPage(productId: productId);
              },
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        // Redirect to home if authenticated and trying to access auth pages
        if (isAuthenticated && isAuthRoute) {
          return '/home';
        }

        // Redirect to login if not authenticated and trying to access protected pages
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        // No redirect needed
        return null;
      },
    );
  }
}

class NavigatorKeys {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();
}

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/categories');
        break;
      case 2:
        context.go('/products');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update selected index based on current route
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) {
      _selectedIndex = 0;
    } else if (location.startsWith('/categories')) {
      _selectedIndex = 1;
    } else if (location.startsWith('/products') || location.startsWith('/category-products')) {
      _selectedIndex = 2;
    } else if (location.startsWith('/profile')) {
      _selectedIndex = 3;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF0099CC), // Koumbaya primary color
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Catégories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}