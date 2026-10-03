class PassengerModel {
  final String title;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String nationality;
  final String idType; // Passport, National ID, Aadhaar
  final String idNumber;
  final String email;
  final String phone;
  final String passengerType; // Adult, Child, Infant
  final String selectedSeat;

  const PassengerModel({
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    this.idType = 'Govt ID',
    required this.idNumber,
    required this.email,
    required this.phone,
    required this.passengerType,
    this.selectedSeat = '',
  });

  String get fullName => '$title $firstName $lastName'.trim();

  PassengerModel copyWith({
    String? title,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? nationality,
    String? idType,
    String? idNumber,
    String? email,
    String? phone,
    String? passengerType,
    String? selectedSeat,
  }) {
    return PassengerModel(
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passengerType: passengerType ?? this.passengerType,
      selectedSeat: selectedSeat ?? this.selectedSeat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'nationality': nationality,
      'idType': idType,
      'idNumber': idNumber,
      'email': email,
      'phone': phone,
      'passengerType': passengerType,
      'selectedSeat': selectedSeat,
    };
  }

  factory PassengerModel.fromMap(Map<String, dynamic> map) {
    return PassengerModel(
      title: map['title'] ?? 'Mr',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      gender: map['gender'] ?? 'Male',
      nationality: map['nationality'] ?? 'Indian',
      idType: map['idType'] ?? 'Govt ID',
      idNumber: map['idNumber'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      passengerType: map['passengerType'] ?? 'Adult',
      selectedSeat: map['selectedSeat'] ?? '',
    );
  }
}
