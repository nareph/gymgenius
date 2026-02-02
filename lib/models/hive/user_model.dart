// lib/models/hive/user_model.dart
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String uid;

  @HiveField(1)
  String email;

  @HiveField(2)
  String? displayName;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  Map<String, dynamic>? onboardingData;

  @HiveField(5)
  bool onboardingCompleted;

  @HiveField(6)
  DateTime? profileLastUpdatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
    this.onboardingData,
    this.onboardingCompleted = false,
    this.profileLastUpdatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'onboardingData': onboardingData,
      'onboardingCompleted': onboardingCompleted,
      'profileLastUpdatedAt': profileLastUpdatedAt?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      onboardingData: map['onboardingData'] as Map<String, dynamic>?,
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      profileLastUpdatedAt: map['profileLastUpdatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['profileLastUpdatedAt'] as int)
          : null,
    );
  }
}

