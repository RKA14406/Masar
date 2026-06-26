import 'general_quiz_model.dart';

class GeneralQuizService {
  static const int passPercent = 70;

  List<GeneralQuizQuestion> questionsFor(String specialization) {
    final major = specialization.trim().isEmpty ? 'your major' : specialization;
    return [
      GeneralQuizQuestion(
        section: 'Fundamentals',
        question:
            'What is the best first step when learning a new topic in $major?',
        options: [
          'Understand the core concepts and vocabulary',
          'Skip directly to advanced tools',
          'Memorize answers without context',
          'Avoid practice exercises',
        ],
        correctIndex: 0,
        feedback: 'Strong learning starts with concepts, terms, and context.',
      ),
      const GeneralQuizQuestion(
        section: 'Fundamentals',
        question: 'Which habit helps most with long-term academic progress?',
        options: [
          'Studying only before exams',
          'Consistent practice and review',
          'Ignoring weak areas',
          'Changing goals every day',
        ],
        correctIndex: 1,
        feedback: 'Consistent review and practice improve retention.',
      ),
      const GeneralQuizQuestion(
        section: 'Fundamentals',
        question: 'What should a student do after receiving low quiz feedback?',
        options: [
          'Stop studying the subject',
          'Review mistakes and practice weak topics',
          'Delete progress',
          'Move to unrelated content',
        ],
        correctIndex: 1,
        feedback: 'Feedback is useful when it guides targeted revision.',
      ),
      const GeneralQuizQuestion(
        section: 'Fundamentals',
        question:
            'Which source is usually most reliable for course requirements?',
        options: [
          'Random social posts',
          'Official syllabus or university guidance',
          'Unverified rumors',
          'A single outdated note',
        ],
        correctIndex: 1,
        feedback: 'Official material should anchor course planning.',
      ),
      GeneralQuizQuestion(
        section: 'Core Major Knowledge',
        question:
            'What does a prerequisite usually mean in a $major learning path?',
        options: [
          'A topic that should be learned before another topic',
          'A subject that can never be completed',
          'A career role',
          'A deadline bonus',
        ],
        correctIndex: 0,
        feedback: 'Prerequisites protect learning order and readiness.',
      ),
      const GeneralQuizQuestion(
        section: 'Core Major Knowledge',
        question: 'Which statement best describes applied learning?',
        options: [
          'Only reading theory',
          'Using concepts to solve realistic tasks',
          'Avoiding projects',
          'Skipping evaluation',
        ],
        correctIndex: 1,
        feedback: 'Applied learning connects theory with practical tasks.',
      ),
      const GeneralQuizQuestion(
        section: 'Core Major Knowledge',
        question: 'Why are completed subjects useful for career guidance?',
        options: [
          'They show learning evidence and skill direction',
          'They replace all interviews',
          'They guarantee certification',
          'They remove the need for projects',
        ],
        correctIndex: 0,
        feedback: 'Completed subjects provide evidence for readiness signals.',
      ),
      const GeneralQuizQuestion(
        section: 'Core Major Knowledge',
        question: 'What is the safest way to describe a skill on a student CV?',
        options: [
          'Claim expert level without proof',
          'List skills supported by coursework or projects',
          'Invent tools used',
          'Add unrelated buzzwords',
        ],
        correctIndex: 1,
        feedback: 'CV claims should be honest and evidence-backed.',
      ),
      const GeneralQuizQuestion(
        section: 'Problem Solving',
        question: 'When stuck on a problem, what should you do first?',
        options: [
          'Break it into smaller parts',
          'Guess randomly',
          'Ignore requirements',
          'Delete previous work',
        ],
        correctIndex: 0,
        feedback: 'Decomposition makes complex problems easier to solve.',
      ),
      const GeneralQuizQuestion(
        section: 'Problem Solving',
        question: 'What makes a project description stronger?',
        options: [
          'Clear goal, role, tools, and result',
          'Only a title',
          'No context',
          'Fake awards',
        ],
        correctIndex: 0,
        feedback: 'Good project evidence is specific and honest.',
      ),
      const GeneralQuizQuestion(
        section: 'Problem Solving',
        question: 'What should be tested before calling a task complete?',
        options: [
          'Only the easiest case',
          'Expected behavior and likely edge cases',
          'Nothing',
          'Unrelated screens only',
        ],
        correctIndex: 1,
        feedback: 'Verification should cover expected and risky behavior.',
      ),
      const GeneralQuizQuestion(
        section: 'Problem Solving',
        question: 'Which action improves learning from mistakes?',
        options: [
          'Write down the mistake and the corrected approach',
          'Hide the result',
          'Repeat without changes',
          'Skip the topic forever',
        ],
        correctIndex: 0,
        feedback: 'Reflection turns mistakes into learning data.',
      ),
      const GeneralQuizQuestion(
        section: 'Tools and Technologies',
        question:
            'How should tools and technologies be selected for a project?',
        options: [
          'By fit for the problem and team capability',
          'Only because they are popular',
          'Randomly',
          'To make the project harder',
        ],
        correctIndex: 0,
        feedback: 'Good tool choice follows the task and constraints.',
      ),
      const GeneralQuizQuestion(
        section: 'Tools and Technologies',
        question: 'Why is version control useful?',
        options: [
          'It tracks changes and supports collaboration',
          'It replaces learning',
          'It writes all code automatically',
          'It removes testing needs',
        ],
        correctIndex: 0,
        feedback: 'Version control protects work and collaboration history.',
      ),
      const GeneralQuizQuestion(
        section: 'Tools and Technologies',
        question:
            'What should you do before using a new tool in a serious project?',
        options: [
          'Check documentation and basic examples',
          'Use it without reading anything',
          'Ignore compatibility',
          'Delete existing work',
        ],
        correctIndex: 0,
        feedback: 'Documentation reduces avoidable setup and usage errors.',
      ),
      const GeneralQuizQuestion(
        section: 'Tools and Technologies',
        question:
            'Which item is appropriate to include in a student CV skills section?',
        options: [
          'A tool the student actually used',
          'A tool never seen before',
          'A fake certificate',
          'A company name without experience',
        ],
        correctIndex: 0,
        feedback: 'ATS-friendly CVs should list real, relevant skills.',
      ),
      const GeneralQuizQuestion(
        section: 'Career Readiness',
        question: 'What is a target role?',
        options: [
          'The type of role a student is preparing for',
          'A completed subject',
          'A random grade',
          'A university policy',
        ],
        correctIndex: 0,
        feedback: 'A target role helps focus skills, projects, and CV wording.',
      ),
      const GeneralQuizQuestion(
        section: 'Career Readiness',
        question: 'Which CV layout is best for ATS systems?',
        options: [
          'Simple one-column text with clear headings',
          'Heavy graphics and images',
          'Text hidden in pictures',
          'Unlabeled sections',
        ],
        correctIndex: 0,
        feedback: 'ATS systems read simple text layouts more reliably.',
      ),
      const GeneralQuizQuestion(
        section: 'Career Readiness',
        question: 'What should a student do if they have no work experience?',
        options: [
          'Invent a job',
          'Show projects, coursework, skills, and honest achievements',
          'Leave the CV blank',
          'Claim senior experience',
        ],
        correctIndex: 1,
        feedback:
            'Students can show readiness through honest learning evidence.',
      ),
      const GeneralQuizQuestion(
        section: 'Career Readiness',
        question: 'What is the right way to use competitions or achievements?',
        options: [
          'Include only real participation, role, or result',
          'Invent awards',
          'Copy another student',
          'Use vague claims without evidence',
        ],
        correctIndex: 0,
        feedback: 'Achievements must be accurate and evidence-based.',
      ),
    ];
  }
}
