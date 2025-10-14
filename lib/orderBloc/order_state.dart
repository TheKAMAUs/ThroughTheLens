// order_state.dart
import 'package:equatable/equatable.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderList extends OrderState {
  final DateTime timestamp;
  final String message;
  OrderList(this.message) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [message, timestamp];
}

class OrderUploadingImages extends OrderState {}

class OrderUploadedImages extends OrderState {}

class OrderUploadingvideos extends OrderState {}

class OrderUploadedvideos extends OrderState {}

class OrderSuccess extends OrderState {}

class OrderReceiptTaken extends OrderState {
  final DateTime timestamp;

  OrderReceiptTaken() : timestamp = DateTime.now();

  @override
  List<Object?> get props => [timestamp];
}

class OrderFailure extends OrderState {
  final String message;

  const OrderFailure(this.message);

  @override
  List<Object?> get props => [message];
}
