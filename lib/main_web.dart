import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:verified_glam/services/supabase/vg_supabase_init.dart';
import 'package:verified_glam/services/vg_scan_history_store.dart';
import 'package:verified_glam/store/AppStore.dart';
import 'package:verified_glam/utils/AppTheme.dart';
import 'package:verified_glam/utils/BMConstants.dart';
import 'package:verified_glam/utils/BMDataGenerator.dart';
import 'package:verified_glam/utils/vg_constants.dart';
import 'package:verified_glam/web/vg_web_router.dart';

AppStore appStore = AppStore();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const VGWebBootApp());
}

/// Web-only boot — app routes (/app/*) only; marketing is static HTML.
class VGWebBootApp extends StatefulWidget {
  const VGWebBootApp({super.key});

  @override
  State<VGWebBootApp> createState() => _VGWebBootAppState();
}

class _VGWebBootAppState extends State<VGWebBootApp> {
  String? _error;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    const timeout = Duration(seconds: 45);
    try {
      await initialize(aLocaleLanguageList: languageList()).timeout(timeout);
      await VGSupabaseInit.initialize().timeout(timeout);
      await setValue(vgWalkthroughCompleteKey, true);
      await VGScanHistoryStore.clearLegacyLocalHistoryOnce();
      appStore.toggleDarkMode(value: getBoolAsync(isDarkModeOnPref));
      defaultRadius = 10;
      defaultToastGravityGlobal = ToastGravity.BOTTOM;
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (e, st) {
      debugPrint('VGWebBootApp failed: $e\n$st');
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Could not start app: $_error')),
        ),
      );
    }
    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFFF6E3E3),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF872B3F)),
          ),
        ),
      );
    }
    return Observer(
      builder: (_) {
        final theme = !appStore.isDarkModeOn ? AppThemeData.lightTheme : AppThemeData.darkTheme;
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: vgAppName,
          theme: theme,
          routerConfig: vgWebRouter,
          scrollBehavior: SBehavior(),
          supportedLocales: LanguageDataModel.languageLocales(),
          localeResolutionCallback: (locale, supportedLocales) => locale,
        );
      },
    );
  }
}
