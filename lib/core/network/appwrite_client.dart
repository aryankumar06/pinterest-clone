import 'package:appwrite/appwrite.dart';

class Environment {
  static const String appwriteProjectId = '69ba9043002e0e6dc670';
  static const String appwriteProjectName = 'Appwrite Project1';
  static const String appwritePublicEndpoint = 'https://sgp.cloud.appwrite.io/v1';
}

final Client client = Client()
  .setProject("69ba9043002e0e6dc670")
  .setEndpoint("https://sgp.cloud.appwrite.io/v1");
