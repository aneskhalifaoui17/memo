import 'package:first_attemp/pomodoro.dart';
import 'package:flutter/material.dart';
import 'plan.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'profile.dart';
import 'feed.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// --- 1. THE GLOBAL LIST (ONLY ONE VERSION) ---
// This is the "Single Source of Truth" for your whole app.
List<Module> myModules = []; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyNavigationPage(),
    );
  }
}

// --- 2. DATA MODELS ---
class Chapter {
  String title;
  List<String> imagePaths;

  Chapter({required this.title, List<String>? imagePaths}) 
      : this.imagePaths = imagePaths ?? [];
}

class Module {
  String name;
  List<Chapter> chapters;
  Module({required this.name, List<Chapter>? chapters})
      : this.chapters = chapters ?? [];
}

// --- 3. MAIN NAVIGATION PAGE ---
class MyNavigationPage extends StatefulWidget {
  const MyNavigationPage({super.key});
  @override
  State<MyNavigationPage> createState() => _MyNavigationPageState();
}

class _MyNavigationPageState extends State<MyNavigationPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData(); // Loads data from disk when the app turns on
  }

  Future<void> _loadAllData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/vault_structure.json');

      if (await file.exists()) {
        final String content = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(content);
        setState(() {
          // Updating the GLOBAL myModules
          myModules = jsonList.map((m) {
            return Module(
              name: m['name'],
              chapters: (m['chapters'] as List).map((c) {
                return Chapter(
                  title: c['title'],
                  imagePaths: List<String>.from(c['imagePaths']),
                );
              }).toList(),
            );
          }).toList();
        });
      } else {
        // If no file exists, start with a default module
        setState(() {
          myModules = [Module(name: 'Mathematics')];
        });
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  void _addModule(String name) {
    setState(() => myModules.add(Module(name: name)));
    saveAllData(myModules); // Save immediately
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0: return AcademicFeedScreen();
      case 1: return _buildModuleGrid();
      case 2: return const CalendarPage();
      case 3: return const PomodoroScreen();
      case 4: return const ProfileScreen();
      default: return _buildModuleGrid();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Academic Vault', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: 'feed'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'achievments'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Pomodoro'),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: 'Me'),
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

  Widget _buildModuleGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.0,
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
            ).then((_) => setState(() {})); // Refresh grid when coming back
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.folder_rounded, color: Colors.redAccent, size: 28),
                const Spacer(),
                Text(module.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("${module.chapters.length} items", style: const TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- 4. MODULE DETAIL SCREEN ---
class ModuleDetailScreen extends StatefulWidget {
  final Module module;
  const ModuleDetailScreen({super.key, required this.module});
  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen> {
  final ImagePicker _picker = ImagePicker();

  void _showPhotoOptions(Chapter chapter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Wrap(
          children: [
            _buildPickerTile(chapter: chapter, icon: Icons.camera_alt_outlined, title: "Take a Photo", source: ImageSource.camera),
            const Divider(color: Colors.white10),
            _buildPickerTile(chapter: chapter, icon: Icons.photo_library_outlined, title: "Choose from Gallery", source: ImageSource.gallery),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile({required Chapter chapter, required IconData icon, required String title, required ImageSource source}) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: const Color(0xFF2C2C2E), child: Icon(icon, color: Colors.redAccent)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () async {
        Navigator.pop(context);
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          String fileName = "vault_${DateTime.now().millisecondsSinceEpoch}.jpg";
          String permanentPath = "${appDocDir.path}/$fileName";
          final File savedFile = await File(image.path).copy(permanentPath);

          setState(() {
            chapter.imagePaths.add(savedFile.path);
          });
          saveAllData(myModules); // CRITICAL: Save after photo added
        }
      },
    );
  }

  void _addChapter(String title) {
    setState(() {
      widget.module.chapters.add(Chapter(title: title));
    });
    saveAllData(myModules); // Save after chapter name added
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(widget.module.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.module.chapters.length,
        itemBuilder: (context, index) {
          final chapter = widget.module.chapters[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
            child: ExpansionTile(
              leading: const Icon(Icons.menu_book_rounded, color: Colors.redAccent),
              title: Text(chapter.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: chapter.imagePaths.length + 1,
                    itemBuilder: (context, imgIndex) {
                      if (imgIndex == chapter.imagePaths.length) {
                        return GestureDetector(
                          onTap: () => _showPhotoOptions(chapter),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.add_a_photo_outlined, color: Colors.white60),
                          ),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(chapter.imagePaths[imgIndex]), fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () => _showAddDialog(context, _addChapter, "Chapter"),
        child: const Icon(Icons.post_add),
      ),
    );
  }
}

// --- 5. SHARED HELPERS ---
void _showAddDialog(BuildContext context, Function(String) onSave, String hint) {
  TextEditingController controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("New $hint", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Enter $hint name",
          hintStyle: const TextStyle(color: Colors.white38),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
        TextButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              onSave(controller.text);
              Navigator.pop(context);
            }
          },
          child: const Text('Add', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

Future<void> saveAllData(List<Module> modules) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/vault_structure.json');
  List<Map<String, dynamic>> jsonData = modules.map((module) {
    return {
      'name': module.name,
      'chapters': module.chapters.map((chapter) {
        return {'title': chapter.title, 'imagePaths': chapter.imagePaths};
      }).toList(),
    };
  }).toList();
  await file.writeAsString(jsonEncode(jsonData));
}