import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // We use extendBodyBehindAppBar so the background color shows under the status bar
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. THE BACKGROUND & PROFILE IMAGE SECTION
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none, // Allows the avatar to hang over the edge
              children: [
                // Stylized Background (Gradient block instead of a photo)
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2C2C2E), Color(0xFF1A1A1C)],
                    ),
                  ),
                ),
                // The Avatar
                Positioned(
                  top: 120, // Pushes it down to overlap the background
                  child: Container(
                    padding: const EdgeInsets.all(4), // White border effect
                    decoration: const BoxDecoration(
                      color: Color(0xFF121212),
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 55,
                      backgroundColor: Color(0xFF2C2C2E),
                      child: Icon(Icons.person, size: 60, color: Colors.white24),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70), // Space for the overlapping avatar

            // 2. USER INFO
            const Text(
              "CS Student",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const Text(
              "Level 1 Scholar",
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),

            const SizedBox(height: 25),

            // 3. LARGE EDIT BUTTON (Matches your Focus button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 20),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E), // Dark but distinct
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55), // Large and tall
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Colors.white10),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 4. THE OPTIONS BOX
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  _buildOption(Icons.dark_mode_outlined, "Dark Theme", "On"),
                  _buildDivider(),
                  _buildOption(Icons.auto_graph_rounded, "My Contributions", "12 Sessions"),
                  _buildDivider(),
                  _buildOption(Icons.people_outline_rounded, "Friends", "4"),
                  _buildDivider(),
                  _buildOption(Icons.calendar_month_outlined, "Join Date", "March 2026"),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, String trailing) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.redAccent, size: 20), // Accented icons
      ),
      title: Text(
        title, 
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)
      ),
      trailing: Text(trailing, style: const TextStyle(color: Colors.white38)),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 70);
  }
}