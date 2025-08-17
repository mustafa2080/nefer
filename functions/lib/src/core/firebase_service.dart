import 'dart:io';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:logging/logging.dart';

/// Firebase service for initializing and managing Firebase Admin SDK
class FirebaseService {
  static final _logger = Logger('FirebaseService');
  static FirebaseAdminApp? _app;
  static bool _initialized = false;

  /// Initialize Firebase Admin SDK
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get service account key from environment or file
      final serviceAccountPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
      
      if (serviceAccountPath != null) {
        // Initialize with service account file
        _app = FirebaseAdminApp.initializeApp(
          'nefer-app',
          Credential.fromServiceAccountParams(
            clientId: Platform.environment['FIREBASE_CLIENT_ID']!,
            clientEmail: Platform.environment['FIREBASE_CLIENT_EMAIL']!,
            privateKey: Platform.environment['FIREBASE_PRIVATE_KEY']!,
            privateKeyId: Platform.environment['FIREBASE_PRIVATE_KEY_ID']!,
          ),
          databaseURL: Platform.environment['FIREBASE_DATABASE_URL'],
          projectId: Platform.environment['FIREBASE_PROJECT_ID'],
        );
      } else {
        // Initialize with default credentials (for Cloud Functions environment)
        _app = FirebaseAdminApp.initializeApp(
          'nefer-app',
          Credential.applicationDefault(),
          databaseURL: Platform.environment['FIREBASE_DATABASE_URL'],
          projectId: Platform.environment['FIREBASE_PROJECT_ID'],
        );
      }

      _initialized = true;
      _logger.info('Firebase Admin SDK initialized successfully');
    } catch (error, stackTrace) {
      _logger.severe('Failed to initialize Firebase Admin SDK: $error', error, stackTrace);
      rethrow;
    }
  }

  /// Get Firebase app instance
  static FirebaseAdminApp get app {
    if (!_initialized || _app == null) {
      throw StateError('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _app!;
  }

  /// Get Auth service
  static Auth get auth => app.auth();

  /// Get Realtime Database service
  static Database get database => app.database();

  /// Get Firestore service
  static Firestore get firestore => app.firestore();

  /// Get Storage service
  static Storage get storage => app.storage();

  /// Get Messaging service
  static Messaging get messaging => app.messaging();

  /// Verify ID token
  static Future<DecodedIdToken> verifyIdToken(String idToken) async {
    try {
      return await auth.verifyIdToken(idToken);
    } catch (error) {
      _logger.warning('Failed to verify ID token: $error');
      rethrow;
    }
  }

  /// Get user by UID
  static Future<UserRecord> getUser(String uid) async {
    try {
      return await auth.getUser(uid);
    } catch (error) {
      _logger.warning('Failed to get user $uid: $error');
      rethrow;
    }
  }

  /// Create custom token
  static Future<String> createCustomToken(String uid, [Map<String, dynamic>? claims]) async {
    try {
      return await auth.createCustomToken(uid, claims);
    } catch (error) {
      _logger.warning('Failed to create custom token for $uid: $error');
      rethrow;
    }
  }

  /// Set custom user claims
  static Future<void> setCustomUserClaims(String uid, Map<String, dynamic> claims) async {
    try {
      await auth.setCustomUserClaims(uid, claims);
      _logger.info('Custom claims set for user $uid');
    } catch (error) {
      _logger.warning('Failed to set custom claims for $uid: $error');
      rethrow;
    }
  }

  /// Delete user
  static Future<void> deleteUser(String uid) async {
    try {
      await auth.deleteUser(uid);
      _logger.info('User $uid deleted successfully');
    } catch (error) {
      _logger.warning('Failed to delete user $uid: $error');
      rethrow;
    }
  }

  /// Update user
  static Future<UserRecord> updateUser(String uid, UpdateRequest updateRequest) async {
    try {
      final updatedUser = await auth.updateUser(uid, updateRequest);
      _logger.info('User $uid updated successfully');
      return updatedUser;
    } catch (error) {
      _logger.warning('Failed to update user $uid: $error');
      rethrow;
    }
  }

  /// List users
  static Future<ListUsersResult> listUsers({int maxResults = 1000, String? pageToken}) async {
    try {
      return await auth.listUsers(maxResults: maxResults, pageToken: pageToken);
    } catch (error) {
      _logger.warning('Failed to list users: $error');
      rethrow;
    }
  }

  /// Send notification
  static Future<String> sendNotification(Message message) async {
    try {
      final messageId = await messaging.send(message);
      _logger.info('Notification sent successfully: $messageId');
      return messageId;
    } catch (error) {
      _logger.warning('Failed to send notification: $error');
      rethrow;
    }
  }

  /// Send multicast notification
  static Future<BatchResponse> sendMulticastNotification(MulticastMessage message) async {
    try {
      final response = await messaging.sendMulticast(message);
      _logger.info('Multicast notification sent: ${response.successCount} successful, ${response.failureCount} failed');
      return response;
    } catch (error) {
      _logger.warning('Failed to send multicast notification: $error');
      rethrow;
    }
  }

  /// Get database reference
  static DatabaseReference getDatabaseRef([String? path]) {
    return database.ref(path);
  }

  /// Get Firestore collection
  static CollectionReference getFirestoreCollection(String collectionPath) {
    return firestore.collection(collectionPath);
  }

  /// Get Firestore document
  static DocumentReference getFirestoreDocument(String documentPath) {
    return firestore.doc(documentPath);
  }

  /// Server timestamp for Realtime Database
  static Map<String, String> get serverTimestamp => ServerValue.timestamp;

  /// Server timestamp for Firestore
  static FieldValue get firestoreTimestamp => FieldValue.serverTimestamp();

  /// Increment value for Realtime Database
  static Map<String, dynamic> increment(num value) => ServerValue.increment(value);

  /// Increment value for Firestore
  static FieldValue firestoreIncrement(num value) => FieldValue.increment(value);

  /// Array union for Firestore
  static FieldValue arrayUnion(List<dynamic> elements) => FieldValue.arrayUnion(elements);

  /// Array remove for Firestore
  static FieldValue arrayRemove(List<dynamic> elements) => FieldValue.arrayRemove(elements);

  /// Delete field for Firestore
  static FieldValue get deleteField => FieldValue.delete();

  /// Cleanup resources
  static Future<void> cleanup() async {
    if (_app != null) {
      await _app!.delete();
      _app = null;
      _initialized = false;
      _logger.info('Firebase Admin SDK cleaned up');
    }
  }
}

/// Extension methods for easier database operations
extension DatabaseReferenceExtensions on DatabaseReference {
  /// Set data with server timestamp
  Future<void> setWithTimestamp(Map<String, dynamic> data) async {
    data['createdAt'] = FirebaseService.serverTimestamp;
    data['updatedAt'] = FirebaseService.serverTimestamp;
    return set(data);
  }

  /// Update data with server timestamp
  Future<void> updateWithTimestamp(Map<String, dynamic> data) async {
    data['updatedAt'] = FirebaseService.serverTimestamp;
    return update(data);
  }

  /// Push data with server timestamp
  Future<DatabaseReference> pushWithTimestamp(Map<String, dynamic> data) async {
    data['createdAt'] = FirebaseService.serverTimestamp;
    data['updatedAt'] = FirebaseService.serverTimestamp;
    return push(data);
  }
}

/// Extension methods for easier Firestore operations
extension DocumentReferenceExtensions on DocumentReference {
  /// Set data with server timestamp
  Future<void> setWithTimestamp(Map<String, dynamic> data, [SetOptions? options]) async {
    data['createdAt'] = FirebaseService.firestoreTimestamp;
    data['updatedAt'] = FirebaseService.firestoreTimestamp;
    return set(data, options);
  }

  /// Update data with server timestamp
  Future<void> updateWithTimestamp(Map<String, dynamic> data) async {
    data['updatedAt'] = FirebaseService.firestoreTimestamp;
    return update(data);
  }
}
