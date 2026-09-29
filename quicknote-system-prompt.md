# QuickNote — Engineering Agent System Context

You are working on **QuickNote**, a hyper-fast, offline-first digital note-taking application built with **Flutter/Dart**, **BLoC/Cubit**, **Melos monorepo**, **Pure Dart domain/core**, and a high-performance local storage architecture.

The primary mandate of QuickNote is **uncompromised speed ("speed of light" startup and zero-latency UI interaction)**, extreme modularity, and strict adherence to clean package boundaries.

---

## 1. Performance & "Speed of Light" Standards
- **Sub-100ms Cold Startup:** Keep bootstrap minimal. Never perform heavy I/O, synchronous disk reads, or network initializations on the main startup path.
- **UI Isolate Protection:** Heavy computations (full-text indexing, complex queries, JSON serialization, PDF rendering) MUST be offloaded to background Dart Isolates. The main UI Isolate is reserved strictly for 60/120 FPS rendering.
- **In-Memory First Persistence:** Note reads and active edits happen instantly in-memory. Disk writes must be non-blocking delta flushes using an ultra-fast local database (such as Isar or SQLite in WAL mode).

---

## 2. Modularity & File Size Limits
- **300-Line Refactor Threshold:** Keep files focused and <= 300 lines of code. Reaching 300 lines is a mandatory trigger to refactor independent responsibilities into cohesive modules.
- **Pragmatic SRP & DRY:** Apply Single Responsibility and Don't Repeat Yourself principles pragmatically. Do not fragment naturally cohesive code merely to hit an arbitrary line count.

---

## 3. Package Boundaries & Layer Separation
- **Pure Dart Core & Domain:** Core and feature packages (`packages/core/*`, `packages/features/*`) must remain 100% Pure Dart with **zero dependency on `package:flutter`**.
- **One-Way Dependency Flow:** The application layer (`apps/quicknote`) consumes features and core packages. Lower packages must never depend on Flutter UI or higher-level modules.
- **Passive Presentation (BLoC/Cubit):** Use BLoC/Cubit for UI state. Flutter widgets are passive view components and must not contain business logic, direct database calls, or native invocations.

---

## 4. In-Process & Offline-First Architecture
- **100% Offline-First:** Core note-taking and management capabilities must operate entirely offline without network dependency.
- **Direct In-Process Communications:** Never use internal HTTP servers, localhost REST APIs, WebSockets, or microservices between UI and core layers. Internal communication must rely exclusively on direct in-process Dart APIs.

---

## 5. Localization & Text Management
- **Zero Hardcoded User Strings:** All user-facing text must be resolved through a centralized text registry using stable keys (`TextKey`). Strings must support locale variants and contextual presentation profiles (e.g., UI, errors, dialogs).

---

## 6. Verification Marker & Scope Discipline
- **Scope Restriction:** Do only the explicitly requested work. Never introduce unrequested refactors, extra tests, or extraneous documentation.
- **Agent Verification Marker (`code 11`):** Whenever an AI agent opens and processes this rule file, it MUST output `code 11` at the very beginning of its response to verify compliance.
