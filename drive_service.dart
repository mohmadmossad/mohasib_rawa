import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class DriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[drive.DriveApi.driveFileScope, drive.DriveApi.driveAppdataScope],
  );

  GoogleSignInAccount? _currentUser;

  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null;
    } catch (e) {
      print('Google sign-in error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  Future<drive.File?> uploadFile(File file, {String? folderId}) async {
    if (_currentUser == null) await signIn();
    final authHeaders = await _currentUser!.authHeaders;
    final client = GoogleHttpClient(authHeaders);
    final driveApi = drive.DriveApi(client);
    final media = drive.Media(file.openRead(), await file.length());
    final driveFile = drive.File()..name = file.path.split('/').last;
    if (folderId != null) driveFile.parents = [folderId];
    final result = await driveApi.files.create(driveFile, uploadMedia: media);
    return result;
  }
}

class GoogleHttpClient extends IOClient {
  final Map<String, String> _headers;
  GoogleHttpClient(this._headers) : super();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return super.send(request);
  }
}