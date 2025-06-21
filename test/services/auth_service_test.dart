import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return MockDocumentReference();
  }
}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {
  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {}
}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    authService = AuthService(auth: mockAuth, firestore: mockFirestore);
  });

  group('AuthService Tests', () {
    test('signInWithEmailOrUsername should return UserCredential on successful sign in with email', () async {
      // Arrange
      final mockUserCredential = MockUserCredential();
      when(mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await authService.signInWithEmailOrUsername('test@example.com', 'password123');

      // Assert
      expect(result, equals(mockUserCredential));
    });

    test('signInWithEmailOrUsername should throw error on invalid credentials', () async {
      // Arrange
      when(mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'wrongpassword',
      )).thenThrow(FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that email.',
      ));

      // Act & Assert
      expect(
        () => authService.signInWithEmailOrUsername('test@example.com', 'wrongpassword'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signInWithEmailOrUsername should return UserCredential on successful sign in with username', () async {
      // Arrange
      final mockUserCredential = MockUserCredential();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockCollectionReference = MockCollectionReference();
      final mockDocSnapshot = MockQueryDocumentSnapshot();
      
      when(mockFirestore.collection('pm')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('username', isEqualTo: 'testuser')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(mockDocSnapshot.data()).thenReturn({'email': 'test@example.com'});
      
      when(mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await authService.signInWithEmailOrUsername('testuser', 'password123');

      // Assert
      expect(result, equals(mockUserCredential));
    });

    test('signInWithEmailOrUsername should throw error when username not found', () async {
      // Arrange
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockCollectionReference = MockCollectionReference();
      
      when(mockFirestore.collection('pm')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('username', isEqualTo: 'nonexistentuser')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act & Assert
      expect(
        () => authService.signInWithEmailOrUsername('nonexistentuser', 'password123'),
        throwsA(isA<Exception>()),
      );
    });

    test('registerWithEmailAndPassword should return UserCredential on successful sign up', () async {
      // Arrange
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockCollectionReference = MockCollectionReference();

      when(mockAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);
      
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');
      
      when(mockFirestore.collection('pm')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('username', isEqualTo: 'testuser')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Act
      final result = await authService.registerWithEmailAndPassword(
        'test@example.com',
        'password123',
        'testuser',
      );

      // Assert
      expect(result, equals(mockUserCredential));
    });

    test('registerWithEmailAndPassword should throw error when email already in use', () async {
      // Arrange
      when(mockAuth.createUserWithEmailAndPassword(
        email: 'existing@example.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use by another account.',
      ));

      // Act & Assert
      expect(
        () => authService.registerWithEmailAndPassword(
          'existing@example.com',
          'password123',
          'testuser',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('registerWithEmailAndPassword should throw error when username already exists', () async {
      // Arrange
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockCollectionReference = MockCollectionReference();
      final mockDocSnapshot = MockQueryDocumentSnapshot();
      
      when(mockFirestore.collection('pm')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('username', isEqualTo: 'existinguser')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);

      // Act & Assert
      expect(
        () => authService.registerWithEmailAndPassword(
          'test@example.com',
          'password123',
          'existinguser',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('signOut should call Firebase signOut', () async {
      // Arrange
      when(mockAuth.signOut()).thenAnswer((_) async => null);

      // Act
      await authService.signOut();

      // Assert
      verify(mockAuth.signOut()).called(1);
    });

    test('getCurrentUser should return current user', () {
      // Arrange
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = authService.currentUser;

      // Assert
      expect(result, equals(mockUser));
    });

    test('getCurrentUser should return null when no user is logged in', () {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act
      final result = authService.currentUser;

      // Assert
      expect(result, isNull);
    });

    test('authStateChanges should return auth state changes stream', () {
      // Arrange
      final mockStream = Stream<User?>.empty();
      when(mockAuth.authStateChanges()).thenReturn(mockStream);

      // Act
      final result = authService.authStateChanges;

      // Assert
      expect(result, equals(mockStream));
    });

    test('resetPassword should call Firebase sendPasswordResetEmail', () async {
      // Arrange
      when(mockAuth.sendPasswordResetEmail(email: 'test@example.com'))
          .thenAnswer((_) async => null);

      // Act
      await authService.resetPassword('test@example.com');

      // Assert
      verify(mockAuth.sendPasswordResetEmail(email: 'test@example.com')).called(1);
    });

    test('resetPassword should throw error when email not found', () async {
      // Arrange
      when(mockAuth.sendPasswordResetEmail(email: 'nonexistent@example.com'))
          .thenThrow(FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that email.',
      ));

      // Act & Assert
      expect(
        () => authService.resetPassword('nonexistent@example.com'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
} 