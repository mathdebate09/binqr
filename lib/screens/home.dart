import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/file_storage.dart';
import '../widgets/binqr_button.dart';
import 'send.dart';
import 'receive.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;
  const HomeScreen({super.key, required this.themeModeNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showFilesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Received Files',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<File>>(
              future: FileStorage.listSavedFiles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final files = snapshot.data ?? [];
                if (files.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No files yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: files.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final file = files[index];
                      final name = p.basename(file.path);
                      final size = _formatSize(file.lengthSync());

                      return GestureDetector(
                        onTap: () => OpenFilex.open(file.path),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file_rounded),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                size,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.share_rounded),
                                onPressed: () =>
                                    Share.shareXFiles([XFile(file.path)]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQrSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Image.asset(
              'assets/images/logo-qr.png',
              height: 220,
              fit: BoxFit.contain,
              semanticLabel: 'binqr qr logo',
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Image.asset(
              isDark
                  ? 'assets/images/logo-text-dark.png'
                  : 'assets/images/logo-text-light.png',
              height: 34,
              fit: BoxFit.contain,
              semanticLabel: 'binqr',
            ),
            const SizedBox(height: 8),
            Text(
              'Transfer any file between devices using QR codes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _InfoTile(
              icon: Icons.tag_rounded,
              label: 'Version',
              value: '1.0.0',
            ),
            const SizedBox(height: 12),
            _InfoTile(
              icon: Icons.code_rounded,
              label: 'Source',
              value: 'mathdebate09/binqr',
              onTap: () => launchUrl(
                Uri.parse('https://github.com/mathdebate09/binqr'),
                mode: LaunchMode.externalApplication,
              ),
            ),
            const SizedBox(height: 28),
            BinQRButton(
              label: 'Latest Release',
              icon: Icons.open_in_new_rounded,
              width: double.infinity,
              onPressed: () => launchUrl(
                Uri.parse(
                  'https://github.com/mathdebate09/binqr/releases/latest',
                ),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: widget.themeModeNotifier,
                    builder: (_, mode, __) {
                      final isLight =
                          mode == ThemeMode.light ||
                          (mode == ThemeMode.system && !isDark);
                      return GestureDetector(
                        onTap: () {
                          widget.themeModeNotifier.value = isLight
                              ? ThemeMode.dark
                              : ThemeMode.light;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 52,
                          height: 32,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isLight
                                ? const Color(0xFFE5E5EA)
                                : const Color(0xFF3A3A3C),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            alignment: isLight
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isLight
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                size: 15,
                                color: isLight
                                    ? const Color(0xFFFF9500)
                                    : const Color(0xFF636366),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.folder_rounded, size: 22),
                    onPressed: () => _showFilesSheet(context),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.info_outline_rounded, size: 22),
                    onPressed: () => _showInfoSheet(context),
                  ),
                ],
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _showQrSheet(context),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.qr_code_2_rounded,
                              color: theme.colorScheme.onPrimary,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Image.asset(
                          isDark
                              ? 'assets/images/logo-text-dark.png'
                              : 'assets/images/logo-text-light.png',
                          height: 44,
                          fit: BoxFit.contain,
                          semanticLabel: 'binqr',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 56),

                    BinQRButton(
                      label: 'Send',
                      icon: Icons.arrow_upward_rounded,
                      width: double.infinity,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SendScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),

                    BinQRButton(
                      label: 'Receive',
                      icon: Icons.arrow_downward_rounded,
                      outlined: true,
                      width: double.infinity,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReceiveScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.secondary),
            const SizedBox(width: 12),
            Text(label, style: theme.textTheme.bodyMedium),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onTap != null
                    ? const Color(0xFF007AFF)
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
