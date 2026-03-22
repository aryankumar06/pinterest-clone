import 'dart:io';
import 'package:appwrite/appwrite.dart';
import '../../../../core/network/appwrite_client.dart';

class StorageRepository {
  final Storage _storage;

  StorageRepository() : _storage = Storage(client);

  Future<String?> uploadImage(File file) async {
    try {
      final response = await _storage.createFile(
        bucketId: '69baa80c001f33352f7e', // Updated Bucket ID
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path),
      );

      // Construct public URL for the file
      // URL: endpoint + /storage/buckets/{bucketId}/files/{fileId}/view?project={projectId}
      return '${Environment.appwritePublicEndpoint}/storage/buckets/69baa80c001f33352f7e/files/${response.$id}/view?project=${Environment.appwriteProjectId}';
    } catch (e) {
      print('Appwrite Storage Error: $e');
      return null;
    }
  }
}
