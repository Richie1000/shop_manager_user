class Employee {
  final String id;
  final String email;
  final int phoneNumber;
  final String role;
  final String? uuid;

  Employee(
      {required this.id,
      required this.email,
      required this.phoneNumber,
      this.uuid,
      required this.role});

  factory Employee.fromFirestore(Map<String, dynamic> data, String id) {
    return Employee(
        id: id,
        email: data["email"],
        phoneNumber: data['phoneNumber'],
        role: data["role"],
        uuid: data["uuid"]);
  }

  Map<String, dynamic> toMap() {
    return {"email": email, "phoneNumber": phoneNumber, "role": role};
  }
}
