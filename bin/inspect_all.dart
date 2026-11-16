import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  final atlasUri = Platform.environment['MONGODB_ATLAS_URI'] ??
      'mongodb+srv://vishal250820_db_user:vishal25082006@portfolio.mo5wnyq.mongodb.net/pandarathar_matrimony?appName=portfolio&safeAtlas=true';
  final db = await Db.create(atlasUri);
  await db.open();

  print('=== USERS ===');
  final users = await db.collection('users').find().toList();
  for (var u in users) {
    print('${u["name"]} | ${u["phone"]} | ${u["username"]} | ${u["email"]}');
  }

  print('\n=== PAYMENTS ===');
  final payments = await db.collection('payments').find().toList();
  for (var p in payments) {
    print('${p["id"]} | ${p["userName"]} | ${p["userPhone"]} | ${p["totalAmount"]} | ${p["status"]}');
  }

  print('\n=== SHORTLISTS ===');
  final shortlists = await db.collection('shortlists').find().toList();
  for (var s in shortlists) {
    print('userId: ${s["userId"]} | userPhone: ${s["userPhone"]} | profileIds: ${s["profileIds"]}');
  }

  await db.close();
}
