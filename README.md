# Weather Explorer 🌤️

A cross-platform weather application built with **Flutter and Dart**, providing users with current weather conditions and forecasts for locations around the world.

The project demonstrates modern Flutter development practices, including API integration, asynchronous data handling, responsive UI design, and clean separation of application layers.

## Features

* 🌤️ View current weather conditions
* 🌡️ Display temperature and weather details
* 📍 Search weather by location
* 📅 View weather forecasts
* 🔄 Pull to refresh weather data
* 📱 Responsive UI for different screen sizes
* ⚡ Asynchronous API data loading
* ❌ Error and loading state handling

## Tech Stack

* **Flutter**
* **Dart**
* REST API
* JSON
* Material Design

## Architecture

The application is structured to keep UI, business logic, and data access separated for easier maintenance and testing.

```text
lib/
├── models/          # Weather and API data models
├── services/        # API and external data services
├── screens/         # Application screens
├── widgets/         # Reusable UI components
└── main.dart        # Application entry point
```

## Getting Started

### Prerequisites

* Flutter SDK
* Dart SDK
* Android Studio or Xcode
* An Android or iOS device/emulator

### Installation

Clone the repository:

```bash
git clone git@github.com:SaraHung1/weather_explorer.git
```

Navigate to the project:

```bash
cd weather_explorer
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Screenshots

*Add screenshots of the application here.*

## Platform Support

| Platform | Supported |
| -------- | --------- |
| Android  | ✅         |
| iOS      | ✅         |
| Web      | ✅         |
| macOS    | ✅         |

## What This Project Demonstrates

This project was built to demonstrate practical cross-platform development skills with Flutter, including:

* Building reusable Flutter UI components
* Managing asynchronous API requests
* Working with REST APIs and JSON
* Handling loading, success, and error states
* Creating responsive layouts
* Structuring a maintainable Flutter application
* Building and running applications across multiple platforms

## License

This project is for portfolio and demonstration purposes.
