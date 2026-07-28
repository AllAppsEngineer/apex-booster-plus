import 'package:flutter/material.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';

/// AUDIO-FALLBACK-UX-U1.1: explains that a recording ended without internal
/// audio because the source itself delivered silence or was unavailable, and
/// offers the screen-recorder + Apex Studio import workaround. [onOpenStudio]
/// runs after the sheet closes.
Future<void> showAudioFallbackNoticeSheet(
  BuildContext context,
  AppLanguage lang, {
  required VoidCallback onOpenStudio,
}) async {
  final openStudio = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: const Color(0xFF111111),
    useSafeArea: true,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _AudioFallbackNoticeContent(lang: lang),
  );
  if (openStudio == true) onOpenStudio();
}

class _AudioFallbackNoticeContent extends StatelessWidget {
  final AppLanguage lang;
  const _AudioFallbackNoticeContent({required this.lang});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    final navBottom = MediaQuery.of(context).viewPadding.bottom;
    final bottomGap = (navBottom > 0 ? navBottom : 48.0) + 32.0;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 16, 24, bottomGap),
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
              s.audioFallbackNoticeTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              s.audioFallbackNoticeBody,
              style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14, height: 1.4),
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
                    child: Text(s.audioFallbackNoticeDismiss),
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
                      s.audioFallbackNoticeOpenStudio,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
