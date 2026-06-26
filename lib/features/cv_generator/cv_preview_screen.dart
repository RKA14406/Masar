import 'package:flutter/material.dart';

import '../../core/widgets/app_drawer.dart';
import '../../l10n/masar_text.dart';
import 'cv_builder_screen.dart';
import 'cv_model.dart';
import 'cv_pdf_preview_screen.dart';
import 'cv_pdf_service.dart';
import 'cv_storage_service.dart';

class CvPreviewScreen extends StatefulWidget {
  final SavedCv savedCv;
  final bool usedFallback;

  const CvPreviewScreen({
    super.key,
    required this.savedCv,
    this.usedFallback = false,
  });

  @override
  State<CvPreviewScreen> createState() => _CvPreviewScreenState();
}

class _CvPreviewScreenState extends State<CvPreviewScreen> {
  final _storage = CvStorageService();
  final _pdf = CvPdfService();
  bool _exporting = false;
  String? _lastPath;

  SavedCv get _fresh => SavedCv(
    input: widget.savedCv.input,
    cv: widget.savedCv.cv,
    atsScore: widget.savedCv.atsScore,
    improvementTips: widget.savedCv.improvementTips,
    lastUpdated: DateTime.now(),
  );

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      await _storage.saveCv(_fresh);
      final file = await _pdf.saveCvPdf(_fresh);
      if (!mounted) return;
      setState(() {
        _lastPath = file.path;
        _exporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${MasarText.t(context, 'CV exported:', 'تم تصدير السيرة الذاتية:')} ${file.path}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _exporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${MasarText.t(context, 'Export failed:', 'فشل التصدير:')} $error',
          ),
        ),
      );
    }
  }

  void _previewPdf() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CvPdfPreviewScreen(savedCv: _fresh)),
    );
  }

  Future<void> _sharePdf() async {
    try {
      await _pdf.shareCvPdf(_fresh);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${MasarText.t(context, 'Share failed:', 'فشلت المشاركة:')} $error',
          ),
        ),
      );
    }
  }

  void _edit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CvBuilderScreen(initialInput: widget.savedCv.input),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = MasarText.t;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(t(context, 'CV Preview', 'معاينة السيرة الذاتية')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
        children: [
          if (widget.usedFallback)
            _Banner(
              text: t(
                context,
                'Gemini was unavailable, so this CV uses a local ATS-friendly draft.',
                'لم يكن Gemini متاحاً، لذلك تستخدم هذه السيرة مسودة محلية مناسبة لـ ATS.',
              ),
            ),
          _AtsCard(
            score: widget.savedCv.atsScore,
            tips: widget.savedCv.improvementTips,
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 760),
              padding: const EdgeInsets.all(18),
              color: const Color(0xFFE5E7EB),
              child: _CvDocument(savedCv: widget.savedCv),
            ),
          ),
          if (_lastPath != null) ...[
            const SizedBox(height: 12),
            _Banner(
              text:
                  '${t(context, 'Last exported PDF:', 'آخر ملف PDF مُصدّر:')} $_lastPath',
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: _previewPdf,
                icon: const Icon(Icons.preview_outlined),
                label: Text(t(context, 'Preview PDF', 'معاينة PDF')),
              ),
              FilledButton.icon(
                onPressed: _exporting ? null : _exportPdf,
                icon: _exporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  t(context, 'Export CV as PDF', 'تصدير السيرة كـ PDF'),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _sharePdf,
                icon: const Icon(Icons.ios_share_outlined),
                label: Text(t(context, 'Share PDF', 'مشاركة PDF')),
              ),
              OutlinedButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(t(context, 'Edit CV Info', 'تعديل بيانات السيرة')),
              ),
              OutlinedButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.refresh),
                label: Text(t(context, 'Regenerate', 'إعادة الإنشاء')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CvDocument extends StatelessWidget {
  final SavedCv savedCv;

  const _CvDocument({required this.savedCv});

  @override
  Widget build(BuildContext context) {
    final input = savedCv.input;
    final cv = savedCv.cv;
    final t = MasarText.t;
    final contacts = [
      input.email,
      input.phone,
      input.location,
      ...input.links.map((link) => '${link.label}: ${link.url}'),
    ].where((item) => item.trim().isNotEmpty).join(' | ');

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 960),
      padding: const EdgeInsets.all(34),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xFF111827),
          fontSize: 13,
          height: 1.35,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              input.fullName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            if (input.targetRole.isNotEmpty)
              Text(
                input.targetRole,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            if (contacts.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                contacts,
                style: const TextStyle(color: Color(0xFF4B5563), fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            if (cv.summary.isNotEmpty)
              _TextSection(
                title: t(context, 'Professional Summary', 'الملخص المهني'),
                text: cv.summary,
              ),
            if (cv.education.isNotEmpty) _EducationSection(items: cv.education),
            if (cv.technicalSkills.isNotEmpty ||
                cv.tools.isNotEmpty ||
                cv.softSkills.isNotEmpty)
              _TextSection(
                title: t(context, 'Technical Skills', 'المهارات التقنية'),
                text: [
                  if (cv.technicalSkills.isNotEmpty)
                    '${t(context, 'Technical:', 'تقنية:')} ${cv.technicalSkills.join(', ')}',
                  if (cv.tools.isNotEmpty)
                    '${t(context, 'Tools/Languages:', 'الأدوات/اللغات:')} ${cv.tools.join(', ')}',
                  if (cv.softSkills.isNotEmpty)
                    '${t(context, 'Soft:', 'شخصية:')} ${cv.softSkills.join(', ')}',
                ].join('\n'),
              ),
            if (cv.projects.isNotEmpty) _ProjectsSection(projects: cv.projects),
            if (cv.coursework.isNotEmpty)
              _ListSection(
                title: t(
                  context,
                  'Relevant Coursework / Completed Subjects',
                  'المواد ذات الصلة / المواد المكتملة',
                ),
                values: cv.coursework,
              ),
            if (cv.achievements.isNotEmpty)
              _ListSection(
                title: t(
                  context,
                  'Competitions and Achievements',
                  'المسابقات والإنجازات',
                ),
                values: cv.achievements,
              ),
            if (cv.competitions.isNotEmpty)
              _ListSection(
                title: t(context, 'Competition Experience', 'خبرات المسابقات'),
                values: cv.competitions,
              ),
            if (cv.experience.isNotEmpty)
              _ExperienceSection(items: cv.experience),
            if (cv.languages.isNotEmpty)
              _ListSection(
                title: t(context, 'Languages', 'اللغات'),
                values: cv.languages,
              ),
          ],
        ),
      ),
    );
  }
}

class _AtsCard extends StatelessWidget {
  final int score;
  final List<String> tips;

  const _AtsCard({required this.score, required this.tips});

  @override
  Widget build(BuildContext context) {
    final t = MasarText.t;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${t(context, 'ATS Readiness Score:', 'درجة جاهزية ATS:')} $score/100',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (tips.isEmpty)
              Text(
                t(
                  context,
                  'Your CV includes the main ATS-friendly basics.',
                  'سيرتك الذاتية تحتوي على الأساسيات المناسبة لـ ATS.',
                ),
              )
            else
              ...tips.take(5).map((tip) => Text('- $tip')),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 4),
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black87)),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  final String title;
  final String text;
  const _TextSection({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_Header(title), Text(text)],
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final List<String> values;
  const _ListSection({required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_Header(title), ...values.map((value) => Text('- $value'))],
    );
  }
}

class _EducationSection extends StatelessWidget {
  final List<CvEducation> items;
  const _EducationSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(MasarText.t(context, 'Education', 'التعليم')),
        ...items.map((item) {
          final title = [
            item.degree,
            item.major,
            item.specialization,
          ].where((part) => part.isNotEmpty).join(' - ');
          final meta = [
            item.institution,
            item.graduationYear,
            if (item.gpa.isNotEmpty)
              '${MasarText.t(context, 'GPA:', 'المعدل:')} ${item.gpa}',
          ].where((part) => part.isNotEmpty).join(' | ');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (meta.isNotEmpty) Text(meta),
            ],
          );
        }),
      ],
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  final List<CvProject> projects;
  const _ProjectsSection({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(MasarText.t(context, 'Projects', 'المشاريع')),
        ...projects.map(
          (project) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (project.technologies.isNotEmpty)
                Text(
                  '${MasarText.t(context, 'Technologies:', 'التقنيات:')} ${project.technologies.join(', ')}',
                  style: const TextStyle(color: Color(0xFF4B5563)),
                ),
              if (project.link.isNotEmpty)
                Text(
                  '${MasarText.t(context, 'Link:', 'الرابط:')} ${project.link}',
                  style: const TextStyle(color: Color(0xFF4B5563)),
                ),
              ...project.descriptionBullets.map((bullet) => Text('- $bullet')),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExperienceSection extends StatelessWidget {
  final List<CvExperience> items;
  const _ExperienceSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(MasarText.t(context, 'Experience', 'الخبرة')),
        ...items.map(
          (item) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  item.title,
                  item.organization,
                ].where((part) => part.isNotEmpty).join(' - '),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (item.date.isNotEmpty) Text(item.date),
              ...item.bullets.map((bullet) => Text('- $bullet')),
            ],
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  final String text;
  const _Banner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(14), child: Text(text)),
    );
  }
}
