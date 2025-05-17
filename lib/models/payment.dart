import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  @JsonKey(name: 'current_payment_ref')
  final String? currentPaymentRef; // Corresponds to CurrentPaymentRef in backend
  @JsonKey(name: 'payment_successful')
  final bool? paymentSuccessful; // Corresponds to PaymentSuccessful in backend
  @JsonKey(name: 'failed_payment_ref')
  final List<String>? failedPaymentRef; // Corresponds to FailedPaymentRef in backend

  Payment({
    this.currentPaymentRef,
    this.paymentSuccessful,
    this.failedPaymentRef,
  });

  // Factory constructor to create a Payment object from a JSON map
  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  // Method to convert a Payment object to a JSON map
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
