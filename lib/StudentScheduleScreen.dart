import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentScheduleScreen extends StatefulWidget {
  final String studentId;
  const StudentScheduleScreen({super.key, required this.studentId});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  List<dynamic> schedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:3000/student/schedules/${widget.studentId}',
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          schedules = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Schedule error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        title: const Text("Менің сабақтарым"),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : schedules.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchSchedules,
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final lesson = schedules[index];
                  return _buildLessonCard(lesson);
                },
              ),
            ),
    );
  }

  Widget _buildLessonCard(dynamic lesson) {
    // Репетитор мәліметтері (populate арқылы келген)
    final tutor = lesson['tutorId'];

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  child: const Icon(Icons.school, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutor != null ? tutor['name'] : "Репетитор",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        tutor != null ? tutor['subject'] : "Пән",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(Icons.calendar_today, lesson['date']),
                _buildInfoItem(Icons.access_time, lesson['time']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text(
            "Әлі сабақтар белгіленбеді",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
