import 'package:first_attemp/pomodoro.dart';
import 'package:flutter/material.dart';
import 'plan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyNavigationPage(), // This MUST be the name of your class
    );
  }
}

// --- 1. DATA MODELS ---
class Chapter {
  String title;
  Chapter({required this.title});
}

class Module {
  String name;
  List<Chapter> chapters;
  Module({required this.name, List<Chapter>? chapters}) : this.chapters = chapters ?? [];
}

// --- 2. MAIN NAVIGATION PAGE ---
class MyNavigationPage extends StatefulWidget {
  const MyNavigationPage({super.key});
  @override
  State<MyNavigationPage> createState() => _MyNavigationPageState();
}

class _MyNavigationPageState extends State<MyNavigationPage> {
  int _selectedIndex = 0;
  List<Module> myModules = [Module(name: 'Mathematics')];

  void _addModule(String name) {
    setState(() => myModules.add(Module(name: name)));
  }

  Widget _getPage() {
  switch (_selectedIndex) {
    case 0:
      return _buildModuleGrid();
    case 1:
      return const CalendarPage();
    case 2:
      return const Center(child: Text("Review Page"));
    case 3:
      return const PomodoroScreen(); // <--- Your timer lives here!
    default:
      return _buildModuleGrid();
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Vault'), backgroundColor: Colors.blue[100]),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Modules'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: 'Review'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Pomodoro'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, _addModule, "Module Name"),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildModuleGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15,
      ),
      itemCount: myModules.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ModuleDetailScreen(module: myModules[index]),
          )).then((_) => setState(() {})); // Refresh UI on return
        },
        child: Card(child: Center(child: Text(myModules[index].name))),
      ),
    );
  }
}

// --- 3. MODULE DETAIL SCREEN ---
class ModuleDetailScreen extends StatefulWidget {
  final Module module;
  const ModuleDetailScreen({super.key, required this.module});

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  void _addChapter(String title) {
    setState(() => widget.module.chapters.add(Chapter(title: title)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.module.name)),
      body: ListView.builder(
        itemCount: widget.module.chapters.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(widget.module.chapters[index].title),
          leading: const Icon(Icons.book),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, _addChapter, "Chapter Name"),
        child: const Icon(Icons.post_add),
      ),
    );
  }
}

// --- 4. SHARED HELPER ---
void _showAddDialog(BuildContext context, Function(String) onSave, String hint) {
  TextEditingController controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Create $hint"),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          if (controller.text.isNotEmpty) {
            onSave(controller.text);
            Navigator.pop(context);
          }
        }, child: const Text('Add')),
      ],
    ),
  );
}
