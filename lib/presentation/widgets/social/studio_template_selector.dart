import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../domain/entities/studio_template_spec.dart';

/// STUDIO-TEMPLATE-ASSETS-U2: lets the user pick orientation (Vertical or
/// Horizontal) and one of the 9 official template skins for that
/// orientation. Purely a picker over [kStudioTemplates] — no card rendering
/// happens here.
class StudioTemplateSelector extends StatelessWidget {
  final StudioTemplateOrientation orientation;
  final String selectedId;
  final AppLanguage lang;
  final ValueChanged<StudioTemplateOrientation> onOrientationChanged;
  final ValueChanged<StudioTemplateSpec> onTemplateSelected;

  const StudioTemplateSelector({
    super.key,
    required this.orientation,
    required this.selectedId,
    required this.lang,
    required this.onOrientationChanged,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    final templates = studioTemplatesFor(orientation);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _OrientationChip(
                  label: s.apexStudioOrientationVertical,
                  selected: orientation == StudioTemplateOrientation.vertical,
                  onTap: () => onOrientationChanged(StudioTemplateOrientation.vertical),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OrientationChip(
                  label: s.apexStudioOrientationHorizontal,
                  selected: orientation == StudioTemplateOrientation.horizontal,
                  onTap: () => onOrientationChanged(StudioTemplateOrientation.horizontal),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final t = templates[index];
              final selected = t.id == selectedId;
              return GestureDetector(
                key: Key('studio_template_option_${t.id}'),
                onTap: () => onTemplateSelected(t),
                child: SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? AppColors.apexGreen : const Color(0xFF2A2A2A),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.asset(t.backgroundAssetPath, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: selected ? AppColors.apexGreen : const Color(0xFFA1A1AA),
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OrientationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OrientationChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.apexGreen.withValues(alpha: 0.12) : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.apexGreen.withValues(alpha: 0.4) : const Color(0xFF2A2A2A),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.apexGreen : const Color(0xFFA1A1AA),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
