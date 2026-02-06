import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TutorScheduleScreen extends StatefulWidget {
  final String tutorId;

  TutorScheduleScreen({required this.tutorId});

  @override
  _TutorScheduleScreenState createState() => _TutorScheduleScreenState();
}

class _TutorScheduleScreenState extends State<TutorScheduleScreen> {
  List<dynamic> schedules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSchedules();
  }

  Future<void> fetchSchedules() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/tutor/schedules/${widget.tutorId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          schedules = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Кестені жүктеу қатесі: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFD),
      body: Column(
        children: [
          // Дизайнды стильді Header
          _buildHeader(),

          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchSchedules,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : schedules.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) =>
                          _buildScheduleCard(schedules[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Кесте",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Жоспарланған сабақтар",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(dynamic lesson) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  lesson['time'] ?? "00:00",
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  lesson['date'] ?? "01.01", // КҮН ОСЫ ЖЕРДЕ ШЫҒАДЫ
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['subject'] ?? "Пән",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person, size: 12, color: Colors.grey),
                    ),
                    SizedBox(width: 8),
                    Text(
                      lesson['studentName'] ?? "Студент",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 100, color: Colors.grey[300]),
          SizedBox(height: 15),
          Text(
            "Әзірге сабақтар жоқ",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
