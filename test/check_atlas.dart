// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() {
  test('Check Atlas collections and users', () async {
    const uri = "mongodb+srv://vishal250820_db_user:vishal25082006@portfolio.mo5wnyq.mongodb.net/pandarathar_matrimony?appName=portfolio";
    final db = await Db.create(uri);
    await db.open();
    print("✓ Successfully connected to MongoDB Atlas!");
    
    final collections = await db.getCollectionNames();
    print("Collections in Atlas: $collections");

    final usersCol = db.collection('users');
    final allUsers = await usersCol.find().toList();
    print("Total users in Atlas: ${allUsers.length}");
    for (var u in allUsers) {
      print("User in Atlas: name=${u['name']}, phone=${u['phone']}, email=${u['email']}");
    }

    final profilesCol = db.collection('profiles');
    final allProfiles = await profilesCol.find().toList();
    print("Total profiles in Atlas: ${allProfiles.length}");
    for (var p in allProfiles) {
      print("Profile in Atlas: name=${p['name']}, id=${p['id']}, phone=${p['phone']}");
    }

    await db.close();
  });
}
