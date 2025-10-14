import 'package:memoriesweb/model/payModel.dart';

/// Manages the current payment state
class PaymentManager {
  /// Singleton instance (so you always access the same payment state)
  static final PaymentManager _instance = PaymentManager._internal();

  factory PaymentManager() => _instance;

  PaymentManager._internal();

  /// Holds the latest Payment response
  Payment? _globalPayment;

  /// Get the latest payment
  Payment? get globalPayment => _globalPayment;

  /// Save a payment response globally
  void savePaymentResponse(Map<String, dynamic> response) {
    try {
      final payment = Payment.fromMap(response);
      _globalPayment = payment;
      print("✅ Payment saved globally: $_globalPayment");
    } catch (e) {
      print("❌ Failed to save payment: $e");
    }
  }

  /// Clear the stored payment
  void clear() {
    _globalPayment = null;
    print("🗑️ Cleared global payment");
  }
}
