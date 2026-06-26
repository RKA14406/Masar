import '../datasources/subject_local_datasource.dart';
import '../models/subject_model.dart';

class SubjectRepository {
  final SubjectLocalDataSource localDataSource;

  SubjectRepository({required this.localDataSource});

  Future<List<Subject>> getAllSubjects() {
    return localDataSource.loadAllSubjects();
  }

  Future<List<Subject>> getSubjectsBySpecialization(String specialization) {
    return localDataSource.loadSubjectsBySpecialization(specialization);
  }

  Future<List<Subject>> getSubjectsByCollegeAndSpecialization({
    required String college,
    required String specialization,
  }) {
    return localDataSource.loadSubjectsByCollegeAndSpecialization(
      college: college,
      specialization: specialization,
    );
  }

  Future<List<String>> getAvailableColleges() {
    return localDataSource.loadAvailableColleges();
  }

  Future<List<String>> getAvailableSpecializations() {
    return localDataSource.loadAvailableSpecializations();
  }

  Future<List<String>> getAvailableSpecializationsByCollege(String college) {
    return localDataSource.loadAvailableSpecializationsByCollege(college);
  }
}
