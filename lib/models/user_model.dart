class UserModel {
  final String id;
  final String? email;
  final String? partnerId;
  final String? pairingCode;
  final bool isPaired;

  UserModel({
    required this.id,
    this.email,
    this.partnerId,
    this.pairingCode,
    this.isPaired = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'partnerId': partnerId,
      'pairingCode': pairingCode,
      'isPaired': isPaired,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'],
      partnerId: map['partnerId'],
      pairingCode: map['pairingCode'],
      isPaired: map['isPaired'] ?? false,
    );
  }
}
