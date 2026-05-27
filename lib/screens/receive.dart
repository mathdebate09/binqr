import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:open_filex/open_filex.dart';
import '../core/binqr_encoder.dart';
import '../core/file_storage.dart';
import '../widgets/binqr_button.dart';

enum ReceiveState { waitingMeta, receiving, done, error }

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  ReceiveState _state = ReceiveState.waitingMeta;
  BinQRMetadata? _metadata;
  BinQRDecoder? _decoder;

  String? _savedPath;
  String? _errorMsg;
  final Map<int, DateTime> _lastSeenAt = {};

  Rect _scanWindow(Size size) => Rect.fromCenter(
    center: Offset(size.width / 2, size.height / 2),
    width: 260,
    height: 260,
  );

  void _onDetect(BarcodeCapture capture) async {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    if (_state == ReceiveState.waitingMeta) {
      if (BinQRMetadata.isMetadata(raw)) {
        final meta = BinQRMetadata.fromQRString(raw);
        setState(() {
          _metadata = meta;
          _decoder = BinQRDecoder(meta);
          _state = ReceiveState.receiving;
        });
      }
      return;
    }

    if (_state == ReceiveState.receiving) {
      if (BinQRMetadata.isMetadata(raw)) return;

      final chunk = BinQRChunk.fromQRString(raw);
      if (chunk == null) return;

      if (_decoder!.hasChunk(chunk.index)) return;

      final now = DateTime.now();
      final lastSeen = _lastSeenAt[chunk.index];
      if (lastSeen != null && now.difference(lastSeen).inMilliseconds < 200)
        return;
      _lastSeenAt[chunk.index] = now;

      final added = _decoder!.addChunk(chunk);
      if (added) setState(() {});
      if (_decoder!.isComplete) await _finalize();
    }
  }

  Future<void> _finalize() async {
    _scanner.stop();
    try {
      final bytes = _decoder!.assemble();
      final path = await FileStorage.save(
        bytes: bytes,
        fileName: _metadata!.fileName,
        extension: _metadata!.fileExtension,
      );
      setState(() {
        _savedPath = path;
        _state = ReceiveState.done;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _state = ReceiveState.error;
      });
    }
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      ReceiveState.waitingMeta => _buildWaitingMeta(),
      ReceiveState.receiving => _buildReceiving(),
      ReceiveState.done => _buildDone(),
      ReceiveState.error => _buildError(),
    };
  }

  // ── WAITING META ──────────────────────────────────────────────────────────

  Widget _buildWaitingMeta() {
    final size = MediaQuery.of(context).size;
    final window = _scanWindow(size);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
            scanWindow: window,
          ),

          CustomPaint(
            size: Size.infinite,
            painter: _ScanWindowPainter(scanWindow: window),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Receive',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Point at the metadata QR code',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── RECEIVING ─────────────────────────────────────────────────────────────

  Widget _buildReceiving() {
    final meta = _metadata!;
    final decoder = _decoder!;
    final progress = decoder.progress;
    final missing = decoder.missingIndices;
    final size = MediaQuery.of(context).size;
    final window = _scanWindow(size);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
            scanWindow: window,
          ),

          CustomPaint(
            size: Size.infinite,
            painter: _ScanWindowPainter(scanWindow: window),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xD4000000),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${meta.fileName}${meta.fileExtension}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatSize(meta.fileSize),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF34C759),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${decoder.receivedCount} / ${decoder.totalCount} chunks',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 16),
                    const Text(
                      'Pending chunks',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: missing
                                .map(
                                  (index) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _MissingBox(label: '${index + 1}'),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        IgnorePointer(
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      const Color(0xD4000000),
                                      const Color(0xD4000000).withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 18,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [
                                      const Color(0xD4000000),
                                      const Color(0xD4000000).withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── DONE ──────────────────────────────────────────────────────────────────

  Widget _buildDone() {
    final meta = _metadata!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF34C759),
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text('Transfer Complete', style: theme.textTheme.displayMedium),
              const SizedBox(height: 8),
              Text('Saved to binqr folder', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 32),
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
                    Text(
                      '${meta.fileName}${meta.fileExtension}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatSize(meta.fileSize),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BinQRButton(
                label: 'Open File',
                icon: Icons.open_in_new_rounded,
                width: double.infinity,
                onPressed: _savedPath != null
                    ? () => OpenFilex.open(_savedPath!)
                    : null,
              ),
              const SizedBox(height: 12),
              BinQRButton(
                label: 'Done',
                outlined: true,
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ERROR ─────────────────────────────────────────────────────────────────

  Widget _buildError() {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Color(0xFFFF3B30),
              ),
              const SizedBox(height: 20),
              Text(
                'Something went wrong',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMsg ?? 'Unknown error',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              BinQRButton(
                label: 'Go Back',
                outlined: true,
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ── SCAN WINDOW PAINTER ───────────────────────────────────────────────────────

class _ScanWindowPainter extends CustomPainter {
  final Rect scanWindow;
  const _ScanWindowPainter({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(scanWindow, const Radius.circular(20)),
        ),
      ),
      Paint()..color = Colors.black.withOpacity(0.55),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanWindow, const Radius.circular(20)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    const cornerLen = 24.0;
    const cornerRadius = 20.0;
    final accentPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
      Offset(scanWindow.left + cornerRadius, scanWindow.top),
      Offset(scanWindow.left + cornerRadius + cornerLen, scanWindow.top),
      accentPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.top + cornerRadius),
      Offset(scanWindow.left, scanWindow.top + cornerRadius + cornerLen),
      accentPaint,
    );
    // Top-right
    canvas.drawLine(
      Offset(scanWindow.right - cornerRadius, scanWindow.top),
      Offset(scanWindow.right - cornerRadius - cornerLen, scanWindow.top),
      accentPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.top + cornerRadius),
      Offset(scanWindow.right, scanWindow.top + cornerRadius + cornerLen),
      accentPaint,
    );
    // Bottom-left
    canvas.drawLine(
      Offset(scanWindow.left + cornerRadius, scanWindow.bottom),
      Offset(scanWindow.left + cornerRadius + cornerLen, scanWindow.bottom),
      accentPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.bottom - cornerRadius),
      Offset(scanWindow.left, scanWindow.bottom - cornerRadius - cornerLen),
      accentPaint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(scanWindow.right - cornerRadius, scanWindow.bottom),
      Offset(scanWindow.right - cornerRadius - cornerLen, scanWindow.bottom),
      accentPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.bottom - cornerRadius),
      Offset(scanWindow.right, scanWindow.bottom - cornerRadius - cornerLen),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(_ScanWindowPainter old) => old.scanWindow != scanWindow;
}

class _MissingBox extends StatelessWidget {
  final String label;
  const _MissingBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
