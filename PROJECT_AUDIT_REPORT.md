# Prompta AI Assistant - Project Audit Report

**Date:** 2026-03-28
**Scope:** Security, Performance, Architecture

---

## 1. Architecture Overview

### Tech Stack

| Layer | Technology |
|-------|-----------|
| Client | Flutter (Dart SDK 3.9.2+) |
| State Management | BLoC (flutter_bloc ^9.1.1) |
| Backend | Express.js (TypeScript) |
| Auth | Firebase Auth (email/password) |
| Database | Cloud Firestore |
| AI Provider | OpenRouter API (GPT-4o-mini) |
| Hosting | Render (server), Firebase Hosting (web) |

### Architecture Pattern

The client follows **Clean Architecture** with strict layer separation:

```
Features/
  auth/
    blocs/          -> BLoC state management
    sign_in/        -> Sign-in UI
    sign_up/        -> Sign-up UI
    utils/          -> Shared auth widgets
  chat/
    data/           -> Datasources, Repositories (implementation)
    domain/         -> Entities, UseCases, Repository interfaces
    presentation/   -> BLoCs, Pages, Widgets
```

**Shared packages:**
- `packages/user_repository/` - Firebase Auth wrapper with Firestore user storage

### Data Flow

```
Flutter UI -> BLoC Event -> UseCase -> Repository -> Remote Datasource
                                                          |
                                                    Express Server
                                                          |
                                                    OpenRouter API
                                                          |
                                                  Streaming SSE Response
```

### Navigation

State-based conditional routing via `AuthenticationBloc`:
- **Authenticated** -> OnboardingPage -> ChatPage
- **Unauthenticated** -> SignInScreen (with SignUpScreen option)

### Architecture Score: 7/10

**Strengths:**
- Clean Architecture with proper layer separation
- BLoC pattern well-implemented for auth flow
- Repository pattern with abstract interfaces
- Streaming SSE for real-time chat responses

**Weaknesses:**
- No dependency injection framework (manual BLoC creation)
- No routing package (hardcoded navigation)
- Missing Firestore security rules in repo
- No testing infrastructure

---

## 2. Security Audit

### CRITICAL Issues

#### 2.1 Hardcoded Firebase API Keys
- **File:** `client/lib/firebase_options.dart`
- **Issue:** Web, Android, and iOS API keys are hardcoded as constants
- **Risk:** Keys exposed in version control; can be used for unauthorized Firebase access
- **Fix:** While Firebase client keys are semi-public by design, implement strict Firestore Security Rules to restrict what these keys can do

#### 2.2 Google Services JSON in Version Control
- **File:** `client/android/app/google-services.json`
- **Issue:** Contains Firebase API key for Android
- **Fix:** Add to `.gitignore`, distribute via secure channels

#### 2.3 API Key Logged in Test File
- **File:** `server/test.js` (line 2)
- **Code:** `console.log('Key evaluated:', process.env.OPENROUTER_API_KEY)`
- **Fix:** Remove immediately - never log secrets

#### 2.4 Git History Contains .env Files
- **Evidence:** Commits `603f081` and `eb29d87` show .env was added and removed
- **Risk:** Secrets remain in git history even after removal
- **Fix:** Use `git filter-repo` or BFG Repo-Cleaner to scrub history; regenerate all keys

### HIGH Priority Issues

#### 2.5 No Firestore Security Rules
- **Risk:** Default rules may allow unauthorized read/write to all collections
- **Fix:** Add `firestore.rules`:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /Prompta-Users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

#### 2.6 No Server-Side Input Validation
- **File:** `server/src/routes/chat.ts`
- **Issue:** `req.body.messages` is forwarded to OpenRouter without validation
- **Risk:** Prompt injection, malformed payloads, oversized requests
- **Fix:** Validate message structure, limit content length, sanitize input

#### 2.7 Weak Email Validation
- **File:** `client/lib/features/auth/utils/textfield.dart`
- **Current:** Only checks for `@` symbol
- **Fix:** Use proper email regex: `^[^\s@]+@[^\s@]+\.[^\s@]+$`

#### 2.8 Error Details Exposed to Client
- **File:** `server/src/routes/chat.ts:12`
- **Code:** `res.status(500).json({ error })`
- **Fix:** Return generic error messages to clients

### MEDIUM Priority Issues

#### 2.9 No Rate Limiting on Server
- **Risk:** API abuse, cost overrun on OpenRouter
- **Fix:** Implement `express-rate-limit` per user/IP

#### 2.10 CORS Origins Hardcoded
- **File:** `server/src/index.ts`
- **Fix:** Use environment variables for CORS configuration

#### 2.11 device_preview in Production Dependencies
- **File:** `client/pubspec.yaml`
- **Fix:** Move to `dev_dependencies`

#### 2.12 No Authentication on Chat API
- **Issue:** Server chat endpoints have no auth middleware
- **Risk:** Anyone with the URL can use the API
- **Fix:** Add Firebase ID token verification middleware

### Security Score: 4/10

---

## 3. Performance Audit

### CRITICAL Issues

#### 3.1 Message List Copied on Every Stream Chunk
- **File:** `client/lib/features/chat/presentation/blocs/chat_bloc/chat_bloc.dart` (lines 41-48)
- **Code:** `List<Message>.from(state.messages)` called on every SSE chunk (10-100+ times/sec)
- **Impact:** Massive GC pressure, UI jank, battery drain
- **Fix:** Use mutable list or buffer emissions with throttling

#### 3.2 PostFrameCallback Called Every BLoC Rebuild
- **File:** `client/lib/features/chat/presentation/pages/chat_page.dart` (lines 52-53)
- **Issue:** `addPostFrameCallback` added inside `BlocBuilder`, accumulates on every rebuild
- **Fix:** Use `BlocListener` for scroll-to-bottom logic

### HIGH Priority Issues

#### 3.3 Missing const Constructors
- **File:** `client/lib/features/chat/presentation/widgets/message_bubble.dart`
- **Impact:** Unnecessary widget rebuilds on parent state changes
- **Fix:** Add `const` constructor to `MessageBubble` and other leaf widgets

#### 3.4 No HTTP Timeout on Client
- **File:** `client/lib/features/chat/data/datasources/chat_remote_datasource.dart`
- **Impact:** Indefinite hangs on slow/dead networks
- **Fix:** Add `timeout` parameter to HTTP requests (30s recommended)

#### 3.5 Large Inline Widget Trees
- **Files:** `chat_page.dart` (sidebar: 170+ lines inline), `sign_in_screen.dart` (460+ lines)
- **Fix:** Extract to separate `StatelessWidget` classes

### MEDIUM Priority Issues

#### 3.6 BLoC Recreation on Navigation
- **File:** `client/lib/features/chat/presentation/pages/onboarding_page.dart` (lines 99-106)
- **Issue:** New BLoC instances created inside `Navigator.push`
- **Fix:** Provide BLoCs at app level or use dependency injection

#### 3.7 Animations Not Cached
- Lottie and SVG assets decoded repeatedly on each widget build
- **Fix:** Use `LottieBuilder` with caching, or `SvgPicture.asset` with `cacheColorFilter`

#### 3.8 No Server Compression
- **File:** `server/src/index.ts`
- **Fix:** Add `compression` middleware for response gzip

#### 3.9 No Connection Pooling (Server)
- **File:** `server/src/services/openrouter.ts`
- **Issue:** New Axios instance per request
- **Fix:** Create persistent Axios instance with Keep-Alive

#### 3.10 Firestore Full Document Writes
- **File:** `client/packages/user_repository/lib/src/firebase_user_repo.dart` (line 42-43)
- **Issue:** `setUserData` does full document write, no merge
- **Fix:** Use `SetOptions(merge: true)`

### Performance Score: 5/10

---

## 4. Summary & Priority Action Items

### Immediate Actions (Do Now)

| # | Action | Category |
|---|--------|----------|
| 1 | Remove `console.log` of API key from `server/test.js` | Security |
| 2 | Scrub git history of committed `.env` files | Security |
| 3 | Add Firestore security rules | Security |
| 4 | Add auth middleware to server chat endpoints | Security |
| 5 | Fix message list copying in `ChatBloc` | Performance |
| 6 | Fix `addPostFrameCallback` in `ChatPage` | Performance |

### Short-Term (This Sprint)

| # | Action | Category |
|---|--------|----------|
| 7 | Add server-side input validation | Security |
| 8 | Add rate limiting to Express server | Security |
| 9 | Add HTTP timeout to Flutter client | Performance |
| 10 | Add `const` constructors to leaf widgets | Performance |
| 11 | Extract large widget trees to separate classes | Architecture |
| 12 | Move `device_preview` to dev_dependencies | Both |

### Medium-Term (Next Sprint)

| # | Action | Category |
|---|--------|----------|
| 13 | Implement dependency injection (get_it/injectable) | Architecture |
| 14 | Add proper routing (go_router) | Architecture |
| 15 | Add unit & widget tests | Architecture |
| 16 | Implement server-side logging & monitoring | Performance |
| 17 | Add response compression to server | Performance |
| 18 | Configure release build optimization flags | Performance |

---

### Overall Project Score

| Category | Score | Status |
|----------|-------|--------|
| Architecture | 7/10 | Good foundation, needs DI and routing |
| Security | 4/10 | Critical issues with exposed keys and missing rules |
| Performance | 5/10 | Streaming works but has inefficiencies |
| **Overall** | **5.3/10** | **Functional but needs hardening** |

---

*Report generated on 2026-03-28 by Claude Code audit.*
