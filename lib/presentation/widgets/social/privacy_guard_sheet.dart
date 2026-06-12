import 'package:flutter/material.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';

Future<bool> showPrivacyGuardSheet(
  BuildContext context,
  AppLanguage lang,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: const Color(0xFF111111),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _PrivacyGuardContent(lang: lang),
  );
  return result ?? false;
}

class _PrivacyGuardContent extends StatelessWidget {
  final AppLanguage lang;
  const _PrivacyGuardContent({required this.lang});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.privacyGuardTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            s.privacyGuardBody,
            style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            s.privacyGuardNoAutoPost,
            style: const TextStyle(
              color: Color(0xFF22C55E),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFA1A1AA),
                    side: const BorderSide(color: Color(0xFF2A2A2A)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(s.privacyGuardCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    s.privacyGuardConfirm,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
