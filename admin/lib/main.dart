import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/api_key_service.dart';
import 'services/post_service.dart';
import 'providers/auth_provider.dart';
import 'providers/api_key_provider.dart';
import 'providers/post_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/api_keys_screen.dart';
import 'screens/posts_screen.dart';
import 'screens/post_edit_screen.dart';
import 'screens/users_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final authService = AuthService(apiService);
    final apiKeyService = ApiKeyService(apiService);
    final postService = PostService(apiService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ApiKeyProvider(apiKeyService),
        ),
        ChangeNotifierProvider(
          create: (_) => PostProvider(postService),
        ),
      ],
      child: MaterialApp(
        title: 'AI Knowledge Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              );
            case '/dashboard':
              return MaterialPageRoute(
                builder: (_) => const DashboardScreen(),
              );
            case '/api-keys':
              return MaterialPageRoute(
                builder: (_) => const ApiKeysScreen(),
              );
            case '/posts':
              return MaterialPageRoute(
                builder: (_) => const PostsScreen(),
              );
            case '/posts/create':
              return MaterialPageRoute(
                builder: (_) => const PostEditScreen(),
              );
            case '/posts/edit':
              final postId = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (_) => PostEditScreen(postId: postId),
              );
            case '/users':
              return MaterialPageRoute(
                builder: (_) => const UsersScreen(),
              );
            default:
              return MaterialPageRoute(
                builder: (_) => const AuthWrapper(),
              );
          }
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.isLoggedIn) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}
