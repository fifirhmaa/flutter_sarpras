class ReturnModel {
  final int? id;
  final int? userId;
  final int borrowId;
  final String returnDate;
  final String? condition;
  final String? note;
  final String? status;
  

  ReturnModel({
    this.id,
    this.userId,
    required this.borrowId,
    required this.returnDate,
    this.condition,
    this.note,
    this.status,
  });

  factory ReturnModel.fromJson(Map<String, dynamic> json) {
    return ReturnModel(
      id: json['id'],
      userId: json['user_id'],
      borrowId: json['borrow_id'],
      returnDate: json['return_date'],
      condition: json['condition'],
      note: json['note'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'borrow_id': borrowId,
        'return_date': returnDate,
        'condition': condition,
        'note': note,
        'status': status,
      };
}
