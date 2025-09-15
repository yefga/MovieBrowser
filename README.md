# 🎬 MovieBrowser

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![iOS](https://img.shields.io/badge/iOS-15%2B-blue.svg)
![Xcode](https://img.shields.io/badge/XcodeGen-2.41-green.svg)
![Architecture](https://img.shields.io/badge/Architecture-MVVM--C%20+%20DDD-lightgrey.svg)

MovieBrowser is a sample iOS app that lets users search for movies, view details, and mark favorites.  
It was built using **UIKit + SwiftUI (bonus)**, with **MVVM-C architecture** and **Domain-Driven Design** principles.  
Networking is implemented using `URLSession` (no Alamofire), with a clean, testable abstraction.  
Core Data is used for caching results and storing favorites.

---

## 🚀 Features
- Search movies from TMDB API
- View detailed information (poster, overview, release date, etc.)
- Mark/unmark favorites
- Persistent storage using Core Data
- Dark/Light mode support
- Coordinators for navigation
- Shared UI components via `MovieUI`
- Modularized into `Core`, `Persistence`, `UI`, and `App`

---

## 🛠 Requirements
- iOS 15.0+
- Xcode 15+
- Swift 6.2
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [SwiftLint](https://github.com/realm/SwiftLint)

---

## 📦 Project Setup

1. Clone the repository
   ```bash
   git clone https://github.com/yefga/MovieBrowser.git
   cd MovieBrowser
   ```

2. Make sure you have **Homebrew**, **XcodeGen**, and **SwiftLint** installed:
   ```bash
   brew install xcodegen swiftlint
   ```

3. Generate the Xcode project:
   ```bash
   ./build.sh
   ```

4. Open the generated project:
   ```bash
   open MovieBrowser.xcodeproj
   ```

5. Add your TMDB API key and token in `Config/Debug.xcconfig` and `Config/Release.xcconfig`.

---

## ▶️ Running the App
- Select the **MovieBrowser** target
- Run on iOS Simulator or a real device

---

## 🧩 Architecture
- **MVVM-C** for testability and clear navigation flow
- **Domain-Driven Design** for modular separation:
  - `Core`: Networking layer (HTTP, Endpoints, Errors)
  - `Persistence`: Core Data stack & caching
  - `UI`: Shared UI components
  - `App`: Features, Coordinators, ViewModels

---

## 📸 Screenshots

### 🔍 Search
<img src="docs/screenshots/search.png" width="250"/>

### 📖 Details
<img src="docs/screenshots/details.png" width="250"/>

### ❤️ Favorites
<img src="docs/screenshots/favorites.png" width="250"/>

---

## ✍️ Decisions & Challenges

### Why MVVM-C + DDD?
MVVM-C keeps view controllers lightweight and testable. Coordinators manage navigation cleanly.  
Domain-Driven Design enforces modularity: networking in `Core`, persistence in `Persistence`, UI in `UI`.

### Why no Alamofire?
To demonstrate a testable, lightweight solution using `URLSession` and custom abstractions.

### Persistence
Favorites and offline caching both rely on a single Core Data entity (`CachedMovie`).  
The challenge was balancing reusability and simplicity — solved by keeping all models optional-friendly.

### Dark Mode
UI was designed with adaptability in mind. Added a toggle for quick testing.

### Biggest Challenges
- Keeping the architecture clean without over-engineering for a small project
- Handling Core Data favorites and cache with one entity
- Making UIKit + SwiftUI co-exist cleanly (optional SwiftUI bonus views)

---

## 🧪 Tests
Unit tests are **coming soon**. The project has been structured to make testing straightforward.

---

## 📄 License
MIT
