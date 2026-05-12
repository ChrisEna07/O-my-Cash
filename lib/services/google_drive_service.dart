import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  static final GoogleDriveService _instance = GoogleDriveService._();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '573825219942-8leh412jei2qlg034g86l6a2uha7hob6.apps.googleusercontent.com',
    scopes: [
      drive.DriveApi.driveAppdataScope,
    ],
  );

  GoogleSignInAccount? _currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (error) {
      return null;
    }
  }

  Future<void> signOut() => _googleSignIn.disconnect();

  Future<bool> isLoggedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<drive.DriveApi?> _getDriveApi() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

  Future<bool> uploadBackup(String jsonContent) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return false;

    final List<int> content = utf8.encode(jsonContent);
    final Stream<List<int>> mediaStream = Stream.value(content);
    final media = drive.Media(mediaStream, content.length);

    try {
      // Buscar si ya existe un archivo de respaldo
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'omycash_backup.json'",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Actualizar existente
        final fileId = fileList.files!.first.id!;
        await driveApi.files.update(
          drive.File(),
          fileId,
          uploadMedia: media,
        );
      } else {
        // Crear nuevo
        final driveFile = drive.File()
          ..name = 'omycash_backup.json'
          ..parents = ['appDataFolder'];
        await driveApi.files.create(
          driveFile,
          uploadMedia: media,
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> downloadBackup() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return null;

    try {
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = 'omycash_backup.json'",
      );

      if (fileList.files == null || fileList.files!.isEmpty) return null;

      final fileId = fileList.files!.first.id!;
      final drive.Media response = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.metadata,
      ) as drive.Media; // Esto a veces falla en tipado, se usa get con downloadOptions

      // Para descargar contenido real:
      final drive.Media media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> data = [];
      await for (final chunk in media.stream) {
        data.addAll(chunk);
      }

      return utf8.decode(data);
    } catch (e) {
      return null;
    }
  }
}
