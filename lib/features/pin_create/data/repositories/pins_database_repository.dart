import 'package:appwrite/appwrite.dart';
import '../../../../core/network/appwrite_client.dart';
import '../../../home/domain/entities/pin.dart';

class PinsDatabaseRepository {
  final Databases _databases;

  PinsDatabaseRepository() : _databases = Databases(client);

  Future<void> createPinRecord({
    required String title,
    required String description,
    required String imageUrl,
    required String author,
    required String authorAvatar,
  }) async {
    try {
      await _databases.createDocument(
        databaseId: '69baaf87000280b3d9e7', // pin-create DB
        collectionId: '69baaf87000280b3d9e7', // pin-create collection
        documentId: ID.unique(),
        data: {
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'author': author,
          'authorAvatar': authorAvatar,
          'category': 'General',
          'aspectRatio': 1.0,
          'isVideo': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      print('Appwrite Database Error: $e');
      rethrow;
    }
  }

  Future<List<Pin>> getCreatedPins() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: '69baaf87000280b3d9e7',
        collectionId: '69baaf87000280b3d9e7',
        queries: [Query.orderDesc('createdAt')],
      );

      return response.documents.map((doc) {
        return Pin(
          id: doc.$id,
          title: doc.data['title'] ?? '',
          description: doc.data['description'] ?? '',
          imageUrl: doc.data['imageUrl'] ?? '',
          author: doc.data['author'] ?? 'Unknown',
          authorAvatar: doc.data['authorAvatar'] ?? '',
          category: doc.data['category'] ?? 'General',
          aspectRatio: (doc.data['aspectRatio'] ?? 1.0).toDouble(),
          isVideo: doc.data['isVideo'] ?? false,
        );
      }).toList();
    } catch (e) {
      print('Appwrite Fetch Error: $e');
      return [];
    }
  }
}
