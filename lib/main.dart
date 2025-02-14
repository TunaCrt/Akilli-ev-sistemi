import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("✅ Firebase başarıyla başlatıldı!");
  } catch (e) {
    print("❌ Firebase başlatılamadı! Hata: $e");
  }
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _ledStatus = false;

  @override
  void initState() {
    super.initState();
    _getLedStatus();
  }

  void _getLedStatus() async {
    final snapshot = await _database.child("led/status").get();
    if (snapshot.exists) {
      setState(() {
        _ledStatus = snapshot.value == 1;
      });
    }
  }

  void _toggleLed() async {
    setState(() {
      _ledStatus = !_ledStatus;
    });
    await _database.child("led/status").set(_ledStatus ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("ESP8266 LED Kontrol")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _ledStatus ? "💡 LED Açık" : "💡 LED Kapalı",
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Switch(
                value: _ledStatus,
                onChanged: (value) => _toggleLed(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
