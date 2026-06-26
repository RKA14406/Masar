import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../l10n/masar_text.dart';
import 'cv_model.dart';
import 'cv_pdf_service.dart';

class CvPdfPreviewScreen extends StatelessWidget {
  final SavedCv savedCv;

  const CvPdfPreviewScreen({super.key, required this.savedCv});

  @override
  Widget build(BuildContext context) {
    final service = CvPdfService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          MasarText.t(context, 'CV PDF Preview', 'معاينة PDF للسيرة الذاتية'),
        ),
      ),
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
