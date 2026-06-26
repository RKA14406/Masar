import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'cv_model.dart';

class CvPdfService {
  Future<Uint8List> buildCvPdf(SavedCv saved) async {
    final doc = pw.Document(title: _fileName(saved), author: 'Masar');
    final cv = saved.cv;
    final input = saved.input;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 36, 42, 36),
        build: (_) => [
          _header(input),
          if (cv.summary.trim().isNotEmpty)
            _section('Professional Summary', [
              pw.Text(cv.summary, style: _body()),
            ]),
          if (cv.education.isNotEmpty) _education(cv.education),
          if (_hasSkills(cv)) _skills(cv),
          if (cv.projects.isNotEmpty) _projects(cv.projects),
          if (cv.coursework.isNotEmpty)
            _bullets('Relevant Coursework / Completed Subjects', cv.coursework),
          if (cv.achievements.isNotEmpty)
            _bullets('Competitions and Achievements', cv.achievements),
          if (cv.competitions.isNotEmpty)
            _bullets('Competition Experience', cv.competitions),
          if (cv.experience.isNotEmpty) _experience(cv.experience),
          if (cv.languages.isNotEmpty) _bullets('Languages', cv.languages),
        ],
      ),
    );

    return doc.save();
  }

  Future<void> previewCvPdf(SavedCv saved) async {
    await Printing.layoutPdf(
      name: _fileName(saved),
      onLayout: (_) => buildCvPdf(saved),
    );
  }

  Future<File> saveCvPdf(SavedCv saved) async {
    final bytes = await buildCvPdf(saved);
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}${Platform.pathSeparator}${_fileName(saved)}',
    );
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<void> shareCvPdf(SavedCv saved) async {
    await Printing.sharePdf(
      bytes: await buildCvPdf(saved),
      filename: _fileName(saved),
    );
  }

  pw.Widget _header(CvInput input) {
    final contacts = [
      input.email,
      input.phone,
      input.location,
      ...input.links.map((link) => '${link.label}: ${link.url}'),
    ].where((item) => item.trim().isNotEmpty).join(' | ');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          input.fullName.trim(),
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        if (input.targetRole.trim().isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Text(input.targetRole.trim(), style: _body(bold: true)),
        ],
        if (contacts.isNotEmpty) ...[
          pw.SizedBox(height: 5),
          pw.Text(contacts, style: _small()),
        ],
        pw.SizedBox(height: 14),
      ],
    );
  }

  pw.Widget _education(List<CvEducation> items) {
    return _section(
      'Education',
      items.map((education) {
        final title = [
          education.degree,
          education.major,
          education.specialization,
        ].where((item) => item.trim().isNotEmpty).join(' - ');
        final meta = [
          education.institution,
          education.graduationYear,
          if (education.gpa.trim().isNotEmpty) 'GPA: ${education.gpa}',
        ].where((item) => item.trim().isNotEmpty).join(' | ');

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) pw.Text(title, style: _body(bold: true)),
            if (meta.isNotEmpty) pw.Text(meta, style: _small()),
            ...education.details.map((detail) => _bullet(detail)),
          ],
        );
      }).toList(),
    );
  }

  pw.Widget _skills(GeneratedCv cv) {
    final lines = <String>[];
    if (cv.technicalSkills.isNotEmpty) {
      lines.add('Technical: ${cv.technicalSkills.join(', ')}');
    }
    if (cv.tools.isNotEmpty) {
      lines.add('Tools/Languages: ${cv.tools.join(', ')}');
    }
    if (cv.softSkills.isNotEmpty) {
      lines.add('Soft: ${cv.softSkills.join(', ')}');
    }

    return _section(
      'Technical Skills',
      lines.map((line) => pw.Text(line, style: _body())).toList(),
    );
  }

  pw.Widget _projects(List<CvProject> projects) {
    return _section(
      'Projects',
      projects.map((project) {
        final tech = project.technologies.isEmpty
            ? ''
            : 'Technologies: ${project.technologies.join(', ')}';
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(project.title, style: _body(bold: true)),
            if (tech.isNotEmpty) pw.Text(tech, style: _small()),
            if (project.link.trim().isNotEmpty)
              pw.Text('Link: ${project.link}', style: _small()),
            ...project.descriptionBullets.map(_bullet),
            pw.SizedBox(height: 5),
          ],
        );
      }).toList(),
    );
  }

  pw.Widget _experience(List<CvExperience> items) {
    return _section(
      'Experience',
      items.map((item) {
        final title = [
          item.title,
          item.organization,
        ].where((part) => part.trim().isNotEmpty).join(' - ');
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) pw.Text(title, style: _body(bold: true)),
            if (item.date.trim().isNotEmpty)
              pw.Text(item.date, style: _small()),
            ...item.bullets.map(_bullet),
            pw.SizedBox(height: 5),
          ],
        );
      }).toList(),
    );
  }

  pw.Widget _bullets(String title, List<String> values) {
    return _section(title, values.map(_bullet).toList());
  }

  pw.Widget _section(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.only(bottom: 3),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.8)),
          ),
          child: pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 7),
        ...children,
        pw.SizedBox(height: 11),
      ],
    );
  }

  pw.Widget _bullet(String text) {
    if (text.trim().isEmpty) return pw.SizedBox.shrink();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('- ', style: _body()),
          pw.Expanded(child: pw.Text(text.trim(), style: _body())),
        ],
      ),
    );
  }

  pw.TextStyle _body({bool bold = false}) {
    return pw.TextStyle(
      fontSize: 10,
      lineSpacing: 2,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
  }

  pw.TextStyle _small() =>
      const pw.TextStyle(fontSize: 9, color: PdfColors.grey700);

  bool _hasSkills(GeneratedCv cv) {
    return cv.technicalSkills.isNotEmpty ||
        cv.tools.isNotEmpty ||
        cv.softSkills.isNotEmpty;
  }

  String _fileName(SavedCv saved) {
    final name = saved.input.fullName.trim().isEmpty
        ? 'student'
        : saved.input.fullName.trim();
    return '${name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}_cv.pdf';
  }
}
