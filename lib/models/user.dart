class User {
  final String userId;
  final String username;
  final String name;
  final String? photoUrl;
  final List<String> followers;
  final List<String> followings;
  final List<String> blockUsers;
  final String profile;
  final String token;

  User({
    required this.userId,
    required this.username,
    required this.name,
    required this.photoUrl,
    required this.followers,
    required this.followings,
    required this.blockUsers,
    required this.profile,
    required this.token,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map["userId"],
      username: map["username"],
      name: map["name"],
      photoUrl: map["photoUrl"],
      followers: List<String>.from(map["followers"]),
      followings: List<String>.from(map["followings"]),
      blockUsers: List<String>.from(map["blockUsers"]),
      profile: map["profile"],
      token: map["token"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "username": username,
      "name": name,
      "photoUrl": photoUrl,
      "followers": followers,
      "followings": followings,
      "blockUsers": blockUsers,
      "profile": profile,
      "token": token,
    };
  }
}
