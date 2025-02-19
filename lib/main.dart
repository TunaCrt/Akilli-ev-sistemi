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
  runApp(SmartHomeApp());
}

class SmartHomeApp extends StatefulWidget {
  @override
  _SmartHomeAppState createState() => _SmartHomeAppState();
}

class _SmartHomeAppState extends State<SmartHomeApp> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  bool _ledStatus = false;
  double _havaKalitesi = 0.0;

  @override
  void initState() {
    super.initState();
    _getLedStatus();
    _listenToAirQuality();
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

  void _listenToAirQuality() {
    _database.child("hava_kalitesi/ppm").onValue.listen((event) {
      final dynamic value = event.snapshot.value;
      if (value != null) {
        setState(() {
          _havaKalitesi = double.parse(value.toString());
        });
      }
    });
  }

  String getAirQualityStatus(double ppm) {
    if (ppm < 400) {
      return "✅ Hava Kalitesi İyi";
    } else if (ppm >= 400 && ppm < 600) {
      return "⚠️ Hava Kalitesi Orta";
    } else if (ppm >= 600 && ppm < 1000) {
      return "❌ Hava Kalitesi Kötü";
    } else if (ppm >= 1000 && ppm < 2000) {
      return "🚨 Tehlikeli! Hava Çok Kirli";
    } else {
      return "🔥 Yangın Alarmı! Dikkat!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), 
      home: Scaffold(
        backgroundColor: Colors.blueGrey[900],
        appBar: AppBar(
          title: Text("🏠 Akıllı Ev Kontrol"),
          backgroundColor: Colors.blueGrey[700],
        ),
        body: Center(
          child: SingleChildScrollView( // Ekrana göre ortalamayı garanti eder
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // İçeriği sıkıştırarak ortaya alır
                children: [
                  // 🌿 Hava Kalitesi Kartı
                  Align(
                    alignment: Alignment.center, // Kartı sayfa ortasında hizalar
                    child: Card(
                      color: Colors.blueGrey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_outlined,
                              color: Colors.white,
                              size: 50,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Hava Kalitesi (PPM)",
                              style: TextStyle(color: Colors.white, fontSize: 22),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "${_havaKalitesi.toStringAsFixed(2)} PPM",
                              style: TextStyle(
                                color: _havaKalitesi < 600 ? Colors.greenAccent : Colors.redAccent,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              getAirQualityStatus(_havaKalitesi),
                              style: TextStyle(
                                fontSize: 18,
                                color: _havaKalitesi < 400
                                    ? Colors.green
                                    : (_havaKalitesi < 600
                                        ? Colors.orange
                                        : (_havaKalitesi < 1000 ? Colors.red : Colors.purple)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // 💡 LED Kontrol Kartı
                  Align(
                    alignment: Alignment.center, // Kartı sayfa ortasında hizalar
                    child: Card(
                      color: Colors.blueGrey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(
                              _ledStatus ? Icons.lightbulb : Icons.lightbulb_outline,
                              color: _ledStatus ? Colors.yellowAccent : Colors.white,
                              size: 60,
                            ),
                            SizedBox(height: 10),
                            Text(
                              _ledStatus ? "💡 Işık Açık" : "💡 Işık Kapalı",
                              style: TextStyle(color: Colors.white, fontSize: 22),
                            ),
                            SizedBox(height: 10),
                            Switch(
                              value: _ledStatus,
                              activeColor: Colors.yellowAccent,
                              onChanged: (value) => _toggleLed(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
