import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../core/i18n/app_language.dart';
import '../../../data/services/template_compositor.dart';
import '../../../domain/entities/social_card.dart';
import '../../../domain/entities/studio_template_spec.dart';

/// STUDIO-TEMPLATE-ASSETS-U2: live preview of the Apex Studio card —
/// background, media (clipped into the fixed [StudioTemplateSpec.mediaSlot]),
/// then the foreground chrome (wordmark, mascot, dynamic text). The
/// background and foreground layers are painted by
/// [TemplateComposer.paintBackground]/[paintForegroundChrome] — the exact
/// same methods the export path calls — so preview and export are
/// guaranteed to be the same composition, never two implementations that can
/// drift apart.
class TemplateShareCard extends StatefulWidget {
  final SocialCard card;
  final StudioTemplateSpec spec;
  final AppLanguage lang;
  final BoxFit mediaFit;
  final String? mediaPath;
  final bool isVideo;
  final Uint8List? videoThumbnail;

  const TemplateShareCard({
    super.key,
    required this.card,
    required this.spec,
    this.lang = AppLanguage.ptBr,
    this.mediaFit = BoxFit.cover,
    this.mediaPath,
    this.isVideo = false,
    this.videoThumbnail,
  });

  @override
  State<TemplateShareCard> createState() => _TemplateShareCardState();
}

class _TemplateShareCardState extends State<TemplateShareCard> {
  late Future<ui.Image> _backgroundFuture;
  late Future<List<ui.Image>> _chromeFuture;

  @override
  void initState() {
    super.initState();
    _backgroundFuture = TemplateComposer.backgroundFor(widget.spec);
    _chromeFuture = Future.wait([
      TemplateComposer.wordmarkImage(),
      TemplateComposer.mascotImage(),
    ]);
  }

  @override
  void didUpdateWidget(covariant TemplateShareCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spec.id != widget.spec.id) {
      _backgroundFuture = TemplateComposer.backgroundFor(widget.spec);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    // Media renders synchronously on the first frame — only the background
    // and chrome (decoded off assets) wait on their futures, so there's no
    // blank flash while they resolve.
    return AspectRatio(
      aspectRatio: spec.aspectRatio,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: spec.canvasWidth,
          height: spec.canvasHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: FutureBuilder<ui.Image>(
                  future: _backgroundFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    return CustomPaint(
                      size: Size(spec.canvasWidth, spec.canvasHeight),
                      painter: _BackgroundPainter(snapshot.data!),
                    );
                  },
                ),
              ),
              Positioned.fromRect(
                rect: spec.mediaSlot.toRect(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(spec.slotBorderRadius),
                  child: _buildMedia(),
                ),
              ),
              Positioned.fill(
                child: FutureBuilder<List<ui.Image>>(
                  future: _chromeFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    return CustomPaint(
                      size: Size(spec.canvasWidth, spec.canvasHeight),
                      painter: _ForegroundChromePainter(
                        spec: spec,
                        wordmark: snapshot.data![0],
                        mascot: snapshot.data![1],
                        gameName: widget.card.gameName,
                        caption: widget.card.caption,
                        lang: widget.lang,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.mediaPath == null) {
      return const SizedBox.expand();
    }
    if (widget.isVideo) {
      return widget.videoThumbnail != null
          ? Image.memory(
              widget.videoThumbnail!,
              fit: widget.mediaFit,
              errorBuilder: (_, __, ___) => _mediaPlaceholder(),
            )
          : _mediaPlaceholder();
    }
    return Image.file(
      File(widget.mediaPath!),
      fit: widget.mediaFit,
      errorBuilder: (_, __, ___) => _mediaPlaceholder(),
    );
  }

  Widget _mediaPlaceholder() {
    return Container(
      color: const Color(0xFF111111),
      alignment: Alignment.center,
      child: Icon(
        widget.isVideo ? Icons.videocam_outlined : Icons.image_outlined,
        color: const Color(0xFF444444),
        size: 40,
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final ui.Image background;
  const _BackgroundPainter(this.background);

  @override
  void paint(Canvas canvas, Size size) {
    TemplateComposer.paintBackground(canvas, background: background, canvasSize: size);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) =>
      oldDelegate.background != background;
}

class _ForegroundChromePainter extends CustomPainter {
  final StudioTemplateSpec spec;
  final ui.Image wordmark;
  final ui.Image mascot;
  final String gameName;
  final String caption;
  final AppLanguage lang;

  const _ForegroundChromePainter({
    required this.spec,
    required this.wordmark,
    required this.mascot,
    required this.gameName,
    required this.caption,
    required this.lang,
  });

  @override
  void paint(Canvas canvas, Size size) {
    TemplateComposer.paintForegroundChrome(
      canvas,
      spec: spec,
      wordmark: wordmark,
      mascot: mascot,
      gameName: gameName,
      caption: caption,
      lang: lang,
    );
  }

  @override
  bool shouldRepaint(covariant _ForegroundChromePainter oldDelegate) =>
      oldDelegate.spec.id != spec.id ||
      oldDelegate.gameName != gameName ||
      oldDelegate.caption != caption ||
      oldDelegate.lang != lang;
}
