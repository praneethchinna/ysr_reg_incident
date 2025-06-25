class ProfileResponseModel {
  int userId;
  String name;
  String gender;
  String country;
  String state;
  String parliament;
  String constituency;
  String mobile;
  String email;
  String referralCode;

  ProfileResponseModel({
    required this.userId,
    required this.name,
    required this.gender,
    required this.country,
    required this.state,
    required this.parliament,
    required this.constituency,
    required this.mobile,
    required this.email,
    required this.referralCode,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      userId: json['user_id'],
      name: json['name'],
      gender: json['gender'],
      country: json['country'],
      state: json['state'],
      parliament: json['parliament'],
      constituency: json['constituency'],
      mobile: json['mobile'],
      email: json['email'],
      referralCode: json['referral_code'] ?? "",
    );
  }
}
