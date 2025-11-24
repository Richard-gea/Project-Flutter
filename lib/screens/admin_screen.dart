import "package:flutter/material.dart";

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Portal"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Admin Portal - Coming Soon!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
