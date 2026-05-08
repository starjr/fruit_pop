import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';
import 'services/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const FruitMergeApp());
}

class FruitMergeApp extends StatelessWidget {
  const FruitMergeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Pop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Pretendard',
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: const TextTheme().apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
          fontFamily: 'Pretendard',
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.candyPink),
      ),
      home: const HomeScreen(),
    );
  }
}
