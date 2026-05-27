import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/binqr_encoder.dart';
import '../core/brightness_util.dart';
import '../widgets/binqr_button.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  File? _file;
  List<String>? _qrStrings;
  BinQRMetadata? _metadata;

  bool _sending = false;
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(
    0,
  );
  Timer? _timer;
  Timer? _holdTimer;

  final TextEditingController _chunkInputCtrl = TextEditingController();

  static const int _fps = 10; // QRs / second

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final qrs = BinQREncoder.encode(file);
    final meta = BinQRMetadata.fromQRString(qrs.first);

    _timer?.cancel();
    _holdTimer?.cancel();
    _chunkInputCtrl.clear();

    setState(() {
      _file = file;
      _qrStrings = qrs;
      _metadata = meta;
      _currentIndex.value = 0;
      _sending = false;
    });
  }

  void _startSending() async {
    if (_qrStrings == null) return;
    if (_metadata?.totalChunks == 0) return;
    await BrightnessUtil.setMax();
    _holdTimer?.cancel();
    setState(() {
      _sending = true;
      _currentIndex.value = 1;
    });
    _startLoop();
  }

  void _startLoop() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: (1000 / _fps).round()),
      _tick,
    );
  }

  void _showChunkOnce(int chunkIndex) {
    if (_qrStrings == null) return;
    final total = _metadata?.totalChunks ?? 0;
    if (total == 0) return;
    final safeIndex = chunkIndex.clamp(0, total - 1);
    _timer?.cancel();
    _holdTimer?.cancel();
    setState(() {
      _sending = true;
      _currentIndex.value = safeIndex + 1;
    });
    _holdTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !_sending) return;
      _startLoop();
    });
  }

  void _tick(Timer t) {
    if (!mounted) {
      t.cancel();
      return;
    }
    final next = _currentIndex.value + 1;
    if (next >= _qrStrings!.length) {
      _currentIndex.value = 1;
      return;
    }
    _currentIndex.value = next;
  }

  void _stopSending() async {
    _timer?.cancel();
    _holdTimer?.cancel();
    await BrightnessUtil.restore();
    setState(() {
      _sending = false;
      _currentIndex.value = 0;
    });
    _showSendAgainDialog();
  }

  int? _parseChunkInput(String value) {
    final raw = int.tryParse(value.trim());
    if (raw == null) return null;
    final total = _metadata?.totalChunks ?? 0;
    if (total == 0) return null;
    final index = raw - 1;
    if (index < 0 || index >= total) return null;
    return index;
  }

  Future<void> _showSelectChunkSheet() async {
    if (_metadata == null) return;
    final total = _metadata!.totalChunks;
    _timer?.cancel();
    _holdTimer?.cancel();
    final didSelect = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          40 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
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
                    ).colorScheme.secondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Chunk',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a chunk number (1 - $total).',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chunkInputCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Chunk #',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  BinQRButton(
                    label: 'Show',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {
                      final index = _parseChunkInput(_chunkInputCtrl.text);
                      if (index == null) return;
                      Navigator.pop(context, true);
                      _showChunkOnce(index);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (_sending && didSelect != true) {
      _startLoop();
    }
  }

  void _showSendAgainDialog() {
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
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 28),
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: Color(0xFF34C759),
            ),
            const SizedBox(height: 16),
            Text(
              'Transmission Complete',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Did the receiver get all chunks?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            BinQRButton(
              label: 'Send Again',
              icon: Icons.replay_rounded,
              width: double.infinity,
              onPressed: () {
                Navigator.pop(context);
                _startSending();
              },
            ),
            const SizedBox(height: 12),
            BinQRButton(
              label: 'Done',
              outlined: true,
              width: double.infinity,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _holdTimer?.cancel();
    _chunkInputCtrl.dispose();
    _currentIndex.dispose();
    BrightnessUtil.restore();
    super.dispose();
  }

  String get _currentQRData =>
      _qrStrings?[_currentIndex.value.clamp(
        0,
        (_qrStrings?.length ?? 1) - 1,
      )] ??
      '';

  bool get _isShowingMeta => _currentIndex.value == 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _sending ? Colors.black : theme.scaffoldBackgroundColor,
      appBar: _sending
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Send',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
      body: SafeArea(
        child: _file == null ? _buildPickerView(theme) : _buildQRView(theme),
      ),
    );
  }

  Widget _buildPickerView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.upload_file_rounded,
                size: 36,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 20),
            Text('Select a File', style: theme.textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
              'Any file type',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            BinQRButton(
              label: 'Choose File',
              icon: Icons.folder_open_rounded,
              width: double.infinity,
              onPressed: _pickFile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRView(ThemeData theme) {
    if (_sending) return _buildSendingView();
    return _buildReadyView(theme);
  }

  Widget _buildReadyView(ThemeData theme) {
    final meta = _metadata!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ready to Send', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  '${meta.fileName}${meta.fileExtension}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Chip(label: _formatSize(meta.fileSize)),
                    const SizedBox(width: 8),
                    _Chip(label: '${meta.totalChunks + 1} QR codes'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Metadata QR', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: QrImageView(
              data: _currentQRData,
              version: QrVersions.auto,
              size: 240,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Point receiver\'s camera here',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 32),

          BinQRButton(
            label: 'Start Sending',
            icon: Icons.play_arrow_rounded,
            width: double.infinity,
            onPressed: _startSending,
          ),
          const SizedBox(height: 12),
          BinQRButton(
            label: 'Choose Different File',
            outlined: true,
            width: double.infinity,
            onPressed: _pickFile,
          ),
        ],
      ),
    );
  }

  Widget _buildSendingView() {
    final total = _qrStrings!.length - 1;

    return ValueListenableBuilder<int>(
      valueListenable: _currentIndex,
      builder: (context, value, _) {
        final chunkIndex = (value - 1).clamp(0, total);
        final progress = total == 0 ? 0.0 : chunkIndex / total;

        return Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: QrImageView(
                      data: _currentQRData,
                      version: QrVersions.auto,
                      size: double.infinity,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Container(
              color: Colors.black,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QR ${chunkIndex + 1} / $total',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  BinQRButton(
                    label: 'Select Chunk',
                    icon: Icons.format_list_numbered_rounded,
                    outlined: true,
                    textColor: Colors.white,
                    width: double.infinity,
                    onPressed: (_metadata?.totalChunks ?? 0) > 0
                        ? _showSelectChunkSheet
                        : null,
                  ),
                  const SizedBox(height: 12),
                  BinQRButton(
                    label: 'Stop',
                    icon: Icons.stop_rounded,
                    color: const Color(0xFFFF3B30),
                    textColor: Colors.white,
                    width: double.infinity,
                    onPressed: _stopSending,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
