import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../../core/config/app_colors.dart';
import '../models/report_model.dart';

class PdfViewerModal extends StatefulWidget {
  final String title;
  final String assetPath;
  final ReportDocumentType documentType;
  final String? originalFileName;

  const PdfViewerModal({
    super.key,
    required this.title,
    required this.assetPath,
    required this.documentType,
    this.originalFileName,
  });

  @override
  State<PdfViewerModal> createState() => _PdfViewerModalState();
}

class _PdfViewerModalState extends State<PdfViewerModal> {
  PdfControllerPinch? _pdfController;
  int _currentPage = 1;
  int _pageCount = 0;

  bool get _fileExists =>
      widget.assetPath.startsWith('assets/') ||
      File(widget.assetPath).existsSync();

  @override
  void initState() {
    super.initState();
    if (widget.documentType == ReportDocumentType.pdf &&
        widget.assetPath.isNotEmpty &&
        _fileExists) {
      _pdfController = PdfControllerPinch(
        document: widget.assetPath.startsWith('assets/')
            ? PdfDocument.openAsset(widget.assetPath)
            : PdfDocument.openFile(widget.assetPath),
      );
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF35383D),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
            Text(
              _pageCount > 0
                  ? 'Page $_currentPage of $_pageCount'
                  : widget.originalFileName ?? 'Original medical document',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          if (_pdfController != null) ...[
            IconButton(
              tooltip: 'Previous page',
              onPressed: _currentPage > 1
                  ? () => _pdfController!.previousPage(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                      )
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            IconButton(
              tooltip: 'Next page',
              onPressed: _pageCount == 0 || _currentPage < _pageCount
                  ? () => _pdfController!.nextPage(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                      )
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ],
      ),
      body: _buildDocument(),
    );
  }

  Widget _buildDocument() {
    if (widget.assetPath.isEmpty || !_fileExists) {
      return const _DocumentUnavailable();
    }

    if (widget.documentType == ReportDocumentType.image) {
      return Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: Image.file(
            File(widget.assetPath),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const _DocumentUnavailable(),
          ),
        ),
      );
    }

    final controller = _pdfController;
    if (controller == null) return const _DocumentUnavailable();

    return PdfViewPinch(
      key: const Key('real-pdf-viewer'),
      controller: controller,
      onDocumentLoaded: (document) {
        if (mounted) setState(() => _pageCount = document.pagesCount);
      },
      onPageChanged: (page) {
        if (mounted) setState(() => _currentPage = page);
      },
    );
  }
}

class _DocumentUnavailable extends StatelessWidget {
  const _DocumentUnavailable();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(28),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.file_present_outlined,
              size: 52,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              'Original document unavailable',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6),
            Text(
              'No original document is attached to this report. Import a PDF or capture a report with the camera to view it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
