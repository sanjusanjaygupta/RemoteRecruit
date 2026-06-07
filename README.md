# RemoteRecruit

A small iOS app for browsing, searching and viewing job postings. Built as the
iOS Engineer technical assignment.

## Tech

- Swift 5, SwiftUI
- MVVM
- async/await for the async work
- Dependency injection through a small container
- Min iOS 17.0
- Data comes from a bundled `jobs.json` file (acting as a mock API)
- Unit tests with XCTest

## Features

- **Job list** – title, company, location and salary range for each job.
- **Search** – filter by job title or company name as you type.
- **Job detail** – description, company info, salary and location.
- **States** – loading, empty and error (with a retry button) are all handled,
  plus pull to refresh on the list.

## Getting started

You'll need Xcode 16 or newer with an iOS 17 simulator.

```bash
open RemoteRecruit.xcodeproj
```

Pick the `RemoteRecruit` scheme and a simulator, then run with Cmd-R.

To run the tests use Cmd-U, or from the terminal:

```bash
xcodebuild test \
  -project RemoteRecruit.xcodeproj \
  -scheme RemoteRecruit \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

(Use any simulator you have installed - check with `xcrun simctl list devices`.)

## Architecture

It's a fairly standard MVVM setup:

- **Models** (`Models/Job.swift`) – `Job`, `Company`, `SalaryRange` value types,
  plus the salary/location display formatting.
- **ViewState** (`Common/ViewState.swift`) – a generic enum with the four UI
  states (loading / loaded / empty / failed). Each screen renders off one of
  these, which keeps the views simple and avoids impossible states.
- **Services** (`Services/`) – `JobService` is a protocol; `LocalJobService`
  is the concrete one that reads and decodes `jobs.json`. The app depends on
  the protocol, so the tests can pass in a stub instead.
- **ViewModels** (`ViewModels/`) – the actual logic: fetching, filtering and
  state transitions. Both are `@MainActor`.
- **Views** (`Views/`) – SwiftUI screens, driven entirely by the view model
  state. No logic lives here.
- **AppContainer** (`DI/AppContainer.swift`) – the composition root. It holds
  the service and builds the view models, so the wiring is all in one place.

The flow is: the view asks the container for a view model, the view model calls
the service, and the view renders whatever `ViewState` comes back.

Swapping the JSON file for a real network API later would mean adding one
`URLSession`-based `JobService` and changing one line in `AppContainer` -
nothing in the views or view models would need to change.

## Tests

The business logic is covered by XCTest:

- `JobListViewModelTests` – loading state, success, empty result, error +
  message, search by title and by company, case-insensitive/trimmed search,
  no-match, clearing the search, and retry after a failure.
- `JobDetailViewModelTests` – seeding from a job vs. an id, reloading by id,
  and a missing job.
- `ModelAndServiceTests` – salary formatting (INR and others), location text,
  JSON decoding and the service's not-found error.

A `StubJobService` and a small `JobFixtures` helper keep the tests fast and
predictable. Coverage on the view models / services / models is around 90%+,
which is well past the 70% target. The lines that aren't covered are the
SwiftUI view layout, which isn't really worth unit testing.

To see the numbers: Product > Scheme > Edit Scheme > Test > Options > Code
Coverage, then run Cmd-U.

## Assumptions

- **Mock data.** The brief allows a local JSON file, so `LocalJobService` reads
  `jobs.json` from the app bundle. There's a small artificial delay in there on
  purpose so the loading spinner is actually visible.
- **Indian Rupees.** Salaries are shown in INR (₹) using the Indian
  lakh/crore grouping, e.g. ₹12,00,000. The formatter picks the grouping from
  the currency, so other currencies (USD/GBP/EUR) still format the normal way.
- **Search.** Matches title and company only, as listed in the brief.
- **Detail data.** Tapping a row hands the full job straight to the detail
  screen so it shows instantly. There's also a reload-by-id path for things
  like deep links.
- **iOS 17+.** Uses `ContentUnavailableView` and `.searchable` to keep the UI
  code small.
- Out of scope: persistence, pagination, saved jobs, login.

## Project layout

```
RemoteRecruit/
  RemoteRecruitApp.swift      app entry + DI wiring
  Common/ViewState.swift
  Models/Job.swift
  Services/
    JobService.swift          protocol
    LocalJobService.swift     reads jobs.json
  ViewModels/
    JobListViewModel.swift
    JobDetailViewModel.swift
  Views/
    JobListView.swift
    JobRowView.swift
    JobDetailView.swift
    StateViews.swift          loading / empty / error
  DI/AppContainer.swift
  Resources/jobs.json
  Assets.xcassets
RemoteRecruitTests/
  StubJobService.swift        test double + fixtures
  JobListViewModelTests.swift
  JobDetailViewModelTests.swift
  ModelAndServiceTests.swift
```
