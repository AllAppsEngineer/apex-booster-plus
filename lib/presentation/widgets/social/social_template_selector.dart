import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_language.dart';
import '../../../domain/entities/social_template.dart';

class SocialTemplateSelector extends StatelessWidget {
  final List<SocialTemplate> templates;
  final String selectedId;
  final ValueChanged<SocialTemplate> onSelected;
  final AppLanguage lang;

  const SocialTemplateSelector({
    super.key,
    required this.templates,
    required this.selectedId,
    required this.onSelected,
    required this.lang,
  });

  String _nameFor(SocialTemplate t) => switch (lang) {
    AppLanguage.ptBr => t.namePtBr,
    AppLanguage.en   => t.nameEn,
    AppLanguage.es   => t.nameEs,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final t = templates[i];
          final isSelected = t.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? t.accentColor.withValues(alpha: 0.12)
                    : const Color(0xFF111111),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? t.accentColor : const Color(0xFF2A2A2A),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 6,
                    decoration: BoxDecoration(
                      color: t.accentColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _nameFor(t),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textGray,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (!t.isFree) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.energyOrange.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'Premium',
                        style: TextStyle(
                          color: AppColors.energyOrange,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
