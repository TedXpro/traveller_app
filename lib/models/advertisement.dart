class Advertisement {
  final String title;
  final String imageUrl;
  // final String agencyID;

  Advertisement({
    required this.title,
    required this.imageUrl,
    // required this.agencyID,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      title: json['title'] as String,
      imageUrl: json['media_url'] as String,
      // agencyID: json['agency_id'] as String,
    );
  }
}
