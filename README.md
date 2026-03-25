# Money Diary 📔 ৳

**Money Diary** is a premium, production-ready personal finance manager built with Flutter. It helps you track your expenses, manage multiple accounts (Cash, Bank, bKash, Nagad, Credit Cards), and stay on top of your budgets with a beautiful, user-centric interface.

---

## ✨ Key Features

### 🔐 Security & Privacy
- **Biometric Authentication**: Secure your financial data with Fingerprint or FaceID (powered by `local_auth`).
- **Custom PIN Access**: A secondary layer of protection using a secure PIN code.
- **Privacy Mode**: Sensitive balances and transaction details can be hidden from prying eyes.

### 🌓 Premium Design System
- **Full Dark & Light Modes**: Seamless toggling with persistent user preference storage.
- **Modern Fintech UI**: High-end visuals using **Inter** typography and a tailored Slate/Cyan palette.
- **Micro-animations**: Smooth transitions and interactive elements for a premium user experience.

### 🏦 Advanced Financial Tracking
- **Multi-Account Support**: Track Cash, Banks, **bKash**, **Nagad**, and more.
- **Credit Card Management**: Separate tracking for Liabilities and Credit Limits.
- **Net Worth Monitoring**: Real-time summary of total Assets vs. total Liabilities.
- **Smart Bill Payments**: Unified flow for paying card bills from other asset accounts.

### ☁️ Cloud Sync & Data Portability
- **Google Drive Backup**: Secure, private backups stored in your personal `appDataFolder` scope.
- **Automatic Restore**: Seamlessly recover your financial history on a new device.
- **CSV Export**: Export your transaction logs for external analysis or reporting.

### 📝 Smart Budgeting
- Monthly category-based budgeting with visual progress indicators.
- Automatic transaction categorization and real-time balance updates.

---

## 🛠️ Technical Stack

- **Framework**: [Flutter](https://flutter.dev) (iOS/Android)
- **Database**: [Drift](https://drift.simonbinder.eu/) (Reactive SQLite)
- **State Management**: [Riverpod](https://riverpod.dev)
- **Cloud API**: [Google APIs](https://pub.dev/packages/googleapis) (v3 Drive API)
- **Security**: [Local Auth](https://pub.dev/packages/local_auth)
- **Analytics**: [FL Chart](https://pub.dev/packages/fl_chart)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.11.0 or higher)
- Android SDK (v36 recommended for latest plugin support)

### Installation & Build

1. **Clone & Dependencies**:
   ```bash
   git clone https://github.com/[your-username]/money_diary.git
   flutter pub get
   ```

2. **Generate Database Code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Release Build (Production-Ready)**:
   ```bash
   # Generate Signed APK
   flutter build apk --release
   
   # Generate Signed AAB (for Play Store)
   flutter build appbundle --release
   ```

---

## 👨‍💻 Developer Information
- **Developed by**: Tanvir Ahmed
- **Email**: `protanvir@gmail.com`
- **Web**: [protanvir.me](https://protanvir.me)
- **Copyright**: PROTANVIR LABS 2026

---
*Empowering your financial freedom, one transaction at a time.*
