/// Response from Member/UpdateFamilyDetails.
/// iOS: UpdateFamilyResult (Obj-C) — status + message.
class UpdateFamilyResult {
  UpdateFamilyResult({this.status, this.message});

  final String? status;
  final String? message;

  bool get isSuccess => status == '0';

  factory UpdateFamilyResult.fromJson(Map<String, dynamic> json) {
    return UpdateFamilyResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
