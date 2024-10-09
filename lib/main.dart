import 'package:buybit/data/api/auth_service.dart';
import 'package:buybit/data/provider/auth_provider.dart';
import 'package:buybit/data/provider/favorite_coin_provider.dart';
import 'package:buybit/data/provider/wallet_provider.dart';
import 'package:buybit/data/api/notification_service.dart';
import 'package:buybit/navigation/navigation_screen.dart';
import 'package:buybit/screens/login_screen.dart';
import 'package:buybit/screens/resigter_screen.dart';
import 'package:buybit/screens/vertify_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestNotificationPermission();
  runApp(const BuyBitApp());
}

class BuyBitApp extends StatelessWidget {
  const BuyBitApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<WalletProvider>(
          create: (_) => WalletProvider(),
        ),
        ChangeNotifierProvider<FavoriteCoinProvider>(
          create: (_) => FavoriteCoinProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BuyBit',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            return authService.isLoggedIn()
                ? const NavigationScreen()
                : const LoginScreen();
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/verify': (context) => const VerifyScreen(),
          '/main': (context) => const NavigationScreen(),
        },
      ),
    );
  }
}
