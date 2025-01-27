import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled5/sumifun.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyAvUGU3VGbnru7oRtDCrIfA_bcm0Qodjiw",
        authDomain: "loginfierbase-c4bc0.firebaseapp.com",
        projectId: "loginfierbase-c4bc0",
        storageBucket: "loginfierbase-c4bc0.appspot.com",
        messagingSenderId: "88867532408",
        appId: "1:88867532408:web:23549621489296af9ac78d"
    ),
  );
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(persistenceEnabled: true); // إعداد Firestore
  var a= FirebaseFirestore.instance.collection('ids').get();

  print("==========");
  print(a);
  print("==========");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: RechargeScreen(), // تأكد من أن شاشة RechageScreen موجودة
    );
  }
}
