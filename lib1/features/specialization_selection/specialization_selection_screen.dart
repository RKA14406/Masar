import 'package:flutter/material.dart';

import '../../data/datasources/subject_local_datasource.dart';
import '../../data/repositories/subject_repository.dart';
import '../path_view/path_view_screen.dart';

class SpecializationSelectionScreen extends StatefulWidget {
  final String? initialCollege;

  const SpecializationSelectionScreen({
    super.key,
    this.initialCollege,
  });

  @override
  State<SpecializationSelectionScreen> createState() =>
      _SpecializationSelectionScreenState();
}

class _SpecializationSelectionScreenState
    extends State<SpecializationSelectionScreen> {
  late final SubjectRepository _repository;

  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedCollege;
  List<String> _colleges = const [];
  List<String> _specializations = const [];

  @override
  void initState() {
    super.initState();
    _repository = SubjectRepository(
      localDataSource: SubjectLocalDataSource(),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final colleges = await _repository.getAvailableColleges();
      final preferredCollege = widget.initialCollege != null &&
              colleges.any(
                (college) => college.toLowerCase() == widget.initialCollege!.toLowerCase(),
              )
          ? colleges.firstWhere(
              (college) => college.toLowerCase() == widget.initialCollege!.toLowerCase(),
            )
          : (colleges.isNotEmpty ? colleges.first : null);

      final specializations = preferredCollege == null
          ? <String>[]
          : await _repository.getAvailableSpecializationsByCollege(preferredCollege);

      setState(() {
        _colleges = colleges;
        _selectedCollege = preferredCollege;
        _specializations = specializations;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Could not load colleges and specializations.';
        _isLoading = false;
      });
      debugPrint('SpecializationSelectionScreen error: $error');
    }
  }

  Future<void> _onCollegeChanged(String? college) async {
    if (college == null) return;

    setState(() {
      _selectedCollege = college;
      _isLoading = true;
    });

    final specializations =
        await _repository.getAvailableSpecializationsByCollege(college);

    setState(() {
      _specializations = specializations;
      _isLoading = false;
    });
  }

  void _openPath(String specialization) {
    if (_selectedCollege == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PathViewScreen(
          college: _selectedCollege!,
          specialization: specialization,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _colleges.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Specializations')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Specialization'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCollege,
              decoration: const InputDecoration(
                labelText: 'College',
                border: OutlineInputBorder(),
              ),
              items: _colleges
                  .map(
                    (college) => DropdownMenuItem<String>(
                      value: college,
                      child: Text(college),
                    ),
                  )
                  .toList(),
              onChanged: _onCollegeChanged,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _specializations.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No specializations were found for this college.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _specializations.length,
                        itemBuilder: (context, index) {
                          final specialization = _specializations[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _openPath(specialization),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.school_outlined),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          specialization,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
