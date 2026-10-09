import 'package:flutter/material.dart';
import '../../core/theme/tokens/app_colors.dart';

/// Centralized Adaptive App Scaffold for Pindea
class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? header;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final Widget? drawer;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const AppScaffold({
    super.key,
    required this.body,
    this.header,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.drawer,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? AppColors.darkBackground : AppColors.lightBackground);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: bg,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: SafeArea(
        child: header != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header!,
                  Expanded(child: body),
                ],
              )
            : body,
      ),
    );
  }
}


