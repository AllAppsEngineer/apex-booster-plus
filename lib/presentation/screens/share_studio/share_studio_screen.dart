import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/i18n/app_language.dart';
import '../../../core/i18n/app_strings.dart';
import '../../../data/services/screen_capture_gallery_service.dart';
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
  final ScreenCaptureGalleryService? galleryService;
  const ApexStudioScreen({
    super.key,
    required this.gameId,
    this.initialMediaPath,
    this.galleryService,
  });

  @override
  State<ApexStudioScreen> createState() => _ApexStudioScreenState();
}

class _ApexStudioScreenState extends State<ApexStudioScreen> {
  final _exportKey = GlobalKey();
  final _captionController = TextEditingController();
  final _gameNameController = TextEditingController();
  final _imagePicker = ImagePicker();
  late SocialCard _card;
  String _selectedTemplateId = 'default';
  bool _exporting = false;
  bool _loaded = false;
  AppLanguage _lang = AppLanguage.ptBr;
  String? _mediaPath;
  bool _mediaIsVideo = false;
  BoxFit _imageFit = BoxFit.cover;
  Uint8List? _videoThumbnail;
  late final ScreenCaptureGalleryService _galleryService;

  // Reference point for T+ timing logs (same pattern as [DETAIL-NAV]).
  final int _t0 = DateTime.now().millisecondsSinceEpoch;

  int get _tms => DateTime.now().millisecondsSinceEpoch - _t0;

  @override
  void initState() {
    super.initState();
    debugPrint('[ApexStudio] T+${_tms}ms studio init');
    _galleryService = widget.galleryService ?? ScreenCaptureGalleryService();
    _lang = languageNotifier.value;
    final path = widget.initialMediaPath;
    const videoExts = {'.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp', '.3gpp'};
    final isVideo = path != null &&
        videoExts.any((ext) => path.toLowerCase().endsWith(ext));
    _card = SocialCard(
      id: '${widget.gameId}_${DateTime.now().millisecondsSinceEpoch}',
      gameId: widget.gameId,
      gameName: '',
      templateId: _selectedTemplateId,
      createdAt: DateTime.now(),
      importedMediaPath: path,
    );
    _mediaPath = path;
    _mediaIsVideo = isVideo;
    _loaded = true;
    // Thumbnail generation is kicked off after the first frame paints (not
    // here in initState) so the native platform-channel round trip never
    // competes with the page-transition frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[ApexStudio] T+${_tms}ms studio first frame');
      if (isVideo) {
        _generateVideoThumbnail(path);
      }
    });
  }

  void _onGameNameChanged(String value) {
    setState(() {
      _card = _card.copyWith(gameName: value.trim());
    });
  }

  Future<void> _showVideoPreview() async {
    final path = _mediaPath;
    if (path == null || !_mediaIsVideo) return;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => _VideoPreviewDialog(filePath: path),
    );
  }

  Future<void> _generateVideoThumbnail(String path) async {
    debugPrint('[ApexStudio] T+${_tms}ms thumbnail generation started');
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 144,
        quality: 75,
      );
      debugPrint(
          '[ApexStudio] T+${_tms}ms thumbnail generation ended (bytes=${bytes?.length})');
      if (!mounted || bytes == null) return;
      setState(() => _videoThumbnail = bytes);
    } catch (e) {
      debugPrint('[ApexStudio] T+${_tms}ms thumbnail generation failed ($e)');
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _gameNameController.dispose();
    super.dispose();
  }

  bool get _canExport => _mediaPath != null;

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

      if (choice == _MediaType.apexCapture) {
        await _pickApexCapture(s);
        return;
      }

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
      final pickedPath = picked.path;
      setState(() {
        _mediaPath = pickedPath;
        _mediaIsVideo = choice == _MediaType.video;
        _imageFit = BoxFit.cover;
        _videoThumbnail = null;
        _card = _card.copyWith(importedMediaPath: pickedPath);
      });
      if (choice == _MediaType.video) {
        _generateVideoThumbnail(pickedPath);
      }
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

  Future<void> _pickApexCapture(AppStrings s) async {
    // Sheet opens immediately with a lightweight loading placeholder;
    // listCaptures() resolves inside the sheet so it never blocks navigation.
    debugPrint('[ApexStudio] T+${_tms}ms apex captures sheet opened (async load)');
    final selected = await showModalBottomSheet<CapturedScreenshot>(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ApexCapturesSheet(
        galleryService: _galleryService,
        title: s.apexStudioCapturesSheetTitle,
        subtitle: s.apexStudioCapturesSheetSubtitle,
        emptyMessage: s.apexStudioCapturesEmpty,
        mostRecentLabel: s.apexStudioCaptureMostRecent,
        lang: _lang,
        t0: _t0,
        onCaptureDeleted: _onApexCaptureDeleted,
      ),
    );

    if (selected == null || !mounted) return;
    setState(() {
      _mediaPath = selected.path;
      _mediaIsVideo = selected.isVideo;
      _imageFit = BoxFit.cover;
      _videoThumbnail = null;
      _card = _card.copyWith(importedMediaPath: selected.path);
    });
    if (selected.isVideo) {
      _generateVideoThumbnail(selected.path);
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
            ListTile(
              leading:
                  const Icon(Icons.collections_outlined, color: Colors.white),
              title: Text(
                s.apexStudioPickApexCapture,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              onTap: () => Navigator.pop(context, _MediaType.apexCapture),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _onApexCaptureDeleted(CapturedScreenshot deleted) {
    if (_mediaPath == deleted.path) {
      _removeMedia();
    }
  }

  void _removeMedia() {
    setState(() {
      _mediaPath = null;
      _mediaIsVideo = false;
      _imageFit = BoxFit.cover;
      _videoThumbnail = null;
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

  Future<void> _confirmAndShareOriginalClip() async {
    final privacyConfirmed = await showPrivacyGuardSheet(context, _lang);
    if (!privacyConfirmed || !mounted) return;
    await _shareVideoFile();
  }

  Future<void> _shareVideoFile() async {
    final path = _mediaPath;
    if (path == null) return;

    final file = File(path);
    if (!file.existsSync()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings(_lang).apexStudioVideoMissingError),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _exporting = true);
    try {
      await Share.shareXFiles([XFile(path)], text: _card.caption);
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

    final viewBottom = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: _buildAppBar(s),
      // Footer anchored in bottomNavigationBar so o Scaffold posiciona
      // corretamente e viewPadding.bottom garante clearance real sobre a barra
      // do Android independente de qual ancestral consumiu MediaQuery.padding.
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF050505),
          border: Border(
            top: BorderSide(color: Color(0xFF1A1A1A), width: 1),
          ),
        ),
        padding: EdgeInsets.fromLTRB(16, 12, 16, viewBottom + 16),
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
                  s.apexStudioGenerateCardLabel,
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
            ],
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // ── Card preview ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 24,
                      spreadRadius: 0,
                      color: _activeTemplate.accentColor
                          .withValues(alpha: 0.15),
                    ),
                  ],
                ),
                child: RepaintBoundary(
                  key: _exportKey,
                  child: _card.preset == SharePreset.portrait
                      ? ShareCardPortrait(
                          card: _card,
                          template: _activeTemplate,
                          lang: _lang,
                          mediaFit: _imageFit,
                          videoThumbnail: _videoThumbnail,
                        )
                      : ShareCardSquare(
                          card: _card,
                          template: _activeTemplate,
                          lang: _lang,
                          mediaFit: _imageFit,
                          videoThumbnail: _videoThumbnail,
                        ),
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
            // ── Nome do jogo/sessão ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                s.apexStudioSessionNameSection.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                key: const Key('apex_studio_session_name_field'),
                controller: _gameNameController,
                onChanged: _onGameNameChanged,
                maxLength: 40,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: s.apexStudioSessionNameHint,
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
    );
  }

  Widget _buildAddMediaButton(AppStrings s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _pickMedia,
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.apexGreen.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.apexGreen,
                size: 32,
              ),
              const SizedBox(height: 6),
              Text(
                s.apexStudioAddMedia,
                style: TextStyle(
                  color: AppColors.apexGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s.apexStudioAddMediaSubtitle,
                style: const TextStyle(
                  color: Color(0xFF444444),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(AppStrings s) {
    final filename = _mediaPath!.split('/').last.split('\\').last;
    final badgeColor = _mediaIsVideo
        ? const Color(0xFF3B82F6)
        : AppColors.apexGreen;
    final badgeLabel = _mediaIsVideo ? 'VÍDEO' : 'FOTO';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F0F0F), Color(0xFF141414)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                // Thumbnail
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(11)),
                    border: Border(
                      right: BorderSide(
                        color: badgeColor.withValues(alpha: 0.20),
                        width: 1,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(11)),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: _mediaIsVideo
                          ? GestureDetector(
                              onTap: _showVideoPreview,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _videoThumbnail != null
                                      ? Image.memory(
                                          _videoThumbnail!,
                                          fit: _imageFit,
                                          width: 72,
                                          height: 72,
                                        )
                                      : _buildVideoThumbnail(s),
                                  Center(
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black
                                            .withValues(alpha: 0.55),
                                      ),
                                      child: const Icon(
                                        Icons.play_circle_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Image.file(
                              File(_mediaPath!),
                              fit: _imageFit,
                              errorBuilder: (_, __, ___) =>
                                  _buildVideoThumbnail(s),
                            ),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: badgeColor.withValues(alpha: 0.30),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        filename,
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                // Actions
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFitChip(s.apexStudioFitFill, BoxFit.cover),
              const SizedBox(width: 6),
              _buildFitChip(s.apexStudioFitContain, BoxFit.contain),
            ],
          ),
          if (_mediaIsVideo) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF3B82F6),
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.apexStudioVideoExportNotice,
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('apex_studio_share_original_clip_button'),
                onPressed: _confirmAndShareOriginalClip,
                icon: const Icon(
                  Icons.ios_share_rounded,
                  color: Color(0xFF3B82F6),
                  size: 16,
                ),
                label: Text(
                  s.apexStudioShareOriginalClipLabel,
                  style: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xFF3B82F6),
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFitChip(String label, BoxFit fit) {
    final selected = _imageFit == fit;
    return GestureDetector(
      onTap: () => setState(() => _imageFit = fit),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.apexGreen.withValues(alpha: 0.12)
              : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.apexGreen.withValues(alpha: 0.40)
                : const Color(0xFF2A2A2A),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.apexGreen : const Color(0xFFA1A1AA),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(AppStrings s) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF111827), Color(0xFF0A0A0A)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Color(0xFF3B82F6),
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.apexStudioVideoLabel,
            style: TextStyle(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.75),
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

enum _MediaType { image, video, apexCapture }

// ─── Video preview dialog ─────────────────────────────────────────────────────

class _VideoPreviewDialog extends StatefulWidget {
  final String filePath;
  const _VideoPreviewDialog({required this.filePath});

  @override
  State<_VideoPreviewDialog> createState() => _VideoPreviewDialogState();
}

class _VideoPreviewDialogState extends State<_VideoPreviewDialog> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _error = false;
  // Guard against setState after dispose (async init race condition)
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath));
    _initController();
  }

  Future<void> _initController() async {
    try {
      await _controller.initialize();
      if (_disposed || !mounted) return;
      setState(() => _initialized = true);
      try {
        _controller.play();
      } catch (_) {}
    } catch (_) {
      if (_disposed || !mounted) return;
      setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!mounted) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(languageNotifier.value);

    final aspectRatio = (_initialized && _controller.value.aspectRatio > 0)
        ? _controller.value.aspectRatio
        : 16.0 / 9.0;

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      // SafeArea garante que o conteúdo nunca fique atrás da barra de sistema.
      // Flexible + LayoutBuilder eliminam o cálculo explícito de dialogH que
      // ignorava viewPadding.top/bottom e causava BOTTOM OVERFLOWED BY 72 PIXELS.
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header — altura fixa
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.apexStudioVideoPreviewLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Área de vídeo — Flexible absorve a altura disponível sem overflow
            Flexible(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final maxW = constraints.maxWidth;
                  final maxH = constraints.hasBoundedHeight
                      ? constraints.maxHeight
                      : maxW / aspectRatio;
                  double videoW, videoH;
                  if (maxW / aspectRatio <= maxH) {
                    videoW = maxW;
                    videoH = maxW / aspectRatio;
                  } else {
                    videoH = maxH;
                    videoW = maxH * aspectRatio;
                  }
                  videoW = math.min(videoW, maxW);
                  videoH = math.max(80.0, videoH);
                  return Center(
                    child: SizedBox(
                      width: videoW,
                      height: videoH,
                      child: _error
                          ? const Center(
                              child: Icon(Icons.error_outline_rounded,
                                  color: Colors.white54, size: 40),
                            )
                          : !_initialized
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF22C55E),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: _togglePlay,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      VideoPlayer(_controller),
                                      ValueListenableBuilder<VideoPlayerValue>(
                                        valueListenable: _controller,
                                        builder: (_, value, __) {
                                          if (value.isPlaying) {
                                            return const SizedBox.shrink();
                                          }
                                          return Center(
                                            child: Container(
                                              width: 52,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black
                                                    .withValues(alpha: 0.5),
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  );
                },
              ),
            ),
            // Scrubber — apenas após inicialização, sempre acima das barras do sistema
            if (_initialized) ...[
              const SizedBox(height: 4),
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: _controller,
                builder: (_, value, __) {
                  final pos = value.position;
                  final dur = value.duration;
                  final progress = (dur.inMilliseconds > 0)
                      ? (pos.inMilliseconds / dur.inMilliseconds)
                          .clamp(0.0, 1.0)
                      : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Text(
                          _formatDuration(pos),
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                        Expanded(
                          child: Slider(
                            value: progress,
                            onChanged: (v) => _controller.seekTo(
                              Duration(
                                  milliseconds:
                                      (v * dur.inMilliseconds).round()),
                            ),
                            activeColor: const Color(0xFF22C55E),
                            inactiveColor: const Color(0xFF333333),
                          ),
                        ),
                        Text(
                          _formatDuration(dur),
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ApexCapturesSheet extends StatefulWidget {
  final ScreenCaptureGalleryService galleryService;
  final String title;
  final String subtitle;
  final String emptyMessage;
  final String mostRecentLabel;
  final AppLanguage lang;
  final int t0;
  final void Function(CapturedScreenshot) onCaptureDeleted;
  const _ApexCapturesSheet({
    required this.galleryService,
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.mostRecentLabel,
    required this.lang,
    required this.t0,
    required this.onCaptureDeleted,
  });

  @override
  State<_ApexCapturesSheet> createState() => _ApexCapturesSheetState();
}

class _ApexCapturesSheetState extends State<_ApexCapturesSheet> {
  final List<CapturedScreenshot> _captures = [];
  bool _loading = true;

  int get _tms => DateTime.now().millisecondsSinceEpoch - widget.t0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    debugPrint('[ApexStudio] T+${_tms}ms listCaptures started');
    final captures = await widget.galleryService.listCaptures();
    debugPrint(
        '[ApexStudio] T+${_tms}ms listCaptures ended (count=${captures.length})');
    if (!mounted) return;
    setState(() {
      _captures.addAll(captures);
      _loading = false;
    });
  }

  Future<void> _confirmDelete(CapturedScreenshot capture) async {
    final s = AppStrings(widget.lang);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          capture.isVideo
              ? s.apexStudioDeleteVideoTitle
              : s.apexStudioDeleteCaptureTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        content: Text(
          s.apexStudioDeleteDialogContent,
          style: const TextStyle(
            color: Color(0xFFA1A1AA),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              s.actionCancel,
              style: const TextStyle(color: Color(0xFFA1A1AA)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              s.apexStudioDeleteConfirm,
              style: const TextStyle(
                color: Color(0xFFF97316),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await widget.galleryService.deleteCapture(capture);
    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.apexStudioDeleteError),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _captures.remove(capture));
    widget.onCaptureDeleted(capture);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    final captures = _captures;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.subtitle,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              _buildLoadingState()
            else if (captures.isEmpty)
              _buildEmptyState()
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: captures.length,
                  itemBuilder: (_, i) {
                    final capture = captures[i];
                    return GestureDetector(
                      key: Key('apex_capture_tile_$i'),
                      onTap: () => Navigator.of(context).pop(capture),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            capture.isVideo
                                ? Container(
                                    color: const Color(0xFF111827),
                                    child: const Center(
                                      child: Icon(
                                        Icons.play_circle_fill_rounded,
                                        color: Color(0xFF3B82F6),
                                        size: 28,
                                      ),
                                    ),
                                  )
                                : Image.file(
                                    File(capture.path),
                                    fit: BoxFit.cover,
                                  ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 3),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Color(0xCC000000),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  s.relativeTime(capture.capturedAt),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            if (i == 0)
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.apexGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.mostRecentLabel,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 7,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: Material(
                                type: MaterialType.transparency,
                                child: IconButton(
                                  key: Key('apex_capture_delete_$i'),
                                  onPressed: () => _confirmDelete(capture),
                                  tooltip: s.apexStudioDeleteTooltip,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 26,
                                    minHeight: 26,
                                  ),
                                  icon: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          Colors.black.withValues(alpha: 0.55),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF22C55E),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(
            Icons.collections_outlined,
            color: Color(0xFF444444),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            widget.emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
