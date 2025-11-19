🎓 Careerise – AI-Powered Career & Exam Recommendation App
Smart Resume Analysis • Skill Scoring • Exam Eligibility • Career Roadmaps • Personalized Growth

Careerise is an AI-powered mobile + backend platform that analyzes resumes, skills, academic details, and user preferences to generate personalized career recommendations, exam eligibility lists, internships, and real-time skill score analysis.

Built using Flutter, FastAPI, and Python ML, the project delivers an end-to-end professional career guidance system
⭐ Features
🔍 Resume Parsing

Upload resume (PDF)

Extract skills, education, academic information

Auto-fill profile builder

🧠 Skill Score Engine

Calculates a dynamic skill score based on:

Resume skills

Manually added skills

Academic field

Projects & achievements

📊 Dashboard Analytics

Profile completion

Skill score dial animation

Career match count

Skills added

Growth score

Learning streak

Certificates (future expansion)

🚀 Career Insights

Personalized role recommendations (AI-based)

Skill match percentage

Roadmaps for each career

Save / bookmark roles

📝 Exam & Opportunity Recommender

Government exams

Private company exams

Internship opportunities

Based on skills + education level

🧩 Profile Builder

Skills

Interests

Academic details

Preferences

Resume upload

Certificates (upcoming)

📱 Mobile App

Built using Flutter

Sidebar navigation

Clean UI with dark theme

Works on Android & iOS

🧱 Tech Stack
Frontend (Mobile)

Flutter

Dart

SharedPreferences

Lottie Animations

Backend

FastAPI

Python

JSON Storage / MongoDB-ready

Resume Parsing Engine (Python)

Tools

Render (backend hosting)

GitHub (version control)
📥 Installation & Setup
🔧 Backend (FastAPI)
cd backend-ml
pip install -r requirements.txt
uvicorn app.main:app --reload

📱 Flutter App
cd flutter_app
flutter pub get
flutter run

🌐 API Endpoints
🔹 Profile
Method	Endpoint	Description
GET	/profile/{user_id}	Get user profile
POST	/profile/save	Save/update profile
🔹 Resume
Method	Endpoint	Description
POST	/resume/upload/{user_id}	Upload resume (PDF)
🔹 Recommendations
Method	Endpoint	Description
GET	/careers/{user_id}	AI career recommendations
GET	/exams/{user_id}	Gov/Private/Intern exams
📸 UI Screenshots (Add Later)
/screenshots
  dashboard.png
  career_insights.png
  exams.png
  profile_builder.png

🤝 Contributing

Pull requests are welcome!
For major changes, open an issue first to discuss the proposal.

📄 License

MIT License.

❤️ Created by Aniket Shukla

If you like the project, please ⭐ star the repo!
