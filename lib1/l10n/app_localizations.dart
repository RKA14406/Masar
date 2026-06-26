import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @welcomeBack.
  ///
  /// No description provided for @home.
  String get home;

  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @fillFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get fillFields;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(Object error);

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @invalidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age.'**
  String get invalidAge;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully.'**
  String get accountCreated;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Register failed: {error}'**
  String registerFailed(Object error);

  /// No description provided for @joinMasar.
  ///
  /// In en, this message translates to:
  /// **'Join Masar'**
  String get joinMasar;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get loginSubtitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Masar'**
  String get appName;

  /// No description provided for @whatDoYouWantToBecome.
  ///
  /// In en, this message translates to:
  /// **'What do you want to become?'**
  String get whatDoYouWantToBecome;

  /// No description provided for @weGuideYou.
  ///
  /// In en, this message translates to:
  /// **'We’ll guide you step by step'**
  String get weGuideYou;

  /// No description provided for @iWantToBe.
  ///
  /// In en, this message translates to:
  /// **'I want to be a...'**
  String get iWantToBe;

  /// No description provided for @startWithAI.
  ///
  /// In en, this message translates to:
  /// **'Start with AI'**
  String get startWithAI;

  /// No description provided for @notSureYet.
  ///
  /// In en, this message translates to:
  /// **'Not sure yet?'**
  String get notSureYet;

  /// No description provided for @quickQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quick Career Quiz'**
  String get quickQuiz;

  /// No description provided for @quizDescription.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions and we’ll guide you'**
  String get quizDescription;

  /// No description provided for @iKnowWhatIWant.
  ///
  /// In en, this message translates to:
  /// **'I know what I want'**
  String get iKnowWhatIWant;

  /// No description provided for @describeYourGoal.
  ///
  /// In en, this message translates to:
  /// **'Describe your goal, and I’ll refine it for you...'**
  String get describeYourGoal;

  /// No description provided for @youCanEdit.
  ///
  /// In en, this message translates to:
  /// **'You can refine your idea before continuing'**
  String get youCanEdit;

  /// No description provided for @getSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Get suggestions'**
  String get getSuggestions;

  /// No description provided for @emptyDescriptionError.
  ///
  /// In en, this message translates to:
  /// **'Write a short description first.'**
  String get emptyDescriptionError;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @suggestedSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Suggested specialties'**
  String get suggestedSpecialties;

  /// No description provided for @choosePathSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose one path to open its learning tree.'**
  String get choosePathSubtitle;

  /// No description provided for @aiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Tell me what you want to become, and I’ll guide you...'**
  String get aiInputHint;

  /// No description provided for @career_phase3_title.
  ///
  /// In en, this message translates to:
  /// **'Final Phase'**
  String get career_phase3_title;

  /// No description provided for @career_phase3_header.
  ///
  /// In en, this message translates to:
  /// **'FINAL PHASE'**
  String get career_phase3_header;

  /// No description provided for @career_phase3_description.
  ///
  /// In en, this message translates to:
  /// **'You completed the academic path for {specialization} in {college}. This phase turns your finished subjects into a career-readiness mini path.'**
  String career_phase3_description(Object college, Object specialization);

  /// No description provided for @career_phase3_what_next.
  ///
  /// In en, this message translates to:
  /// **'What happens next?'**
  String get career_phase3_what_next;

  /// No description provided for @career_phase3_step1.
  ///
  /// In en, this message translates to:
  /// **'1. The AI suggests matching jobs.'**
  String get career_phase3_step1;

  /// No description provided for @career_phase3_step2.
  ///
  /// In en, this message translates to:
  /// **'2. You choose up to 3 jobs.'**
  String get career_phase3_step2;

  /// No description provided for @career_phase3_step3.
  ///
  /// In en, this message translates to:
  /// **'3. The app builds your final 3–5 employability nodes.'**
  String get career_phase3_step3;

  /// No description provided for @career_phase3_step4.
  ///
  /// In en, this message translates to:
  /// **'4. Each node uses the same quiz and resources system.'**
  String get career_phase3_step4;

  /// No description provided for @career_phase3_step5.
  ///
  /// In en, this message translates to:
  /// **'5. Generation is locked permanently after creation.'**
  String get career_phase3_step5;

  /// No description provided for @career_phase3_button.
  ///
  /// In en, this message translates to:
  /// **'Start Final Phase'**
  String get career_phase3_button;

  /// No description provided for @career_error_loading_jobs.
  ///
  /// In en, this message translates to:
  /// **'Could not load job suggestions: {error}'**
  String career_error_loading_jobs(Object error);

  /// No description provided for @careerSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Career Summary'**
  String get careerSummaryTitle;

  /// No description provided for @careerSelectedJobs.
  ///
  /// In en, this message translates to:
  /// **'Selected Jobs'**
  String get careerSelectedJobs;

  /// No description provided for @careerNoJobs.
  ///
  /// In en, this message translates to:
  /// **'No selected jobs found.'**
  String get careerNoJobs;

  /// No description provided for @careerCompletedSubjects.
  ///
  /// In en, this message translates to:
  /// **'Completed Subjects'**
  String get careerCompletedSubjects;

  /// No description provided for @careerAcademicCompleted.
  ///
  /// In en, this message translates to:
  /// **'Academic subjects completed: {count}'**
  String careerAcademicCompleted(Object count);

  /// No description provided for @careerPhase3Completed.
  ///
  /// In en, this message translates to:
  /// **'Phase 3 nodes completed: {count}'**
  String careerPhase3Completed(Object count);

  /// No description provided for @careerFinalSkills.
  ///
  /// In en, this message translates to:
  /// **'Final Skills Summary'**
  String get careerFinalSkills;

  /// No description provided for @careerCvReady.
  ///
  /// In en, this message translates to:
  /// **'CV-Ready Text'**
  String get careerCvReady;

  /// No description provided for @jobs_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Jobs'**
  String get jobs_screen_title;

  /// No description provided for @jobs_select_title.
  ///
  /// In en, this message translates to:
  /// **'Select up to 3 target jobs'**
  String get jobs_select_title;

  /// No description provided for @jobs_select_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to select. Long press to view details. Selected: {count} / 3'**
  String jobs_select_subtitle(Object count);

  /// No description provided for @jobs_max_selection.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 3 jobs only.'**
  String get jobs_max_selection;

  /// No description provided for @jobs_select_at_least_one.
  ///
  /// In en, this message translates to:
  /// **'Select at least 1 job to continue.'**
  String get jobs_select_at_least_one;

  /// No description provided for @jobs_generate_button.
  ///
  /// In en, this message translates to:
  /// **'Generate Final Path'**
  String get jobs_generate_button;

  /// No description provided for @jobs_fit_title.
  ///
  /// In en, this message translates to:
  /// **'Why it fits you'**
  String get jobs_fit_title;

  /// No description provided for @jobs_fit_reason.
  ///
  /// In en, this message translates to:
  /// **'Fit reason: {reason}'**
  String jobs_fit_reason(Object reason);

  /// No description provided for @jobs_generation_failed.
  ///
  /// In en, this message translates to:
  /// **'Phase 3 generation failed: {error}'**
  String jobs_generation_failed(Object error);

  /// No description provided for @phase3_title.
  ///
  /// In en, this message translates to:
  /// **'Phase 3 Path'**
  String get phase3_title;

  /// No description provided for @phase3_header.
  ///
  /// In en, this message translates to:
  /// **'Final career-readiness path'**
  String get phase3_header;

  /// No description provided for @phase3_description.
  ///
  /// In en, this message translates to:
  /// **'Tap any node to open details. Long press to attempt quiz.'**
  String get phase3_description;

  /// No description provided for @phase3_empty.
  ///
  /// In en, this message translates to:
  /// **'No Phase 3 nodes found. Generate first.'**
  String get phase3_empty;

  /// No description provided for @phase3_related_jobs.
  ///
  /// In en, this message translates to:
  /// **'Related jobs: {jobs}'**
  String phase3_related_jobs(Object jobs);

  /// No description provided for @phase3_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get phase3_status_completed;

  /// No description provided for @phase3_status_unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked • Long press to attempt quiz'**
  String get phase3_status_unlocked;

  /// No description provided for @phase3_status_locked.
  ///
  /// In en, this message translates to:
  /// **'Locked until previous node is completed'**
  String get phase3_status_locked;

  /// No description provided for @phase3_open_summary.
  ///
  /// In en, this message translates to:
  /// **'Open Final Career Summary'**
  String get phase3_open_summary;

  /// No description provided for @phase3_already_completed.
  ///
  /// In en, this message translates to:
  /// **'{name} is already completed.'**
  String phase3_already_completed(Object name);

  /// No description provided for @phase3_locked_first.
  ///
  /// In en, this message translates to:
  /// **'This node is locked. Complete first: {names}'**
  String phase3_locked_first(Object names);

  /// No description provided for @phase3_quiz_failed_score.
  ///
  /// In en, this message translates to:
  /// **'Quiz score {score}%. You need 60% to complete {name}.'**
  String phase3_quiz_failed_score(Object name, Object score);

  /// No description provided for @phase3_quiz_integrity.
  ///
  /// In en, this message translates to:
  /// **'Integrity violation detected during quiz for {name}.'**
  String phase3_quiz_integrity(Object name);

  /// No description provided for @phase3_marked_completed.
  ///
  /// In en, this message translates to:
  /// **'{name} marked as completed.'**
  String phase3_marked_completed(Object name);

  /// No description provided for @phase3_attempt_limit.
  ///
  /// In en, this message translates to:
  /// **'Daily attempt limit reached for {name}. Try again tomorrow.'**
  String phase3_attempt_limit(Object name);

  /// No description provided for @college_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Path'**
  String get college_title;

  /// No description provided for @college_select_title.
  ///
  /// In en, this message translates to:
  /// **'Select a college'**
  String get college_select_title;

  /// No description provided for @college_select_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Start by choosing your general direction.'**
  String get college_select_subtitle;

  /// No description provided for @college_load_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load colleges.'**
  String get college_load_error;

  /// No description provided for @college_it_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Software, AI, Cybersecurity'**
  String get college_it_subtitle;

  /// No description provided for @college_engineering_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Civil, robotics, communications'**
  String get college_engineering_subtitle;

  /// No description provided for @college_business_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Accounting, MIS, marketing'**
  String get college_business_subtitle;

  /// No description provided for @college_science_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Math, physics, biology'**
  String get college_science_subtitle;

  /// No description provided for @college_default_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Available specializations'**
  String get college_default_subtitle;

  /// No description provided for @fitChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Your Fit • Stage 2'**
  String get fitChatTitle;

  /// No description provided for @fitChatProgress.
  ///
  /// In en, this message translates to:
  /// **'Guided AI Chat • Question {current} of {total}'**
  String fitChatProgress(Object current, Object total);

  /// No description provided for @fitChatDescription.
  ///
  /// In en, this message translates to:
  /// **'This stage helps you discover the right college direction, then the right specialty inside it.'**
  String get fitChatDescription;

  /// No description provided for @fitChatHint.
  ///
  /// In en, this message translates to:
  /// **'Type your answer...'**
  String get fitChatHint;

  /// No description provided for @fitChatFallbackError.
  ///
  /// In en, this message translates to:
  /// **'AI chat failed. A safe fallback flow is being used.'**
  String get fitChatFallbackError;

  /// No description provided for @fitChatFinalizeError.
  ///
  /// In en, this message translates to:
  /// **'Could not finalize the AI chat summary. Please try again.'**
  String get fitChatFinalizeError;

  /// No description provided for @fitChatSummaryFailed.
  ///
  /// In en, this message translates to:
  /// **'Chat summary failed: {error}'**
  String fitChatSummaryFailed(Object error);

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @fitResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Your Fit • Results'**
  String get fitResultTitle;

  /// No description provided for @fitResultMainTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Best-Match Specialties'**
  String get fitResultMainTitle;

  /// No description provided for @fitResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'These results combine your interests, guided chat answers, and soft aptitude signals. Choose one specialty to open the tree immediately.'**
  String get fitResultSubtitle;

  /// No description provided for @fitResultEmpty.
  ///
  /// In en, this message translates to:
  /// **'No valid specialties were returned after local validation. Retry the fit flow.'**
  String get fitResultEmpty;

  /// No description provided for @fitResultError.
  ///
  /// In en, this message translates to:
  /// **'Could not build specialty results. Please retry the fit flow.'**
  String get fitResultError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @chooseSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Specialty'**
  String get chooseSpecialty;

  /// No description provided for @specialtyEmptyFallback.
  ///
  /// In en, this message translates to:
  /// **'No valid specialties were found. Go back and try again.'**
  String get specialtyEmptyFallback;

  /// No description provided for @specialtyOpenError.
  ///
  /// In en, this message translates to:
  /// **'This specialty could not be opened.'**
  String get specialtyOpenError;

  /// No description provided for @college.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get college;

  /// No description provided for @openTree.
  ///
  /// In en, this message translates to:
  /// **'Open Tree'**
  String get openTree;

  /// No description provided for @id_imageQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Quiz'**
  String get id_imageQuizTitle;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pickFromGallery;

  /// No description provided for @useCamera.
  ///
  /// In en, this message translates to:
  /// **'Use Camera'**
  String get useCamera;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected yet'**
  String get noImageSelected;

  /// No description provided for @submitImage.
  ///
  /// In en, this message translates to:
  /// **'Submit Image for Grading'**
  String get submitImage;

  /// No description provided for @imageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select or capture an image before submitting.'**
  String get imageRequired;

  /// No description provided for @imagePickError.
  ///
  /// In en, this message translates to:
  /// **'Failed to select image: {error}'**
  String imagePickError(Object error);

  /// No description provided for @imageQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Quiz'**
  String get imageQuizTitle;

  /// No description provided for @quizQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current}/{total}'**
  String quizQuestionProgress(Object current, Object total);

  /// No description provided for @quizFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get quizFinish;

  /// No description provided for @quizNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get quizNext;

  /// No description provided for @quizSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get quizSubmit;

  /// No description provided for @quizWriteHint.
  ///
  /// In en, this message translates to:
  /// **'Write your answer here...'**
  String get quizWriteHint;

  /// No description provided for @imageGradingFailed.
  ///
  /// In en, this message translates to:
  /// **'Image grading failed: {error}'**
  String imageGradingFailed(Object error);

  /// No description provided for @imageTaskCompleted.
  ///
  /// In en, this message translates to:
  /// **'I completed the required image task'**
  String get imageTaskCompleted;

  /// No description provided for @imageExplainHint.
  ///
  /// In en, this message translates to:
  /// **'Explain what your image contains and why it matches the task...'**
  String get imageExplainHint;

  /// No description provided for @noQuestionsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No questions available.'**
  String get noQuestionsAvailable;

  /// No description provided for @chooseSpecializationTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Specialization'**
  String get chooseSpecializationTitle;

  /// No description provided for @specializationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Specializations'**
  String get specializationsTitle;

  /// No description provided for @collegeLabel.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get collegeLabel;

  /// No description provided for @noSpecializations.
  ///
  /// In en, this message translates to:
  /// **'No specializations were found for this college.'**
  String get noSpecializations;

  /// No description provided for @loadSpecializationsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load colleges and specializations.'**
  String get loadSpecializationsError;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @college_it.
  ///
  /// In en, this message translates to:
  /// **'IT'**
  String get college_it;

  /// No description provided for @college_engineering.
  ///
  /// In en, this message translates to:
  /// **'Engineering'**
  String get college_engineering;

  /// No description provided for @college_business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get college_business;

  /// No description provided for @college_science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get college_science;

  /// No description provided for @browseTracks.
  ///
  /// In en, this message translates to:
  /// **'Browse Tracks'**
  String get browseTracks;

  /// No description provided for @allSpecialties.
  ///
  /// In en, this message translates to:
  /// **'All Specializations'**
  String get allSpecialties;

  /// No description provided for @searchSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Search specialty...'**
  String get searchSpecialty;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @noTrackSelected.
  ///
  /// In en, this message translates to:
  /// **'No track selected yet'**
  String get noTrackSelected;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @specialtyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No specialties found. Try again.'**
  String get specialtyEmpty;

  /// No description provided for @specialtyTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Specialty'**
  String get specialtyTitle;

  String get pathHeaderHint;

  String get chooseTrack;

  String get trackSelectedSuccess;

  String alreadyCompleted(Object name);

  String completeFirstMessage(Object subjects);

  String quizScoreNeedMore(Object score);

  String get integrityViolation;

  String subjectCompleted(Object name);

  String get completePhasesFirst;

  String get learningPath;

  String get fitQuestionsTitle;

  String get fitQuestionsHeader;

  String get fitQuestionsSubtitle;

  String fitQuestionsAnswered(Object current, Object total);

  String fitQuestionsContinue(Object current, Object total);

  String get answerAllFirst;

  String fitQuestionsSaveError(Object error);

  String questionLabel(Object index);

  String get fitQuizTitle;

  String get fitQuizHeader;

  String get fitQuizSubtitle;

  String get fitQuizFinishButton;

  String get answerAllQuizFirst;

  String fitQuizSaveError(Object error);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
