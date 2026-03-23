import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

final backupServiceProvider = Provider((ref) => BackupService());

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class BackupService {
  // final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn(
  //   scopes: [
  //     drive.DriveApi.driveAppdataScope, 
  //   ],
  // );

  Future<drive.DriveApi?> _getDriveApi() async {
    // TODO: USER must configure google_sign_in OAuth Client ID in cloud console.
    throw Exception('Google Sign In is mocked. Please configure OAuth Client ID and uncomment GoogleSignIn in BackupService.');
    
    // final account = await _googleSignIn.signIn();
    // if (account == null) return null;
    
    // final authHeaders = await account.authHeaders;
    // final client = GoogleAuthClient(authHeaders);
    // return drive.DriveApi(client);
  }

  Future<void> backupDatabase() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) throw Exception('Google Sign In failed');

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    if (!await file.exists()) throw Exception('DB file not found locally');

    final driveFile = drive.File()
      ..name = 'khorochpati_backup.sqlite'
      ..parents = ['appDataFolder'];

    final length = await file.length();
    final media = drive.Media(file.openRead(), length);

    // Delete existing backup first to overwrite
    final fileList = await driveApi.files.list(spaces: 'appDataFolder');
    final existingFile = fileList.files?.where((f) => f.name == 'khorochpati_backup.sqlite').firstOrNull;
    if (existingFile != null && existingFile.id != null) {
      await driveApi.files.delete(existingFile.id!);
    }

    await driveApi.files.create(driveFile, uploadMedia: media);
  }

  Future<void> restoreDatabase() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) throw Exception('Google Sign In failed');

    final fileList = await driveApi.files.list(spaces: 'appDataFolder');
    final existingFile = fileList.files?.where((f) => f.name == 'khorochpati_backup.sqlite').firstOrNull;
    
    if (existingFile == null || existingFile.id == null) {
      throw Exception('No backup found in Google Drive');
    }

    final media = await driveApi.files.get(existingFile.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    if (await file.exists()) {
       await file.delete(); // Delete local db file
    }
    
    final sink = file.openWrite();
    await media.stream.forEach((chunk) => sink.add(chunk));
    await sink.flush();
    await sink.close();
  }
}
