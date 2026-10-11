import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'state/app_state.dart';
import 'presentation/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Indonesian locale formatting for dates and currency
  await initializeDateFormatting('id_ID', null);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const DesaApps(),
    ),
  );
}

class DesaApps extends StatelessWidget {
  const DesaApps({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desa Apps - RW 05 Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}
