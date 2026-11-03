import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class DropZone extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final dynamic icono; // Acepta IconData o FaIconData
  final Function(String path) onFileDropped;
  final bool habilitado;

  const DropZone({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.onFileDropped,
    this.habilitado = true,
  });

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _isDragging = false;

  Future<void> _abrirSelector() async {
    try {
      final result = await FilePicker.pickFiles();
      if (result.isNotEmpty && result.first.path != null) {
        widget.onFileDropped(result.first.path!);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.habilitado) {
      return Opacity(
        opacity: 0.5,
        child: _buildContainer(),
      );
    }

    return DropTarget(
      onDragDone: (detail) {
        if (detail.files.isNotEmpty) {
          widget.onFileDropped(detail.files.first.path);
        }
      },
      onDragEntered: (detail) {
        setState(() => _isDragging = true);
      },
      onDragExited: (detail) {
        setState(() => _isDragging = false);
      },
      child: GestureDetector(
        onTap: _abrirSelector,
        child: _buildContainer(),
      ),
    );
  }

  Widget _buildContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: _isDragging
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppSizes.md),
        border: Border.all(
          color: _isDragging ? AppColors.primary : AppColors.border,
          width: _isDragging ? 2 : 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          // Si el ícono es FaIconData, usamos FaIcon. Si es IconData, usamos Icon.
          widget.icono is FaIconData
              ? FaIcon(
                  _isDragging ? FontAwesomeIcons.download : widget.icono as FaIconData,
                  size: 48,
                  color: _isDragging ? AppColors.primary : AppColors.textSecondary,
                )
              : Icon(
                  _isDragging ? Icons.download_done : widget.icono as IconData,
                  size: 48,
                  color: _isDragging ? AppColors.primary : AppColors.textSecondary,
                ),
          const SizedBox(height: AppSizes.md),
          Text(
            _isDragging ? '¡Suelta el archivo aquí!' : widget.titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isDragging ? AppColors.primary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            widget.subtitulo,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
