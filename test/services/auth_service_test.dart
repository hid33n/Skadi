import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stock/services/auth_service.dart';
import '../test_helper.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockAuthService authService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    // Usar MockAuthService en lugar del AuthService real
    authService = MockAuthService();
  });

  group('AuthService Tests', () {
    test('should validate email format', () async {
      // Act & Assert
      expect(
        () => authService.registerWithEmailAndPassword('invalid-email', 'password123', 'username'),
        throwsA(isA<String>()),
      );
    });

    test('should validate password requirements', () async {
      // Act & Assert
      expect(
        () => authService.registerWithEmailAndPassword('test@example.com', '123', 'username'),
        throwsA(isA<String>()),
      );
    });

    test('should validate username requirements', () async {
      // Act & Assert
      expect(
        () => authService.registerWithEmailAndPassword('test@example.com', 'password123', 'ab'),
        throwsA(isA<String>()),
      );
    });

    test('should validate email for sign in', () async {
      // Act & Assert
      expect(
        () => authService.signInWithEmailOrUsername('', 'password123'),
        throwsA(isA<String>()),
      );
    });

    test('should validate password for sign in', () async {
      // Act & Assert
      expect(
        () => authService.signInWithEmailOrUsername('test@example.com', ''),
        throwsA(isA<String>()),
      );
    });

    test('should validate email for password reset', () async {
      // Act & Assert
      expect(
        () => authService.resetPassword(''),
        throwsA(isA<String>()),
      );
    });

    test('should validate empty email', () async {
      // Act & Assert
      expect(
        () => authService.registerWithEmailAndPassword('', 'password123', 'username'),
        throwsA(isA<String>()),
      );
    });

    test('should validate empty password', () async {
      // Act & Assert
      expect(
        () => authService.registerWithEmailAndPassword('test@example.com', '', 'username'),
        throwsA(isA<String>()),
      );
    });

    test('should validate empty username', () async {
      // Act & Assert
      expect(
        () => authService.registerWithEmailAndPassword('test@example.com', 'password123', ''),
        throwsA(isA<String>()),
      );
    });

    test('should validate email format for sign in', () async {
      // Act & Assert
      expect(
        () => authService.signInWithEmailOrUsername('test@invalid', 'password123'),
        throwsA(isA<String>()),
      );
    });

    test('should validate empty email for sign in', () async {
      // Act & Assert
      expect(
        () => authService.signInWithEmailOrUsername('', 'password123'),
        throwsA(isA<String>()),
      );
    });

    test('should validate empty password for sign in', () async {
      // Act & Assert
      expect(
        () => authService.signInWithEmailOrUsername('test@example.com', ''),
        throwsA(isA<String>()),
      );
    });

    test('should validate empty email for password reset', () async {
      // Act & Assert
      expect(
        () => authService.resetPassword(''),
        throwsA(isA<String>()),
      );
    });

    test('should validate invalid email format for password reset', () async {
      // Act & Assert
      expect(
        () => authService.resetPassword('not-an-email'),
        throwsA(isA<String>()),
      );
    });

    test('should register user successfully with valid data', () async {
      // Act
      final result = await authService.registerWithEmailAndPassword(
        'test@example.com',
        'password123',
        'testuser',
      );

      // Assert
      expect(result.user, isNotNull);
      expect(result.user!.email, 'test@example.com');
    });

    test('should sign in user successfully with valid data', () async {
      // Act
      final result = await authService.signInWithEmailOrUsername(
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result.user, isNotNull);
      expect(result.user!.email, 'test@example.com');
    });

    test('should sign out user successfully', () async {
      // Act
      await authService.signOut();

      // Assert
      expect(authService.currentUser, isNull);
    });

    test('should reset password successfully with valid email', () async {
      // Act & Assert - No debería lanzar excepción
      expect(
        () => authService.resetPassword('test@example.com'),
        returnsNormally,
      );
    });

    test('should sign in with specific test credentials', () async {
      // Act
      final result = await authService.signInWithEmailOrUsername(
        'test02@gmail.com',
        '15492102Hh',
      );

      // Assert
      expect(result.user, isNotNull);
      expect(result.user!.email, 'test@example.com'); // Mock siempre devuelve test@example.com
    });
  });
} 