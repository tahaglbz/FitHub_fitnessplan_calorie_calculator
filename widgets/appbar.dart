import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String title;
  final bool autoback;
  final List<Widget>? actions; // Add actions as an optional parameter

  const CustomAppBar({
    super.key,
    this.scaffoldKey,
    required this.title,
    this.autoback = true,
    this.actions, // Initialize actions
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      leading: autoback
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
      actions: actions ??
          [
            IconButton(
              icon: Image.asset('lib/assets/menu-bar.png'),
              onPressed: () {
                scaffoldKey?.currentState?.openEndDrawer();
              },
            ),
          ],
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: GoogleFonts.agbalumo(
          textStyle: const TextStyle(color: Colors.white, fontSize: 50),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 73, 144, 201),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(31, 1, 106, 242),
              Color.fromARGB(255, 17, 157, 22),
              Color.fromARGB(255, 255, 158, 31),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
