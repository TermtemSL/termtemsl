# Thai Sign Language AI Project

A Deep Learning-based Thai Sign Language platform designed to improve communication accessibility between hearing-impaired users and the general public through AI-powered sign language recognition and interaction systems.

---

# Project Overview

This project focuses on building an intelligent Thai Sign Language ecosystem using Deep Learning, Computer Vision, and AI technologies. The platform aims to recognize Thai sign language gestures from video or camera input and translate them into understandable text and speech outputs.

The long-term vision of this project is to create a scalable and accessible communication assistant that can:
- Detect and classify Thai sign language gestures in real time
- Translate sign language into readable text
- Support speech output for verbal communication
- Provide educational resources for learning Thai sign language
- Integrate AI chatbot interaction with sign language interfaces

---

# Why This Project?

Communication barriers remain a major challenge for hearing-impaired communities, especially for Thai Sign Language where publicly available AI tools and datasets are still limited compared to other languages.

This project was chosen because:
- Thai Sign Language AI research is still relatively underdeveloped
- The problem has meaningful real-world social impact
- It combines multiple interesting AI fields:
  - Deep Learning
  - Computer Vision
  - Human-Computer Interaction
  - Natural Language Processing
  - Real-time AI systems

---

# Why Deep Learning?

Traditional approaches such as rule-based systems or handcrafted feature extraction struggle with:
- Complex hand movements
- Different lighting conditions
- Camera angles
- Dynamic gestures
- User variations

Deep Learning provides stronger capabilities for:
- Automatic feature extraction
- Spatial pattern recognition
- Temporal sequence learning
- Real-time inference
- Higher scalability for larger datasets

---

# Current Tech Stack

## Frontend
- Flutter

## Backend
- Python
- GoLang

## AI / Deep Learning
- PyTorch
- OpenCV
- NumPy
- Pandas

## Database / Infrastructure
- Supabase
- PostgreSQL

## Other Tools
- Git & GitHub
- Streamlit (Prototype/Testing)
- Selenium (Dataset Collection)

---

# Planned Features

- [ ] Thai sign language recognition from camera input
- [ ] Real-time AI translation
- [ ] Sign-to-text conversion
- [ ] Text-to-speech output
- [ ] AI chatbot integration
- [ ] Dataset management system
- [ ] Educational sign language dictionary
- [ ] User authentication and profiles
- [ ] Interactive learning modules

---

# Installation Guide

## Backend Setup

The backend is built with FastAPI. For full backend setup details, please refer to the [Backend README](./backend/README.md).

To run the backend server quickly, you can use the following commands:
```bash
cd backend
uvicorn app.main:app --reload
```

## Frontend Setup

The frontend is a Flutter application. To run and build the mobile app, you will need Android Studio.

### Prerequisites
- Install [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Install [Android Studio](https://developer.android.com/studio) (required for the Android emulator and SDK tools)
- Run `flutter doctor` in your terminal to verify that all prerequisites are met.

### Running the Application

1. **Navigate to the frontend directory:**
   ```bash
   cd termtem_signlanguage_ai
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   Ensure you have an emulator running in Android Studio or a physical device connected, then run:
   ```bash
   flutter run
   ```

---

# Team Development Guidelines

## 1. Main Branch Protection

❌ Direct commits or pushes to the `main` branch are strictly prohibited under all circumstances.

All changes must go through:
1. Feature branch
2. Pull Request
3. Code Review
4. Approval before merge

---

## 2. Branch Naming Convention

Every branch must follow this structure:

```bash
<main-category>/<sub-problem>
```

### Examples

```bash
backend/user_api
frontend/login_page
database/auth_schema
security/jwt_fix
test/model_validation
ai/training_pipeline
docs/readme_update
```

### Allowed Main Categories

- frontend
- backend
- database
- security
- test
- ai
- docs
- devops
- refactor
- fix
- feature

---

## 3. Pull Request Review Rules

Every Pull Request MUST:
- Be reviewed by at least 1 team member
- Receive approval before merging
- Include comments if issues are found

### Review Process

#### If everything is correct:

```text
Everything looks good and ready to merge.
```

#### If issues are found:

Reviewer must provide bullet-point feedback:

```text
- Found bug in authentication middleware
- API response format is inconsistent
- Missing validation for empty inputs
```

The PR creator must:
- Fix all issues
- Reply with update notes about what was fixed

Example:

```text
Fixed:
- Added input validation
- Refactored API response structure
- Fixed middleware authorization bug
```

This process repeats until approval is granted.

---

## 4. Pull Request Template

Every Pull Request MUST follow this format:

```md
## Description
Short description about the pull request


## Relates to issue
#issue_number


## Changes

### Subproblem 1
-
-
-

### Subproblem 2
-
-
-


## Screenshots


## Checklist
- [ ] Code runs successfully
- [ ] No merge conflicts
- [ ] Reviewed locally
- [ ] Documentation updated
- [ ] Naming conventions followed
- [ ] No sensitive data exposed
```

---

## 5. Commit Message Convention

Every commit message MUST follow this format:

```bash
<type>: <short description>
```

### Examples

```bash
feat: add user authentication api
fix: resolve jwt expiration bug
chore: update dependencies
refactor: simplify database queries
docs: update installation guide
test: add model unit tests
```

### Allowed Commit Types

- feat
- fix
- chore
- docs
- refactor
- test
- style
- perf
- build

---

# Coding Standards

## General Rules

- Write clean and readable code
- Prioritize maintainability over cleverness
- Avoid unnecessary complexity
- Keep functions small and focused
- Use meaningful variable and function names
- Avoid duplicated logic
- Remove unused imports and dead code
- Avoid hardcoded values whenever possible
- Use environment variables for configurations
- Prefer reusable components and functions
- Keep business logic separated from UI logic

---

## Naming Conventions

### Variables

Use `camelCase`

```ts
userProfile
signPrediction
modelOutput
```

### Functions

Use `camelCase`

```ts
predictGesture()
fetchUserData()
trainModel()
```

### Classes

Use `PascalCase`

```ts
GestureRecognizer
UserService
PredictionEngine
```

### Constants

Use `UPPER_SNAKE_CASE`

```ts
MAX_UPLOAD_SIZE
DEFAULT_TIMEOUT
MODEL_PATH
```

### File Naming

#### Frontend Components

Use `PascalCase`

```bash
Navbar.tsx
CameraPreview.tsx
```

#### Utility Files

Use `camelCase`

```bash
apiClient.ts
modelHelper.ts
```

#### Python Files

Use `snake_case`

```bash
train_model.py
dataset_loader.py
```

---

# Formatting Standards

## Indentation

- Use 2 spaces for frontend files
- Use 4 spaces for Python files
- Never mix tabs and spaces

---

## Line Length

Recommended maximum:

```text
100 characters per line
```

---

## Comments

Write comments only when necessary.

Good:

```python
# Normalize image before inference
```

Bad:

```python
# Increment i by 1
i += 1
```

---

# Frontend Standards

- Keep components small and reusable
- Separate UI components from business/data logic
- Store shared constants in dedicated files
- Avoid deeply nested component structures
- Prefer functional components over class components
- Use TypeScript types/interfaces whenever possible
- Validate all API responses before rendering

---

# Backend Standards

- Use modular architecture
- Separate routes, services, models, and utilities
- Validate request bodies before processing
- Avoid writing business logic directly inside route handlers
- Use proper HTTP status codes
- Return consistent API response structures
- Add error handling for all endpoints

---

# AI / Model Standards

- Never overwrite trained models without backup
- Store experiment results properly
- Track model accuracy and training metrics
- Keep datasets versioned when possible
- Separate training scripts from inference scripts
- Document preprocessing steps clearly
- Save hyperparameters for reproducibility

---

# API Standards

## Success Response

```json
{
  "success": true,
  "data": {},
  "message": "Request successful"
}
```

## Error Response

```json
{
  "success": false,
  "error": "Invalid input"
}
```

---

# Security Guidelines

- Never commit `.env` files
- Never expose API keys
- Use environment variables for secrets
- Validate all user inputs
- Sanitize uploaded files
- Use HTTPS in production
- Implement authentication properly
- Avoid storing sensitive data in frontend code
- Use parameterized queries for database operations
- Review dependencies regularly for vulnerabilities

---

# Testing Guidelines

- Test features locally before creating Pull Requests
- Write unit tests for important business logic
- Verify API endpoints before merging
- Check for console errors before deployment
- Ensure responsive layouts work correctly
- Avoid merging untested code

---

# Recommended .gitignore

```gitignore
node_modules/
.env
.env.local
venv/
__pycache__/
*.pt
*.pth
dist/
build/
.next/
coverage/
.DS_Store
```

---

# Future Improvements

- Real-time sign sentence recognition
- Transformer-based gesture models
- Mobile application support
- Unreal Engine sign animation generation
- AI-powered sign language tutor
- Multi-language support

---

# Contributors

- Sorasit Kateratorn
- Napatr Saengthongsakullert

---

# License

This project is intended for educational and research purposes.