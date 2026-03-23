# Money Diary 📔 ৳

**Money Diary** is a premium, modern personal finance manager built with Flutter. It helps you track your expenses, manage multiple accounts (Cash, Bank, bKash, Credit Cards), and stay on top of your budgets with a beautiful, user-centric interface inspired by modern fintech designs.

## ✨ Key Features

### 🏦 Multi-Account Management
- Track balances across **Cash**, **Bank**, **bKash**, and **Nagad**.
- Real-time balance updates whenever a transaction is recorded.
- Simple long-press gesture to rename any account or card.

### 💳 Comprehensive Credit Card Tracking
- Dedicated **Credit Card** section to track multiple cards (VISA, MasterCard, AMEX).
- Set and monitor your **Credit Limits**.
- Tracks **Outstanding Balance** vs. **Available Credit** in real-time.
- One-tap **Bill Payments** that seamlessly deduct from your debit accounts.

### 📝 Smart Transactions
- Record Income and Expenses with categorized logging.
- **Dynamic Detail Labels**: Automatically uses Category names as transaction titles if no specific detail is provided.
- View clear history logs for individual accounts or the entire wallet.

### 📊 Budgets & Analytics
- Monthly budget tracking per category.
- Visual progress bars to help you stay within your spending limits.
- Comprehensive Dashboard with net balance and recent activity.

### 📁 Data & Portability
- **CSV Export**: Export your transaction history for external analysis.
- **Clean Seeding**: Starts with zeroed-out accounts for a fresh setup experience.

## 🎨 Design Philosophy (Stitch UI)
Money Diary uses a high-end design system:
- **Palette**: Deep Emerald & Cyan accents for a financial vibe.
- **Typography**: Focused on readability with specialized font pairings.
- **UX**: Gesture-driven interactions and micro-animations for a premium feel.

## 🛠️ Built With

- **Flutter**: Cross-platform mobile framework.
- **Drift (SQLite)**: Robust, reactive local database for offline-first performance.
- **Flutter Riverpod**: Modern state management for reactive UI updates.
- **Google Fonts**: Custom typography.
- **Shared Preferences**: Local settings and user preferences.

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
