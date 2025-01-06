class User {
  final String uid;
  final String name;
  final int age;
  final String phoneNumber;
  final String gender;
  final String address;

  User({
    required this.uid,
    required this.name,
    required this.age,
    required this.phoneNumber,
    required this.gender,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'address': address,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      name: map['name'],
      age: map['age'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'],
      address: map['address'],
    );
  }
}
