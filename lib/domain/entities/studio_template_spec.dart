import 'package:flutter/material.dart';

/// STUDIO-TEMPLATE-ASSETS-U2: orientation of an officially-designed Apex
/// Studio template asset. Drives which asset folder/list the picker shows
/// and which canvas dimensions the compositor renders at.
enum StudioTemplateOrientation { vertical, horizontal }

/// The rectangle inside a template's background PNG where the user's
/// screenshot/video must be placed. Fixed per orientation, given directly by
/// design (not measured/inferred from pixels) — every pixel outside this
/// rect belongs to the background or the foreground chrome (wordmark,
/// mascot) and must never be covered by media.
class TemplateMediaSlot {
  final double x;
  final double y;
  final double width;
  final double height;

  const TemplateMediaSlot({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double get right => x + width;
  double get bottom => y + height;

  Rect toRect() => Rect.fromLTWH(x, y, width, height);
}

/// STUDIO-TEMPLATE-ASSETS-U2: common (orientation-agnostic) foreground chrome
/// assets shared by every template skin — the Apex Booster+ wordmark and
/// mascot. Both are transparent PNGs on a 1024x1024 canvas; drawn on top of
/// the media so they're never a false "hole" like the old white-punch design.
const String kWordmarkAssetPath = 'assets/templates/common/apex_booster_wordmark.png';
const String kMascotAssetPath = 'assets/templates/common/apex_mascot.png';

class StudioTemplateSpec {
  final String id;
  final String displayName;
  final StudioTemplateOrientation orientation;
  final String backgroundAssetPath;
  final double canvasWidth;
  final double canvasHeight;
  final TemplateMediaSlot mediaSlot;
  final double slotBorderRadius;
  final BoxFit defaultFit;

  const StudioTemplateSpec({
    required this.id,
    required this.displayName,
    required this.orientation,
    required this.backgroundAssetPath,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.mediaSlot,
    this.slotBorderRadius = 20.0,
    this.defaultFit = BoxFit.cover,
  });

  double get aspectRatio => canvasWidth / canvasHeight;

  /// STUDIO-TEMPLATE-ASSETS-U2: destination rect for the wordmark, drawn on
  /// top of the background/media — centered horizontally, sitting in the
  /// margin band above [mediaSlot]. Fixed per orientation.
  Rect get wordmarkRect => orientation == StudioTemplateOrientation.horizontal
      ? const Rect.fromLTWH(540, 14, 340, 66)
      : const Rect.fromLTWH(196, 20, 508, 100);

  /// STUDIO-TEMPLATE-ASSETS-U2: destination rect for the mascot, anchored to
  /// the bottom-right corner of the canvas — deliberately overlaps the
  /// bottom-right corner of [mediaSlot] since the mascot is drawn AFTER the
  /// media (foreground layer), never before. Fixed per orientation.
  Rect get mascotRect => orientation == StudioTemplateOrientation.horizontal
      ? const Rect.fromLTWH(1223, 628, 185, 260)
      : const Rect.fromLTWH(660, 1088, 228, 320);

  /// STUDIO-TEMPLATE-ASSETS-U2: safe zone for dynamic text (game name,
  /// caption, "session ready" badge) — the margin strip below the media
  /// slot, capped to 55% of canvas width and left-aligned so it never reaches
  /// [mascotRect], which is anchored to the right. Never overlaps [mediaSlot].
  ///
  /// Horizontal templates only have ~114px of margin below the slot
  /// (vertical templates have ~212px), so the post-slot gap is tightened to
  /// claw back a few px for the name+caption — see [TemplateComposer].
  Rect get textZoneRect => Rect.fromLTRB(
        mediaSlot.x,
        mediaSlot.bottom + (orientation == StudioTemplateOrientation.horizontal ? 4 : 12),
        mediaSlot.x + canvasWidth * 0.55,
        canvasHeight - 12,
      );
}

/// STUDIO-TEMPLATE-ASSETS-U2: catalog of the 18 officially-designed Apex
/// Studio background templates (9 horizontal + 9 vertical), each a plain
/// full-bleed opaque PNG — no placeholder color, no punch. The media slot,
/// wordmark and mascot are all composited on top at fixed rects; see
/// TemplateComposer.
const kStudioTemplates = [
  // ── Horizontal (1420x900) ──────────────────────────────────────────────
  StudioTemplateSpec(
    id: 'horizontal_neon_grid',
    displayName: 'Neon Grid',
    orientation: StudioTemplateOrientation.horizontal,
    backgroundAssetPath: 'assets/templates/horizontal/horizontal_neon_grid_bg.png',
    canvasWidth: 1420,
    canvasHeight: 900,
    mediaSlot: TemplateMediaSlot(x: 38, y: 90, width: 1343, height: 684),
  ),
  StudioTemplateSpec(
    id: 'horizontal_carbon_strike',
    displayName: 'Carbon Strike',
    orientation: StudioTemplateOrientation.horizontal,
    backgroundAssetPath: 'assets/templates/horizontal/horizontal_carbon_strike_bg.png',
    canvasWidth: 1420,
    canvasHeight: 900,
    mediaSlot: TemplateMediaSlot(x: 38, y: 90, width: 1343, height: 684),
  ),
  StudioTemplateSpec(
    id: 'horizontal_cyber_blue',
    displayName: 'Cyber Blue',
    orientation: StudioTemplateOrientation.horizontal,
    backgroundAssetPath: 'assets/templates/horizontal/horizontal_cyber_blue_bg.png',
    canvasWidth: 1420,
    canvasHeight: 900,
    mediaSlot: TemplateMediaSlot(x: 38, y: 90, width: 1343, height: 684),
  ),
  StudioTemplateSpec(
    id: 'horizontal_cyber_red',
    displayName: 'Cyber Red',
    orientation: StudioTemplateOrientation.horizontal,
    backgroundAssetPath: 'assets/templates/horizontal/horizontal_cyber_red_bg.png',
    canvasWidth: 1420,
    canvasHeight: 900,
    mediaSlot: TemplateMediaSlot(x: 38, y: 90, width: 1343, height: 684),
  ),
  StudioTemplateSpec(
    id: 'horizontal_low_poly',
    displayName: 'Low Poly',
    orientation: StudioTemplateOrientation.horizontal,
    backgroundAssetPath: 'assets/templates/horizontal/horizontal_low_poly_bg.png',
    canvasWidth: 1420,
    canvasHeight: 900,
    mediaSlot: TemplateMediaSlot(x: 38, y: 90, width: 1343, height: 684),
  ),
  StudioTemplateSpec(
    id: 'horizontal_neon_edge',
    displayName: 'Neon Edge',
    orientation: StudioTemplateOrientation.horizontal,
    backgroundAssetPath: 'assets/templates/horizontal/horizontal_neon_edge_bg.png',
    canvasWidth: 1420,
    canvasHeight: 900,
    mediaSlot: TemplateMediaSlot(x: 38, y: 90, width: 1343, height: 684),
  ),
  StudioTemplateSpec(
    id: 'horizontal_shadow_green',
    displayName: 'Shadow Green',
    orientation: StudioTemplateOrientation.horizontal,
    backgroundAssetPath: 'assets/templates/horizontal/horizontal_shadow_green_bg.png',
    canvasWidth: 1420,
    canvasHeight: 900,
    mediaSlot: TemplateMediaSlot(x: 38, y: 90, width: 1343, height: 684),
  ),
  StudioTemplateSpec(
    id: 'horizontal_toxic_orange',
    displayName: 'Toxic Orange',
    orientation: StudioTemplateOrientation.horizontal,
    backgroundAssetPath: 'assets/templates/horizontal/horizontal_toxic_orange_bg.png',
    canvasWidth: 1420,
    canvasHeight: 900,
    mediaSlot: TemplateMediaSlot(x: 38, y: 90, width: 1343, height: 684),
  ),
  StudioTemplateSpec(
    id: 'horizontal_toxic_smoke',
    displayName: 'Toxic Smoke',
    orientation: StudioTemplateOrientation.horizontal,
    backgroundAssetPath: 'assets/templates/horizontal/horizontal_toxic_smoke_bg.png',
    canvasWidth: 1420,
    canvasHeight: 900,
    mediaSlot: TemplateMediaSlot(x: 38, y: 90, width: 1343, height: 684),
  ),

  // ── Vertical (900x1420) ─────────────────────────────────────────────────
  StudioTemplateSpec(
    id: 'vertical_neon_grid',
    displayName: 'Neon Grid',
    orientation: StudioTemplateOrientation.vertical,
    backgroundAssetPath: 'assets/templates/vertical/vertical_neon_grid_bg.png',
    canvasWidth: 900,
    canvasHeight: 1420,
    mediaSlot: TemplateMediaSlot(x: 30, y: 134, width: 840, height: 1074),
  ),
  StudioTemplateSpec(
    id: 'vertical_carbon_strike',
    displayName: 'Carbon Strike',
    orientation: StudioTemplateOrientation.vertical,
    backgroundAssetPath: 'assets/templates/vertical/vertical_carbon_strike_bg.png',
    canvasWidth: 900,
    canvasHeight: 1420,
    mediaSlot: TemplateMediaSlot(x: 30, y: 134, width: 840, height: 1074),
  ),
  StudioTemplateSpec(
    id: 'vertical_cyber_blue',
    displayName: 'Cyber Blue',
    orientation: StudioTemplateOrientation.vertical,
    backgroundAssetPath: 'assets/templates/vertical/vertical_cyber_blue_bg.png',
    canvasWidth: 900,
    canvasHeight: 1420,
    mediaSlot: TemplateMediaSlot(x: 30, y: 134, width: 840, height: 1074),
  ),
  StudioTemplateSpec(
    id: 'vertical_cyber_red',
    displayName: 'Cyber Red',
    orientation: StudioTemplateOrientation.vertical,
    backgroundAssetPath: 'assets/templates/vertical/vertical_cyber_red_bg.png',
    canvasWidth: 900,
    canvasHeight: 1420,
    mediaSlot: TemplateMediaSlot(x: 30, y: 134, width: 840, height: 1074),
  ),
  StudioTemplateSpec(
    id: 'vertical_low_poly',
    displayName: 'Low Poly',
    orientation: StudioTemplateOrientation.vertical,
    backgroundAssetPath: 'assets/templates/vertical/vertical_low_poly_bg.png',
    canvasWidth: 900,
    canvasHeight: 1420,
    mediaSlot: TemplateMediaSlot(x: 30, y: 134, width: 840, height: 1074),
  ),
  StudioTemplateSpec(
    id: 'vertical_neon_edge',
    displayName: 'Neon Edge',
    orientation: StudioTemplateOrientation.vertical,
    backgroundAssetPath: 'assets/templates/vertical/vertical_neon_edge_bg.png',
    canvasWidth: 900,
    canvasHeight: 1420,
    mediaSlot: TemplateMediaSlot(x: 30, y: 134, width: 840, height: 1074),
  ),
  StudioTemplateSpec(
    id: 'vertical_shadow_green',
    displayName: 'Shadow Green',
    orientation: StudioTemplateOrientation.vertical,
    backgroundAssetPath: 'assets/templates/vertical/vertical_shadow_green_bg.png',
    canvasWidth: 900,
    canvasHeight: 1420,
    mediaSlot: TemplateMediaSlot(x: 30, y: 134, width: 840, height: 1074),
  ),
  StudioTemplateSpec(
    id: 'vertical_toxic_orange',
    displayName: 'Toxic Orange',
    orientation: StudioTemplateOrientation.vertical,
    backgroundAssetPath: 'assets/templates/vertical/vertical_toxic_orange_bg.png',
    canvasWidth: 900,
    canvasHeight: 1420,
    mediaSlot: TemplateMediaSlot(x: 30, y: 134, width: 840, height: 1074),
  ),
  StudioTemplateSpec(
    id: 'vertical_toxic_smoke',
    displayName: 'Toxic Smoke',
    orientation: StudioTemplateOrientation.vertical,
    backgroundAssetPath: 'assets/templates/vertical/vertical_toxic_smoke_bg.png',
    canvasWidth: 900,
    canvasHeight: 1420,
    mediaSlot: TemplateMediaSlot(x: 30, y: 134, width: 840, height: 1074),
  ),
];

StudioTemplateSpec studioTemplateById(String id) =>
    kStudioTemplates.firstWhere((t) => t.id == id, orElse: () => kStudioTemplates.first);

List<StudioTemplateSpec> studioTemplatesFor(StudioTemplateOrientation orientation) =>
    kStudioTemplates.where((t) => t.orientation == orientation).toList(growable: false);
