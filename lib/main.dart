import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  
  if (kDebugMode) {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Analytics Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(
        title: 'Firebase Analytics',
        analytics: analytics,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final FirebaseAnalytics analytics;

  const MyHomePage({
    super.key,
    required this.title,
    required this.analytics,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _logAppOpen();
  }

  Future<void> _logAppOpen() async {
    try {
      await widget.analytics.logAppOpen();
      print('✅ App open event logged successfully');
    } catch (e) {
      print('❌ Error logging app open event: $e');
    }
  }

  Future<void> _testAnalytics() async {
    try {
      // Test event yuborish
      await widget.analytics.logEvent(
        name: 'test_event',
        parameters: {
          'test_param': 'test_value',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      // Debug view'ni ochish (faqat development uchun)
      if (kDebugMode) {
        await widget.analytics.setAnalyticsCollectionEnabled(true);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test event yuborildi!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      print('✅ Test event sent successfully');
    } catch (e) {
      print('❌ Error in test analytics: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test xatolik: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _sendAnalyticsEvent() async {
    try {
      await widget.analytics.logEvent(
        name: 'counter_incremented',
        parameters: {
          'count': _counter,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'platform': defaultTargetPlatform.toString(),
          'app_version': '1.0.0',
        },
      );
      print('✅ Analytics event sent successfully! Count: $_counter');
    } catch (e) {
      print('❌ Error sending analytics event: $e');
    }
  }

  Future<void> _sendTextAnalyticsEvent() async {
    if (_textController.text.trim().isNotEmpty) {
      try {
        await widget.analytics.logEvent(
          name: 'text_sent',
          parameters: {
            'text_length': _textController.text.length,
            'text_content': _textController.text,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'platform': defaultTargetPlatform.toString(),
            'app_version': '1.0.0',
          },
        );
        print('✅ Text Analytics event sent successfully! Text: ${_textController.text}');
        
        _textController.clear();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text Firebase Analytics ga yuborildi!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('❌ Error sending text analytics event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    _sendAnalyticsEvent();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Counter qismi
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('You have pushed the button this many times:'),
                    Text('$_counter',
                        style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Matn kiriting...',
                      border: OutlineInputBorder(),
                      labelText: 'Text Analytics',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sendTextAnalyticsEvent,
                      icon: const Icon(Icons.send),
                      label: const Text('Send to Analytics'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _testAnalytics,
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Test Analytics'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
