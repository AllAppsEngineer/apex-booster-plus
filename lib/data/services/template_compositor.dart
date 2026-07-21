import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../core/i18n/app_language.dart';
import '../../core/i18n/app_strings.dart';
import '../../domain/entities/studio_template_spec.dart';

/// STUDIO-TEMPLATE-ASSETS-U2: composes the Apex Studio card from four plain
/// layers — background, media, wordmark, mascot, dynamic text — with no
/// color detection, white-area punch, or other pixel heuristic anywhere.
/// Every asset (background, wordmark, mascot) is drawn exactly as authored;
/// the media slot, wordmark rect and mascot rect are all fixed geometry from
/// [StudioTemplateSpec]. Preview ([TemplateShareCard]) and export (this
/// class) call the same [paintBackground]/[paintForegroundChrome] methods,
/// so there is only one composition, never two implementations to drift.
class TemplateComposer {
  TemplateComposer._();

  static final Map<String, Future<ui.Image>> _backgroundCache = {};
  static Future<ui.Image>? _wordmarkFuture;
  static Future<ui.Image>? _mascotFuture;

  /// The wordmark/mascot PNGs are 1024x1024 canvases with the real artwork
  /// occupying a smaller region (transparent padding around it) — these
  /// rects are that region, measured directly from the shipped assets, so
  /// drawing crops straight to the art instead of drawing a mostly-empty
  /// square into the destination rect.
  static const Rect _mascotContentSrc = Rect.fromLTRB(166, 18, 882, 1022);
  static const Rect _wordmarkContentSrc = Rect.fromLTRB(8, 408, 1004, 604);

  /// Returns the cached (or newly decoded) background image for [spec] —
  /// the raw asset, undecorated and unmodified.
  static Future<ui.Image> backgroundFor(StudioTemplateSpec spec) {
    return _backgroundCache.putIfAbsent(
      spec.id,
      () => _loadAssetImage(spec.backgroundAssetPath),
    );
  }

  /// Returns the cached (or newly decoded) wordmark image — shared by every
  /// template, loaded once for the app's lifetime.
  static Future<ui.Image> wordmarkImage() =>
      _wordmarkFuture ??= _loadAssetImage(kWordmarkAssetPath);

  /// Returns the cached (or newly decoded) mascot image — shared by every
  /// template, loaded once for the app's lifetime.
  static Future<ui.Image> mascotImage() =>
      _mascotFuture ??= _loadAssetImage(kMascotAssetPath);

  /// Raw bytes of [spec]'s background asset, unmodified — used only by the
  /// photo export path, which composites background -> media -> foreground
  /// on a single canvas (see [composeStaticCard]) and never needs a hole.
  static Future<Uint8List> backgroundAssetBytes(StudioTemplateSpec spec) async {
    final data = await rootBundle.load(spec.backgroundAssetPath);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  /// [spec]'s background, scaled to the canvas, with [spec.mediaSlot] cut
  /// out to fully transparent (`BlendMode.clear`) — this is what
  /// VideoCardExporter.kt's `backgroundPath` doc comment always assumed:
  /// "fully opaque outside the media slot". The native side composites
  /// video -> background overlay -> foreground overlay, so an unpunched
  /// (fully opaque) background PNG hides the video entirely; only this
  /// masked version lets the video frame show through the slot.
  static Future<Uint8List> videoBackgroundMaskBytes(StudioTemplateSpec spec) async {
    final background = await backgroundFor(spec);
    final canvasSize = Size(spec.canvasWidth, spec.canvasHeight);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & canvasSize);
    paintBackground(canvas, background: background, canvasSize: canvasSize);
    canvas.drawRect(spec.mediaSlot.toRect(), Paint()..blendMode = BlendMode.clear);
    return _encodeCanvasToPng(recorder, spec);
  }

  static Future<ui.Image> _loadAssetImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Draws [media] into [slot] using [fit] (the same box-fit math Flutter
  /// widgets use — `applyBoxFit` — so preview and export crop identically).
  static void paintMediaInSlot(
    Canvas canvas, {
    required TemplateMediaSlot slot,
    required ui.Image media,
    required BoxFit fit,
  }) {
    final slotRect = slot.toRect();
    final mediaSize = Size(media.width.toDouble(), media.height.toDouble());
    final fitted = applyBoxFit(fit, mediaSize, slotRect.size);
    final srcRect =
        Alignment.center.inscribe(fitted.source, Offset.zero & mediaSize);
    final dstRect = Alignment.center.inscribe(fitted.destination, slotRect);
    canvas.drawImageRect(media, srcRect, dstRect, Paint()..filterQuality = FilterQuality.high);
  }

  /// Draws the background full-bleed over [canvasSize] — the bottom layer,
  /// drawn before the media so the media can sit on top of it inside the
  /// fixed slot. No transparency, no punch: the asset is opaque and is drawn
  /// exactly as authored.
  static void paintBackground(
    Canvas canvas, {
    required ui.Image background,
    required Size canvasSize,
  }) {
    canvas.drawImageRect(
      background,
      Rect.fromLTWH(0, 0, background.width.toDouble(), background.height.toDouble()),
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      Paint(),
    );
  }

  /// Draws every layer that sits ON TOP of the media — wordmark, mascot,
  /// then the dynamic text — at [spec]'s fixed rects. Shared by the photo
  /// export's final layer, the video export's transparent `overlayPath`
  /// PNG, and the live preview, so all three render identically.
  static void paintForegroundChrome(
    Canvas canvas, {
    required StudioTemplateSpec spec,
    required ui.Image wordmark,
    required ui.Image mascot,
    required String gameName,
    required String caption,
    required AppLanguage lang,
  }) {
    canvas.drawImageRect(
      wordmark,
      _wordmarkContentSrc,
      spec.wordmarkRect,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.drawImageRect(
      mascot,
      _mascotContentSrc,
      spec.mascotRect,
      Paint()..filterQuality = FilterQuality.high,
    );
    _paintTextLayer(canvas, spec: spec, gameName: gameName, caption: caption, lang: lang);
  }

  /// Composes a full-resolution static card — background, media, then the
  /// foreground chrome (wordmark/mascot/text) — and returns PNG bytes. Used
  /// by the "Gerar card" (photo) export path.
  static Future<Uint8List> composeStaticCard({
    required StudioTemplateSpec spec,
    required ui.Image media,
    required BoxFit fit,
    required String gameName,
    required String caption,
    required AppLanguage lang,
  }) async {
    final background = await backgroundFor(spec);
    final wordmark = await wordmarkImage();
    final mascot = await mascotImage();
    final canvasSize = Size(spec.canvasWidth, spec.canvasHeight);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Offset.zero & canvasSize);

    paintBackground(canvas, background: background, canvasSize: canvasSize);

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(
      spec.mediaSlot.toRect(),
      Radius.circular(spec.slotBorderRadius),
    ));
    paintMediaInSlot(canvas, slot: spec.mediaSlot, media: media, fit: fit);
    canvas.restore();

    paintForegroundChrome(
      canvas,
      spec: spec,
      wordmark: wordmark,
      mascot: mascot,
      gameName: gameName,
      caption: caption,
      lang: lang,
    );

    return _encodeCanvasToPng(recorder, spec);
  }

  /// Composes ONLY the foreground chrome (wordmark, mascot, game
  /// name/caption/"session ready" badge) on an otherwise fully transparent
  /// canvas — used as the native video export's `overlayPath` PNG, painted
  /// by the native side on top of the composited video + background.
  static Future<Uint8List> composeOverlayLayer({
    required StudioTemplateSpec spec,
    required String gameName,
    required String caption,
    required AppLanguage lang,
  }) async {
    final wordmark = await wordmarkImage();
    final mascot = await mascotImage();
    final recorder = ui.PictureRecorder();
    final canvasSize = Size(spec.canvasWidth, spec.canvasHeight);
    final canvas = Canvas(recorder, Offset.zero & canvasSize);
    paintForegroundChrome(
      canvas,
      spec: spec,
      wordmark: wordmark,
      mascot: mascot,
      gameName: gameName,
      caption: caption,
      lang: lang,
    );
    return _encodeCanvasToPng(recorder, spec);
  }

  static void _paintTextLayer(
    Canvas canvas, {
    required StudioTemplateSpec spec,
    required String gameName,
    required String caption,
    required AppLanguage lang,
  }) {
    final zone = spec.textZoneRect;
    final s = AppStrings(lang);
    final isHorizontal = spec.orientation == StudioTemplateOrientation.horizontal;
    // Horizontal's margin band below the slot is only ~114px vs vertical's
    // ~212px (see textZoneRect) — that budget can't fit a big name AND a
    // big caption AND the badge, so horizontal trades a smaller name (down
    // to vertical's own 56, still bold/legible) for a materially bigger,
    // single-line caption, a tighter name->caption gap, and no badge (the
    // least essential line) — the freed room is what keeps the caption
    // fully on-canvas instead of pressed against the bottom edge (the
    // "legenda baixa e pequena" bug).
    const nameFontSize = 56.0;
    final captionFontSize = isHorizontal ? 40.0 : 30.0;
    final nameCaptionGap = isHorizontal ? 2.0 : 8.0;
    final captionMaxLines = isHorizontal ? 1 : 2;
    var cursorY = zone.top;

    if (gameName.trim().isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: gameName,
          style: TextStyle(
            color: Colors.white,
            fontSize: nameFontSize,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 14)],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      );
      tp.layout(maxWidth: zone.width);
      tp.paint(canvas, Offset(zone.left, cursorY));
      cursorY += tp.height + nameCaptionGap;
    }

    if (caption.trim().isNotEmpty && cursorY < zone.bottom) {
      final tp = TextPainter(
        text: TextSpan(
          text: caption,
          style: TextStyle(color: const Color(0xFFE5E5E5), fontSize: captionFontSize, height: 1.25),
        ),
        textDirection: TextDirection.ltr,
        maxLines: captionMaxLines,
        ellipsis: '…',
      );
      tp.layout(maxWidth: zone.width);
      tp.paint(canvas, Offset(zone.left, cursorY));
      cursorY += tp.height + 10;
    }

    // Horizontal's tight text band has no room left for the badge after a
    // bigger name+caption — see the budget note above [nameFontSize].
    if (!isHorizontal && cursorY < zone.bottom) {
      final badgeTp = TextPainter(
        text: TextSpan(
          text: s.socialStudioSessionReady,
          style: const TextStyle(color: Color(0xFF22C55E), fontSize: 18, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );
      badgeTp.layout(maxWidth: zone.width - 20);
      final badgeHeight = badgeTp.height + 10;
      if (cursorY + badgeHeight <= zone.bottom) {
        final badgeRect = Rect.fromLTWH(zone.left, cursorY, badgeTp.width + 20, badgeHeight);
        canvas.drawRRect(
          RRect.fromRectAndRadius(badgeRect, const Radius.circular(4)),
          Paint()..color = Colors.black.withValues(alpha: 0.35),
        );
        canvas.drawCircle(
          Offset(badgeRect.left + 10, badgeRect.top + badgeRect.height / 2),
          2.5,
          Paint()..color = const Color(0xFF22C55E),
        );
        badgeTp.paint(canvas, Offset(badgeRect.left + 18, badgeRect.top + 5));
      }
    }
  }

  static Future<Uint8List> _encodeCanvasToPng(
    ui.PictureRecorder recorder,
    StudioTemplateSpec spec,
  ) async {
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      spec.canvasWidth.round(),
      spec.canvasHeight.round(),
    );
    final pngData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (pngData == null) {
      throw StateError('template composition failed to encode PNG');
    }
    return pngData.buffer.asUint8List();
  }
}
