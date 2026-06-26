import 'package:flutter/material.dart';

import '../../core/widgets/app_drawer.dart';
import 'portfolio_document_preview_screen.dart';
import 'portfolio_input_screen.dart';
import 'portfolio_model.dart';
import 'portfolio_pdf_service.dart';
import 'portfolio_storage_service.dart';

class PortfolioPreviewScreen extends StatefulWidget {
  final SavedPortfolio portfolio;
  final bool usedFallback;

  const PortfolioPreviewScreen({
    super.key,
    required this.portfolio,
    this.usedFallback = false,
  });

  @override
  State<PortfolioPreviewScreen> createState() => _PortfolioPreviewScreenState();
}

class _PortfolioPreviewScreenState extends State<PortfolioPreviewScreen> {
  final _storageService = PortfolioStorageService();
  final _pdfService = PortfolioPdfService();

  bool _isSaving = false;
  bool _isGeneratingPdf = false;
  String? _lastPdfPath;

  SavedPortfolio get _freshPortfolio {
    return SavedPortfolio(
      input: widget.portfolio.input,
      portfolio: widget.portfolio.portfolio,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> _savePortfolio() async {
    setState(() => _isSaving = true);
    await _storageService.savePortfolio(_freshPortfolio);

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Portfolio saved locally.')));
  }

  Future<void> _generatePdf() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final saved = _freshPortfolio;
      await _storageService.savePortfolio(saved);
      final file = await _pdfService.savePortfolioPdf(saved);

      if (!mounted) return;
      setState(() {
        _lastPdfPath = file.path;
        _isGeneratingPdf = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF generated: ${file.path}')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isGeneratingPdf = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF generation failed: $error')));
    }
  }

  void _previewPdf() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PortfolioDocumentPreviewScreen(portfolio: _freshPortfolio),
      ),
    );
  }

  Future<void> _sharePdf() async {
    try {
      await _pdfService.sharePortfolioPdf(_freshPortfolio);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF sharing failed: $error')));
    }
  }

  void _editInputs() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PortfolioInputScreen(initialInput: widget.portfolio.input),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.portfolio.input;
    final portfolio = widget.portfolio.portfolio;
    final guidance = _guidanceMessages(input, portfolio);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Portfolio Preview')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          if (widget.usedFallback)
            _InfoBanner(
              text:
                  'Gemini was unavailable, so this document uses a local draft. The PDF can still be generated.',
            ),
          if (guidance.isNotEmpty) _GuidancePanel(messages: guidance),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 760),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _DocumentPage(input: input, portfolio: portfolio),
            ),
          ),
          if (_lastPdfPath != null) ...[
            const SizedBox(height: 12),
            _InfoBanner(text: 'Last generated PDF: $_lastPdfPath'),
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
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _isGeneratingPdf ? null : _generatePdf,
                icon: _isGeneratingPdf
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Generate PDF'),
              ),
              OutlinedButton.icon(
                onPressed: _previewPdf,
                icon: const Icon(Icons.preview_outlined),
                label: const Text('Preview PDF'),
              ),
              OutlinedButton.icon(
                onPressed: _sharePdf,
                icon: const Icon(Icons.ios_share_outlined),
                label: const Text('Share PDF'),
              ),
              OutlinedButton.icon(
                onPressed: _editInputs,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Portfolio Info'),
              ),
              IconButton(
                onPressed: _isSaving ? null : _savePortfolio,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                tooltip: 'Save Portfolio',
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _guidanceMessages(
    PortfolioInput input,
    GeneratedPortfolio portfolio,
  ) {
    final messages = <String>[];
    if (input.major.trim().isEmpty) {
      messages.add(
        'Add your major before exporting for a stronger cover page.',
      );
    }
    if (portfolio.projects.isEmpty) {
      messages.add('Add at least one project to make the portfolio stronger.');
    }
    if (portfolio.skills.isEmpty) {
      messages.add('Add skills to show a clear skills snapshot.');
    }
    return messages;
  }
}

class _DocumentPage extends StatelessWidget {
  final PortfolioInput input;
  final GeneratedPortfolio portfolio;

  const _DocumentPage({required this.input, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF172033);
    const muted = Color(0xFF64748B);
    const accent = Color(0xFF1F6FEB);
    final name = input.fullName.trim().isEmpty
        ? 'Student Portfolio'
        : input.fullName.trim();
    final major = input.major.trim();
    final headline = portfolio.headline.trim().isNotEmpty
        ? portfolio.headline.trim()
        : input.goalTitle.trim();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 980),
      padding: const EdgeInsets.fromLTRB(34, 34, 34, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: ink, height: 1.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 74, height: 5, color: accent),
                const Text(
                  'MASAR PORTFOLIO',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 54),
            Text(
              name,
              style: const TextStyle(
                color: ink,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.08,
              ),
            ),
            if (major.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                major,
                style: const TextStyle(
                  color: accent,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            if (headline.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                headline,
                style: const TextStyle(color: ink, fontSize: 18, height: 1.35),
              ),
            ],
            if (portfolio.summary.trim().isNotEmpty) ...[
              const SizedBox(height: 28),
              const _DocumentLabel('Profile Summary'),
              const SizedBox(height: 8),
              Text(
                portfolio.summary.trim(),
                style: const TextStyle(fontSize: 14, height: 1.55),
              ),
            ],
            const SizedBox(height: 34),
            Container(height: 1, color: const Color(0xFFE2E8F0)),
            const SizedBox(height: 22),
            _DocumentTopGrid(input: input, portfolio: portfolio),
            const SizedBox(height: 34),
            ..._contentSections(),
          ],
        ),
      ),
    );
  }

  List<Widget> _contentSections() {
    final sections = <Widget>[];

    if (portfolio.projects.isNotEmpty) {
      sections.add(_ProjectsDocumentSection(projects: portfolio.projects));
    }
    if (input.completedSubjects.isNotEmpty) {
      sections.add(
        _ListDocumentSection(
          title: 'Completed Subjects',
          values: input.completedSubjects,
        ),
      );
    }
    if (input.learningProgress.trim().isNotEmpty &&
        portfolio.academicProgress.trim().isNotEmpty) {
      sections.add(
        _TextDocumentSection(
          title: 'Learning Progress',
          text: portfolio.academicProgress,
        ),
      );
    }
    if (portfolio.achievements.isNotEmpty) {
      sections.add(
        _ListDocumentSection(
          title: 'Achievements',
          values: portfolio.achievements,
        ),
      );
    }
    if (portfolio.competitions.isNotEmpty) {
      sections.add(
        _ListDocumentSection(
          title: 'Competition Experience',
          values: portfolio.competitions,
        ),
      );
    }

    return sections
        .map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: section,
          ),
        )
        .toList();
  }
}

class _DocumentTopGrid extends StatelessWidget {
  final PortfolioInput input;
  final GeneratedPortfolio portfolio;

  const _DocumentTopGrid({required this.input, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    final hasSkills = portfolio.skills.isNotEmpty;
    final hasLinks = portfolio.links.isNotEmpty;

    if (!hasSkills && !hasLinks) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;
        final children = <Widget>[
          if (hasSkills)
            Expanded(
              child: _SnapshotBlock(
                title: 'Skills Snapshot',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: portfolio.skills
                      .take(10)
                      .map((skill) => _SkillPill(label: skill))
                      .toList(),
                ),
              ),
            ),
          if (hasLinks)
            Expanded(
              child: _SnapshotBlock(
                title: 'Contact / Links',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: portfolio.links
                      .map(
                        (link) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            '${link.label}: ${link.url}',
                            style: const TextStyle(fontSize: 12.5),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
        ];

        if (isNarrow || children.length == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: child,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [children.first, const SizedBox(width: 28), children.last],
        );
      },
    );
  }
}

class _SnapshotBlock extends StatelessWidget {
  final String title;
  final Widget child;

  const _SnapshotBlock({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_DocumentLabel(title), const SizedBox(height: 9), child],
    );
  }
}

class _SkillPill extends StatelessWidget {
  final String label;

  const _SkillPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _ProjectsDocumentSection extends StatelessWidget {
  final List<PortfolioProjectInput> projects;

  const _ProjectsDocumentSection({required this.projects});

  @override
  Widget build(BuildContext context) {
    return _DocumentSection(
      title: 'Projects',
      child: Column(
        children: projects
            .where((project) => project.title.trim().isNotEmpty)
            .map(
              (project) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(
                    left: BorderSide(color: Color(0xFF1F6FEB), width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (project.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        project.description,
                        style: const TextStyle(fontSize: 13, height: 1.45),
                      ),
                    ],
                    if (project.technologies.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Technologies: ${project.technologies.join(', ')}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (project.link.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Link: ${project.link}',
                        style: const TextStyle(
                          color: Color(0xFF1F6FEB),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TextDocumentSection extends StatelessWidget {
  final String title;
  final String text;

  const _TextDocumentSection({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return _DocumentSection(
      title: title,
      child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.5)),
    );
  }
}

class _ListDocumentSection extends StatelessWidget {
  final String title;
  final List<String> values;

  const _ListDocumentSection({required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    return _DocumentSection(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: values
            .where((value) => value.trim().isNotEmpty)
            .map(
              (value) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(top: 7),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1F6FEB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 13, height: 1.4),
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
}

class _DocumentSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DocumentSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF172033),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Container(width: 40, height: 2, color: const Color(0xFF1F6FEB)),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _DocumentLabel extends StatelessWidget {
  final String text;

  const _DocumentLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF1F6FEB),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;

  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class _GuidancePanel extends StatelessWidget {
  final List<String> messages;

  const _GuidancePanel({required this.messages});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Improve before exporting',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...messages.map(
              (message) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(message)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
