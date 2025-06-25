class Parliament {
  final String parliamentName;
  final int regionalId;
  final int parliamentId;

  Parliament({
    required this.parliamentName,
    required this.regionalId,
    required this.parliamentId,
  });

  // Convert JSON to Dart Object
  factory Parliament.fromJson(Map<String, dynamic> json) {
    return Parliament(
      parliamentName: json['parliament_name'],
      regionalId: json['regional_id'],
      parliamentId: json['parliament_id'],
    );
  }

  // Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'parliament_name': parliamentName,
      'regional_id': regionalId,
      'parliament_id': parliamentId,
    };
  }
}