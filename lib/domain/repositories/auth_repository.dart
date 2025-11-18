import 'package:lotto_vision/core/utils/typedefs.dart';
import 'package:lotto_vision/domain/entities/user.dart';

abstract class AuthRepository {
  ResultFuture<User> signInAnonymously();
  ResultFuture<User> signInWithEmail(String email, String password);
  ResultFuture<User> signUpWithEmail(String email, String password);
  ResultFuture<User?> getCurrentUser();
  ResultVoid signOut();
  Stream<User?> get authStateChanges;
}
