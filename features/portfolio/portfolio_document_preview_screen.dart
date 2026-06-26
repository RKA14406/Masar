import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'portfolio_model.dart';
import 'portfolio_pdf_service.dart';

class PortfolioDocumentPreviewScreen extends StatelessWidget {
  final SavedPortfolio portfolio;

  const PortfolioDocumentPreviewScreen({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    final pdfService = PortfolioPdfService();

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio Document Preview')),
      body: PdfPreview(
        initialPageFormat: PdfPageFormat.a4,
        canChangePageFormat: false,
        canChangeOrientation: false,
        allowSharing: true,
        allowPrinting: true,
        build: (_) => pdfService.buildPortfolioPdf(portfolio),
      ),
    );
  }
}
