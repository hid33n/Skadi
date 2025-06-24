import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:stock/services/user_service.dart';
import 'package:stock/models/user_profile.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserService userService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    userService = UserService(fakeFirestore);
  });

  group('UserService Tests', () {
    test('createUser creates a new user', () async {
      // Arrange
      final user = UserProfile(
        id: '',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.employee,
        isActive: true,
        permissions: ['read', 'write'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final userId = await userService.createUser(user);

      // Assert
      expect(userId, isNotEmpty);
      final createdUser = await fakeFirestore.collection('pm').doc(userId).get();
      expect(createdUser.exists, isTrue);
      expect(createdUser.data()!['email'], 'test@example.com');
    });

    test('getUser returns user when exists', () async {
      // Arrange
      final user = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.employee,
        isActive: true,
        permissions: ['read', 'write'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('test-id').set(user.toMap());

      // Act
      final result = await userService.getUser('test-id');

      // Assert
      expect(result, isNotNull);
      expect(result!.email, 'test@example.com');
      expect(result.fullName, 'Test User');
    });

    test('getUser returns null when user does not exist', () async {
      // Act
      final result = await userService.getUser('non-existent');

      // Assert
      expect(result, isNull);
    });

    test('getUserByEmail returns user when exists', () async {
      // Arrange
      final user = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.employee,
        isActive: true,
        permissions: ['read', 'write'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('test-id').set(user.toMap());

      // Act
      final result = await userService.getUserByEmail('test@example.com');

      // Assert
      expect(result, isNotNull);
      expect(result!.email, 'test@example.com');
      expect(result.fullName, 'Test User');
    });

    test('getUserByEmail returns null when user does not exist', () async {
      // Act
      final result = await userService.getUserByEmail('nonexistent@example.com');

      // Assert
      expect(result, isNull);
    });

    test('updateUser updates existing user', () async {
      // Arrange
      final originalUser = UserProfile(
        id: 'test-id',
        email: 'original@example.com',
        firstName: 'Original',
        lastName: 'User',
        role: UserRole.employee,
        isActive: true,
        permissions: ['read'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('test-id').set(originalUser.toMap());

      final updatedUser = UserProfile(
        id: 'test-id',
        email: 'updated@example.com',
        firstName: 'Updated',
        lastName: 'User',
        role: UserRole.admin,
        isActive: true,
        permissions: ['read', 'write', 'admin'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await userService.updateUser('test-id', updatedUser);

      // Assert
      final doc = await fakeFirestore.collection('pm').doc('test-id').get();
      expect(doc.data()!['email'], 'updated@example.com');
      expect(doc.data()!['firstName'], 'Updated');
    });

    test('deleteUser deletes existing user', () async {
      // Arrange
      final user = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.employee,
        isActive: true,
        permissions: ['read', 'write'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('test-id').set(user.toMap());

      // Act
      await userService.deleteUser('test-id');

      // Assert
      final doc = await fakeFirestore.collection('pm').doc('test-id').get();
      expect(doc.exists, isFalse);
    });

    test('getAllUsers returns all users', () async {
      // Arrange
      final user1 = UserProfile(
        id: '1',
        email: 'user1@example.com',
        firstName: 'User',
        lastName: 'One',
        role: UserRole.employee,
        isActive: true,
        permissions: ['read'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final user2 = UserProfile(
        id: '2',
        email: 'user2@example.com',
        firstName: 'User',
        lastName: 'Two',
        role: UserRole.admin,
        isActive: true,
        permissions: ['read', 'write'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('1').set(user1.toMap());
      await fakeFirestore.collection('pm').doc('2').set(user2.toMap());

      // Act
      final users = await userService.getAllUsers();

      // Assert
      expect(users.length, 2);
      expect(users[0].email, 'user1@example.com');
      expect(users[1].email, 'user2@example.com');
    });

    test('activateUser activates user', () async {
      // Arrange
      final user = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.employee,
        isActive: false,
        permissions: ['read'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('test-id').set(user.toMap());

      // Act
      await userService.activateUser('test-id');

      // Assert
      final doc = await fakeFirestore.collection('pm').doc('test-id').get();
      expect(doc.data()!['isActive'], isTrue);
    });

    test('suspendUser suspends user', () async {
      // Arrange
      final user = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.employee,
        isActive: true,
        permissions: ['read'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('test-id').set(user.toMap());

      // Act
      await userService.suspendUser('test-id');

      // Assert
      final doc = await fakeFirestore.collection('pm').doc('test-id').get();
      expect(doc.data()!['isActive'], isFalse);
    });

    test('updateLastLogin updates user timestamp', () async {
      // Arrange
      final user = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.employee,
        isActive: true,
        permissions: ['read'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('test-id').set(user.toMap());

      // Act
      await userService.updateLastLogin('test-id');

      // Assert
      final doc = await fakeFirestore.collection('pm').doc('test-id').get();
      expect(doc.data()!.containsKey('updatedAt'), isTrue);
    });

    test('hasPermission returns true for user with permission', () async {
      // Arrange
      final user = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.employee,
        isActive: true,
        permissions: ['read', 'write'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('test-id').set(user.toMap());

      // Act
      final hasPermission = await userService.hasPermission('test-id', 'write');

      // Assert
      expect(hasPermission, isTrue);
    });

    test('hasPermission returns false for user without permission', () async {
      // Arrange
      final user = UserProfile(
        id: 'test-id',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: UserRole.employee,
        isActive: true,
        permissions: ['read'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('test-id').set(user.toMap());

      // Act
      final hasPermission = await userService.hasPermission('test-id', 'admin');

      // Assert
      expect(hasPermission, isFalse);
    });

    test('hasPermission returns true for admin user', () async {
      // Arrange
      final user = UserProfile(
        id: 'test-id',
        email: 'admin@example.com',
        firstName: 'Admin',
        lastName: 'User',
        role: UserRole.admin,
        isActive: true,
        permissions: ['read'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('test-id').set(user.toMap());

      // Act
      final hasPermission = await userService.hasPermission('test-id', 'any-permission');

      // Assert
      expect(hasPermission, isTrue);
    });

    test('getUserStats returns correct statistics', () async {
      // Arrange
      final user1 = UserProfile(
        id: '1',
        email: 'owner@example.com',
        firstName: 'Owner',
        lastName: 'User',
        role: UserRole.owner,
        isActive: true,
        permissions: ['all'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final user2 = UserProfile(
        id: '2',
        email: 'admin@example.com',
        firstName: 'Admin',
        lastName: 'User',
        role: UserRole.admin,
        isActive: true,
        permissions: ['read', 'write'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final user3 = UserProfile(
        id: '3',
        email: 'employee@example.com',
        firstName: 'Employee',
        lastName: 'User',
        role: UserRole.employee,
        isActive: false,
        permissions: ['read'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await fakeFirestore.collection('pm').doc('1').set(user1.toMap());
      await fakeFirestore.collection('pm').doc('2').set(user2.toMap());
      await fakeFirestore.collection('pm').doc('3').set(user3.toMap());

      // Act
      final stats = await userService.getUserStats();

      // Assert
      expect(stats['total'], 3);
      expect(stats['active'], 2);
      expect(stats['inactive'], 1);
      expect(stats['owners'], 1);
      expect(stats['admins'], 1);
      expect(stats['employees'], 1);
    });

    test('handles errors gracefully', () async {
      // Arrange - Crear un servicio con un userId inválido
      final invalidUserService = UserService(fakeFirestore);

      // Act & Assert
      final result = await invalidUserService.getUser('');
      expect(result, isNull);
    });
  });
} 