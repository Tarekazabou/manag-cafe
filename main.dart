import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'providers/app_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/deliveries_screen.dart';
import 'screens/statistics_screen.dart';
import 'services/auth_service.dart';
import 'screens/manage_requests_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.setLanguageCode('fr');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  final token = await messaging.getToken();
  print('FCM Token: $token');
  runApp(const CoffeeShopManagerApp());
}

class CoffeeShopManagerApp extends StatelessWidget {
  const CoffeeShopManagerApp({super.key});

  // Define light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF4A2F1A),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4A2F1A),
      secondary: Color(0xFFDAB49D),
      surface: Color(0xFFF5F5F5),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF4A2F1A),
      onSurface: Color(0xFF333333),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4A2F1A),
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF4A2F1A),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF333333),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF4A2F1A),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A2F1A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      filled: true,
      fillColor: Color(0xFFF0E8E2),
      labelStyle: TextStyle(color: Color(0xFF4A2F1A)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF4A2F1A), width: 2),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    cardTheme: const CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      color: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF4A2F1A),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4A2F1A),
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );

  // Define dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: const Color(0xFF4A2F1A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4A2F1A),
      secondary: Color(0xFFDAB49D),
      surface: Color(0xFF2A2A2A),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF4A2F1A),
      onSurface: Color(0xFFE0E0E0),
    ),
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFFDAB49D),
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFDAB49D),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFE0E0E0),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFFDAB49D),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A2F1A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      filled: true,
      fillColor: Color(0xFF2A2A2A),
      labelStyle: TextStyle(color: Color(0xFFDAB49D)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFDAB49D), width: 2),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      color: Colors.grey[850],
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[900],
      selectedItemColor: const Color(0xFFDAB49D),
      unselectedItemColor: Colors.grey[500],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4A2F1A),
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider(),
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          title: 'Coffee Shop Manager',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('fr', ''),
          ],
          locale: const Locale('fr'),
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final user = snapshot.data;
              if (user == null) {
                return const LoginScreen();
              }

              final appProvider = Provider.of<AppProvider>(context);
              if (appProvider.isLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (appProvider.errorMessage != null) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => FirebaseAuth.instance.signOut(),
                          child: Text(AppLocalizations.of(context)!.signOut),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const HomeScreen();
            },
          ),
        );
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _shopCodeController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSignUpMode = false;
  bool _showShopCodeField = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shopCodeController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      setState(() {
        _showShopCodeField = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.signInError(e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
    await _authService.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _shopCodeController.text.trim(), // Added the missing argument
    );
    if (mounted) { // Check if the widget is still mounted
      setState(() {
        _showShopCodeField = true;
      });
    }
  } catch (e) {
    if (mounted) { // Check if the widget is still mounted
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.signUpError(e.toString());
      });
    }
  } finally {
    if (mounted) { // Check if the widget is still mounted
      setState(() {
        _isLoading = false;
      });
    }
  }
  }

  Future<void> _joinShop() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.requestToJoinShop(_shopCodeController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appProvider.errorMessage ?? AppLocalizations.of(context)!.requestSentSuccess)),
      );
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.joinShopError(e.toString());
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo or Title
              Text(
                _isSignUpMode ? localizations.signUp : localizations.signIn,
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: localizations.email,
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: localizations.password,
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Shop Code Field (shown after successful sign-in/sign-up)
              if (_showShopCodeField)
                TextField(
                  controller: _shopCodeController,
                  decoration: InputDecoration(
                    labelText: localizations.shopCode,
                    prefixIcon: const Icon(Icons.store),
                    helperText: localizations.shopCodeHelper,
                  ),
                ),
              if (_showShopCodeField) const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Buttons
              if (!_showShopCodeField)
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _isSignUpMode ? _signUp : _signIn,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(
                              _isSignUpMode ? localizations.signUp : localizations.signIn,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isSignUpMode = !_isSignUpMode;
                                _errorMessage = null;
                                _emailController.clear();
                                _passwordController.clear();
                              });
                            },
                            child: Text(
                              _isSignUpMode
                                  ? localizations.alreadyHaveAccount
                                  : localizations.noAccount,
                              style: TextStyle(color: theme.colorScheme.secondary),
                            ),
                          ),
                        ],
                      )
              else
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _joinShop,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          localizations.joinShop,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const InventoryScreen(),
      const SalesScreen(),
      const ManageRequestsScreen(), // Replaced AdminScreen
      const DeliveriesScreen(),
      const StatisticsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.signOutSuccess)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.signOutError(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final shopId = appProvider.shopId;

    if (shopId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.shopNotFound,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signOut,
                child: Text(localizations.signOut),
              ),
            ],
          ),
        ),
      );
    }

    final titles = [
      localizations.dashboardTitle,
      localizations.itemsScreenTitle,
      localizations.salesTitle,
      localizations.adminTitle,
      localizations.deliveriesTitle,
      localizations.statisticsTitle,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: localizations.signOut,
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.chartLine),
            activeIcon: const Icon(FontAwesomeIcons.chartLine, color: Color(0xFF4A2F1A)),
            label: localizations.dashboardTitle,
            tooltip: localizations.dashboardTooltip,
          ),
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.boxesStacked),
            activeIcon: const Icon(FontAwesomeIcons.boxesStacked, color: Color(0xFF4A2F1A)),
            label: localizations.itemsScreenTitle,
            tooltip: localizations.inventoryTooltip,
          ),
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.cashRegister),
            activeIcon: const Icon(FontAwesomeIcons.cashRegister, color: Color(0xFF4A2F1A)),
            label: localizations.salesTitle,
            tooltip: localizations.salesTooltip,
          ),
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.userLock),
            activeIcon: const Icon(FontAwesomeIcons.userLock, color: Color(0xFF4A2F1A)),
            label: localizations.adminTitle,
            tooltip: localizations.adminTooltip,
          ),
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.truck),
            activeIcon: const Icon(FontAwesomeIcons.truck, color: Color(0xFF4A2F1A)),
            label: localizations.deliveriesTitle,
            tooltip: localizations.deliveriesTooltip,
          ),
          BottomNavigationBarItem(
            icon: const Icon(FontAwesomeIcons.chartPie),
            activeIcon: const Icon(FontAwesomeIcons.chartPie, color: Color(0xFF4A2F1A)),
            label: localizations.statisticsTitle,
            tooltip: localizations.statisticsTooltip,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Placeholder implementation of InventoryScreen
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final shopId = appProvider.shopId;

    if (shopId == null) {
      return const Center(child: Text('Shop ID not available'));
    }

    return Scaffold(
      body: Center(
        child: Text('Inventory for Shop ID: $shopId'),
      ),
    );
  }
}