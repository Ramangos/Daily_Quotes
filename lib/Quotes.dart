import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

class QuotesPage extends StatefulWidget {
  @override
  _QuotesPageState createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  String _quote = "Tap to load a quote";
  bool _isLoading = false;
  List<Color> quoteBackground = [];

  @override
  void initState() {
    super.initState();
    quoteBackground = getRandomDeepPurpleGradient();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          setState(() {
            _quote = '${data[0]['q']}\n\n- ${data[0]['a']}';
            quoteBackground = getRandomDeepPurpleGradient();
          });
        } else {
          setState(() => _quote = 'No quote found.');
        }
      } else {
        setState(() => _quote = 'You can request new quotes in 30 seconds. Please try again later.');
      }
    } catch (e) {
      setState(() => _quote = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Color> getRandomDeepPurpleGradient() {
    final List<Color> shades = [
      Colors.deepPurple.shade400,
      Colors.deepPurple.shade500,
      Colors.deepPurple.shade600,
      Colors.deepPurple.shade700,
      Colors.deepPurple.shade800,
      Colors.deepPurple.shade900,
    ];
    final random = Random();
    Color color1 = shades[random.nextInt(shades.length)];
    Color color2 = shades[random.nextInt(shades.length)];
    return [color1, color2];
  }

  void _shareQuote() {
    SharePlus.instance.share(ShareParams(text: _quote));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Quotes',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: quoteBackground.first,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _quote.isNotEmpty ? _shareQuote : null,
          )
        ],
      ),
      body: GestureDetector(
        onTap: _fetchQuote,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: quoteBackground,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Text(
                _quote,
                key: ValueKey(_quote),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchQuote,
        icon: const Icon(Icons.refresh),
        label: const Text("New Quote"),

      ),

    );
  }
}
