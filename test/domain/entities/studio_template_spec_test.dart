import 'package:flutter_test/flutter_test.dart';
import 'package:apex_booster_plus/domain/entities/studio_template_spec.dart';

void main() {
  group('kStudioTemplates', () {
    test('has exactly 18 templates', () {
      expect(kStudioTemplates.length, 18);
    });

    test('has 9 horizontal and 9 vertical templates', () {
      expect(
        kStudioTemplates.where((t) => t.orientation == StudioTemplateOrientation.horizontal).length,
        9,
      );
      expect(
        kStudioTemplates.where((t) => t.orientation == StudioTemplateOrientation.vertical).length,
        9,
      );
    });

    test('template ids are unique', () {
      final ids = kStudioTemplates.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('all background asset paths point at assets/templates/', () {
      for (final t in kStudioTemplates) {
        expect(t.backgroundAssetPath, startsWith('assets/templates/'));
        expect(t.backgroundAssetPath, endsWith('.png'));
      }
    });

    test('horizontal templates are landscape canvas (1420x900)', () {
      for (final t in kStudioTemplates.where((t) => t.orientation == StudioTemplateOrientation.horizontal)) {
        expect(t.canvasWidth, 1420);
        expect(t.canvasHeight, 900);
        expect(t.canvasWidth, greaterThan(t.canvasHeight));
      }
    });

    test('vertical templates are portrait canvas (900x1420)', () {
      for (final t in kStudioTemplates.where((t) => t.orientation == StudioTemplateOrientation.vertical)) {
        expect(t.canvasWidth, 900);
        expect(t.canvasHeight, 1420);
        expect(t.canvasHeight, greaterThan(t.canvasWidth));
      }
    });

    test('mediaSlot is fully contained within the canvas for every template', () {
      for (final t in kStudioTemplates) {
        expect(t.mediaSlot.x, greaterThanOrEqualTo(0));
        expect(t.mediaSlot.y, greaterThanOrEqualTo(0));
        expect(t.mediaSlot.right, lessThanOrEqualTo(t.canvasWidth));
        expect(t.mediaSlot.bottom, lessThanOrEqualTo(t.canvasHeight));
      }
    });

    test('mediaSlot matches the fixed design geometry exactly', () {
      for (final t in kStudioTemplates.where((t) => t.orientation == StudioTemplateOrientation.horizontal)) {
        expect(t.mediaSlot.x, 38);
        expect(t.mediaSlot.y, 90);
        expect(t.mediaSlot.width, 1343);
        expect(t.mediaSlot.height, 684);
      }
      for (final t in kStudioTemplates.where((t) => t.orientation == StudioTemplateOrientation.vertical)) {
        expect(t.mediaSlot.x, 30);
        expect(t.mediaSlot.y, 134);
        expect(t.mediaSlot.width, 840);
        expect(t.mediaSlot.height, 1074);
      }
    });

    test('textZoneRect never overlaps mediaSlot', () {
      for (final t in kStudioTemplates) {
        expect(t.textZoneRect.top, greaterThanOrEqualTo(t.mediaSlot.bottom));
      }
    });

    test('textZoneRect stays within canvas bounds', () {
      for (final t in kStudioTemplates) {
        expect(t.textZoneRect.left, greaterThanOrEqualTo(0));
        expect(t.textZoneRect.right, lessThanOrEqualTo(t.canvasWidth));
        expect(t.textZoneRect.bottom, lessThanOrEqualTo(t.canvasHeight));
      }
    });

    test('wordmarkRect stays within canvas bounds and above the media slot', () {
      for (final t in kStudioTemplates) {
        expect(t.wordmarkRect.left, greaterThanOrEqualTo(0));
        expect(t.wordmarkRect.right, lessThanOrEqualTo(t.canvasWidth));
        expect(t.wordmarkRect.top, greaterThanOrEqualTo(0));
        expect(t.wordmarkRect.bottom, lessThanOrEqualTo(t.mediaSlot.y));
      }
    });

    test('mascotRect stays within canvas bounds', () {
      for (final t in kStudioTemplates) {
        expect(t.mascotRect.left, greaterThanOrEqualTo(0));
        expect(t.mascotRect.right, lessThanOrEqualTo(t.canvasWidth));
        expect(t.mascotRect.top, greaterThanOrEqualTo(0));
        expect(t.mascotRect.bottom, lessThanOrEqualTo(t.canvasHeight));
      }
    });

    test('mascotRect never overlaps textZoneRect', () {
      for (final t in kStudioTemplates) {
        expect(t.mascotRect.left, greaterThanOrEqualTo(t.textZoneRect.right));
      }
    });
  });

  group('studioTemplateById', () {
    test('returns the matching template', () {
      expect(studioTemplateById('horizontal_carbon_strike').displayName, 'Carbon Strike');
    });

    test('falls back to the first template for an unknown id', () {
      expect(studioTemplateById('does_not_exist'), kStudioTemplates.first);
    });
  });

  group('studioTemplatesFor', () {
    test('returns only templates of the requested orientation', () {
      final horizontals = studioTemplatesFor(StudioTemplateOrientation.horizontal);
      expect(horizontals.length, 9);
      expect(horizontals.every((t) => t.orientation == StudioTemplateOrientation.horizontal), true);
    });
  });
}
