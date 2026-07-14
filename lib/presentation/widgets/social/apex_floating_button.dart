import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SOCIAL-U2A-RESET: flutter_overlay_window removed. Widget preserved for
// SOCIAL-U2A-NATIVE (Kotlin WindowManager implementation).
class ApexFloatingButton extends StatefulWidget {
  const ApexFloatingButton({super.key});

  @override
  State<ApexFloatingButton> createState() => _ApexFloatingButtonState();
}

class _ApexFloatingButtonState extends State<ApexFloatingButton> {
  bool _expanded = false;
  Timer? _collapseTimer;
  String _labelGallery = 'Adicionar print ou vídeo';
  String _labelStudio = 'Voltar ao Apex Studio';
  String _labelClose = 'Fechar';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('apex_app_language') ?? 'ptBr';
      if (!mounted) return;
      setState(() {
        if (lang == 'en') {
          _labelGallery = 'Add screenshot or video';
          _labelStudio = 'Back to Apex Studio';
          _labelClose = 'Close';
        } else if (lang == 'es') {
          _labelGallery = 'Agregar captura o video';
          _labelStudio = 'Volver a Apex Studio';
          _labelClose = 'Cerrar';
        }
      });
    } catch (_) {}
  }

  Future<void> _expand() async {
    _collapseTimer?.cancel();
    if (mounted) setState(() => _expanded = true);
    _collapseTimer = Timer(const Duration(seconds: 5), _collapse);
  }

  Future<void> _collapse() async {
    _collapseTimer?.cancel();
    if (mounted) setState(() => _expanded = false);
  }

  Future<void> _send(String action) async {
    await _collapse();
  }

  Future<void> _closeAll() async {
    _collapseTimer?.cancel();
    if (mounted) setState(() => _expanded = false);
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _expanded ? _buildExpanded() : _buildCollapsed(),
    );
  }

  Widget _buildCollapsed() {
    return GestureDetector(
      onTap: _expand,
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E).withValues(alpha: 0.50),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withValues(alpha: 0.20),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.bolt_rounded,
          color: Colors.black.withValues(alpha: 0.85),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildExpanded() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF22C55E).withValues(alpha: 0.30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OverlayTile(
            icon: Icons.image_outlined,
            label: _labelGallery,
            onTap: () => _send('open_gallery'),
          ),
          const Divider(color: Color(0xFF1A1A1A), height: 1),
          _OverlayTile(
            icon: Icons.bolt_rounded,
            label: _labelStudio,
            onTap: () => _send('open_studio'),
          ),
          const Divider(color: Color(0xFF1A1A1A), height: 1),
          _OverlayTile(
            icon: Icons.close_rounded,
            label: _labelClose,
            onTap: _closeAll,
          ),
        ],
      ),
    );
  }
}

class _OverlayTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OverlayTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF22C55E), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
