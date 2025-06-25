class Assembly {
  final String assemblyName;
  final int parliamentId;
  final int assemblyId;
  final int regionalId;

  Assembly({
    required this.assemblyName,
    required this.parliamentId,
    required this.assemblyId,
    required this.regionalId,
  });

  // Convert JSON to Dart Object
  factory Assembly.fromJson(Map<String, dynamic> json) {
    return Assembly(
      assemblyName: json['assembly_name'],
      parliamentId: json['parliament_id'],
      assemblyId: json['assembly_id'],
      regionalId: json['regional_id'],
    );
  }

  // Convert Dart Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'assembly_name': assemblyName,
      'parliament_id': parliamentId,
      'assembly_id': assemblyId,
      'regional_id': regionalId,
    };
  }
}