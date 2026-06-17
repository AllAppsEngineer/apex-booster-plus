import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../domain/entities/social_card.dart';
import '../../../domain/entities/share_preset.dart';
import '../../../domain/entities/social_template.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/i18n/app_language.dart';

class ShareCardPortrait extends StatelessWidget {
  final SocialCard card;
  final SocialTemplate template;
  final AppLanguage lang;
  final BoxFit mediaFit;
  final Uint8List? videoThumbnail;

  const ShareCardPortrait({
    super.key,
    required this.card,
    required this.template,
    this.lang = AppLanguage.ptBr,
    this.mediaFit = BoxFit.cover,
    this.videoThumbnail,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    final bg = template.backgroundColor;
    final accent = template.accentColor;
    final bgEnd = Color.lerp(bg, accent, 0.06)!;

    return AspectRatio(
      aspectRatio: SharePreset.portrait.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bg, bgEnd],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withValues(alpha: 0.28),
            width: 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.5),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _ApexGridPainter(accent)),
              ),
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.13),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.09),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        accent.withValues(alpha: 0.65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.28),
                              width: 0.5,
                            ),
                          ),
                          child: Icon(Icons.bolt_rounded, color: accent, size: 10),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'APEX BOOSTER+',
                            style: TextStyle(
                              color: accent,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.28),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            'APEX',
                            style: TextStyle(
                              color: accent.withValues(alpha: 0.60),
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(height: 0.5, color: accent.withValues(alpha: 0.12)),
                    const SizedBox(height: 4),
                    if (card.importedMediaPath != null)
                      _buildMediaSlot(card.importedMediaPath!, accent, s,
                          fit: mediaFit, videoThumbnail: videoThumbnail)
                    else
                      const Spacer(),
                    const SizedBox(height: 10),
                    Text(
                      card.gameName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: accent.withValues(alpha: 0.45),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (card.caption.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        card.caption,
                        style: const TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.22),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            s.socialStudioSessionReady,
                            style: TextStyle(
                              color: accent,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (card.includeWatermark)
                      Text(
                        s.socialStudioWatermark,
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.45),
                          fontSize: 9,
                          letterSpacing: 0.3,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildMediaSlot(
  String path,
  Color accent,
  AppStrings s, {
  BoxFit fit = BoxFit.cover,
  Uint8List? videoThumbnail,
}) {
  final isVideo = _isVideoPath(path);
  return Expanded(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isVideo
          ? (videoThumbnail != null
              ? Image.memory(
                  videoThumbnail,
                  fit: fit,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _ScanLinePlaceholder(accent: accent, s: s),
                )
              : _ScanLinePlaceholder(accent: accent, s: s))
          : Image.file(
              File(path),
              fit: fit,
              width: double.infinity,
              errorBuilder: (_, __, ___) => _ScanLinePlaceholder(accent: accent, s: s),
            ),
    ),
  );
}

class _ScanLinePlaceholder extends StatefulWidget {
  final Color accent;
  final AppStrings s;
  const _ScanLinePlaceholder({required this.accent, required this.s});

  @override
  State<_ScanLinePlaceholder> createState() => _ScanLinePlaceholderState();
}

class _ScanLinePlaceholderState extends State<_ScanLinePlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _filmStrip(Color accent) => Container(
        height: 10,
        color: Colors.black.withValues(alpha: 0.55),
        padding: const EdgeInsets.symmetric(vertical: 1.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            10,
            (_) => Container(
              width: 7,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final s = widget.s;
    return LayoutBuilder(
      builder: (_, constraints) {
        final height = constraints.maxHeight;
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF111827), Color(0xFF0A0A0A)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(top: 0, left: 0, right: 0, child: _filmStrip(accent)),
              Positioned(bottom: 0, left: 0, right: 0, child: _filmStrip(accent)),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.10),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.32),
                          width: 1,
                        ),
                      ),
                      child: Icon(Icons.play_arrow_rounded, color: accent, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.apexStudioVideoPreviewLabel.toUpperCase(),
                      style: TextStyle(
                        color: accent.withValues(alpha: 0.70),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final top = _ctrl.value * (height > 0 ? height : 100);
                  return Positioned(
                    top: top,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            accent.withValues(alpha: 0.30),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

bool _isVideoPath(String path) {
  final ext = path.split('.').last.toLowerCase();
  return const {'mp4', 'mov', 'avi', 'mkv', 'webm', '3gp', '3gpp'}.contains(ext);
}

class _ApexGridPainter extends CustomPainter {
  final Color color;
  const _ApexGridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.04)
      ..strokeWidth = 0.5;
    const spacing = 22.0;
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_ApexGridPainter old) => old.color != color;
}
