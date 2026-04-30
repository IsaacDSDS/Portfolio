import 'package:flutter/material.dart';
import 'package:so_portfolio/widgets/mac_window.dart';

void main() {
  runApp(const SoPortfolioApp());
}

class SoPortfolioApp extends StatelessWidget {
  const SoPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio',
      home: const HomePage(title: 'Home'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _windowTags = [];

  void _addWindow(String tag) {
    if (_windowTags.contains(tag)) return;
    setState(() => _windowTags.add(tag));
  }

  void _removeWindow(String tag) {
    setState(() => _windowTags.remove(tag));
  }

  void _reOrderWindows(String tag) {
    setState(() {
      _windowTags.remove(tag);
      _windowTags.add(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                _addWindow('prueba_${DateTime.now().millisecondsSinceEpoch}');
              },
              child: const Text("Open Prueba"),
            ),
          ),
          for (final tag in _windowTags)
            DraggableMacWindow(
              key: ValueKey(tag),
              tag: tag,
              title: tag,
              builder: (size) =>
                  Text('hola $tag ${size.width} x ${size.height}'),
              onClose: _removeWindow,
            ),
        ],
      ),
    );
  }
}
