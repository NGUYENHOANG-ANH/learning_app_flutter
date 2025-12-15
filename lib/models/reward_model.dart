class Reward {
  final String id;
  final String name;
  final String description;
  final int requiredStars;
  final String icon; // Emoji icon
  final String rarity; // 'common', 'rare', 'legendary'

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredStars,
    required this.icon,
    required this.rarity,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      requiredStars: json['requiredStars'] as int,
      icon: json['icon'] as String,
      rarity: json['rarity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'requiredStars': requiredStars,
      'icon': icon,
      'rarity': rarity,
    };
  }
}
