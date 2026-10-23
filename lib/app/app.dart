import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/lifecycle/android_lifecycle_observer.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/screens/home_screen.dart';

class TeslaRoadsterGameApp extends StatefulWidget {
  const TeslaRoadsterGameApp({super.key});

  @override
  State<TeslaRoadsterGameApp> createState() => _TeslaRoadsterGameAppState();
}

class _TeslaRoadsterGameAppState extends State<TeslaRoadsterGameApp> {
  late final AndroidLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = AndroidLifecycleObserver();
    _lifecycleObserver.register();
  }

  @override
  void dispose() {
    _lifecycleObserver.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Cyber Roadster 3D',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: child,
        );
      },
      child: const HomeScreen(),
    );
  }
}
