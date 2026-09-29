// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() {
  test('Insert Vishal into MongoDB Atlas users and profiles', () async {
    const uri = "mongodb+srv://vishal250820_db_user:vishal25082006@portfolio.mo5wnyq.mongodb.net/pandarathar_matrimony?appName=portfolio";
    final db = await Db.create(uri);
    await db.open();
    print("✓ Successfully connected to MongoDB Atlas database 'pandarathar_matrimony'!");

    final usersCol = db.collection('users');
    final vishalUser = {
      'name': 'Vishal',
      'username': 'vishal',
      'phone': '9842100002',
      'email': 'vishal@pandarathar.com',
      'password': 'password123',
      'gender': 'Groom',
      'status': 'verified',
      'registeredAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await usersCol.update(
      where.eq('username', 'vishal').or(where.eq('phone', '9842100002')),
      {
        r'$set': vishalUser,
      },
      upsert: true,
    );
    print("✓ User 'Vishal' successfully saved to MongoDB Atlas 'users' collection!");

    final profilesCol = db.collection('profiles');
    final vishalProfile = {
      'id': 'PM0002',
      'name': 'Vishal',
      'nameTamil': 'விஷால்',
      'caste': 'Pandarathar (பண்டாரத்தார்)',
      'community': 'பண்டாரத்தார்',
      'subSect': 'பண்டாரத்தார் (Pandarathar)',
      'phone': '9842100002',
      'whatsapp': '9842100002',
      'email': 'vishal@pandarathar.com',
      'gender': 'Groom',
      'age': 25,
      'height': "5'10\"",
      'maritalStatus': 'Never Married',
      'motherTongue': 'Tamil',
      'motherTongueTamil': 'தமிழ்',
      'religion': 'Hindu',
      'education': 'B.Tech / Professional',
      'occupation': 'Software Engineer',
      'location': 'Coimbatore, Tamil Nadu',
      'isVerified': true,
      'status': 'active',
      'about': 'Looking for an understanding partner from Pandarathar community.',
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await profilesCol.update(
      where.eq('id', 'PM0002').or(where.eq('phone', '9842100002')),
      {
        r'$set': vishalProfile,
      },
      upsert: true,
    );
    print("✓ Profile 'PM0002' (Vishal) successfully saved to MongoDB Atlas 'profiles' collection!");

    final allUsers = await usersCol.find().toList();
    print("Total users in Atlas now: ${allUsers.length}");
    for (var u in allUsers) {
      print("-> User: ${u['name']} (${u['username']} / ${u['phone']})");
    }

    await db.close();
  });
}
