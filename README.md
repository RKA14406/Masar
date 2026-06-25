# Vision Career



## Table of Contents

* [Overview](#overview)
* [How to Start](#how-to-start)
* [Why This Project Exists](#why-this-project-exists)
* [Core Idea](#core-idea)
* [Main User Flow](#main-user-flow)
* [Key Features](#key-features)
* [Tech Stack](#tech-stack)
* [Project Structure](#project-structure)
* [Current Architecture Direction](#current-architecture-direction)
* [Data Model Overview](#data-model-overview)
* [Screens and Modules](#screens-and-modules)
* [Learning Resource Strategy](#learning-resource-strategy)
* [Assessment Philosophy](#assessment-philosophy)
* [AI Quiz System](#ai-quiz-system)
* [Roadmap](#roadmap)
* [Getting Started](#getting-started)
* [Repository Goals](#repository-goals)
* [Status](#status)
* [Contribution Note](#contribution-note)




---


## overview


**AI-guided academic and career path planning for university students.**

Vision Career is a Flutter mobile application that helps students move from **uncertainty** to a **structured, guided path**.

Instead of randomly choosing courses, the app routes the user through:

- **Phase 0** — discover the right major/specialization
- **Phase 1** — complete foundation subjects
- **Phase 2** — complete specialization subjects
- **Phase 3** — become more job-ready with targeted final learning nodes

The current system is dataset-driven and uses a prerequisite graph to build the learning tree, while AI is used where it adds value: discovery, recommendation, quiz generation, assessment evaluation, learning resource support, and final career preparation.

Implementation reference available at: https://github.com/khalilAmustafa/Vision-Career

---

## How to Start

### 1. Clone the Repository

```bash
git clone https://github.com/khalilAmustafa/Vision-Career.git
cd Vision-Career
```

---

### 2. Install Dependencies

```bash
flutter pub get
```

---

### 3. Configure Required API Keys

Before running the project, you must add your API keys manually.

#### Gemini API Key

Open:

`lib/core/constants/gemini_quiz_config.dart`

Add your Gemini API key there.

Gemini is used for recommendation logic, quiz generation, text-answer evaluation, image-answer validation, and Phase 3 career-readiness generation.

---

#### Vertex / Discovery Engine / Custom Search Configuration

Open:

`lib/core/constants/vertex_search_config.dart`

Add your:

* Custom Search API / Search configuration
* Discovery Engine / Vertex AI Search configuration

These services are used to retrieve and rank learning resources for subject nodes and generated Phase 3 nodes.

---

### 4. Run the App

```bash
flutter run
```

---

### 5. Recommended Setup Notes

* Use a physical device or emulator.
* Ensure Flutter SDK is installed and configured.
* Make sure your APIs are enabled in Google Cloud / Vertex AI before testing.
* If learning resources, AI recommendations, quizzes, or Phase 3 generation fail, verify your API keys/config first.

---

## Important Security Note

Do **NOT** commit real API keys to public repositories.
Use placeholder values before pushing to GitHub if the repository is public.



## Why this project exists

Many students know they want a strong future, but they do **not** know:

- which college direction fits them best
- which specialization to choose
- what to learn first
- how subjects connect together
- how to prove they understood each learning step
- how to prepare for a real job after graduation

Vision Career turns that confusion into a **clear path**.

The app is designed to guide the student from exploration to specialization to career readiness through one connected system. The intended journey is:

**Student → Structured Learning → Assessment → Skill Development → Career Preparation → Job Readiness**

---

## Core idea

Vision Career is built around a simple product promise:

> Help the user choose the right direction, enter the correct specialization tree, follow subjects in the right order, prove progress through assessment, and finish with a stronger job-ready profile.

The app combines:

- **local structured datasets** for colleges, specializations, and subjects
- **prerequisite-based path generation** for stable learning trees
- **AI recommendation flows** for Phase 0 and Phase 3
- **multi-type quiz and integrity systems** for progress validation
- **learning resource retrieval** for subject support
- **career-readiness generation** for final practical preparation

The mobile app currently centers on a rule-based prerequisite graph and local JSON datasets, with AI layered on top for the experience that benefits from interpretation, personalization, assessment, and guidance.

---

## Main user flow

### 1. Phase 0 — discovery

Phase 0 replaces the old college/specialization entry flow with two smart entry points:

- **I Know What I Want**
- **I Don't Know Where I Fit**

Both routes end the same way: the user receives **valid specialty suggestions that already exist in the app**, selects one, and enters the specialization tree directly. The design rule is:

> **AI may suggest; the app must map and control all final logic.**

#### Flow A — I Know What I Want

The user writes a short free-text description of what they want to study, build, or become. Gemini receives that text plus the allowed specialty list and returns ranked recommendations from the supported specialties only. The app validates them locally before showing them to the user.

#### Flow B — I Don't Know Where I Fit

This is the main guided discovery flow:

1. **Preference Questions**
2. **AI Chat Follow-up**
3. **Fundamentals Quiz**
4. **Gemini analysis**
5. **Specialty recommendations**
6. **User chooses one and opens the tree**

Phase 0 is meant to feel intelligent but still deterministic: Gemini interprets and ranks, while the app validates, maps, stores, and navigates.

---

### 2. Phase 1 — foundation

Once a specialty is selected, the app loads the **college foundation subjects** required before deeper specialization work. These subjects are ordered according to prerequisite relationships so the user learns in the right sequence.

Each subject node can include learning resources, gained skills, prerequisites, quiz requirements, completion state, and unlock rules.

---

### 3. Phase 2 — specialization

After the foundation layer, the user continues through **specialization-specific subjects**. These are still represented as nodes in the same prerequisite-controlled structure, so the user progresses through a guided skill tree rather than a flat list.

Completion is not only visual. A node may require a generated quiz before it can be marked as completed and before the next nodes can unlock.

---

### 4. Phase 3 — final phase / career readiness

After completing Phase 1 and Phase 2, the user unlocks **FINAL PHASE**.

In this stage:

1. The app sends the user’s college, specialization, completed subjects, and skill context to an LLM.
2. The LLM returns a list of possible job roles.
3. The user selects up to 3 roles.
4. The LLM then returns 3–5 final learning topics.
5. The app builds those as final nodes.
6. The app fetches learning resources for each final node.
7. The app reuses the same quiz, integrity, completion, and unlock logic.

Important design rule:

> **LLM suggests → App controls execution**

Phase 3 exists to help the user move from “I finished the tree” to “I am more ready for internships, projects, and job applications.”

Generated Phase 3 nodes should be persisted after commitment and should not be casually regenerated, so the final path stays stable for the user.

---

## Key features

### AI-guided entry into the correct path

Instead of forcing the user to manually guess the right specialization first, Phase 0 helps them discover or confirm the correct direction. The app only shows specialties that exist in the local dataset.

### Dataset-driven skill trees

The real learning path is built from local structured subject data and prerequisites. This keeps the path deterministic, stable, and compatible with app-side validation.

### Prerequisite-based progression

Subjects are not just displayed — they are ordered by dependency logic so the user moves through the path in the correct academic sequence.

### Subject details + learning resources

Each node can include a description, skills gained, prerequisites, unlock requirements, completion status, and learning resources retrieved by the app.

### Multi-type quizzes before completion

A node is not just checked off visually. The system can validate learning using different quiz types:

- **MCQ quizzes** for direct concept checking
- **Text-based answers** for explanations, reasoning, and short written responses
- **Image-based answers** for visual, design, diagram, or upload-based validation

The quiz is generated from the subject context, including the subject name, description, skills, prerequisites, and phase.

### Smart quiz evaluation

Different answer types are evaluated differently:

- **MCQ** → auto-check against the correct answer
- **Text answer** → Gemini evaluates the response using the expected answer/rubric
- **Image answer** → AI/rubric validation checks whether the uploaded image matches the task requirements

This lets the system support more than simple multiple-choice tests while keeping the final decision controlled by the app.

### Integrity / anti-cheat support

The system includes quiz security ideas such as app-switching detection, focus-loss detection, screenshot protection, anti-copy behavior, abnormal session monitoring, phone detection, face detection, and session integrity flags.

The goal is not to over-collect data. The goal is to store only useful signals that affect the quiz decision and progression logic.

### Progress tracking

The user can track completed nodes, remaining work, attempts, scores, integrity status, and overall progression across the path.

### Career-readiness final phase

Phase 3 turns completed academic progress into a final practical bridge. The user selects target jobs, then the system generates final nodes that close readiness gaps before internships, portfolio work, or job applications.

---

## Tech stack

### Frontend

- **Flutter**
- **Dart**

### Local data / app-side logic

- **Local JSON dataset** for MVP
- **Rule-based prerequisite graph**
- Local persistence/services inside the mobile app architecture

### AI / service layer used in the project

- **Gemini** for Phase 0 recommendation logic, quiz generation, text evaluation, image validation, job-role suggestions, and Phase 3 node generation
- **Vertex AI Search / Discovery Engine** for learning resource retrieval and ranking support
- **App-side decision logic** for validation, mapping, persistence, unlock rules, and safe navigation

### AI / integrity direction

The broader system direction includes integrity monitoring signals such as phone detection, face detection, focus monitoring, app switching, and session integrity scoring.

### Planned / optional backend direction

The technical documentation notes a future backend direction using **Python FastAPI**, moving from MVP-style local behavior toward a fuller service architecture later.

---

## Project structure

Current project skeleton provided in the repo materials:

```text
vision_career_mobile/
|-- assets/
|   |-- data/
|   |   `-- vision_career_phase1_phase2_master_dataset_rebuilt.json
|   `-- json/
|       |-- it_subject_graph.xlsx
|       |-- vision_career_phase1_phase2_dataset.json
|       `-- vision_career_phase1_phase2_dataset.xlsx
`-- lib/
    |-- app/
    |   |-- app.dart
    |   |-- routes.dart
    |   `-- theme.dart
    |-- core/
    |   |-- constants/
    |   |-- services/
    |   `-- utils/
    |-- data/
    |   |-- datasources/
    |   |-- models/
    |   `-- repositories/
    |-- features/
    |   |-- auth/
    |   |-- career/
    |   |-- college_selection/
    |   |-- common/
    |   |-- path_view/
    |   |-- phase0/
    |   |-- profile/
    |   |-- quiz/
    |   |-- specialization_selection/
    |   `-- subject_details/
    `-- main.dart
```

### Important folders

- `lib/features/phase0/` — AI-guided entry flow
- `lib/features/path_view/` — learning tree screen
- `lib/features/subject_details/` — node details
- `lib/features/quiz/` — quiz generation, answer UI, evaluation, and completion flow
- `lib/features/career/` — Phase 3 career readiness flow
- `lib/core/services/` — app services for auth, Phase 0, Phase 3, quiz, progress, profile, security, and resource retrieval
- `lib/core/constants/` — API configuration and AI/service constants

---

## Current architecture direction

The project has evolved beyond a simple college/specialization picker.

### What is already part of the product direction

- AI-guided Phase 0 entry
- Tree-based subject progression
- Local specialty mapping and validation
- Dynamic resource support
- Multi-type quiz-based completion logic
- Integrity checks during assessment
- Career-focused Phase 3 generation
- Auth/profile foundation inside the mobile project structure

### Product principle

The project consistently follows this split:

- **AI handles interpretation, generation, evaluation support, and ranking**
- **The app handles validation, mapping, persistence, unlock decisions, and navigation**

That principle is what keeps the system impressive for demos while still safe enough to build and debug in production-minded steps.

---

## Data model overview

The mobile technical documentation describes the MVP around these core entities:

- `colleges`
- `specializations`
- `subjects`
- `prerequisites`
- `user_progress`
- `quiz_attempts`
- `quiz_results`
- `integrity_flags`
- `phase3_state`

At the path level, the app takes:

- selected college
- selected specialization

Then it:

- loads subjects
- loads prerequisites
- performs graph traversal
- outputs ordered Phase 1 and Phase 2 subjects
- generates quiz sessions when completion is requested
- stores quiz results and unlock state
- stores Phase 3 generated nodes after commitment

A simplified quiz result can contain:

```json
{
  "subject_id": "string",
  "quiz_type": "mcq | text | image",
  "score": 0,
  "passed": false,
  "attempts": 1,
  "integrity_flags": [],
  "completed_at": "timestamp"
}
```

---

## Screens and modules

Documented MVP and current project skeleton together indicate these important application areas:

### Entry and account
- Splash / onboarding
- Login / register
- Profile

### Discovery and path selection
- Phase 0 home
- “I Know What I Want”
- “I Don’t Know Where I Fit” stages
- Specialty recommendation

### Learning flow
- Path view screen
- Subject details screen
- Quiz components
- Progress logic
- Integrity/session logic

### Final career flow
- Career selection / summary
- Job selection
- Phase 3 generated path screen
- Final readiness quiz flow

---

## Learning resource strategy

Phase 3 documentation states that learning resources reuse the existing retrieval system with these rules:

- maximum 4 resources
- maximum 2 Coursera resources
- priority order: **Coursera → Udemy → YouTube**

This keeps the AI focused on recommending **what** the user should learn, while the app stays responsible for fetching suitable resources.

The same strategy can be reused for normal subject nodes and generated Phase 3 nodes.

---

## Assessment philosophy

Vision Career is not meant to be only a path visualizer. It is meant to verify progress.

The assessment flow is:

> **Node → Quiz → Evaluation → Integrity Check → Completion → Unlock**

This means:

- the user studies a node
- the app generates or loads the right quiz type
- the user answers through MCQ, text, or image submission
- the system evaluates the answer
- integrity flags are checked
- the node completes only when the result is valid
- the next nodes unlock only after prerequisites are satisfied

This makes the path feel more like guided progression and less like a static checklist.

---

## AI Quiz System

The quiz system is one of the most important parts of Vision Career because it connects learning with real progression.

### Quiz types

The system supports three main quiz modes:

- **MCQ** — best for direct concepts, definitions, comparisons, and quick checking
- **Text-based answer** — best for explanations, reasoning, short analysis, code explanation, or written understanding
- **Image-based answer** — best for diagrams, visual tasks, design outputs, handwritten work, or uploaded proof

### Smart generation

Quizzes are generated using the node context, not random questions.

The quiz prompt can include:

- subject name
- subject description
- phase
- gained skills
- prerequisites
- difficulty level
- expected learning outcome

This helps the generated quiz match the exact node and keeps the assessment connected to the learning path.

### Evaluation logic

The evaluation logic depends on the answer type:

- **MCQ** answers are checked automatically using the correct option index.
- **Text answers** are evaluated by Gemini using the expected answer, rubric, and subject context.
- **Image answers** are validated by AI/rubric rules against the required task or expected visual result.

### Integrity check

Before a passing quiz result is accepted, the app checks integrity signals such as:

- app switching
- focus loss
- screenshot/copy attempts
- abnormal session behavior
- phone detection signals
- face detection signals, if enabled

If the score is passing but integrity flags are too high, the node should not complete automatically.

### Unlock decision

The final unlock decision should stay inside the app:

```text
IF quiz_result.passed == true
AND integrity_flags <= allowed_threshold
AND prerequisites_are_valid == true
THEN complete node and unlock next valid nodes
ELSE require retry or show failure reason
```

This keeps AI helpful, while the app remains responsible for the real product state.

---

## Roadmap

Based on the uploaded documentation, the broader roadmap includes:

### Near-term / implemented direction
- AI-guided Phase 0
- Phase 1 + Phase 2 learning trees
- subject details and progress tracking
- multi-type quiz generation and validation flows
- integrity-aware assessment decisions
- learning resource integration
- Phase 3 job-readiness generation

### Later evolution
- stronger backend/API support
- richer user accounts and persistence
- broader college coverage
- stronger integrity monitoring
- more advanced AI assistance inside the app
- improved path generation using trained models / graph-based recommendation

---

## Getting started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- A connected emulator or physical device

### Run locally

```bash
flutter pub get
flutter run
```

### Build release APK

```bash
flutter build apk
```

If your local setup uses API keys or service configs for Gemini or Vertex, keep them out of the public repo and move them to secure configuration before publishing.

---

## Repository goals

This repo is a strong fit for anyone interested in:

- Flutter product development
- AI-assisted UX flows
- academic planning systems
- guided learning-tree products
- quiz and assessment design
- AI-supported answer evaluation
- integrity-aware learning systems
- career-readiness tooling for students

---

## Status

Vision Career is an evolving product prototype / student-built system with a clear architecture direction:

- **Phase 0** for intelligent entry
- **Phase 1 + Phase 2** for structured academic progression
- **AI Quiz System** for learning validation
- **Integrity checks** for fair assessment
- **Phase 3** for job readiness

The project is designed to grow from a local-data MVP into a more complete AI-powered education and career platform over time.

---

## Contribution note

This repository reflects an actively evolving academic/product build. If you fork or extend it, keep the core system rule intact:

> **AI suggests, generates, and evaluates supportively. The app validates and decides.**

That rule is the backbone of the whole project.
