// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  currentPaymentRef: json['current_payment_ref'] as String?,
  paymentSuccessful: json['payment_successful'] as bool?,
  failedPaymentRef:
      (json['failed_payment_ref'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'current_payment_ref': instance.currentPaymentRef,
  'payment_successful': instance.paymentSuccessful,
  'failed_payment_ref': instance.failedPaymentRef,
};
