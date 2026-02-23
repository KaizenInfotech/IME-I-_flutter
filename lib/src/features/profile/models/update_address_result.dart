/// Response from Member/UpdateAddressDetails.
/// iOS: UpdateAddressResult (Obj-C) — status + message.
class UpdateAddressResult {
  UpdateAddressResult({this.status, this.message});

  final String? status;
  final String? message;

  bool get isSuccess => status == '0';

  factory UpdateAddressResult.fromJson(Map<String, dynamic> json) {
    return UpdateAddressResult(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
