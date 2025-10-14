import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:memoriesweb/data/auth_service.dart';
import 'package:memoriesweb/data/payment_Service.dart';
import 'package:memoriesweb/preferences_service.dart';

class MpesaDarajaApi {
  final String consumerKey =
      "Y2OJFJ6R4TgrrQ2H16YOwCiU2ol0MVwSrXzdDGaIjmfgUwQC"; // REPLACE IT WITH YOUR CONSUMER KEY
  final String consumerSecret =
      "IoNApEPZsoe1lIgvDuTQNRFHBuuImTHpFIsG4Fvsmt3isrCULbPBact4Vzi1Fznf"; // REPLACE IT WITH YOUR CONSUMER SECRET
  final String shortCode = "174379"; // Business ShortCode
  final String passkey =
      "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"; // Daraja PassKey
  final String callbackUrl = "https://733eadf9e2d8.ngrok-free.app/api/callback";

  final Dio dio = Dio();

  /// Generate Access Token
  Future<String> getAccessToken() async {
    const url =
        "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials";

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$consumerKey:$consumerSecret'))}";

    try {
      print("🔑 Starting access token request...");
      print("➡ URL: $url");
      print("➡ Basic Auth: $basicAuth");

      Response response = await dio.get(
        url,
        options: Options(headers: {HttpHeaders.authorizationHeader: basicAuth}),
      );

      print("✅ Access token response received!");
      print("📦 Response data: ${response.data}");
      print("🔓 Extracted access token: ${response.data['access_token']}");

      return response.data['access_token'];
    } catch (e) {
      print("❌ Failed to fetch access token: $e");
      rethrow;
    }
  }

  /// STK Push request
  Future<Map<String, dynamic>> stkPushRequest({
    required String phoneNumber,
    required String accountNumber,
    required int amount,
  }) async {
    try {
      print("📞 Raw phone number received: $phoneNumber");

      // Format phone number to 254 format
      if (phoneNumber.startsWith("0")) {
        phoneNumber = "254${phoneNumber.substring(1)}";
      }
      // If starts with "+", remove it
      if (phoneNumber.startsWith("+")) {
        phoneNumber = phoneNumber.substring(1);
      }
      // Remove any spaces/dashes just in case
      phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

      updateUserPhone(phoneNumber);

      // //     // Convert to int
      // final phoneInt = int.parse(phoneNumber);
      // print("✅ Formatted phone number: $phoneNumber");

      final accessToken = await getAccessToken();
      print("🔑 Access token acquired: $accessToken");

      const stkUrl =
          "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest";

      String timestamp = DateFormat("yyyyMMddHHmmss").format(DateTime.now());
      print("🕒 Timestamp generated: $timestamp");

      String password = base64Encode(
        utf8.encode("$shortCode$passkey$timestamp"),
      );
      print("🔐 Encoded password: $password");

      print("🚀 Sending STK Push request to: $stkUrl");
      print(
        "📦 Request body: {"
        "BusinessShortCode: $shortCode, "
        "Password: $password, "
        "Timestamp: $timestamp, "
        "TransactionType: CustomerPayBillOnline, "
        "Amount: $amount, "
        "PartyA: $phoneNumber, "
        "PartyB: $shortCode, "
        "PhoneNumber: $phoneNumber, "
        "CallBackURL: $callbackUrl, "
        "AccountReference: $accountNumber, "
        "TransactionDesc: Mpesa Daraja API stk push test"
        "}",
      );

      Response response = await dio.post(
        stkUrl,
        options: Options(headers: {"Authorization": "Bearer $accessToken"}),
        data: {
          "BusinessShortCode": shortCode,
          "Password": password,
          "Timestamp": timestamp,
          "TransactionType": "CustomerPayBillOnline",
          "Amount": amount,
          "PartyA": phoneNumber,
          "PartyB": shortCode,
          "PhoneNumber": phoneNumber,
          "CallBackURL": callbackUrl,
          "AccountReference": accountNumber,
          "TransactionDesc": "Mpesa Daraja API stk push test",
        },
      );
      // final updatedUser = globalUserDoc?.copyWith(phoneNumber: phoneInt);
      // final clientDocRef = FirebaseFirestore.instance
      //     .collection('clients')
      //     .doc(globalUserDoc?.userId);
      // await clientDocRef.update({'phoneNumber': updatedUser?.phoneNumber});
      // final auth = AuthService();
      // await auth.fetchClient();

      // Save response
      PaymentManager().savePaymentResponse(response.data);

      PreferencesService().setcheckoutId(
        PaymentManager().globalPayment!.checkoutRequestID,
      );
      print("✅ Response received from Safaricom:");
      print(response.data);

      return {
        "msg":
            "Request is successful ✔✔. Please enter mpesa pin to complete the transaction",
        "status": true,
        "response": response.data,
      };
    } catch (e) {
      if (e is DioException) {
        print("❌ DioException response data: ${e.response?.data}");
        print("❌ DioException status code: ${e.response?.statusCode}");
      } else {
        print("❌ Unknown error: $e");
      }

      return {
        "msg": "Request failed ❌",
        "status": false,
        "error": e.toString(),
      };
    }
  }

  Future<void> updateUserPhone(String phoneNumber) async {
    try {
      // Convert to int
      final phoneInt = int.parse(phoneNumber);
      print("✅ Formatted phone number: $phoneNumber");

      // final clientDocRef = FirebaseFirestore.instance
      //     .collection('clients')
      //     .doc(globalUserDoc?.userId);

      // await clientDocRef.update({'phoneNumber': phoneInt});

      // 🔹 Update in-memory user
      final updatedUser = globalUserDoc?.copyWith(phoneNumber: phoneInt);

      final auth = AuthService();
      auth.updateClient(client: updatedUser);
      // await auth.fetchClient();

      print("✅ Phone number updated in Firestore & local memory: $phoneNumber");
    } catch (e) {
      print("❌ Failed to update Firestore phone: $e");
    }
  }

  // /// Callback handler (simulated for server)
  // void handleCallback(Map<String, dynamic> callbackData) {
  //   try {
  //     final stkCallback = callbackData['Body']['stkCallback'];
  //     final merchantRequestID = stkCallback['MerchantRequestID'];
  //     final checkoutRequestID = stkCallback['CheckoutRequestID'];
  //     final resultCode = stkCallback['ResultCode'];
  //     final resultDesc = stkCallback['ResultDesc'];

  //     final callbackMetadata = stkCallback['CallbackMetadata']['Item'];
  //     final amount = callbackMetadata[0]['Value'];
  //     final mpesaReceiptNumber = callbackMetadata[1]['Value'];
  //     final transactionDate = callbackMetadata[3]['Value'];
  //     final phoneNumber = callbackMetadata[4]['Value'];

  //     print("MerchantRequestID: $merchantRequestID");
  //     print("CheckoutRequestID: $checkoutRequestID");
  //     print("ResultCode: $resultCode");
  //     print("ResultDesc: $resultDesc");
  //     print("Amount: $amount");
  //     print("MpesaReceiptNumber: $mpesaReceiptNumber");
  //     print("TransactionDate: $transactionDate");
  //     print("PhoneNumber: $phoneNumber");

  //     // Save callback to file
  //     File("stkcallback.json").writeAsStringSync(jsonEncode(callbackData));
  //     print("STK PUSH CALLBACK STORED SUCCESSFULLY");
  //   } catch (e) {
  //     print("Error handling callback: $e");
  //   }
  // }
}
