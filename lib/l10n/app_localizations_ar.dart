// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get home => 'الرئيسية';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get fillFields => 'يرجى تعبئة جميع الحقول';

  @override
  String loginFailed(Object error) {
    return 'فشل تسجيل الدخول: $error';
  }

  @override
  String get username => 'اسم المستخدم';

  @override
  String get age => 'العمر';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get invalidAge => 'أدخل عمرًا صحيحًا';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح';

  @override
  String registerFailed(Object error) {
    return 'فشل التسجيل: $error';
  }

  @override
  String get joinMasar => 'انضم إلى مسار';

  @override
  String get loginSubtitle => 'سجل الدخول للمتابعة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get or => 'أو';

  @override
  String get appName => 'مسار';

  @override
  String get whatDoYouWantToBecome => 'ماذا تريد أن تصبح؟';

  @override
  String get weGuideYou => 'سنرشدك خطوة بخطوة';

  @override
  String get iWantToBe => 'أريد أن أصبح...';

  @override
  String get startWithAI => 'ابدأ بالذكاء الاصطناعي';

  @override
  String get notSureYet => 'لست متأكدًا بعد؟';

  @override
  String get quickQuiz => 'اختبار سريع';

  @override
  String get quizDescription => 'أجب على بعض الأسئلة وسنرشدك للمسار المناسب';

  @override
  String get iKnowWhatIWant => 'أعرف ما أريد';

  @override
  String get describeYourGoal => 'صف هدفك، وسأساعدك في تحسينه...';

  @override
  String get youCanEdit => 'يمكنك تعديل فكرتك قبل المتابعة';

  @override
  String get getSuggestions => 'عرض التخصصات';

  @override
  String get emptyDescriptionError => 'اكتب وصفًا قصيرًا أولاً';

  @override
  String get genericError => 'حدث خطأ، حاول مرة أخرى';

  @override
  String get suggestedSpecialties => 'التخصصات المقترحة';

  @override
  String get choosePathSubtitle => 'اختر مسارًا لفتح شجرة التعلم';

  @override
  String get aiInputHint => 'اخبرني ماذا تريد أن تصبح، وسأرشدك...';

  @override
  String get career_phase3_title => 'المرحلة النهائية';

  @override
  String get career_phase3_header => 'المرحلة النهائية';

  @override
  String career_phase3_description(Object college, Object specialization) {
    return 'لقد أكملت المسار الأكاديمي لتخصص $specialization في $college. في هذه المرحلة، سيتم تحويل ما تعلمته إلى مسار مصغر للاستعداد المهني.';
  }

  @override
  String get career_phase3_what_next => 'ماذا سيحدث بعد ذلك؟';

  @override
  String get career_phase3_step1 => '1. يقترح الذكاء الاصطناعي وظائف مناسبة لك.';

  @override
  String get career_phase3_step2 => '2. تختار حتى 3 وظائف.';

  @override
  String get career_phase3_step3 => '3. ينشئ التطبيق من 3 إلى 5 عقد للتأهيل المهني.';

  @override
  String get career_phase3_step4 => '4. كل عقدة تستخدم نفس نظام الاختبارات والموارد.';

  @override
  String get career_phase3_step5 => '5. يتم تثبيت المسار ولا يمكن تغييره بعد إنشائه.';

  @override
  String get career_phase3_button => 'ابدأ المرحلة النهائية';

  @override
  String career_error_loading_jobs(Object error) {
    return 'تعذر تحميل اقتراحات الوظائف: $error';
  }

  @override
  String get careerSummaryTitle => 'ملخص المسار المهني';

  @override
  String get careerSelectedJobs => 'الوظائف المختارة';

  @override
  String get careerNoJobs => 'لم يتم اختيار أي وظائف';

  @override
  String get careerCompletedSubjects => 'المواد المكتملة';

  @override
  String careerAcademicCompleted(Object count) {
    return 'عدد المواد الأكاديمية المكتملة: $count';
  }

  @override
  String careerPhase3Completed(Object count) {
    return 'عدد عقد المرحلة الثالثة المكتملة: $count';
  }

  @override
  String get careerFinalSkills => 'ملخص المهارات النهائية';

  @override
  String get careerCvReady => 'نص جاهز للسيرة الذاتية';

  @override
  String get jobs_screen_title => 'اختر الوظائف';

  @override
  String get jobs_select_title => 'اختر حتى 3 وظائف مستهدفة';

  @override
  String jobs_select_subtitle(Object count) {
    return 'اضغط للاختيار، واضغط مطولاً لعرض التفاصيل. المختار: $count / 3';
  }

  @override
  String get jobs_max_selection => 'يمكنك اختيار 3 وظائف فقط';

  @override
  String get jobs_select_at_least_one => 'اختر وظيفة واحدة على الأقل للمتابعة';

  @override
  String get jobs_generate_button => 'إنشاء المسار النهائي';

  @override
  String get jobs_fit_title => 'لماذا يناسبك';

  @override
  String jobs_fit_reason(Object reason) {
    return 'سبب التوافق: $reason';
  }

  @override
  String jobs_generation_failed(Object error) {
    return 'فشل إنشاء المرحلة الثالثة: $error';
  }

  @override
  String get phase3_title => 'مسار المرحلة الثالثة';

  @override
  String get phase3_header => 'مسار الاستعداد المهني النهائي';

  @override
  String get phase3_description => 'اضغط على أي عقدة لعرض التفاصيل. اضغط مطولًا لمحاولة الاختبار.';

  @override
  String get phase3_empty => 'لا توجد عقد للمرحلة الثالثة. قم بإنشائها أولاً.';

  @override
  String phase3_related_jobs(Object jobs) {
    return 'وظائف مرتبطة: $jobs';
  }

  @override
  String get phase3_status_completed => 'مكتمل';

  @override
  String get phase3_status_unlocked => 'متاح • اضغط مطولًا للمحاولة';

  @override
  String get phase3_status_locked => 'مغلق حتى يتم إكمال العقد السابقة';

  @override
  String get phase3_open_summary => 'عرض الملخص النهائي';

  @override
  String phase3_already_completed(Object name) {
    return '$name مكتمل بالفعل';
  }

  @override
  String phase3_locked_first(Object names) {
    return 'هذه العقدة مغلقة. أكمل أولاً: $names';
  }

  @override
  String phase3_quiz_failed_score(Object name, Object score) {
    return 'نتيجة الاختبار $score%. تحتاج إلى 60% لإكمال $name.';
  }

  @override
  String phase3_quiz_integrity(Object name) {
    return 'تم اكتشاف خرق للنزاهة أثناء اختبار $name.';
  }

  @override
  String phase3_marked_completed(Object name) {
    return 'تم إكمال $name';
  }

  @override
  String phase3_attempt_limit(Object name) {
    return 'تم الوصول للحد اليومي لمحاولات $name. حاول غدًا.';
  }

  @override
  String get college_title => 'اختر مسارك';

  @override
  String get college_select_title => 'اختر الكلية';

  @override
  String get college_select_subtitle => 'ابدأ باختيار الاتجاه العام لك.';

  @override
  String get college_load_error => 'تعذر تحميل الكليات.';

  @override
  String get college_it_subtitle => 'البرمجيات، الذكاء الاصطناعي، الأمن السيبراني';

  @override
  String get college_engineering_subtitle => 'الهندسة المدنية، الروبوتات، الاتصالات';

  @override
  String get college_business_subtitle => 'المحاسبة، نظم المعلومات، التسويق';

  @override
  String get college_science_subtitle => 'الرياضيات، الفيزياء، الأحياء';

  @override
  String get college_default_subtitle => 'تخصصات متاحة';

  @override
  String get fitChatTitle => 'اكتشف مسارك • المرحلة 2';

  @override
  String fitChatProgress(Object current, Object total) {
    return 'الدردشة الموجهة • السؤال $current من $total';
  }

  @override
  String get fitChatDescription => 'تساعدك هذه المرحلة على اكتشاف التخصص المناسب ثم المسار داخل الكلية.';

  @override
  String get fitChatHint => 'اكتب إجابتك...';

  @override
  String get fitChatFallbackError => 'فشل الذكاء الاصطناعي. تم استخدام مسار بديل.';

  @override
  String get fitChatFinalizeError => 'تعذر إنهاء ملخص الدردشة. حاول مرة أخرى.';

  @override
  String fitChatSummaryFailed(Object error) {
    return 'فشل إنشاء الملخص: $error';
  }

  @override
  String get finish => 'إنهاء';

  @override
  String get next => 'التالي';

  @override
  String get fitResultTitle => 'اكتشف مسارك • النتائج';

  @override
  String get fitResultMainTitle => 'أفضل التخصصات المناسبة لك';

  @override
  String get fitResultSubtitle => 'تم تحديد هذه النتائج بناءً على اهتماماتك، إجاباتك في المحادثة، وقدراتك العامة. اختر تخصصًا لعرض المسار مباشرة.';

  @override
  String get fitResultEmpty => 'لم يتم العثور على تخصصات مناسبة بعد التحقق. حاول إعادة الاختبار.';

  @override
  String get fitResultError => 'حدث خطأ أثناء إنشاء النتائج. يرجى إعادة المحاولة.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get chooseSpecialty => 'اختر تخصصك';

  @override
  String get specialtyEmptyFallback => 'لم يتم العثور على تخصصات مناسبة. حاول العودة وإعادة المحاولة.';

  @override
  String get specialtyOpenError => 'لا يمكن فتح هذا التخصص.';

  @override
  String get college => 'الكلية';

  @override
  String get openTree => 'فتح المسار';

  @override
  String get id_imageQuizTitle => 'Image Quiz';

  @override
  String get pickFromGallery => 'اختيار من المعرض';

  @override
  String get useCamera => 'استخدام الكاميرا';

  @override
  String get noImageSelected => 'لم يتم اختيار صورة بعد';

  @override
  String get submitImage => 'إرسال الصورة للتقييم';

  @override
  String get imageRequired => 'يرجى اختيار أو التقاط صورة قبل الإرسال.';

  @override
  String imagePickError(Object error) {
    return 'فشل في اختيار الصورة: $error';
  }

  @override
  String get imageQuizTitle => 'اختبار الصورة';

  @override
  String quizQuestionProgress(Object current, Object total) {
    return 'السؤال $current/$total';
  }

  @override
  String get quizFinish => 'إنهاء';

  @override
  String get quizNext => 'التالي';

  @override
  String get quizSubmit => 'إرسال';

  @override
  String get quizWriteHint => 'اكتب إجابتك هنا...';

  @override
  String imageGradingFailed(Object error) {
    return 'فشل تقييم الصورة: $error';
  }

  @override
  String get imageTaskCompleted => 'لقد أكملت مهمة الصورة المطلوبة';

  @override
  String get imageExplainHint => 'اشرح ماذا تحتوي صورتك ولماذا تتوافق مع المهمة...';

  @override
  String get noQuestionsAvailable => 'لا توجد أسئلة متاحة';

  @override
  String get chooseSpecializationTitle => 'اختر التخصص';

  @override
  String get specializationsTitle => 'التخصصات';

  @override
  String get collegeLabel => 'الكلية';

  @override
  String get noSpecializations => 'لم يتم العثور على تخصصات لهذه الكلية';

  @override
  String get loadSpecializationsError => 'تعذر تحميل الكليات والتخصصات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get theme => 'المظهر';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get college_it => 'تقنية المعلومات';

  @override
  String get college_engineering => 'الهندسة';

  @override
  String get college_business => 'الأعمال';

  @override
  String get college_science => 'العلوم';

  @override
  String get browseTracks => 'تصفح التخصصات';

  @override
  String get allSpecialties => 'جميع التخصصات';

  @override
  String get searchSpecialty => 'ابحث عن تخصص...';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get continueLearning => 'متابعة التعلم';

  @override
  String get progress => 'التقدم';

  @override
  String get noTrackSelected => 'لم يتم اختيار مسار بعد';

  @override
  String get accountStatus => 'حالة الحساب';

  @override
  String get active => 'نشط';

  @override
  String get progressLabel => 'التقدم';

  @override
  String get yourProgress => 'تقدمك';

  @override
  String get specialtyEmpty => 'لم يتم العثور على تخصصات. حاول مرة أخرى.';

  @override
  String get specialtyTitle => 'اختر تخصصك';

  @override
  String get pathHeaderHint => 'اضغط على عقدة لفحصها. اضغط مطولاً لمحاولة إتمام الاختبار. اسحب لاستكشاف الشجرة.';

  @override
  String get chooseTrack => 'اختيار المسار';

  @override
  String get trackSelectedSuccess => 'تم اختيار المسار بنجاح';

  @override
  String alreadyCompleted(Object name) => '$name مكتمل بالفعل.';

  @override
  String completeFirstMessage(Object subjects) => 'أكمل هذه أولاً: $subjects';

  @override
  String quizScoreNeedMore(Object score) => 'النتيجة $score٪. المطلوب 60٪.';

  @override
  String get integrityViolation => 'انتهاك سلامة الاختبار.';

  @override
  String subjectCompleted(Object name) => 'تم إكمال $name.';

  @override
  String get completePhasesFirst => 'أكمل جميع المراحل 1 و 2 أولاً.';

  @override
  String get learningPath => 'مسار التعلم';

  @override
  String get fitQuestionsTitle => 'اكتشف مسارك • المرحلة 1';

  @override
  String get fitQuestionsHeader => 'أسئلة التفضيلات';

  @override
  String get fitQuestionsSubtitle => 'أجب على أسئلة السيناريوهات بصدق. تهدف هذه المرحلة إلى فهم اتجاهك الطبيعي قبل محادثة الذكاء الاصطناعي واختبار الأساسيات.';

  @override
  String fitQuestionsAnswered(Object current, Object total) => '$current/$total تم الإجابة عليها';

  @override
  String fitQuestionsContinue(Object current, Object total) => 'المتابعة إلى محادثة الذكاء الاصطناعي ($current/$total)';

  @override
  String get answerAllFirst => 'أجب على جميع الأسئلة أولاً.';

  @override
  String fitQuestionsSaveError(Object error) => 'تعذر حفظ إجاباتك: $error';

  @override
  String questionLabel(Object index) => 'السؤال $index';

  @override
  String get fitQuizTitle => 'اكتشف مسارك • المرحلة 3';

  @override
  String get fitQuizHeader => 'اختبار الاستعداد الأكاديمي';

  @override
  String get fitQuizSubtitle => 'يركز هذا الاختبار على إشارات المالية والرياضيات والفيزياء والكيمياء لتقوية ملفك الشخصي.';

  @override
  String get fitQuizFinishButton => 'اعرض اقتراحات تخصصي';

  @override
  String get answerAllQuizFirst => 'أجب على جميع أسئلة الاختبار أولاً.';

  @override
  String fitQuizSaveError(Object error) => 'تعذر حفظ نتائج الاختبار: $error';
}
