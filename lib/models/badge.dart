class Badge {
  const Badge({
    required this.id,
    required this.nameAr,
    required this.descriptionAr,
    required this.iconKey,
    required this.conditionType,
    required this.conditionValue,
  });

  final String id;
  final String nameAr;
  final String descriptionAr;
  final String iconKey;
  final String conditionType;
  final int conditionValue;
}
