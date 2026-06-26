import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'cv_model.dart';
import 'cv_pdf_service.dart';

class CvPdfPreviewScreen extends StatelessWidget {
  final SavedCv savedCv;

  const CvPdfPreviewScreen({super.key, required this.savedCv});

  @override
  Widget build(BuildContext context) {
    final service = CvPdfService();

    return Scaffold(
      appBar: AppBar(title: const Text('CV PDF Preview')),
      body: PdfPreview(
        initialPageFormat: PdfPageFormat.a4,
        canChangePageFormat: false,
        canChangeOrientation: false,
        allowPrinting: true,
        allowSharing: true,
        build: (_) => service.buildCvPdf(savedCv),
      ),
    );
  }
}
