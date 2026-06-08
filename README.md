# RemoteRecruit

A simple job browser app I built for the iOS engineer assignment. You can see a
list of jobs, search them, and open a job to see the full details.

## Built with

- Swift 5 + SwiftUI
- MVVM
- async/await
- Min iOS 17

The data comes from a local `jobs.json` file in the app bundle instead of a real
backend (the assignment allowed a mock source).

## How to run

Open `RemoteRecruit.xcodeproj` in Xcode 16, pick a simulator and hit Run (Cmd+R).

For the tests, use Cmd+U. Or from terminal:

```
xcodebuild test -project RemoteRecruit.xcodeproj -scheme RemoteRecruit \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## What it does

- List of jobs with title, company, location and salary
- Search by job title or company name
- Job detail screen with description, company info, salary and location
- Handles loading, empty and error states (error has a retry button)
- Pull to refresh on the list

## How it's structured

Pretty standard MVVM.

- `Models/Job.swift` - the Job/Company/SalaryRange types and the salary
  formatting
- `Common/ViewState.swift` - small enum for the screen state (loading, loaded,
  empty, failed). Each screen just renders based on this.
- `Services/JobService.swift` - a protocol for fetching jobs.
  `LocalJobService` is the real one that reads jobs.json. Using a protocol here
  is what lets the tests inject a fake instead of touching the real file.
- `ViewModels/` - the logic. They fetch from the service, do the search
  filtering and set the state. Both are @MainActor.
- `Views/` - the SwiftUI screens. No logic in here, they just draw the state.
- `DI/AppContainer.swift` - creates the service and builds the view models, so
  all the wiring is in one place.

Flow is basically: View -> ViewModel -> Service, and the View redraws from
whatever state the ViewModel publishes.

If I wanted to use a real API later I'd just add a new JobService that uses
URLSession and swap it in AppContainer. The views and view models wouldn't
change.

## Tests

Tests are in `RemoteRecruitTests`. They cover the view models and the
service/model logic - loading, search by title and company, empty results,
errors and retry, salary formatting, and JSON decoding. There's a StubJobService
so the tests don't depend on the real data.

Coverage on the view model / service / model code is around 90%, which is above
the 70% asked for. I didn't write tests for the SwiftUI views themselves since
that's just layout.

## Notes / assumptions

- Salaries are shown in Indian Rupees (₹) with the lakh format like
  ₹12,00,000. The formatter picks the grouping from the currency so it's not
  hardcoded.
- Search only looks at title and company, like the assignment said.
- There's a small fake delay in LocalJobService so the loading spinner is
  actually visible.
- Tapping a job passes the job straight to the detail screen so it opens
  instantly. There's also a load-by-id path in case it's needed later.
- No login, pagination or saved jobs - kept it to what was asked.
