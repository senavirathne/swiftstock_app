# Swiftstock App

Welcome to the **Swiftstock App**! This application is designed with a primary focus on reducing the time taken to complete a transaction to the absolute minimum. By streamlining processes and optimizing the user interface, we've aimed to create an app that facilitates quick and efficient transactions, enhancing productivity and user satisfaction.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [Modular Architecture](#modular-architecture)
  - [Adding or Removing Features](#adding-or-removing-features)
- [Feature Flags](#feature-flags)
- [Usage](#usage)
  - [Home Screen](#home-screen)
  - [Item Search](#item-search)
  - [Cart and Payment](#cart-and-payment)
  - [Settings](#settings)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Features

- **Rapid Transactions**: Optimized for speed to reduce transaction time significantly.
- **Modular Design**: Features can be independently added or removed without affecting the core application.
- **Customizable Settings**: Adjust settings like the number of mod items and keyboard preferences.
- **Subscription Management**: Handles subscription validation and activation.
- **Activity Logging**: Keeps a log of activities for auditing and monitoring.
- **Data Import/Export**: Import items from CSV and export data for backup or analysis.
- **Cross-Platform Support**: Runs on both mobile and web platforms.

---

## Getting Started

These instructions will help you set up and run the application on your local machine for development and testing purposes.

### Prerequisites

- **Flutter SDK**: Version 2.0 or higher.
- **Dart SDK**: Included with Flutter.
- **Git**: For cloning the repository.
- **IDE/Text Editor**: Visual Studio Code, Android Studio, or any other preferred IDE.

### Installation

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/swiftstock_app.git
   cd swiftstock_app
   ```

2. **Install Dependencies**

   Run the following command to fetch all the necessary packages:

   ```bash
   flutter pub get
   ```

### Running the App

To run the application on an emulator or physical device:

```bash
flutter run
```

To run the application on the web:

```bash
flutter run -d chrome
```

---

## Project Structure

The application is organized into modules, each representing a feature of the app. Below is the directory structure:

```
lib/
├── main.dart
├── modules/
│   ├── activity/
│   │   ├── activity_model.dart
│   │   ├── activity_service.dart
│   │   └── activity_log_screen.dart
│   ├── item/
│   │   ├── item_model.dart
│   │   ├── item_service.dart
│   │   ├── item_search_screen.dart
│   │   └── add_item_screen.dart
│   ├── subscription/
│   │   ├── subscription_service.dart
│   │   ├── subscription_screen.dart
│   │   └── subscription_info_screen.dart
│   ├── transaction/
│   │   ├── transaction_model.dart
│   │   ├── transaction_service.dart
│   │   ├── cart_screen.dart
│   │   └── payment_screen.dart
│   └── home/
│       └── home_screen.dart
├── services/
│   ├── database_service.dart
│   ├── null_database_service.dart
│   ├── real_database_service.dart
│   └── service_locator.dart
├── widgets/
│   ├── custom_drawer.dart
│   └── custom_keyboard.dart
└── utils/
    ├── feature_flags.dart
    └── constants.dart
```

---

## Modular Architecture

The app is built using a modular architecture that allows each feature to function independently. This design ensures that:

- **Features are Decoupled**: Each module contains all the code related to a specific feature, making it self-contained.
- **Easy Maintenance**: Modules can be updated or refactored without affecting other parts of the application.
- **Selective Feature Inclusion**: Features can be enabled or disabled based on requirements.

### Adding or Removing Features

To add a new feature:

1. **Create a New Module**: Add a new directory under `lib/modules/` for your feature.
2. **Implement Feature Code**: Include models, services, screens, and widgets related to the feature.
3. **Register Services**: If your feature requires services, register them in `service_locator.dart`.

To remove a feature:

1. **Disable Feature Flag**: Set the corresponding feature flag to `false` in `feature_flags.dart`.
2. **Unregister Services**: Remove or comment out the service registration in `service_locator.dart`.
3. **Remove Module (Optional)**: Delete the module directory if it's no longer needed.

---

## Feature Flags

Feature flags are used to enable or disable features dynamically. They are defined in `lib/utils/feature_flags.dart`:

```dart
class FeatureFlags {
  static const bool isDatabaseEnabled = true;
  static const bool isSubscriptionEnabled = true;
  // Add other feature flags as needed
}
```

To disable a feature, set its flag to `false`. The application will handle the absence of the feature gracefully.

---

## Usage

### Home Screen

- **Start Transaction**: Begin a new transaction by tapping the "Start Transaction" button.
- **Navigation Drawer**: Access additional features like subscription info, settings, and activity logs.

### Item Search

- **Search Items Quickly**: Use the search bar to find items rapidly.
- **Custom Keyboard**: Enable the custom keyboard in settings to optimize search speed.
- **Add Items to Cart**: Specify quantities and add items to the cart with minimal input.

### Cart and Payment

- **Review Cart**: View items added to the cart and make adjustments if necessary.
- **Proceed to Payment**: Complete the transaction swiftly through the streamlined payment process.
- **Transaction Completion**: Get immediate feedback on the transaction status and start new transactions promptly.

### Settings

- **Customize App Behavior**: Adjust settings to suit your workflow, such as the number of mod items or keyboard preferences.
- **Data Management**: Import items from CSV or export data for backup and analysis.
- **Feature Management**: Enable or disable features via feature flags.

---

## Contributing

We welcome contributions from the community to enhance the application further.

1. **Fork the Repository**: Create a personal copy of the repository.
2. **Create a Feature Branch**: Work on your feature or bug fix in a new branch.
3. **Commit Your Changes**: Make sure to write clear and concise commit messages.
4. **Push to Your Fork**: Push your changes to your forked repository.
5. **Submit a Pull Request**: Create a pull request to merge your changes into the main repository.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

For any inquiries or support, please contact:

- **Email**: madushika4@icloud.com
- **GitHub Issues**: [Create an issue](https://github.com/Madushika-Pramod/swiftstock_app/issues)

---

Thank you for using the **Swiftstock App**! We are committed to providing a tool that enhances efficiency and reduces transaction times significantly. Your feedback and support are invaluable to us.