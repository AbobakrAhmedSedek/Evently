class MyUser {
   static const String collectionName = 'users';
   final String id;
    final String name;
    final String email;
  
    MyUser({
      required this.id,
       required this.name, 
       required this.email
       });
  
    factory MyUser.fromMap(Map<String, dynamic> data) {
      return MyUser(
        id: data['id'],
        name: data['name'],
        email: data['email'],
      );
    }
  
    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'name': name,
        'email': email,
      };
    }    
}
