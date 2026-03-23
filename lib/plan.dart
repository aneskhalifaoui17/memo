import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}


class _CalendarPageState extends State<CalendarPage> {
  // We store which day is currently selected
  int selectedIndex = 1; // Default to Tuesday (17th)

  final List<String> days = ["M", "T", "W", "T", "F", "S", "S"];
  final List<String> dates = ["16", "17", "18", "19", "20", "21", "22"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      body: Column(
        children: [ // <--- The "List" of things in your column starts here
          // 1. The Gray Calendar Strip
          Container(
            color: const Color(0xFF1E1E1E), 
            padding: const EdgeInsets.symmetric(vertical: 20),
            height: 150, // I lowered this height so it's not too big
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedIndex = index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(days[index], style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.redAccent : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            dates[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 3. The empty area
          /*const Expanded(
            child: Center(
              child: Text("Tasks for this day will appear here", 
                style: TextStyle(color: Colors.white54)),
                
            ),
          ),*/
            // 2. BLOCK 2: THE ANYTIME SECTION (Now inside the children list!)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Anytime (0)",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                onTap: () {
                  _showAddTaskDialog(); // This calls the function we made in the last step
                },
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.grey),
                    Text(" Add an Anytime task", style: TextStyle(color: Colors.grey)),
                  ],
                ),
                  ),
                ),
              ]
                ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Anytime (0)",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                
              ],
            ),
          );
  }

void _showAddTaskDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E), // Match your dark theme
        title: const Text("New Anytime Task", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Prevents the pop-up from taking the whole screen
          children: [
            const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Task Name",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 15), // That vertical space you asked for!
            const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Add a note...",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Closes the pop-up
            child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            onPressed: () {
              // Later, we will add logic here to save the task
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      );
    },
  ); 
  } 
  }