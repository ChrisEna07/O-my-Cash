import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._();
  factory SecurityService() => _instance;
  SecurityService._();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  static const String _dbKeyName = 'omycash_db_encryption_key';

  /// Verifies if biometric hardware is available
  Future<bool> canCheckBiometrics() async {
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  }

  /// Authenticates the user using biometrics or device PIN/Passcode
  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Accede a tus finanzas de forma segura',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Permite PIN/Patrón si la biometría falla
        ),
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Gets or generates the database encryption key
  Future<String> getEncryptionKey() async {
    String? key = await _storage.read(key: _dbKeyName);
    
    if (key == null) {
      // Generate a new high-entropy key if it doesn't exist
      key = _uuid.v4() + _uuid.v4(); 
      await _storage.write(key: _dbKeyName, value: key);
    }
    
    return key;
  }
}
