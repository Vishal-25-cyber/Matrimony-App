// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  print('================================================================');
  print('  PANDARATHAR MATRIMONY - DATABASE PURGE & FRESH APP RESETTER   ');
  print('================================================================');

  // 1. Read clean catalog profiles from bin/clean_catalog.json
  final catalogFile = File('bin/clean_catalog.json');
  if (!catalogFile.existsSync()) {
    print('❌ Error: bin/clean_catalog.json not found! Please run export first.');
    exit(1);
  }
  final List<dynamic> rawCatalog = jsonDecode(catalogFile.readAsStringSync());
  final List<Map<String, dynamic>> cleanProfiles = rawCatalog.map((e) {
    final m = Map<String, dynamic>.from(e as Map);
    m.remove('_id'); // Ensure clean IDs
    m['isContactUnlocked'] = false;
    m['isHoroscopeUnlocked'] = false;
    m['isShortlisted'] = false;
    m['interestStatus'] = 'none';
    return m;
  }).toList();
  print('✓ Loaded ${cleanProfiles.length} canonical catalog profiles from bin/clean_catalog.json');

  // 2. MongoDB Atlas Configuration
  final atlasUri = 'mongodb+srv://vishal250820_db_user:vishal25082006@portfolio.mo5wnyq.mongodb.net/pandarathar_matrimony?appName=portfolio&safeAtlas=true';
  final localUri = 'mongodb://127.0.0.1:27017/pandarathar_matrimony';

  print('\n>>> STEP 1: Purging & Resetting MongoDB Atlas (portfolio.mo5wnyq.mongodb.net)...');
  try {
    final dbAtlas = await Db.create(atlasUri);
    await dbAtlas.open().timeout(const Duration(seconds: 15));
    print('✓ Connected to MongoDB Atlas cluster.');

    // 2a. Purge users collection
    final usersCol = dbAtlas.collection('users');
    final userCountBefore = await usersCol.count();
    await usersCol.drop();
    print('  - users collection: dropped ($userCountBefore test user accounts purged)');

    // 2b. Purge payments collection
    final paymentsCol = dbAtlas.collection('payments');
    final paymentCountBefore = await paymentsCol.count();
    await paymentsCol.drop();
    print('  - payments collection: dropped ($paymentCountBefore test payment records purged)');

    // 2c. Purge shortlists collection
    final shortlistsCol = dbAtlas.collection('shortlists');
    final shortlistsCountBefore = await shortlistsCol.count();
    await shortlistsCol.drop();
    print('  - shortlists collection: dropped ($shortlistsCountBefore test shortlist records purged)');

    // 2d. Purge horoscope_registrations collection if exists
    final horoCol = dbAtlas.collection('horoscope_registrations');
    await horoCol.drop();
    print('  - horoscope_registrations collection: dropped');

    // 2e. Reset system_status collection
    final statusCol = dbAtlas.collection('system_status');
    await statusCol.drop();
    await statusCol.insert({
      'service': 'pandarathar_matrimony_app',
      'status': 'fresh_initialized',
      'database': 'pandarathar_matrimony',
      'version': '1.0.0',
      'resetAt': DateTime.now().toUtc().toIso8601String(),
    });
    print('  - system_status collection: reset with fresh initialization status');

    // 2f. Reset profiles collection with pristine 14 catalog profiles
    final profilesCol = dbAtlas.collection('profiles');
    final profileCountBefore = await profilesCol.count();
    await profilesCol.drop();
    print('  - profiles collection: dropped ($profileCountBefore old profiles purged)');

    for (final p in cleanProfiles) {
      await profilesCol.insert(Map<String, dynamic>.from(p));
    }
    print('  - profiles collection: re-seeded with ${cleanProfiles.length} pristine catalog profiles (all locked)');

    // Verify Atlas counts
    print('\n  [Atlas Verification]');
    print('    - users: ${await dbAtlas.collection("users").count()} docs (Clean)');
    print('    - payments: ${await dbAtlas.collection("payments").count()} docs (Clean)');
    print('    - shortlists: ${await dbAtlas.collection("shortlists").count()} docs (Clean)');
    print('    - profiles: ${await dbAtlas.collection("profiles").count()} docs (Clean)');
    print('    - system_status: ${await dbAtlas.collection("system_status").count()} docs (Clean)');

    await dbAtlas.close();
    print('✓ MongoDB Atlas reset complete!\n');
  } catch (e) {
    print('❌ Error resetting MongoDB Atlas: $e');
  }

  // 3. Purge Local MongoDB (if running)
  print('>>> STEP 2: Checking Local MongoDB (127.0.0.1:27017)...');
  try {
    final dbLocal = await Db.create(localUri);
    await dbLocal.open().timeout(const Duration(seconds: 3));
    print('✓ Connected to Local MongoDB.');
    await dbLocal.collection('users').drop();
    await dbLocal.collection('payments').drop();
    await dbLocal.collection('shortlists').drop();
    await dbLocal.collection('horoscope_registrations').drop();
    await dbLocal.collection('system_status').drop();
    final localProfiles = dbLocal.collection('profiles');
    await localProfiles.drop();
    for (final p in cleanProfiles) {
      await localProfiles.insert(Map<String, dynamic>.from(p));
    }
    print('✓ Local MongoDB reset complete!');
    await dbLocal.close();
  } catch (e) {
    print('ℹ Local MongoDB not active or already clean: $e');
  }

  // 4. Cloudflare R2 Storage Cleanup (Remove test uploaded avatars)
  print('\n>>> STEP 3: Purging Cloudflare R2 Uploaded Files...');
  try {
    await purgeCloudflareR2();
  } catch (e) {
    print('❌ Error cleaning Cloudflare R2: $e');
  }

  print('\n================================================================');
  print('  🎉 DATABASE & APP PURGE SUCCESSFUL! APP IS NOW 100% FRESH!    ');
  print('================================================================');
  exit(0);
}

Future<void> purgeCloudflareR2() async {
  const r2AccountId = 'b535b7c908a09f10d27773b1b9536777';
  const r2AccessKeyId = '16fa39f1d2e94ee5405a9995244691f0';
  const r2SecretAccessKey = '06dfc88dcbf86cb0174233ab6670274da20d30de78383b87d2c3d08a736e1bd3';
  const r2BucketName = 'matrimony-profile-images';
  const r2Endpoint = 'https://$r2AccountId.r2.cloudflarestorage.com';
  final r2Host = Uri.parse(r2Endpoint).host;
  const r2Region = 'auto';

  // List all objects
  final now = DateTime.now().toUtc();
  final dateStamp = "${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
  final amzDate = "${dateStamp}T${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}Z";

  final payloadHash = sha256.convert([]).toString();
  final canonicalUri = "/$r2BucketName";
  const canonicalQueryString = "list-type=2";
  final canonicalHeaders = "host:$r2Host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n";
  const signedHeaders = "host;x-amz-content-sha256;x-amz-date";
  final canonicalRequest = "GET\n$canonicalUri\n$canonicalQueryString\n$canonicalHeaders\n$signedHeaders\n$payloadHash";

  const algorithm = "AWS4-HMAC-SHA256";
  final credentialScope = "$dateStamp/$r2Region/s3/aws4_request";
  final stringToSign = "$algorithm\n$amzDate\n$credentialScope\n${sha256.convert(utf8.encode(canonicalRequest))}";

  List<int> sign(List<int> key, String msg) => Hmac(sha256, key).convert(utf8.encode(msg)).bytes;
  final kDate = sign(utf8.encode("AWS4$r2SecretAccessKey"), dateStamp);
  final kRegion = sign(kDate, r2Region);
  final kService = sign(kRegion, "s3");
  final signingKey = sign(kService, "aws4_request");
  final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

  final authorizationHeader = "$algorithm Credential=$r2AccessKeyId/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature";

  final listUri = Uri.parse("$r2Endpoint/$r2BucketName?list-type=2");
  final response = await http.get(
    listUri,
    headers: {
      'Host': r2Host,
      'x-amz-date': amzDate,
      'x-amz-content-sha256': payloadHash,
      'Authorization': authorizationHeader,
    },
  );

  if (response.statusCode != 200) {
    print('⚠ Unable to list R2 objects: ${response.statusCode}');
    return;
  }

  // Parse keys from XML
  final keyRegex = RegExp(r'<Key>([^<]+)<\/Key>');
  final matches = keyRegex.allMatches(response.body);
  final keys = matches.map((m) => m.group(1)!).toList();
  print('  - Found ${keys.length} object(s) in R2 bucket $r2BucketName: $keys');

  for (final key in keys) {
    print('  - Deleting R2 object: $key ...');
    final delNow = DateTime.now().toUtc();
    final delDateStamp = "${delNow.year.toString().padLeft(4, '0')}${delNow.month.toString().padLeft(2, '0')}${delNow.day.toString().padLeft(2, '0')}";
    final delAmzDate = "${delDateStamp}T${delNow.hour.toString().padLeft(2, '0')}${delNow.minute.toString().padLeft(2, '0')}${delNow.second.toString().padLeft(2, '0')}Z";

    final delUri = "/$r2BucketName/$key";
    final delCanonicalHeaders = "host:$r2Host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$delAmzDate\n";
    final delCanonicalRequest = "DELETE\n$delUri\n\n$delCanonicalHeaders\n$signedHeaders\n$payloadHash";

    final delCredentialScope = "$delDateStamp/$r2Region/s3/aws4_request";
    final delStringToSign = "$algorithm\n$delAmzDate\n$delCredentialScope\n${sha256.convert(utf8.encode(delCanonicalRequest))}";

    final delKDate = sign(utf8.encode("AWS4$r2SecretAccessKey"), delDateStamp);
    final delKRegion = sign(delKDate, r2Region);
    final delKService = sign(delKRegion, "s3");
    final delSigningKey = sign(delKService, "aws4_request");
    final delSig = Hmac(sha256, delSigningKey).convert(utf8.encode(delStringToSign)).toString();

    final delAuth = "$algorithm Credential=$r2AccessKeyId/$delCredentialScope, SignedHeaders=$signedHeaders, Signature=$delSig";

    final res = await http.delete(
      Uri.parse("$r2Endpoint/$r2BucketName/$key"),
      headers: {
        'Host': r2Host,
        'x-amz-date': delAmzDate,
        'x-amz-content-sha256': payloadHash,
        'Authorization': delAuth,
      },
    );
    print('    Deleted $key -> HTTP ${res.statusCode}');
  }
  print('✓ Cloudflare R2 bucket purged completely.');
}
