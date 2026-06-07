# RemoteRecruit — Job Browser App

A small, production-quality iOS app for browsing, searching, and viewing job postings.
Built as the **iOS Engineer Technical Examination**.

| | |
|---|---|
| **Language** | Swift 5 |
| **UI** | SwiftUI |
| **Architecture** | MVVM + Dependency Injection |
| **Concurrency** | `async/await` |
| **Min iOS** | 17.0 |
| **Data source** | Bundled JSON file (`jobs.json`) acting as a mock API |
| **Tests** | XCTest — ViewModels, services, and models |

---

## Features

- **Job Listing** — title, company, location, and salary range for every job.
- **Search** — filter jobs live by **title** or **company** (case-insensitive, whitespace-trimmed).
- **Job Details** — full description, company information, salary range, and location.
- **State handling** — explicit **loading**, **empty**, and **error** (with retry) states, plus pull-to-refresh.

---

## Setup & Run

### Requirements
- macOS with **Xcode 16** or newer
- iOS 17 Simulator (bundled with Xcode)

### Run the app
```bash
# 1. Open the project
open RemoteRecruit/RemoteRecruit.xcodeproj

# 2. Select the "RemoteRecruit" scheme and an iOS 17+ simulator
# 3. Press Cmd-R
```

### Run the tests
From Xcode: **Product ▸ Test** (`Cmd-U`).

Or from the command line:
```bash
cd RemoteRecruit
xcodebuild test \
  -project RemoteRecruit.xcodeproj \
  -scheme RemoteRecruit \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```
> Adjust the simulator name to one installed on your machine (`xcrun simctl list devices`).

---

## Architecture

The app follows **MVVM** with a thin **dependency-injection container** as the composition root.

```
┌──────────────┐     observes      ┌─────────────────┐     calls      ┌──────────────┐
│    Views      │ ◀──────────────── │   ViewModels     │ ─────────────▶ │  JobService   │
│  (SwiftUI)    │   @Published      │  (@MainActor)    │   async/await  │  (protocol)   │
└──────────────┘     state         └─────────────────┘                └──────┬───────┘
        ▲                                                                     │
        │ builds via                                              ┌──────────┴──────────┐
        │                                                          │  LocalJobService     │
┌──────────────┐                                                  │  (jobs.json)         │
│ AppContainer  │ ── injects service & makes view models ──▶      └─────────────────────┘
│  (DI root)    │
└──────────────┘
```

### Layers

| Layer | Files | Responsibility |
|---|---|---|
| **Models** | `Models/Job.swift` | Immutable value types (`Job`, `Company`, `SalaryRange`) + display formatting. |
| **Common** | `Common/ViewState.swift` | Generic `ViewState<Value>` enum modelling loading / loaded / empty / failed. |
| **Services** | `Services/JobService.swift`, `Services/LocalJobService.swift` | Data access behind a protocol; concrete impl decodes the bundled JSON. |
| **ViewModels** | `ViewModels/*` | Business logic: fetching, filtering, and state transitions. `@MainActor`. |
| **Views** | `Views/*` | SwiftUI rendering, driven entirely by `ViewState`. No business logic. |
| **DI** | `DI/AppContainer.swift` | Composition root: owns the service, builds view models. |

### Key decisions

- **Single source of UI truth.** Each screen renders from one `ViewState` enum, which makes
  invalid combinations (e.g. "loading *and* error") unrepresentable and keeps the views declarative.
- **Protocol-based service.** `JobService` is an abstraction; the app injects `LocalJobService`,
  while tests inject a `StubJobService`. This is what makes the business logic unit-testable
  without any network or file system.
- **Dependency injection via a container.** Views never construct services. They ask `AppContainer`
  for a ready-made view model, so the entire object graph can be swapped in one place (app, tests, previews).
- **`@MainActor` view models.** All `@Published` mutations are guaranteed on the main thread;
  `async/await` handles the off-main work inside the service.
- **Search runs in memory.** The full list is fetched once and filtered locally, so typing is instant
  and does not re-hit the data source.

---

## Testing

Business logic is covered by `XCTest`:

| Test file | Covers |
|---|---|
| `JobListViewModelTests` | Initial loading state, success → loaded, empty result, error + message, search by title, search by company, case-insensitivity/trimming, no-match → empty, clearing search, retry-after-failure. |
| `JobDetailViewModelTests` | Seeding from a job vs. an id, reload-by-id, missing job → failed. |
| `ModelAndServiceTests` | Salary/location formatting, JSON decoding, and the service's not-found error. |

A `StubJobService` test double and `JobFixtures` factory keep the tests fast and deterministic.
Coverage of the ViewModel/service business logic is **well above the 70% target** (those layers are
exercised end-to-end; the only untested code is declarative SwiftUI layout).

To see coverage in Xcode: **Product ▸ Scheme ▸ Edit Scheme ▸ Test ▸ Options ▸ Code Coverage**, then `Cmd-U`.

---

## Assumptions

1. **Mock API via bundled JSON.** The brief allows a local JSON file; `LocalJobService` reads
   `jobs.json` from the app bundle and decodes it, simulating a networked API (including a short
   artificial delay so the loading state is visible). Swapping in a real `URLSession`-backed service
   later means adding one type and changing one line in `AppContainer` — no view or view-model changes.
2. **Search scope.** Per the brief, search matches **title** and **company** only (not description/location).
3. **Detail data is already loaded.** Tapping a row passes the full `Job` straight to the detail screen,
   so it renders instantly. A `reload(by:id)` path is also included to support deep links / refresh.
4. **iOS 17+.** Uses `ContentUnavailableView` and `.searchable`, keeping the UI code minimal and modern.
5. **No persistence / pagination / favouriting.** These were out of scope for the exam.

---

## Project structure

```
RemoteRecruit/
├── README.md
├── .gitignore
├── RemoteRecruit.xcodeproj
└── RemoteRecruit/
    ├── RemoteRecruitApp.swift        # @main entry point + DI wiring
    ├── Common/ViewState.swift
    ├── Models/Job.swift
    ├── Services/
    │   ├── JobService.swift           # protocol
    │   └── LocalJobService.swift      # JSON-backed implementation
    ├── ViewModels/
    │   ├── JobListViewModel.swift
    │   └── JobDetailViewModel.swift
    ├── Views/
    │   ├── JobListView.swift
    │   ├── JobRowView.swift
    │   ├── JobDetailView.swift
    │   └── StateViews.swift           # loading / empty / error
    ├── DI/AppContainer.swift
    ├── Resources/jobs.json            # mock data
    └── Assets.xcassets
└── RemoteRecruitTests/
    ├── StubJobService.swift           # test double + fixtures
    ├── JobListViewModelTests.swift
    ├── JobDetailViewModelTests.swift
    └── ModelAndServiceTests.swift
```

---

## Optional: TestFlight

Not included by default. To distribute:
1. Set a unique `PRODUCT_BUNDLE_IDENTIFIER` and your team in **Signing & Capabilities**.
2. **Product ▸ Archive**, then upload to App Store Connect and add the build to TestFlight.
