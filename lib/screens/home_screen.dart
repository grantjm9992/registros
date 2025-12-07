import 'package:flutter/material.dart';
import '../widgets/registro_wizard.dart';
import 'list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<_HomeScreenState> _wizardKey = GlobalKey();

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onRegistroComplete() {
    // Refresh cuando se complete un registro
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros de Sentimiento'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          RegistroWizard(
            key: _wizardKey,
            onComplete: _onRegistroComplete,
          ),
          const ListScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Nuevo Registro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_outlined),
            activeIcon: Icon(Icons.list),
            label: 'Mis Registros',
          ),
        ],
      ),
    );
  }
}
