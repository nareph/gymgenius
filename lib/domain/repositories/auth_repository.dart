import 'package:gymgenius/domain/entities/user.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';

abstract interface class AuthRepository {
  Future<User?> getCurrentUser();
  Future<HealthProfile?> getCurrentHealthProfile();
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<bool> isProfileComplete(String userId);
  Stream<User?> watchUser();
}
