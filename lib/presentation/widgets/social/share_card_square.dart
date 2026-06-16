import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../domain/entities/social_card.dart';
import '../../../domain/entities/share_preset.dart';
import '../../../domain/entities/social_template.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../core/i18n/app_language.dart';

class ShareCardSquare extends StatelessWidget {
  final SocialCard card;
  final SocialTemplate template;
  final AppLanguage lang;
  final BoxFit mediaFit;
  final Uint8List? videoThumbnail;

  const ShareCardSquare({
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
      aspectRatio: SharePreset.square.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bg, bgEnd],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accent.withValues(alpha: 0.18),
            width: 0.5,
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
                top: -35,
                right: -35,
                child: Container(
                  width: 160,
                  height: 160,
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
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1.5,
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
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
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
                          child: Icon(Icons.bolt_rounded, color: accent, size: 9),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'APEX BOOSTER+',
                            style: TextStyle(
                              color: accent,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
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
                              fontSize: 6,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (card.importedMediaPath != null)
                      _buildMediaSlotSquare(card.importedMediaPath!, accent, s,
                          fit: mediaFit, videoThumbnail: videoThumbnail)
                    else
                      const Spacer(),
                    const SizedBox(height: 8),
                    Text(
                      card.gameName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: accent.withValues(alpha: 0.45),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (card.caption.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        card.caption,
                        style: const TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
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
                          const SizedBox(width: 4),
                          Text(
                            s.socialStudioSessionReady,
                            style: TextStyle(
                              color: accent,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (card.includeWatermark)
                      Text(
                        s.socialStudioWatermark,
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.45),
                          fontSize: 8,
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

Widget _buildMediaSlotSquare(
  String path,
  Color accent,
  AppStrings s, {
  BoxFit fit = BoxFit.cover,
  Uint8List? videoThumbnail,
}) {
  final isVideo = _isVideoPathSquare(path);
  return Expanded(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: isVideo
          ? (videoThumbnail != null
              ? Image.memory(
                  videoThumbnail,
                  fit: fit,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      _videoPremiumPlaceholderSquare(accent, s),
                )
              : _videoPremiumPlaceholderSquare(accent, s))
          : Image.file(
              File(path),
              fit: fit,
              width: double.infinity,
              errorBuilder: (_, __, ___) =>
                  _videoPremiumPlaceholderSquare(accent, s),
            ),
    ),
  );
}

Widget _videoPremiumPlaceholderSquare(Color accent, AppStrings s) {
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
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _filmStripRowSquare(accent),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _filmStripRowSquare(accent),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.10),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.32),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.play_arrow_rounded, color: accent, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                s.apexStudioVideoPreviewLabel.toUpperCase(),
                style: TextStyle(
                  color: accent.withValues(alpha: 0.70),
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _filmStripRowSquare(Color accent) {
  return Container(
    height: 9,
    color: Colors.black.withValues(alpha: 0.55),
    padding: const EdgeInsets.symmetric(vertical: 1.5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        10,
        (_) => Container(
          width: 6,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    ),
  );
}

bool _isVideoPathSquare(String path) {
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
    const spacing = 20.0;
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
