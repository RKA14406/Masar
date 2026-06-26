import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/progress_service.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/widgets/app_drawer.dart';
import 'personal_info_model.dart';
import 'personal_info_storage_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _storage = PersonalInfoStorageService();
  final _progressService = ProgressService();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _majorController = TextEditingController();
  final _skillController = TextEditingController();
  final _goalsController = TextEditingController();
  final _countryController = TextEditingController();
  final _enrollmentYearController = TextEditingController();

  final List<String> _skills = [];
  String _enrollmentQuarter = '';
  String _gender = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _majorController.dispose();
    _skillController.dispose();
    _goalsController.dispose();
    _countryController.dispose();
    _enrollmentYearController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final saved = await _storage.load();
    final profile = await UserProfileService().getCurrentUserProfile();
    final track = await _progressService.getSelectedTrack();
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    final fullName = saved?.fullName.trim().isNotEmpty == true
        ? saved!.fullName
        : (profile?['username'] ?? '').toString();
    final email = saved?.email.trim().isNotEmpty == true
        ? saved!.email
        : (user?.email ?? profile?['email'] ?? '').toString();
    final major = saved?.major.trim().isNotEmpty == true
        ? saved!.major
        : (track?.specialization ?? '');

    setState(() {
      _fullNameController.text = fullName;
      _emailController.text = email;
      _majorController.text = major;
      _goalsController.text = saved?.goals ?? '';
      _countryController.text = saved?.country ?? '';
      _enrollmentYearController.text = saved?.enrollmentYear ?? '';
      _skills
        ..clear()
        ..addAll(saved?.skills ?? const []);
      _enrollmentQuarter = saved?.enrollmentQuarter ?? '';
      _gender = saved?.gender ?? '';
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final info = PersonalInfo(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      major: _majorController.text.trim(),
      skills: List<String>.unmodifiable(_skills),
      goals: _goalsController.text.trim(),
      country: _countryController.text.trim(),
      enrollmentQuarter: _enrollmentQuarter,
      enrollmentYear: _enrollmentYearController.text.trim(),
      gender: _gender,
    );

    await _storage.save(info);

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal info saved locally.')),
    );
  }

  void _addSkill() {
    final value = _skillController.text.trim();
    if (value.isEmpty || _skills.contains(value)) return;
    setState(() {
      _skills.add(value);
      _skillController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Personal Info')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SectionCard(
                  title: 'Basic Details',
                  children: [
                    _TextField(
                      controller: _fullNameController,
                      label: 'Full name',
                    ),
                    _TextField(controller: _emailController, label: 'Email'),
                    _TextField(controller: _majorController, label: 'Major'),
                    _TextField(
                      controller: _countryController,
                      label: 'Country',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Skills',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _TextField(
                            controller: _skillController,
                            label: 'Add a skill',
                            onSubmitted: (_) => _addSkill(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _addSkill,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_skills.isEmpty)
                      Text(
                        'Add skills to improve your CV and guidance.',
                        style: theme.textTheme.bodySmall,
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _skills
                            .map(
                              (skill) => InputChip(
                                label: Text(skill),
                                onDeleted: () {
                                  setState(() => _skills.remove(skill));
                                },
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Goals and Enrollment',
                  children: [
                    _TextField(
                      controller: _goalsController,
                      label: 'Goals',
                      maxLines: 3,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _enrollmentQuarter.isEmpty
                          ? null
                          : _enrollmentQuarter,
                      decoration: const InputDecoration(
                        labelText: 'Enrollment Quarter',
                        border: OutlineInputBorder(),
                      ),
                      items: const ['Q1', 'Q2', 'Q3', 'Q4']
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _enrollmentQuarter = value ?? '');
                      },
                    ),
                    const SizedBox(height: 12),
                    _TextField(
                      controller: _enrollmentYearController,
                      label: 'Enrollment Year',
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _gender.isEmpty ? null : _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items: const ['Male', 'Female', 'Prefer not to say']
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _gender = value ?? '');
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gender is optional and is not used to restrict jobs or opportunities.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_isSaving ? 'Saving...' : 'Save Personal Info'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ...children.expand((child) => [child, const SizedBox(height: 12)]),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;

  const _TextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: maxLines == 1 ? TextInputAction.next : null,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
