import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../data/repositories/shared_preferences_game_library_repository.dart';
import '../../../domain/entities/share_preset.dart';
import '../../../domain/entities/social_card.dart';
import '../../../domain/entities/social_template.dart';
import '../../widgets/social/privacy_guard_sheet.dart';
import '../../widgets/social/share_card_portrait.dart';
import '../../widgets/social/share_card_square.dart';
import '../../widgets/social/social_template_selector.dart';

class ApexStudioScreen extends StatefulWidget {
  final String gameId;
  final String? initialMediaPath;
  const ApexStudioScreen({
    super.key,
    required this.gameId,
    this.initialMediaPath,
  });

  @override
  State<ApexStudioScreen> createState() => _ApexStudioScreenState();
}

class _ApexStudioScreenState extends State<ApexStudioScreen> {
  final _exportKey = GlobalKey();
  final _captionController = TextEditingController();
  final _imagePicker = ImagePicker();
  late SocialCard _card;
  String _selectedTemplateId = 'default';
  bool _exporting = false;
  bool _loaded = false;
  AppLanguage _lang = AppLanguage.ptBr;
  SharedPreferencesGameLibraryRepository? _repo;
  String? _mediaPath;
  bool _mediaIsVideo = false;

  @override
  void initState() {
    super.initState();
    _lang = languageNotifier.value;
    _loadGame();
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    _repo = SharedPreferencesGameLibraryRepository(prefs);
    final game = await _repo!.getGameById(widget.gameId);
    if (!mounted) return;
    final path = widget.initialMediaPath;
    final isVideo = path != null &&
        (path.endsWith('.mp4') ||
            path.endsWith('.mov') ||
            path.endsWith('.avi'));
    setState(() {
      _card = SocialCard(
        id: '${widget.gameId}_${DateTime.now().millisecondsSinceEpoch}',
        gameId: widget.gameId,
        gameName: game?.name ?? widget.gameId,
        templateId: _selectedTemplateId,
        createdAt: DateTime.now(),
        importedMediaPath: path,
      );
      _loaded = true;
      _mediaPath = path;
      _mediaIsVideo = isVideo;
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  bool get _canExport => _mediaPath != null && !_mediaIsVideo;

  SocialTemplate get _activeTemplate =>
      kSocialTemplates.firstWhere((t) => t.id == _selectedTemplateId);

  void _onTemplateSelected(SocialTemplate t) {
    setState(() {
      _selectedTemplateId = t.id;
      _card = _card.copyWith(templateId: t.id);
    });
  }

  void _onPresetChanged(SharePreset p) =>
      setState(() => _card = _card.copyWith(preset: p));

  Future<void> _pickMedia() async {
    final s = AppStrings(_lang);
    try {
      final choice = await _showMediaTypeSheet(s);
      if (choice == null || !mounted) return;

      XFile? picked;
      if (choice == _MediaType.image) {
        picked = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1080,
          imageQuality: 90,
        );
      } else {
        picked = await _imagePicker.pickVideo(source: ImageSource.gallery);
      }

      if (picked == null || !mounted) return;
      setState(() {
        _mediaPath = picked!.path;
        _mediaIsVideo = choice == _MediaType.video;
        _card = _card.copyWith(importedMediaPath: picked.path);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.apexStudioMediaError),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<_MediaType?> _showMediaTypeSheet(AppStrings s) {
    return showModalBottomSheet<_MediaType>(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF333333),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.image_outlined, color: Colors.white),
              title: Text(
                s.apexStudioPickImage,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              onTap: () => Navigator.pop(context, _MediaType.image),
            ),
            ListTile(
              leading:
                  const Icon(Icons.videocam_outlined, color: Colors.white),
              title: Text(
                s.apexStudioPickVideo,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              onTap: () => Navigator.pop(context, _MediaType.video),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _removeMedia() {
    setState(() {
      _mediaPath = null;
      _mediaIsVideo = false;
      _card = SocialCard(
        id: _card.id,
        gameId: _card.gameId,
        gameName: _card.gameName,
        gameIconPath: _card.gameIconPath,
        sessionId: _card.sessionId,
        createdAt: _card.createdAt,
        caption: _card.caption,
        templateId: _card.templateId,
        preset: _card.preset,
        badgeKeys: _card.badgeKeys,
        includeWatermark: _card.includeWatermark,
        importedMediaPath: null,
      );
    });
  }

  Future<void> _export() async {
    final privacyConfirmed = await showPrivacyGuardSheet(context, _lang);
    if (!privacyConfirmed || !mounted) return;

    setState(() => _exporting = true);
    try {
      final boundary = _exportKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/apex_card_${_card.id}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)], text: _card.caption);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(_lang);
    if (!_loaded) {
      return Scaffold(
        backgroundColor: const Color(0xFF050505),
        appBar: _buildAppBar(s),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: _buildAppBar(s),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // ── Card preview ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: RepaintBoundary(
                      key: _exportKey,
                      child: _card.preset == SharePreset.portrait
                          ? ShareCardPortrait(
                              card: _card,
                              template: _activeTemplate,
                              lang: _lang,
                            )
                          : ShareCardSquare(
                              card: _card,
                              template: _activeTemplate,
                              lang: _lang,
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ── MÍDIA section ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      s.apexStudioMediaSection.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _mediaPath == null
                      ? _buildAddMediaButton(s)
                      : _buildMediaPreview(s),
                  const SizedBox(height: 24),
                  // ── TEMA section ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      s.socialStudioTemplate.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SocialTemplateSelector(
                    templates: kSocialTemplates,
                    selectedId: _selectedTemplateId,
                    onSelected: _onTemplateSelected,
                    lang: _lang,
                  ),
                  const SizedBox(height: 16),
                  // ── Format chips ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: SharePreset.values
                          .where((p) => p != SharePreset.landscape)
                          .map((p) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: ChoiceChip(
                                    label: Text(p.label),
                                    selected: _card.preset == p,
                                    onSelected: (_) => _onPresetChanged(p),
                                    selectedColor: AppColors.apexGreen
                                        .withValues(alpha: 0.15),
                                    labelStyle: TextStyle(
                                      color: _card.preset == p
                                          ? AppColors.apexGreen
                                          : AppColors.textGray,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    backgroundColor:
                                        const Color(0xFF111111),
                                    side: BorderSide(
                                      color: _card.preset == p
                                          ? AppColors.apexGreen
                                              .withValues(alpha: 0.4)
                                          : const Color(0xFF2A2A2A),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Caption ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _captionController,
                      onChanged: (v) =>
                          setState(() => _card = _card.copyWith(caption: v)),
                      maxLength: 120,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: s.socialStudioCaptionHint,
                        hintStyle: const TextStyle(
                            color: Color(0xFF555555), fontSize: 14),
                        counterStyle: const TextStyle(
                            color: Color(0xFF555555), fontSize: 11),
                        filled: true,
                        fillColor: const Color(0xFF111111),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF2A2A2A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF2A2A2A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF22C55E)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          // ── Sticky export footer ──────────────────────────────────────────
          SafeArea(
            top: false,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF050505),
                border: Border(
                  top: BorderSide(color: Color(0xFF1A1A1A), width: 1),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: (_canExport && !_exporting) ? _export : null,
                      icon: _exporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.share_rounded, size: 18),
                      label: Text(
                        s.socialStudioExport,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.apexGreen,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: const Color(0xFF1A1A1A),
                        disabledForegroundColor: const Color(0xFF444444),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  if (_mediaPath == null) ...[
                    const SizedBox(height: 8),
                    Text(
                      s.apexStudioNoMediaHint,
                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else if (_mediaIsVideo) ...[
                    const SizedBox(height: 8),
                    Text(
                      s.apexStudioVideoExportNotice,
                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMediaButton(AppStrings s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _pickMedia,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.apexGreen.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.apexGreen,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                s.apexStudioAddMedia,
                style: TextStyle(
                  color: AppColors.apexGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(AppStrings s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(11)),
              child: SizedBox(
                width: 72,
                height: 72,
                child: _mediaIsVideo
                    ? _buildVideoThumbnail()
                    : Image.file(
                        File(_mediaPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildVideoThumbnail(),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _mediaIsVideo
                        ? s.apexStudioVideoSelected
                        : s.apexStudioImageSelected,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _mediaPath!.split('/').last,
                    style: const TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.swap_horiz_rounded,
                      color: Color(0xFFA1A1AA), size: 20),
                  onPressed: _pickMedia,
                  tooltip: s.apexStudioChangeMedia,
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Color(0xFFA1A1AA), size: 20),
                  onPressed: _removeMedia,
                  tooltip: s.apexStudioRemoveMedia,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_rounded,
              color: Color(0xFF3B82F6), size: 24),
          const SizedBox(height: 3),
          Text(
            'VIDEO',
            style: TextStyle(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.7),
              fontSize: 7,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(AppStrings s) => AppBar(
        backgroundColor: const Color(0xFF050505),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              s.socialStudioTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17),
            ),
            Text(
              s.socialStudioSubtitle,
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      );
}

enum _MediaType { image, video }
