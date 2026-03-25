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
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Cleans up the UI
      theme: ThemeData.dark(), // Sets a base dark theme
      home: const MyNavigationPage(),
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
  Module({required this.name, List<Chapter>? chapters})
      : this.chapters = chapters ?? [];
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
        return const PomodoroScreen();
      default:
        return _buildModuleGrid();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Academic Vault',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Modules'),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: 'Review'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Pomodoro'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        onPressed: () => _showAddDialog(context, _addModule, "Module Name"),
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- THE FIXED MODULE GRID ---
  Widget _buildModuleGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.0, // FORCES THE SQUARE SHAPE
      ),
      itemCount: myModules.length,
      itemBuilder: (context, index) {
        final module = myModules[index];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ModuleDetailScreen(module: module)),
            ).then((_) => setState(() {}));
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Same as calendar box
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.folder_rounded, color: Colors.redAccent, size: 28),
                const Spacer(),
                Text(
                  module.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "${module.chapters.length} items",
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} // <--- This brace closes the Navigation Page State

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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(widget.module.name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: widget.module.chapters.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            title: Text(
              widget.module.chapters[index].title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            leading: const Icon(Icons.menu_book_rounded, color: Colors.redAccent),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        onPressed: () => _showAddDialog(context, _addChapter, "Chapter"),
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
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("New $hint",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Enter $hint name",
          hintStyle: const TextStyle(color: Colors.white38),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              onSave(controller.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Add',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
