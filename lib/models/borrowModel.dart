import 'package:ass_sisforas/models/itemModel.dart';

class Borrow {
  int? id;
  int? userId;
  int? itemId;
  int? quantity;
  String? borrowDate;
  String? returnDate;
  String? purposes;
  String? status;
  int? isApproved;
  ItemModel? item;
  ItemModel? codeItem;

  Borrow({
    this.id,
    this.userId,
    this.itemId,
    this.quantity,
    this.borrowDate,
    this.returnDate,
    this.purposes,
    this.status = 'borrowed',
    this.isApproved = 0,
    this.item,
    this.codeItem,
  });

  Borrow.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    itemId = json['item_id'];
    quantity = json['quantity'];
    borrowDate = json['borrow_date'];
    returnDate = json['return_date'];
    purposes = json['purposes'];
    status = json['status'];
    isApproved = json['is_approved'];
    item = json['item'] != null ? ItemModel.fromJson(json['item']) : null;
    codeItem = json['code_item'] != null ? ItemModel.fromJson(json['code_item']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['item_id'] = itemId;
    data['quantity'] = quantity;
    data['borrow_date'] = borrowDate;
    data['return_date'] = returnDate;
    data['purposes'] = purposes;
    data['status'] = status;
    data['is_approved'] = isApproved;
    data['item'] = item;
    data['code_item'] = codeItem;

    return data;
  }

  @override
  String toString() {
    return 'Borrow(id: $id, userId: $userId, itemId: $itemId, quantity: $quantity, borrowDate: $borrowDate, returnDate: $returnDate, purposes: $purposes, status: $status, isApproved: $isApproved)';
  }
}
