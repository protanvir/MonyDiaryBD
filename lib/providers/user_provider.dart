import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class UserSettings {
  final String name;
  final String email;
  final String? pin;
  final bool useBiometrics;
  final String? profileImagePath;

  UserSettings({
    this.name = 'User',
    this.email = '',
    this.pin,
    this.useBiometrics = false,
    this.profileImagePath,
  });

  UserSettings copyWith({
    String? name,
    String? email,
    String? pin,
    bool? useBiometrics,
    String? profileImagePath,
    bool clearPin = false,
    bool clearImage = false,
  }) {
    return UserSettings(
      name: name ?? this.name,
      email: email ?? this.email,
      pin: clearPin ? null : (pin ?? this.pin),
      useBiometrics: useBiometrics ?? this.useBiometrics,
      profileImagePath: clearImage ? null : (profileImagePath ?? this.profileImagePath),
    );
  }
}

class UserSettingsNotifier extends Notifier<UserSettings> {
  late SharedPreferences _prefs;

  @override
  UserSettings build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return UserSettings(
      name: _prefs.getString('userName') ?? 'User',
      email: _prefs.getString('userEmail') ?? '',
      pin: _prefs.getString('userPin'),
      useBiometrics: _prefs.getBool('useBiometrics') ?? false,
      profileImagePath: _prefs.getString('profileImagePath'),
    );
  }

  Future<void> updateName(String name) async {
    await _prefs.setString('userName', name);
    state = state.copyWith(name: name);
  }

  Future<void> updateEmail(String email) async {
    await _prefs.setString('userEmail', email);
    state = state.copyWith(email: email);
  }

  Future<void> setPin(String pin) async {
    await _prefs.setString('userPin', pin);
    state = state.copyWith(pin: pin);
  }

  Future<void> clearPin() async {
    await _prefs.remove('userPin');
    state = state.copyWith(clearPin: true);
  }

  Future<void> setUseBiometrics(bool use) async {
    await _prefs.setBool('useBiometrics', use);
    state = state.copyWith(useBiometrics: use);
  }

  Future<void> setProfileImagePath(String path) async {
    await _prefs.setString('profileImagePath', path);
    state = state.copyWith(profileImagePath: path);
  }

  Future<void> clearProfileImage() async {
    await _prefs.remove('profileImagePath');
    state = state.copyWith(clearImage: true);
  }
  
  bool get hasSecurity => state.pin != null || state.useBiometrics;
}

final userSettingsProvider = NotifierProvider<UserSettingsNotifier, UserSettings>(() {
  return UserSettingsNotifier();
});
