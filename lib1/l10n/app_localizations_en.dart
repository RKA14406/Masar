// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get createAccount => 'Create account';

  @override
  String get fillFields => 'Please fill in all fields.';

  @override
  String loginFailed(Object error) {
    return 'Login failed: $error';
  }

  @override
  String get username => 'Username';

  @override
  String get age => 'Age';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get register => 'Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get invalidAge => 'Enter a valid age.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get accountCreated => 'Account created successfully.';

  @override
  String registerFailed(Object error) {
    return 'Register failed: $error';
  }

  @override
  String get joinMasar => 'Join Masar';

  @override
  String get loginSubtitle => 'Log in to continue';

  @override
  String get logout => 'Logout';

  @override
  String get or => 'or';

  @override
  String get appName => 'Masar';

  @override
  String get whatDoYouWantToBecome => 'What do you want to become?';

  @override
  String get weGuideYou => 'We’ll guide you step by step';

  @override
  String get iWantToBe => 'I want to be a...';

  @override
  String get startWithAI => 'Start with AI';

  @override
  String get notSureYet => 'Not sure yet?';

  @override
  String get quickQuiz => 'Quick Career Quiz';

  @override
  String get quizDescription => 'Answer a few questions and we’ll guide you';

  @override
  String get iKnowWhatIWant => 'I know what I want';

  @override
  String get describeYourGoal => 'Describe your goal, and I’ll refine it for you...';

  @override
  String get youCanEdit => 'You can refine your idea before continuing';

  @override
  String get getSuggestions => 'Get suggestions';

  @override
  String get emptyDescriptionError => 'Write a short description first.';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get suggestedSpecialties => 'Suggested specialties';

  @override
  String get choosePathSubtitle => 'Choose one path to open its learning tree.';

  @override
  String get aiInputHint => 'Tell me what you want to become, and I’ll guide you...';

  @override
  String get career_phase3_title => 'Final Phase';

  @override
  String get career_phase3_header => 'FINAL PHASE';

  @override
  String career_phase3_description(Object college, Object specialization) {
    return 'You completed the academic path for $specialization in $college. This phase turns your finished subjects into a career-readiness mini path.';
  }

  @override
  String get career_phase3_what_next => 'What happens next?';

  @override
  String get career_phase3_step1 => '1. The AI suggests matching jobs.';

  @override
  String get career_phase3_step2 => '2. You choose up to 3 jobs.';

  @override
  String get career_phase3_step3 => '3. The app builds your final 3–5 employability nodes.';

  @override
  String get career_phase3_step4 => '4. Each node uses the same quiz and resources system.';

  @override
  String get career_phase3_step5 => '5. Generation is locked permanently after creation.';

  @override
  String get career_phase3_button => 'Start Final Phase';

  @override
  String career_error_loading_jobs(Object error) {
    return 'Could not load job suggestions: $error';
  }

  @override
  String get careerSummaryTitle => 'Career Summary';

  @override
  String get careerSelectedJobs => 'Selected Jobs';

  @override
  String get careerNoJobs => 'No selected jobs found.';

  @override
  String get careerCompletedSubjects => 'Completed Subjects';

  @override
  String careerAcademicCompleted(Object count) {
    return 'Academic subjects completed: $count';
  }

  @override
  String careerPhase3Completed(Object count) {
    return 'Phase 3 nodes completed: $count';
  }

  @override
  String get careerFinalSkills => 'Final Skills Summary';

  @override
  String get careerCvReady => 'CV-Ready Text';

  @override
  String get jobs_screen_title => 'Choose Your Jobs';

  @override
  String get jobs_select_title => 'Select up to 3 target jobs';

  @override
  String jobs_select_subtitle(Object count) {
    return 'Tap to select. Long press to view details. Selected: $count / 3';
  }

  @override
  String get jobs_max_selection => 'You can select up to 3 jobs only.';

  @override
  String get jobs_select_at_least_one => 'Select at least 1 job to continue.';

  @override
  String get jobs_generate_button => 'Generate Final Path';

  @override
  String get jobs_fit_title => 'Why it fits you';

  @override
  String jobs_fit_reason(Object reason) {
    return 'Fit reason: $reason';
  }

  @override
  String jobs_generation_failed(Object error) {
    return 'Phase 3 generation failed: $error';
  }

  @override
  String get phase3_title => 'Phase 3 Path';

  @override
  String get phase3_header => 'Final career-readiness path';

  @override
  String get phase3_description => 'Tap any node to open details. Long press to attempt quiz.';

  @override
  String get phase3_empty => 'No Phase 3 nodes found. Generate first.';

  @override
  String phase3_related_jobs(Object jobs) {
    return 'Related jobs: $jobs';
  }

  @override
  String get phase3_status_completed => 'Completed';

  @override
  String get phase3_status_unlocked => 'Unlocked • Long press to attempt quiz';

  @override
  String get phase3_status_locked => 'Locked until previous node is completed';

  @override
  String get phase3_open_summary => 'Open Final Career Summary';

  @override
  String phase3_already_completed(Object name) {
    return '$name is already completed.';
  }

  @override
  String phase3_locked_first(Object names) {
    return 'This node is locked. Complete first: $names';
  }

  @override
  String phase3_quiz_failed_score(Object name, Object score) {
    return 'Quiz score $score%. You need 60% to complete $name.';
  }

  @override
  String phase3_quiz_integrity(Object name) {
    return 'Integrity violation detected during quiz for $name.';
  }

  @override
  String phase3_marked_completed(Object name) {
    return '$name marked as completed.';
  }

  @override
  String phase3_attempt_limit(Object name) {
    return 'Daily attempt limit reached for $name. Try again tomorrow.';
  }

  @override
  String get college_title => 'Choose Your Path';

  @override
  String get college_select_title => 'Select a college';

  @override
  String get college_select_subtitle => 'Start by choosing your general direction.';

  @override
  String get college_load_error => 'Could not load colleges.';

  @override
  String get college_it_subtitle => 'Software, AI, Cybersecurity';

  @override
  String get college_engineering_subtitle => 'Civil, robotics, communications';

  @override
  String get college_business_subtitle => 'Accounting, MIS, marketing';

  @override
  String get college_science_subtitle => 'Math, physics, biology';

  @override
  String get college_default_subtitle => 'Available specializations';

  @override
  String get fitChatTitle => 'Find Your Fit • Stage 2';

  @override
  String fitChatProgress(Object current, Object total) {
    return 'Guided AI Chat • Question $current of $total';
  }

  @override
  String get fitChatDescription => 'This stage helps you discover the right college direction, then the right specialty inside it.';

  @override
  String get fitChatHint => 'Type your answer...';

  @override
  String get fitChatFallbackError => 'AI chat failed. A safe fallback flow is being used.';

  @override
  String get fitChatFinalizeError => 'Could not finalize the AI chat summary. Please try again.';

  @override
  String fitChatSummaryFailed(Object error) {
    return 'Chat summary failed: $error';
  }

  @override
  String get finish => 'Finish';

  @override
  String get next => 'Next';

  @override
  String get fitResultTitle => 'Find Your Fit • Results';

  @override
  String get fitResultMainTitle => 'Your Best-Match Specialties';

  @override
  String get fitResultSubtitle => 'These results combine your interests, guided chat answers, and soft aptitude signals. Choose one specialty to open the tree immediately.';

  @override
  String get fitResultEmpty => 'No valid specialties were returned after local validation. Retry the fit flow.';

  @override
  String get fitResultError => 'Could not build specialty results. Please retry the fit flow.';

  @override
  String get retry => 'Retry';

  @override
  String get chooseSpecialty => 'Choose Your Specialty';

  @override
  String get specialtyEmptyFallback => 'No valid specialties were found. Go back and try again.';

  @override
  String get specialtyOpenError => 'This specialty could not be opened.';

  @override
  String get college => 'College';

  @override
  String get openTree => 'Open Tree';

  @override
  String get id_imageQuizTitle => 'Image Quiz';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get useCamera => 'Use Camera';

  @override
  String get noImageSelected => 'No image selected yet';

  @override
  String get submitImage => 'Submit Image for Grading';

  @override
  String get imageRequired => 'Please select or capture an image before submitting.';

  @override
  String imagePickError(Object error) {
    return 'Failed to select image: $error';
  }

  @override
  String get imageQuizTitle => 'Image Quiz';

  @override
  String quizQuestionProgress(Object current, Object total) {
    return 'Question $current/$total';
  }

  @override
  String get quizFinish => 'Finish';

  @override
  String get quizNext => 'Next';

  @override
  String get quizSubmit => 'Submit';

  @override
  String get quizWriteHint => 'Write your answer here...';

  @override
  String imageGradingFailed(Object error) {
    return 'Image grading failed: $error';
  }

  @override
  String get imageTaskCompleted => 'I completed the required image task';

  @override
  String get imageExplainHint => 'Explain what your image contains and why it matches the task...';

  @override
  String get noQuestionsAvailable => 'No questions available.';

  @override
  String get chooseSpecializationTitle => 'Choose Specialization';

  @override
  String get specializationsTitle => 'Specializations';

  @override
  String get collegeLabel => 'College';

  @override
  String get noSpecializations => 'No specializations were found for this college.';

  @override
  String get loadSpecializationsError => 'Could not load colleges and specializations.';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get college_it => 'IT';

  @override
  String get college_engineering => 'Engineering';

  @override
  String get college_business => 'Business';

  @override
  String get college_science => 'Science';

  @override
  String get browseTracks => 'Browse Tracks';

  @override
  String get allSpecialties => 'All Specializations';

  @override
  String get searchSpecialty => 'Search specialty...';

  @override
  String get profileTitle => 'Profile';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get progress => 'Progress';

  @override
  String get noTrackSelected => 'No track selected yet';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get active => 'Active';

  @override
  String get progressLabel => 'Progress';

  @override
  String get yourProgress => 'Your Progress';

  @override
  String get specialtyEmpty => 'No specialties found. Try again.';

  @override
  String get specialtyTitle => 'Choose Your Specialty';

  @override
  String get pathHeaderHint => 'Tap a node to inspect it. Hold a node to attempt quiz completion. Swipe to explore the full tree.';

  @override
  String get chooseTrack => 'Choose Track';

  @override
  String get trackSelectedSuccess => 'Track selected successfully';

  @override
  String alreadyCompleted(Object name) => '$name is already completed.';

  @override
  String completeFirstMessage(Object subjects) => 'Complete these first: $subjects';

  @override
  String quizScoreNeedMore(Object score) => 'Score $score%. Need 60%.';

  @override
  String get integrityViolation => 'Integrity violation.';

  @override
  String subjectCompleted(Object name) => '$name completed.';

  @override
  String get completePhasesFirst => 'Complete all Phase 1 & 2 first.';

  @override
  String get learningPath => 'Learning Path';

  @override
  String get fitQuestionsTitle => 'Find Your Fit • Stage 1';

  @override
  String get fitQuestionsHeader => 'Preference Questions';

  @override
  String get fitQuestionsSubtitle => 'Answer the scenario questions honestly. This stage is only trying to understand your natural direction before the AI chat and fundamentals quiz.';

  @override
  String fitQuestionsAnswered(Object current, Object total) => '$current/$total answered';

  @override
  String fitQuestionsContinue(Object current, Object total) => 'Continue to AI Chat ($current/$total)';

  @override
  String get answerAllFirst => 'Answer all questions first.';

  @override
  String fitQuestionsSaveError(Object error) => 'Could not save your answers: $error';

  @override
  String questionLabel(Object index) => 'Question $index';

  @override
  String get fitQuizTitle => 'Find Your Fit • Stage 3';

  @override
  String get fitQuizHeader => 'Academic Readiness Quiz';

  @override
  String get fitQuizSubtitle => 'This quiz focuses on finance, mathematics, physics, and chemistry signals to strengthen your profile.';

  @override
  String get fitQuizFinishButton => 'See My Specialty Suggestions';

  @override
  String get answerAllQuizFirst => 'Answer all quiz questions first.';

  @override
  String fitQuizSaveError(Object error) => 'Could not save quiz results: $error';
}
