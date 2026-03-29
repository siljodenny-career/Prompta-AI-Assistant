# Prompta AI Assistant - App Audit Report

**Date:** 2026-03-29
**Version:** 1.0.0
**Audited By:** Claude Code

---

## Overall Ratings

| Category | Score | Grade |
|----------|-------|-------|
| Security | 4/10 | F |
| Performance | 5/10 | D |
| Architecture | 7/10 | C+ |
| UI/UX | 7/10 | C+ |
| Responsiveness | 8/10 | B |
| Data Privacy | 4/10 | F |
| Dependencies | 8/10 | B |
| Testing | 0/10 | F |
| **Overall** | **5.4/10** | **D+** |

---

## 1. SECURITY (4/10)

### CRITICAL Issues

**1.1 Exposed API Key in `.env`**
- OpenRouter API key found in server `.env` working directory
- Must rotate the key immediately in OpenRouter dashboard
- Use Render environment variables instead of `.env` file

**1.2 Missing Firestore Security Rules**
- No `firestore.rules` file found in repository
- Default rules may allow unauthorized read/write to all user data
- Recommended rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /chat_threads/{threadId} {
      allow read, write: if request.auth.uid == resource.data.userId;
      match /messages/{messageId} {
        allow read, write: if request.auth.uid == get(/databases/$(database)/documents/chat_threads/$(threadId)).data.userId;
      }
    }
    match /Prompta-Users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

**1.3 No Authentication on Chat API**
- Chat endpoints (`/api/chat`, `/api/chat/stream`) have no auth middleware
- Anyone with the server URL can use the API and incur OpenRouter costs
- Fix: Add Firebase ID token verification middleware

**1.4 No Server Security Headers**
- Missing `helmet` middleware for HTTP security headers
- No HTTPS enforcement in production

### HIGH Issues

- API key potentially in git history (needs `git filter-repo` scrub)
- No per-user rate limiting on chat endpoints
- No session timeout implementation
- "Forgot password" feature not implemented

### MEDIUM Issues

- Weak email validation in sign-up (`@` check only vs proper regex in sign-in)
- No 2FA support
- No account lockout after failed login attempts

### GOOD

- Firebase Auth handles password hashing securely
- Strong password validation (uppercase, lowercase, number, special char, min 6)
- CORS properly configured with allowed origins
- Basic rate limiting (30 req/min) on server
- Server input validates message structure and content length (10KB max)

---

## 2. PERFORMANCE (5/10)

### CRITICAL Issues

**2.1 Message List Copied on Every Stream Chunk**
- `List.unmodifiable(_messages)` called on every SSE chunk (100-500x per response)
- Creates massive GC pressure, UI jank, battery drain
- Fix: Throttle emissions or use structural sharing (freezed package)

**2.2 PostFrameCallback Accumulation**
- `addPostFrameCallback` added on every BLoC state change in `BlocConsumer.listener`
- Can accumulate 100+ callbacks during streaming
- Fix: Debounce scroll-to-bottom calls

### MEDIUM Issues

- Large inline widget trees (chat_page.dart 600+ lines)
- Missing `const` constructors on leaf widgets
- No server-side response compression
- Firestore full document writes instead of merge updates
- `device_preview` in production dependencies (adds ~2-3MB)

### GOOD

- 30-second HTTP timeout on API calls
- Client-side Firestore sorting avoids index requirements
- Lottie animations cached properly
- Proper stream subscription cleanup in BLoC `close()`

---

## 3. ARCHITECTURE (7/10)

### GOOD

- Clean Architecture pattern (domain/data/presentation layers)
- BLoC state management properly implemented
- Repository pattern for data abstraction
- UseCase pattern for business logic
- Proper separation of concerns
- Firebase Auth with user repository abstraction

### NEEDS IMPROVEMENT

- No dependency injection (no get_it or injectable)
- No proper routing (no go_router, uses Navigator.push directly)
- Large files need extraction into smaller widgets
- No testing infrastructure at all
- Missing repository pattern for local storage

### ARCHITECTURE DIAGRAM

```
Presentation (BLoC + Widgets)
    |
Domain (Entities + UseCases + Repository interfaces)
    |
Data (Models + DataSources + Repository implementations)
    |
External (Firebase + OpenRouter API)
```

---

## 4. UI/UX (7/10)

### EXCELLENT

- Dark/Light theme with animated toggle and persistence
- Smooth transitions (staggered field animations, page transitions)
- Breathing logo animation on splash screen
- Typing indicator animation
- Markdown rendering with syntax-highlighted code blocks
- Copy-to-clipboard on messages and code blocks
- Expandable avatar chip with name on app bar
- Doodle pattern background on chat page

### GOOD

- Haptic feedback on send
- Auto-scroll to latest messages
- Animated search bar in sidebar
- Chat history with swipe-to-delete
- Regenerate response button
- Password strength indicator

### NEEDS IMPROVEMENT

- No semantic labels on icons (accessibility)
- No screen reader support
- Text contrast not verified for WCAG compliance
- No loading skeleton screens
- No empty state illustrations
- No onboarding tooltips for new features

---

## 5. RESPONSIVENESS (8/10)

### GOOD

- `ScreenConfig` utility for responsive dimensions
- `MediaQuery` used for dynamic sizing
- `SafeArea` for notch/status bar handling
- Device preview enabled in debug mode
- Flexible layouts with `Expanded` and `Flexible`
- Constrained message bubble width (85% of screen)
- Input field max height with scroll (120px / 5 lines)

### NEEDS IMPROVEMENT

- No tablet-specific layout
- No landscape orientation handling
- Sidebar width not responsive to screen size
- Font sizes not using responsive scaling

---

## 6. DATA & PRIVACY (4/10)

### CRITICAL

- No Firestore security rules
- Chat conversations stored in plain text
- Thread title generated by sending user's message to 3rd party (OpenRouter) without explicit consent
- No data retention policy
- No data export or deletion capability

### GOOD

- Firebase provides encryption at storage layer
- User data properly structured in Firestore
- Proper timestamp tracking on threads

---

## 7. DEPENDENCIES (8/10)

### Client (Flutter) - All Current

| Package | Status |
|---------|--------|
| flutter_bloc ^9.1.1 | Current |
| firebase_auth ^6.3.0 | Current |
| cloud_firestore ^6.2.0 | Current |
| flutter_markdown ^0.7.7 | Current |
| shared_preferences ^2.5.5 | Current |
| google_fonts ^8.0.2 | Current |

**Issue:** `device_preview` should be in `dev_dependencies`

### Server (Node.js) - All Current

| Package | Status |
|---------|--------|
| express ^5.2.1 | Current |
| axios ^1.13.5 | Current |
| cors ^2.8.6 | Current |
| express-rate-limit ^8.3.1 | Current |

**Missing:** `helmet` for security headers

---

## 8. TESTING (0/10)

- No unit tests
- No widget tests
- No integration tests
- No CI/CD pipeline
- No test coverage reporting

---

## IMMEDIATE ACTION ITEMS

| # | Task | Priority | Time |
|---|------|----------|------|
| 1 | Rotate OpenRouter API key | CRITICAL | 5min |
| 2 | Add Firestore security rules | CRITICAL | 30min |
| 3 | Add auth middleware to chat API | CRITICAL | 1hr |
| 4 | Scrub git history of secrets | CRITICAL | 2hr |
| 5 | Fix message list copying in ChatBloc | HIGH | 2hr |
| 6 | Fix PostFrameCallback accumulation | HIGH | 30min |
| 7 | Add per-user rate limiting | HIGH | 1hr |
| 8 | Move device_preview to dev_deps | MEDIUM | 5min |
| 9 | Fix email validation consistency | MEDIUM | 15min |
| 10 | Add helmet middleware | MEDIUM | 15min |

---

## RECOMMENDATION

**DO NOT deploy to production until all CRITICAL security issues are resolved.**

The app has a solid architectural foundation and good UI/UX polish, but security vulnerabilities make it unsafe for production use. Focus on:
1. Security hardening (API auth, Firestore rules, secret rotation)
2. Performance optimization (BLoC emission throttling)
3. Testing infrastructure
4. Accessibility improvements
