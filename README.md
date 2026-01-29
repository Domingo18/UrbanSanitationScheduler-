# Urban Sanitation Scheduler
An iOS application that provides address-driven sanitation pickup schedules for residential properties. The app resolves user-entered addresses via NYC geospatial services, determines sanitation rules by district, and presents pickup schedules in a calendar-based interface with persistent storage. Designed to help residents understand when and how their waste is collected based on their exact address. By integrating geocoding APIs with sanitation service data, the app converts a free-form street address into actionable scheduling information.

The app follows MVVM

The system emphasizes:

Accurate address normalization
District-based service resolution
Clear schedule visualization
Offline persistence of saved addresses

Core Features:

Address Resolution:
Free-form address input
Normalized via NYC Geoclient API
Resolves borough, community district, and sanitation data

Schedule Generation:
Determines trash, recycling, and bulk pickup schedules
Converts service rules into calendar-ready dates
Calendar Visualization
Highlights sanitation days directly on a calendar
Designed for extensibility (alerts, reminders, notifications)

Persistent Storage:
Save multiple resolved addresses locally
Delete and manage saved entries
Works offline once cached


This is a personal project for understanding Swift fundamentals and expand on my current knowledege.

Language: Swift
UI: SwiftUI
Architecture: MVVM
Concurrency: Async / Await
Networking: URLSession
Data Modeling: Codable
Persistence: UserDefaults (extensible to Core Data)
APIs: NYC Geoclient
