class SkinProfile {
    final String skinType;
    final Set<String> skinProblems;
    final Set<String> avoidIngredients;
    final Set<String> desiredEffects;
    final String? note;

    SkinProfile({
        required this.skinType,
        required this.skinProblems,
        required this.avoidIngredients,
        required this.desiredEffects,
        this.note,
    });

    // JSONからモデルを作成
    factory SkinProfile.fromJson(Map<String, dynamic> json) {
        return SkinProfile(
            skinType: json['skinType'] as String,
            skinProblems: Set<String>.from(json['skinProblems'] as List),
            avoidIngredients: Set<String>.from(json['avoidIngredients'] as List),
            desiredEffects: Set<String>.from(json['desiredEffects'] as List),
            note: json['note'] as String?,
        );
    }

    // モデルをJSONに変換
    Map<String, dynamic> toJson() {
        return {
            'skinType': skinType,
            'skinProblems': skinProblems.toList(),
            'avoidIngredients': avoidIngredients.toList(),
            'desiredEffects': desiredEffects.toList(),
            'note': note,
        };
    }
} 