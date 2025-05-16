# GymGenius - Your AI-Powered Fitness Coach

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**GymGenius is a mobile application designed to be your personal AI fitness coach, crafting personalized workout routines tailored to your goals, experience, and available equipment.**

Say goodbye to generic workout plans! GymGenius understands your unique fitness profile and guides you through structured, effective training sessions, helping you achieve your fitness aspirations.

## ✨ Features

*   **Personalized AI-Generated Routines:** Complete a simple onboarding process detailing your fitness goals (build muscle, lose fat, increase strength, etc.), experience level, gender, physical stats, preferred workout frequency, available days, session duration, and equipment. Our AI then generates a tailored weekly workout plan just for you.
*   **Structured Weekly Schedules:** Follow a clear, day-by-day workout schedule with specific exercises, sets, reps, and rest times.
*   **Dynamic Routine Expiration & Regeneration:** Routines have a set duration (e.g., 4-8 weeks). Upon expiration, GymGenius prompts you to generate a new routine, taking into account your previous plan and (in future versions) your logged performance for intelligent progression.
*   **Detailed Exercise Logging:**
    *   Log reps and weight for each set of strength-based exercises.
    *   Track duration for timed exercises with an integrated stopwatch.
    *   Automatic rest timers between sets with sound notifications.
*   **Workout Session Management:** Start, manage, and end your workout sessions seamlessly.
*   **Workout History Tracking (Calendar View):** Visualize your completed and planned workouts on an intuitive calendar. Tap on a day to see logged workout details.
*   **Profile Management:** View and update your onboarding preferences at any time to ensure your AI coach always has the most up-to-date information.
*   **User Authentication:** Secure account creation and login using Firebase Authentication.
*   **Dark Theme UI:** A sleek, modern dark theme designed for a great user experience.

## 🚀 Getting Started

### Prerequisites

*   Flutter SDK (ensure it's installed and in your PATH)
*   An IDE (like VS Code or Android Studio) with Flutter plugins.
*   Firebase Account & Project:
    *   Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/).
    *   Enable **Authentication** (Email/Password).
    *   Enable **Firestore Database**.
    *   Enable **Cloud Functions for Firebase**.
    *   Obtain a **Google Generative AI (Gemini) API Key** from [Google AI Studio](https://aistudio.google.com/app/apikey) (or the relevant Google Cloud Console page).

### Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/nareph/gymgenius.git 
    cd gymgenius
    ```

2.  **Set up Firebase for Flutter (FlutterFire):**
    *   Install the Firebase CLI: `npm install -g firebase-tools` (or use standalone binary).
    *   Log in to Firebase: `firebase login`.
    *   Install FlutterFire CLI: `dart pub global activate flutterfire_cli`.
    *   Configure your Flutter app with your Firebase project:
        ```bash
        flutterfire configure
        ```
        This will generate `lib/firebase_options.dart`.

3.  **Set up Cloud Functions:**
    *   Navigate to the `functions` directory: `cd functions`
    *   Install dependencies: `npm install`
    *   Set your Gemini API Key as a Firebase Functions secret (replace `YOUR_GEMINI_API_KEY`):
        ```bash
        firebase functions:secrets:set GEMINI_API_KEY
        # When prompted, enter your API key
        ```
        Alternatively, for local emulator testing, create a `functions/.env` file with:
        ```
        GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE
        ```
    *   Deploy your functions:
        ```bash
        firebase deploy --only functions
        ```
        (Or use `firebase emulators:start` for local testing).

4.  **Install Flutter app dependencies:**
    *   Navigate back to the root project directory: `cd ..`
    *   Run: `flutter pub get`

5.  **Run the app:**
    *   Connect a device or start an emulator/simulator.
    *   Run: `flutter run`

    **Note on Emulators:** If using Firebase Emulators, ensure the `_useEmulators` flag in `lib/main.dart` is `true` (default for debug mode) and that `_configureFirebaseEmulators()` points to the correct host IP/ports.

## 🛠️ Tech Stack

*   **Frontend:** Flutter (Dart)
*   **Backend:** Firebase
    *   **Authentication:** Firebase Authentication (Email/Password)
    *   **Database:** Cloud Firestore
    *   **Serverless Functions:** Cloud Functions for Firebase (TypeScript)
*   **AI:** Google Generative AI (Gemini API)
*   **State Management:** Provider, Flutter BLoC (for onboarding)
*   **UI:** Material Design 3, `table_calendar` for tracking.

## 📖 How It Works

1.  **Onboarding:** New users complete a brief onboarding questionnaire to provide their fitness goals, experience, preferences, and available equipment.
2.  **AI Routine Generation:** This data is sent to a Cloud Function, which then queries the Gemini AI model to generate a personalized weekly workout routine.
3.  **Routine Display:** The generated routine is stored in Firestore and displayed to the user in the `HomeTabScreen`, broken down by day.
4.  **Workout Sessions:** Users can start a workout for a specific day. The `ActiveWorkoutSessionScreen` guides them through each exercise, allowing them to log sets/reps or track time. `WorkoutSessionManager` (Provider) manages the active session state.
5.  **Logging:** Completed workout sessions are saved as logs in Firestore.
6.  **Tracking:** The `TrackingTabScreen` displays a calendar densité with planned and completed workouts. Users can view details of past logged sessions.
7.  **Progression:** When a routine expires, users can generate a new one. The AI considers the previous routine and (with future enhancements using workout logs) the user's performance to suggest a progressively challenging new plan.

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute, please follow these steps:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/your-feature-name`).
3.  Make your changes.
4.  Commit your changes (`git commit -m 'Add some feature'`).
5.  Push to the branch (`git push origin feature/your-feature-name`).
6.  Open a Pull Request.

Please make sure to update tests as appropriate and follow the existing code style.

## 🛣️ Future Enhancements (Roadmap Ideas)

*   **Advanced Performance Analysis:** Deeper analysis of workout logs to provide more granular feedback to the AI for routine progression (e.g., 1RM estimation, fatigue tracking).
*   **Exercise Swapping:** Allow users to request an AI-suggested alternative for a specific exercise in their current routine.
*   **Visual Exercise Guidance:** Integrate images or GIFs for each exercise.
*   **Nutrition Tracking/Suggestions:** Expand to include basic nutrition guidance.
*   **Social Features:** Optional sharing of progress or routines.
*   **Light Theme & Theming Options.**
*   **Enhanced Analytics & Charts** in the Tracking Tab.
*   **Email Verification and Password Reset Improvements.**
*   **Localization (i18n).**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details (you'll need to create this file if you choose MIT).

---

Made with ❤️ by Nareph 