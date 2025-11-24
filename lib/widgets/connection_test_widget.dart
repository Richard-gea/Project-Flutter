import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ConnectionTestWidget extends StatefulWidget {
  const ConnectionTestWidget({super.key});

  @override
  State<ConnectionTestWidget> createState() => _ConnectionTestWidgetState();
}

class _ConnectionTestWidgetState extends State<ConnectionTestWidget> {
  String _status = 'Not tested';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing connection...';
    });

    try {
      print('🔄 Testing connection to MongoDB backend...');
      final healthStatus = await ApiService.getHealthStatus();
      setState(() {
        _status = '✅ Connected! Status: ${healthStatus['status']}';
        _isLoading = false;
      });
      print('✅ Health status: $healthStatus');
    } catch (e) {
      setState(() {
        _status = '❌ Connection failed: $e';
        _isLoading = false;
      });
      print('❌ Connection test failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Backend Connection Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Current API URL: ${ApiService.baseUrl}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(
                fontSize: 14,
                color: _status.contains('✅') 
                    ? Colors.green 
                    : _status.contains('❌') 
                        ? Colors.red 
                        : Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading 
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test Connection'),
            ),
          ],
        ),
      ),
    );
  }
}