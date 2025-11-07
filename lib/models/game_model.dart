class GameModel {
  final String name;
  final String image;
  final String playstoreUrl;
  final String appstoreUrl;

  GameModel({
    required this.name,
    required this.image,
    required this.playstoreUrl,
    required this.appstoreUrl,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      name: json['name'] as String,
      image: json['image'] as String,
      playstoreUrl: json['playstore_url'] as String,
      appstoreUrl: json['appstore_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'playstore_url': playstoreUrl,
      'appstore_url': appstoreUrl,
    };
  }
}

