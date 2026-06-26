import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'portfolio_model.dart';

class PortfolioPdfService {
  static const PdfColor _accent = PdfColor.fromInt(0xFF1F6FEB);
  static const PdfColor _ink = PdfColor.fromInt(0xFF172033);
  static const PdfColor _muted = PdfColor.fromInt(0xFF64748B);
  static const PdfColor _line = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor _soft = PdfColor.fromInt(0xFFF8FAFC);

  Future<Uint8List> buildPortfolioPdf(SavedPortfolio saved) async {
    final input = saved.input;
    final portfolio = saved.portfolio;
    final document = pw.Document(
      title: _clean(input.fullName).isEmpty
          ? 'Student Portfolio'
          : '${_clean(input.fullName)} Portfolio',
      author: 'Masar',
    );

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(42),
        build: (_) => _buildCoverPage(input, portfolio, saved.lastUpdated),
      ),
    );

    final evidenceSections = _buildEvidenceSections(input, portfolio);
    if (evidenceSections.isNotEmpty) {
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(42),
          footer: (context) => _footer(context),
          build: (_) => [
            _sectionEyebrow('Work / Learning Evidence'),
            pw.SizedBox(height: 18),
            ...evidenceSections,
          ],
        ),
      );
    }

    return document.save();
  }

  Future<void> previewPortfolioPdf(SavedPortfolio saved) async {
    await Printing.layoutPdf(
      name: _fileName(saved),
      onLayout: (_) => buildPortfolioPdf(saved),
    );
  }

  Future<File> savePortfolioPdf(SavedPortfolio saved) async {
    final bytes = await buildPortfolioPdf(saved);
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}${_fileName(saved)}',
    );
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<void> sharePortfolioPdf(SavedPortfolio saved) async {
    final bytes = await buildPortfolioPdf(saved);
    await Printing.sharePdf(bytes: bytes, filename: _fileName(saved));
  }

  pw.Widget _buildCoverPage(
    PortfolioInput input,
    GeneratedPortfolio portfolio,
    DateTime lastUpdated,
  ) {
    final name = _clean(input.fullName).isEmpty
        ? 'Student Portfolio'
        : _clean(input.fullName);
    final major = _clean(input.major);
    final headline = _clean(portfolio.headline).isNotEmpty
        ? _clean(portfolio.headline)
        : _clean(input.goalTitle);
    final summary = _clean(portfolio.summary);
    final skills = portfolio.skills.where(_notBlank).take(10).toList();
    final links = portfolio.links.where(_validLink).take(5).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(width: 72, height: 5, color: _accent),
            pw.Text(
              'MASAR PORTFOLIO',
              style: pw.TextStyle(
                color: _muted,
                fontSize: 10,
                letterSpacing: 1.4,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        pw.Spacer(),
        pw.Text(
          name,
          style: pw.TextStyle(
            color: _ink,
            fontSize: 38,
            fontWeight: pw.FontWeight.bold,
            lineSpacing: 3,
          ),
        ),
        if (major.isNotEmpty) ...[
          pw.SizedBox(height: 9),
          pw.Text(
            major,
            style: pw.TextStyle(
              color: _accent,
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
        if (headline.isNotEmpty) ...[
          pw.SizedBox(height: 22),
          pw.Container(
            width: 410,
            child: pw.Text(
              headline,
              style: const pw.TextStyle(
                color: _ink,
                fontSize: 18,
                lineSpacing: 4,
              ),
            ),
          ),
        ],
        if (summary.isNotEmpty) ...[
          pw.SizedBox(height: 28),
          _label('Profile Summary'),
          pw.SizedBox(height: 8),
          pw.Container(
            width: 455,
            child: pw.Text(
              summary,
              style: const pw.TextStyle(
                color: _ink,
                fontSize: 11.5,
                lineSpacing: 5,
              ),
            ),
          ),
        ],
        pw.Spacer(),
        pw.Container(height: 1, color: _line),
        pw.SizedBox(height: 18),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (skills.isNotEmpty)
              pw.Expanded(
                child: _compactBlock('Skills Snapshot', skills.join('  |  ')),
              ),
            if (skills.isNotEmpty && links.isNotEmpty) pw.SizedBox(width: 28),
            if (links.isNotEmpty)
              pw.Expanded(
                child: _compactBlock(
                  'Contact / Links',
                  links.map((link) => '${link.label}: ${link.url}').join('\n'),
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'Last updated ${_formatDate(lastUpdated)}',
          style: const pw.TextStyle(color: _muted, fontSize: 9),
        ),
      ],
    );
  }

  List<pw.Widget> _buildEvidenceSections(
    PortfolioInput input,
    GeneratedPortfolio portfolio,
  ) {
    final sections = <pw.Widget>[];

    if (portfolio.projects.any((project) => _clean(project.title).isNotEmpty)) {
      sections.add(_projectsSection(portfolio.projects));
    }

    if (input.completedSubjects.any(_notBlank)) {
      sections.add(
        _bulletsSection('Completed Subjects', input.completedSubjects),
      );
    }

    if (portfolio.skills.any(_notBlank)) {
      sections.add(_chipsSection('Skills', portfolio.skills));
    }

    if (_shouldShowLearningProgress(input, portfolio)) {
      sections.add(
        _textSection('Learning Progress', portfolio.academicProgress),
      );
    }

    if (portfolio.achievements.any(_notBlank)) {
      sections.add(_bulletsSection('Achievements', portfolio.achievements));
    }

    if (portfolio.competitions.any(_notBlank)) {
      sections.add(
        _bulletsSection('Competition Experience', portfolio.competitions),
      );
    }

    return sections
        .map(
          (section) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 18),
            child: section,
          ),
        )
        .toList();
  }

  pw.Widget _projectsSection(List<PortfolioProjectInput> projects) {
    final visible = projects.where(
      (project) => _clean(project.title).isNotEmpty,
    );

    return _sectionShell(
      'Projects',
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: visible.map((project) {
          final tech = project.technologies.where(_notBlank).join(', ');
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.all(13),
            decoration: pw.BoxDecoration(
              color: _soft,
              border: pw.Border(left: pw.BorderSide(color: _accent, width: 3)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  project.title,
                  style: pw.TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (_clean(project.description).isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Text(
                    project.description,
                    style: const pw.TextStyle(
                      color: _ink,
                      fontSize: 10.5,
                      lineSpacing: 4,
                    ),
                  ),
                ],
                if (tech.isNotEmpty) ...[
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Technologies: $tech',
                    style: const pw.TextStyle(color: _muted, fontSize: 9.5),
                  ),
                ],
                if (_clean(project.link).isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Link: ${project.link}',
                    style: const pw.TextStyle(color: _accent, fontSize: 9.5),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _textSection(String title, String text) {
    return _sectionShell(
      title,
      pw.Text(
        text,
        style: const pw.TextStyle(color: _ink, fontSize: 10.5, lineSpacing: 4),
      ),
    );
  }

  pw.Widget _bulletsSection(String title, List<String> values) {
    final visible = values.where(_notBlank).toList();

    return _sectionShell(
      title,
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: visible
            .map(
              (value) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      margin: const pw.EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const pw.BoxDecoration(
                        color: _accent,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Text(
                        value,
                        style: const pw.TextStyle(
                          color: _ink,
                          fontSize: 10.5,
                          lineSpacing: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  pw.Widget _chipsSection(String title, List<String> values) {
    final visible = values.where(_notBlank).toList();

    return _sectionShell(
      title,
      pw.Wrap(
        spacing: 7,
        runSpacing: 7,
        children: visible
            .map(
              (value) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: pw.BoxDecoration(
                  color: _soft,
                  border: pw.Border.all(color: _line),
                  borderRadius: pw.BorderRadius.circular(2),
                ),
                child: pw.Text(
                  value,
                  style: const pw.TextStyle(color: _ink, fontSize: 9.5),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  pw.Widget _sectionShell(String title, pw.Widget child) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            color: _ink,
            fontSize: 15,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(width: 38, height: 2, color: _accent),
        pw.SizedBox(height: 10),
        child,
      ],
    );
  }

  pw.Widget _compactBlock(String title, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _label(title),
        pw.SizedBox(height: 6),
        pw.Text(
          value,
          style: const pw.TextStyle(color: _ink, fontSize: 9.5, lineSpacing: 3),
        ),
      ],
    );
  }

  pw.Widget _sectionEyebrow(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        color: _ink,
        fontSize: 24,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  pw.Widget _label(String text) {
    return pw.Text(
      text.toUpperCase(),
      style: pw.TextStyle(
        color: _accent,
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  pw.Widget _footer(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 16),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(color: _muted, fontSize: 9),
      ),
    );
  }

  bool _shouldShowLearningProgress(
    PortfolioInput input,
    GeneratedPortfolio portfolio,
  ) {
    return _clean(input.learningProgress).isNotEmpty &&
        _clean(portfolio.academicProgress).isNotEmpty;
  }

  String _fileName(SavedPortfolio saved) {
    final name = _clean(saved.input.fullName).isEmpty
        ? 'student'
        : _clean(saved.input.fullName);
    final safeName = name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    return '${safeName}_portfolio.pdf';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _clean(String value) => value.trim();

  bool _notBlank(String value) => _clean(value).isNotEmpty;

  bool _validLink(PortfolioLink link) {
    return _clean(link.label).isNotEmpty && _clean(link.url).isNotEmpty;
  }
}
