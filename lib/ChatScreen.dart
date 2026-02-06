import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:url_launcher/url_launcher.dart';
import 'LocationPickerScreen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String studentId;
  final String tutorId;
  final String chatPartnerName; // 👈 tutorName-ді chatPartnerName деп өзгерттік
  final bool autoSendTemplate;
  final bool isStudent;

  const ChatScreen({
    Key? key,
    required this.studentId,
    required this.tutorId,
    required this.chatPartnerName, // 👈 жаңартылған атау
    this.autoSendTemplate = false,
    required this.isStudent,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  String room = "";

  @override
  void initState() {
    super.initState();
    // 🔍 ОСЫ ЖЕРДІ ТЕКСЕР:
    print("🔍 CHAT DEBUG: studentId = '${widget.studentId}'");
    print("🔍 CHAT DEBUG: tutorId = '${widget.tutorId}'");
    // Бөлме ID-ін жасау (ID-лерді сұрыптау арқылы тұрақтылықты сақтаймыз)
    List<String> ids = [widget.studentId, widget.tutorId];
    ids.sort();
    room = ids.join("_");
    initSocket();
  }

  void initSocket() {
    // ⚠️ Сервер адресін тексер (Эмулятор үшін: 10.0.2.2, шын телефон үшін IP)
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      debugPrint('✅ Серверге қосылды');
      socket.emit('join_room', room);

      // Алғашқы шаблон хатты жіберу
      if (widget.autoSendTemplate && messages.isEmpty) {
        _sendMessage("Сәлеметсіз бе! Сіздің сабағыңызға жазылайын деп едім.");
      }
    });

    // 1. Чат тарихын алу
    socket.on('chat_history', (data) {
      if (mounted) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(data);
        });
      }
    });

    // 2. Жаңа хабарлама алу
    socket.on('receive_message', (data) {
      print("DEBUG receive_message: $data");
      if (mounted) {
        setState(() {
          messages.add(data);
        });
      }
    });

    // 3. Репетитор қабылдағанда хат статусын жаңарту
    socket.on('request_accepted', (data) {
      if (mounted) {
        setState(() {
          int index = messages.indexWhere((m) => m['_id'] == data['messageId']);
          if (index != -1) {
            messages[index]['status'] = 'accepted';
          }
        });
      }
    });
  }

  void _sendMessage(
    String text, {
    String type = 'text',
    String? lat,
    String? lon,
  }) {
    if (text.trim().isEmpty && type == 'text') return;

    String currentSenderId = widget.isStudent
        ? widget.studentId
        : widget.tutorId;
    String currentReceiverId = widget.isStudent
        ? widget.tutorId
        : widget.studentId;
    String senderRole = widget.isStudent ? 'STUDENT' : 'TUTOR';
    String receiverRole = widget.isStudent ? 'TUTOR' : 'STUDENT';

    var messageData = {
      'room': room,
      'senderId': currentSenderId,
      'receiverId': currentReceiverId,
      'senderRole': senderRole,
      'receiverRole': receiverRole,
      'text': text,
      'type': type,
      'lat': lat,
      'lon': lon,
      'status': 'pending',
      'timestamp': DateTime.now().toIso8601String(),
    };

    socket.emit('send_message', messageData);

    // Өз хатын чатта дереу көрсету
    setState(() {
      messages.add(messageData);
    });

    _messageController.clear();
  }

  // Сұранысты қабылдау (Тек репетитор үшін)
  void _acceptRequest(String messageId) {
    socket.emit('accept_request', {
      'room': room,
      'messageId': messageId,
      'tutorId': widget.tutorId,
      'studentId': widget.studentId,
    });
  }

  // 🗓 Күн мен уақыт таңдау
  Future<void> _showInviteDialog() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        String formattedInvite =
            "${pickedDate.day}.${pickedDate.month}.${pickedDate.year} сағат ${pickedTime.format(context)}";
        _sendMessage(formattedInvite, type: 'invite');
      }
    }
  }

  // 📍 2GIS-те ашу
  Future<void> _openIn2GIS(String lat, String lon) async {
    final String url = "https://2gis.kz/geo/$lon,$lat";
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint("2GIS ашылмады");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Студентке репетитор аты, репетиторға студент аты көрінеді
        title: Text(widget.chatPartnerName),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                // Қазіргі қолданушының кім екенін анықтау
                String myId = widget.isStudent
                    ? widget.studentId
                    : widget.tutorId;

                // Егер базадағы 'sender' менің ID-іме тең болса - оң жақ
                bool isMe = msg['senderId'].toString() == myId;

                return _buildMessageBubble(msg, isMe);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  } // <--- build методы осы жерде жабылуы керек

  // Төмендегі көмекші виджеттер build-тан тыс тұрады:

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    if (msg['type'] == null) return _buildTextBubble(msg, isMe);
    if (msg['type'] == 'invite') return _buildInviteCard(msg, isMe);
    if (msg['type'] == 'location') return _buildLocationCard(msg, isMe);
    return _buildTextBubble(msg, isMe);
  }

  // ... қалған _buildTextBubble, _buildInviteCard, _buildLocationCard виджеттері өзгеріссіз қалады

  Widget _buildTextBubble(Map<String, dynamic> msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF1E3A8A) : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          msg['text'] ?? "",
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildInviteCard(Map<String, dynamic> msg, bool isMe) {
    bool isAccepted = msg['status'] == 'accepted';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isAccepted ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isAccepted ? Colors.green : Colors.blue.shade100,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isAccepted ? Icons.check_circle : Icons.event,
            color: isAccepted ? Colors.green : Colors.blue,
            size: 30,
          ),
          const SizedBox(height: 5),
          const Text(
            "Кездесу уақыты:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(msg['text'] ?? ""),
          const Divider(),
          if (!isMe && !isAccepted)
            ElevatedButton(
              onPressed: () => _acceptRequest(msg['_id']),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Қабылдау"),
            )
          else if (isAccepted)
            const Text(
              "✅ Қабылданды",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> msg, bool isMe) {
    return InkWell(
      // ChatScreen.dart ішіндегі _buildLocationCard немесе _openIn2GIS шақырылатын жер
      onTap: () {
        // lat пен lon бар екеніне көз жеткіземіз
        if (msg['location'] != null) {
          _openIn2GIS(msg['location']['lat'], msg['location']['lon']);
        } else {
          debugPrint("❌ Қате: Координаттар табылмады");
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF63B021), width: 2),
        ),
        child: Column(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF63B021), size: 30),
            const Text(
              "Кездесу орны",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              "2GIS картасынан ашу",
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.blue, size: 30),
            onPressed: _showPlusMenu,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Жазу...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF1E3A8A)),
            onPressed: () => _sendMessage(_messageController.text),
          ),
        ],
      ),
    );
  }

  void _pickLocation() async {
    // 1. Карта экранына өту және таңдалған LatLng нәтижесін күту
    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    // 2. Егер студент орынды таңдап, артқа қайтса
    if (result != null && result is LatLng) {
      _sendMessage(
        "📍 Кездесу орны (2GIS-пен ашу)",
        type: 'location',
        lat: result.latitude.toString(),
        lon: result.longitude.toString(),
      );
    }
  }

  void _showPlusMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.blue),
            title: const Text('Кездесу белгілеу'),
            onTap: () {
              Navigator.pop(context);
              _showInviteDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.green),
            title: const Text('2GIS орын таңдап жіберу'),
            onTap: () {
              Navigator.pop(context);
              _pickLocation(); // 👈 Статикалық хаттың орнына картаны ашамыз
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    _messageController.dispose();
    super.dispose();
  }
}
