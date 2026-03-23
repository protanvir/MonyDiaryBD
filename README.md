# Money Diary 📔 ৳

**Money Diary** is a premium, modern personal finance manager built with Flutter. It helps you track your expenses, manage multiple accounts (Cash, Bank, bKash, Credit Cards), and stay on top of your budgets with a beautiful, user-centric interface inspired by modern fintech designs.

## ✨ Key Features

### 🌓 Dark Mode Support
- **Full Dark Theme**: A premium, high-contrast dark mode using deep slate and charcoal colors.
- **Easy Toggle**: Seamlessly switch between light and dark modes directly from the Dashboard.
- **Persistent Selection**: Your theme preference is saved across app restarts.

### 🏦 Advanced Account Management
- **Grouped Categories**: Accounts are intuitively organized into **Cash & Bank** and **Credit Card** sections.
- **Net Worth Tracking**: A real-time summary card showing your total Assets, Liabilities, and calculated Net Worth.
- **Full Control**: Add, Edit, or Delete any account using the streamlined management interface.
- **Brand Identity**: Specialized icons and brand-specific colors for **bKash**, **Nagad**, and major credit cards.

### 💳 Comprehensive Credit Card Tracking
- **Liability Separation**: Credit Card outstanding is tracked separately from your liquid assets on the dashboard.
- **Limit Monitoring**: Set and monitor your **Credit Limits** to avoid overspending.
- **Smart Bill Payments**: One-tap payments that automatically sync balances across your accounts.

### 📝 Smart Transactions
- **Dynamic Labeling**: Transactions automatically use category names (e.g., "Shopping") as titles if notes are missing.
- **Real-time Balance Sync**: Account balances and liabilities update instantly when a transaction is logged.
- **Categorized History**: Clear, searchable logs for every transaction in your diary.

### 📊 Budgets & Analytics
- Monthly budget tracking per category with visual progress indicators.
- Beautiful, modern dashboard showing your liquid capital and recent financial activity.

### 📁 Data & Portability
- **CSV Export**: Export your transaction history for external analysis or reporting.
- **Production-Ready**: Clean seeding (zeroed balances) and custom app icons for an official look and feel.

## 🎨 Design Philosophy (Stitch UI)
Money Diary uses a high-end design system:
- **Palette**: Deep Emerald & Cyan accents in light mode; Slate & Charcoal in dark mode.
- **Typography**: Focused on readability with specialized font pairings like **Inter** or **Roboto**.
- **UX**: Gesture-driven interactions, micro-animations, and a highly responsive layout.

## 🛠️ Built With

- **Flutter**: Cross-platform mobile framework.
- **Drift (SQLite)**: Robust, reactive local database for offline-first performance.
- **Flutter Riverpod**: Modern state management for reactive UI updates.
- **Google Fonts**: Custom typography.
- **Shared Preferences**: Local settings and persistent user preferences.
- **Flutter Launcher Icons**: Custom branded icons for Android and iOS.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.x or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/[your-username]/money_diary.git
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run build_runner to generate database code:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## 🔐 Security (Upcoming Features)
- Biometric Login (FaceID / Fingerprint)
- Custom PIN Code Access
- Secure Google Drive Backup/Restore

---
*Developed with ❤️ for personal financial freedom.*
