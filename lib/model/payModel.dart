import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String merchantRequestID;
  final String checkoutRequestID;
  final int responseCode;
  final String responseDescription;
  final String customerMessage;

  const Payment({
    required this.merchantRequestID,
    required this.checkoutRequestID,
    required this.responseCode,
    required this.responseDescription,
    required this.customerMessage,
  });

  /// ✅ Factory constructor to create Payment from API response / Firestore
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      merchantRequestID: map['MerchantRequestID'] ?? '',
      checkoutRequestID: map['CheckoutRequestID'] ?? '',
      responseCode:
          map['ResponseCode'] is int
              ? map['ResponseCode']
              : int.tryParse(map['ResponseCode'].toString()) ?? 0,
      responseDescription: map['ResponseDescription'] ?? '',
      customerMessage: map['CustomerMessage'] ?? '',
    );
  }

  /// ✅ Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'MerchantRequestID': merchantRequestID,
      'CheckoutRequestID': checkoutRequestID,
      'ResponseCode': responseCode,
      'ResponseDescription': responseDescription,
      'CustomerMessage': customerMessage,
    };
  }

  /// ✅ CopyWith for immutability
  Payment copyWith({
    String? merchantRequestID,
    String? checkoutRequestID,
    int? responseCode,
    String? responseDescription,
    String? customerMessage,
  }) {
    return Payment(
      merchantRequestID: merchantRequestID ?? this.merchantRequestID,
      checkoutRequestID: checkoutRequestID ?? this.checkoutRequestID,
      responseCode: responseCode ?? this.responseCode,
      responseDescription: responseDescription ?? this.responseDescription,
      customerMessage: customerMessage ?? this.customerMessage,
    );
  }

  @override
  List<Object?> get props => [
    merchantRequestID,
    checkoutRequestID,
    responseCode,
    responseDescription,
    customerMessage,
  ];
}
