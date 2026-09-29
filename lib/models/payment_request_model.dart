class PaymentRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final List<String> profileIds;
  final List<String> profileNames;
  final double totalAmount; // Count * 25
  final String utrNumber; // 12-digit UPI reference number
  final String paymentMethod; // e.g. "UPI QR Code"
  final DateTime timestamp;
  String status; // 'pending', 'approved', 'rejected'

  PaymentRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.profileIds,
    required this.profileNames,
    required this.totalAmount,
    required this.utrNumber,
    this.paymentMethod = "UPI QR Code (GPay / PhonePe / Paytm)",
    required this.timestamp,
    this.status = 'pending',
  });

  PaymentRequestModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    List<String>? profileIds,
    List<String>? profileNames,
    double? totalAmount,
    String? utrNumber,
    String? paymentMethod,
    DateTime? timestamp,
    String? status,
  }) {
    return PaymentRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      profileIds: profileIds ?? this.profileIds,
      profileNames: profileNames ?? this.profileNames,
      totalAmount: totalAmount ?? this.totalAmount,
      utrNumber: utrNumber ?? this.utrNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'profileIds': profileIds,
      'profileNames': profileNames,
      'totalAmount': totalAmount,
      'utrNumber': utrNumber,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  factory PaymentRequestModel.fromMap(Map<String, dynamic> map) {
    return PaymentRequestModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      userPhone: map['userPhone']?.toString() ?? '',
      profileIds: (map['profileIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      profileNames: (map['profileNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      totalAmount: (map['totalAmount'] is num) ? (map['totalAmount'] as num).toDouble() : 25.0,
      utrNumber: map['utrNumber']?.toString() ?? '',
      paymentMethod: map['paymentMethod']?.toString() ?? "UPI QR Code (GPay / PhonePe / Paytm)",
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: map['status']?.toString() ?? 'pending',
    );
  }
}

