// --- Express.js және тәуелділіктерді қосу ---
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const bcrypt = require('bcryptjs'); // Құпия сөзді хештеу үшін
const cors = require('cors'); // Flutter қосымшасынан сұраулар қабылдау үшін
const http = require('http'); // WebSocket үшін қажет
const { Server } = require('socket.io'); // WebSocket үшін қажет

// 📸 СУРЕТ ЖҮКТЕУ ҮШІН КЕРЕК ПАКЕТТЕР
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;
const server = http.createServer(app); // HTTP сервер құру
const io = new Server(server, {
  cors: { origin: "*" } // Flutter-ден келетін WebSocket байланысына рұқсат
});

// --- Middleware ---
app.use(cors()); // Барлық Flutter сұрауларына рұқсат
app.use(bodyParser.json()); // JSON сұрауларды талдау

// 📸 СЕРВЕРДЕГІ СУРЕТТЕРГЕ ДОСТУП БЕРУ (Статикалық папка)
app.use('/uploads', express.static('uploads'));

app.post('/forgot-password', async (req, res) => {
  const { email, phone, newPassword } = req.body;

  try {
    // 1. Пайдаланушыны іздеу (роліне қарамастан)
    const user = await User.findOne({ email, phone });

    if (!user) {
      return res.status(404).json({ message: 'Мұндай деректері бар қолданушы табылмады' });
    }

    // 2. Жаңа құпия сөзді хештеу
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // 3. Базада жаңарту
    user.password = hashedPassword;
    await user.save();

    res.json({ message: 'Құпия сөз сәтті жаңартылды!' });
  } catch (error) {
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

// --- 1. MongoDB-ге қосылу ---
const MONGODB_URI = 'mongodb://localhost:27017/repetitorDB'; // Өз базаңның аты
mongoose.connect(MONGODB_URI)
  .then(() => console.log('✅ MongoDB-ге satti qosyldy.'))
  .catch(err => console.error('❌ MongoDB qosylu qatesi:', err));

  // 📸 МУЛЬТЕР БАПТАУЛАРЫ (Суретті қайда және қалай сақтау керек)
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const dir = './uploads/';
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir); // Папка жоқ болса, жасап береді
    }
    cb(null, dir);
  },
  filename: function (req, file, cb) {
    // Файл атын бірегей қылу: аватар-уақыт.сурет_форматы
    cb(null, 'avatar-' + Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage: storage });

// --- 2. Mongoose моделі (User) ---
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  phone: { type: String, required: false },
  password: { type: String, required: true },
  role: { type: String, enum: ['student', 'tutor'], required: true }, // 'tutor' немесе 'student'
  avatar: { type: String, default: "" }, // Аватарка үшін өріс
  studentsCount: { type: Number, default: 0 }, // Студенттер саны
  completedHours: { type: Number, default: 0 }, // Өтілген сағаттар
  subject: { type: String, default: "Пән таңдалмаған" },
  price: { type: Number, default: 0 },
  bio: { type: String, default: "Өзіңіз туралы ақпарат жазыңыз..." },
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', userSchema);

// Хабарламалар моделі (Чат тарихы үшін)
const messageSchema = new mongoose.Schema({

  room: { type: String, required: true },

  senderId: { type: String, required: true },
  senderRole: { type: String, enum: ['STUDENT', 'TUTOR'], required: true },

  receiverId: { type: String, required: true },
  receiverRole: { type: String, enum: ['STUDENT', 'TUTOR'], required: true },

  text: { type: String, required: true },
  type: { type: String, enum: ['text', 'invite', 'location', 'booking_request'], default: 'text' },

  status: { type: String, enum: ['pending', 'accepted'], default: 'pending' },

  location: {
    lat: String,
    lon: String
  },

  isRead: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});
const Message = mongoose.model('Message', messageSchema);


// 🆕 Сабақтар (Кесте) моделі
const lessonSchema = new mongoose.Schema({
  tutorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  studentId: { type: String, required: true }, // 👈 ОСЫНЫ ҚОСЫҢЫЗ
  studentName: String,
  subject: String,
  date: String,
  time: String,
  status: { type: String, default: 'scheduled' }
});
const Lesson = mongoose.model('Lesson', lessonSchema);

// --- 3. WebSocket Логикасы (Чат үшін) ---
// --- 3. WebSocket Логикасы ---
io.on('connection', (socket) => {
  console.log('📡 Jana qoldanushy qosyldy:', socket.id);

  socket.on('join_room', async (room) => {
  try {
    socket.join(room);
    const history = await Message.find({ room }).sort({ createdAt: 1 });
    socket.emit('chat_history', history);
  } catch (e) {
    console.error('join_room error', e);
  }
});


socket.on('send_message', async (data) => {
  try {
    const newMessage = new Message({
      room: data.room,

      senderId: data.senderId,
      senderRole: data.senderRole,
      receiverId: data.receiverId,
      receiverRole: data.receiverRole,


      text: data.text,
      type: data.type || 'text',
      status: 'pending',
      location: data.lat ? { lat: data.lat, lon: data.lon } : null
    });

    const savedMsg = await newMessage.save();
    io.to(data.room).emit('receive_message', savedMsg);
  } catch (err) {
    console.error("❌ send_message error:", err);
  }
  console.log('📨 send_message data:', data);

});



  // ✅ РЕПЕТИТОРДЫҢ ҚАБЫЛДАУЫ
  socket.on('accept_request', async (data) => {
    try {
      const updatedMsg = await Message.findByIdAndUpdate(
        data.messageId, { status: 'accepted' }, { new: true }
      );

      if (updatedMsg && updatedMsg.type === 'invite') {
        const student = await User.findById(data.studentId);
        const parts = updatedMsg.text.split(' сағат ');
        
      // index.js ішіндегі socket.on('accept_request', ...) бөліміне studentId қосыңыз
      const newLesson = new Lesson({
      tutorId: data.tutorId,
      studentId: data.studentId, // 👈 Осыны қосыңыз (lessonSchema-ға да studentId қосу керек)
      studentName: student ? student.name : "Студент",
      subject: "Жеке сабақ", 
      date: parts[0] || "Күні белгісіз",
      time: parts[1] || "Уақыты белгісіз",
      status: 'scheduled'
});
        await newLesson.save();
      }

      await User.findByIdAndUpdate(data.tutorId, { $inc: { studentsCount: 1 } });
      io.to(data.room).emit('request_accepted', { messageId: data.messageId, status: 'accepted' });
    } catch (err) { console.error("❌ Қабылдау қатесі:", err); }
  });

  socket.on('disconnect', () => console.log('🔌 Qoldanushy ajyrady'));
});



// --- 🧑‍🏫 Репетитор маршруттарын анықтау (ОСЫ ЖЕРГЕ НАЗАР АУДАР) ---
const tutorRouter = express.Router();

tutorRouter.post('/upload-avatar/:id', upload.single('avatar'), async (req, res) => {
  try {
    const avatarUrl = `http://localhost:3000/uploads/${req.file.filename}`;
    await User.findByIdAndUpdate(req.params.id, { avatar: avatarUrl });
    res.json({ message: 'Сәтті жүктелді', avatar: avatarUrl });
  } catch (error) { res.status(500).json({ message: 'Сервер қатесі' }); }
});

// Статистика алу
tutorRouter.get('/stats/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'Tabylmady' });
    res.json({
      name: user.name,
      email: user.email,
      avatar: user.avatar,
      subject: user.subject,
      price: user.price,
      bio: user.bio,
      studentsCount: user.studentsCount
    });
  } catch (error) { res.status(500).json({ message: 'Server error' }); }
});

tutorRouter.get('/new-messages/:id', async (req, res) => {
  const tutorId = req.params.id;
  const chats = await Message.aggregate([
   {$match: {
  receiverId: tutorId,
  receiverRole: 'TUTOR',
  isRead: false
}},
    { $sort: { createdAt: -1 } },
    { $group: { _id: "$room", lastMessage: { $first: "$text" }, senderId: { $first: "$senderId" } } }
  ]);
  res.json(chats);
});

// 1. Хабарламаларды алу маршрутын түзету (Timestamp-ты createdAt-қа ауыстыру)
app.get("/tutor/latestMessages/:tutorId", async (req, res) => {
  try {
    const tutorId = req.params.tutorId;

    // find() соңына .lean() қосу деректерді өңдеуді жеңілдетеді
    const messages = await Message.find({ 
      receiverId: tutorId, 
      senderRole: "STUDENT" 
    })
    .sort({ createdAt: -1 })
    .limit(5);

    // Әр хабарлама үшін жіберушінің атын User базасынан тауып қосамыз
    const messagesWithNames = await Promise.all(messages.map(async (msg) => {
      const student = await User.findById(msg.senderId).select('name');
      return {
        ...msg._doc, // хабарламаның барлық өрістері
        senderName: student ? student.name : "Белгісіз студент" // атын ауыстыру
      };
    }));
    
    res.json(messagesWithNames);
  } catch (error) {
    res.status(500).json({ message: "Хабарламаларды алу қатесі" });
  }
});


// 2. Бүгінгі ең жақын сабақты алу маршрутын қосу (ЖАҢА)
// 2. Бүгінгі ең жақын сабақты алу маршрутын ЖАҢАРТУ
tutorRouter.get('/today-lesson/:tutorId', async (req, res) => {
  try {
    const tutorId = req.params.tutorId;
    
    // Бүгінгі күнді алу. Маңызды: Егер базада дата "2026-02-02" болса, 
    // оны қазіргі уақытпен дәл салыстыру керек.
    const now = new Date();
    // Қазақстан уақытымен (UTC+5) датаны алу
    const todayStr = now.toLocaleDateString('en-CA'); // Нәтиже: "2026-02-02"

    // Базадан бүгінгі күнге жоспарланған сабақты іздеу
    const todayLesson = await Lesson.findOne({ 
      tutorId: tutorId, 
      date: todayStr,
      status: 'scheduled' 
    }).sort({ time: 1 }); // Ең ерте сабақты алу

    if (!todayLesson) {
      return res.json({}); 
    }

    res.json(todayLesson);
  } catch (error) {
    console.error("Кестені алу қатесі:", error);
    res.status(500).json({ message: "Серверлік қате" });
  }
});


// Профиль жаңарту
tutorRouter.put('/update-profile/:id', async (req, res) => {
  try {
    const { subject, price, bio } = req.body;
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id, { subject, price, bio }, { new: true }
    );
    res.json({ message: "Сәтті жаңартылды", user: updatedUser });
  } catch (error) { res.status(500).json({ message: "Error" }); }
});

// Репетитор роутерін қосу
app.use('/tutor', tutorRouter);


// ... (Socket.io ішіндегі send_message-ден кейін)

// 📝 Репетитор мәліметтерін жаңарту
tutorRouter.put('/update-profile/:id', async (req, res) => {
  try {
    const { subject, price, bio } = req.body;
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { subject, price, bio },
      { new: true } // Жаңартылған деректі қайтару
    );
    
    if (!updatedUser) return res.status(404).json({ message: "Қолданушы табылмады" });
    
    res.json({ message: "Профиль сәтті жаңартылды", user: updatedUser });
  } catch (error) {
    res.status(500).json({ message: "Сервер қатесі" });
  }
});

// Репетитор статистикасын алу (ЖАҢАРТЫЛҒАН)
tutorRouter.get('/stats/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ message: 'Tabylmady' });
    
    // Барлық қажетті мәліметтерді, соның ішінде жаңа өрістерді де жібереміз
    res.json({
      name: user.name,
      email: user.email,
      phone: user.phone || "Көрсетілмеген",
      avatar: user.avatar,
      studentsCount: user.studentsCount,
      completedHours: user.completedHours,
      // ❗ ОСЫ ЖЕРГЕ НАЗАР АУДАР: Жаңа өрістерді қостық
      subject: user.subject,
      price: user.price,
      bio: user.bio
    });
  } catch (error) {
    res.status(500).json({ message: 'Server qatesi' });
  }
});

// 🆕 КЕСТЕ: Репетитордың сабақтарын алу
tutorRouter.get('/schedules/:id', async (req, res) => {
  try {
    const lessons = await Lesson.find({ tutorId: req.params.id }).sort({ date: 1, time: 1 });
    res.json(lessons);
  } catch (error) {
    res.status(500).json({ message: 'Кестені алу қатесі' });
  }
});

// 🆕 ТЕСТ: Сабақ қосу (Базаға дерек енгізу үшін)
tutorRouter.post('/add-lesson', async (req, res) => {
  const { tutorId, studentName, subject, date, time } = req.body;
  try {
    const newLesson = new Lesson({ tutorId, studentName, subject, date, time });
    await newLesson.save();
    res.status(201).json({ message: 'Сабақ кестеге қосылды' });
  } catch (error) {
    res.status(500).json({ message: 'Сабақ қосу қатесі' });
  }
});

// --- Репетитор тіркелу маршруты ---
tutorRouter.post('/register', async (req, res) => {
  const { name, email, phone, password, role } = req.body;

  if (!name || !email || !password || role !== 'tutor') {
    return res.status(400).json({ message: 'Barlyq óristerdi toltyryńyz jáne rol "tutor" boluy kerek.' });
  }

  try {
    let user = await User.findOne({ email });
    if (user) {
      return res.status(409).json({ message: 'Bul elektrondyq poshta buryn tirkelgen.' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    user = new User({
      name,
      email,
      phone,
      password: hashedPassword,
      role: 'tutor'
    });

    await user.save();

    res.status(201).json({
      message: 'Repetitor sátti tirkeldi.',
      user: { name: user.name, email: user.email, role: user.role, _id: user._id }
    });
  } catch (error) {
    console.error('Registrasia qatesi:', error);
    res.status(500).json({ message: 'Tirkelu kezinde server qatesi oryn aldy.' });
  }
});

// --- Репетитор кіру маршруты ---
tutorRouter.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Elektrondyq poshta men qupia sózdi engizińiz.' });
  }

  try {
    const user = await User.findOne({ email, role: 'tutor' });

    if (!user) {
      return res.status(401).json({ message: 'Qoldanushy tabylmady nemese ol repetitor emes.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: 'Qupia sóz qate.' });
    }

    res.status(200).json({
      message: `Sátti kiru! Qosh keldińiz, ${user.name}.`,
      user: { name: user.name, email: user.email, role: user.role, _id: user._id }
    });
  } catch (error) {
    console.error('Kiru qatesi:', error);
    res.status(500).json({ message: 'Kiru kezinde server qatesi oryn aldy.' });
  }
});

app.use('/tutor', tutorRouter);

// =================================================================
// 🎓 --- Студент маршруттары ---
// =================================================================
const studentRouter = express.Router();

// --- Студент тіркелу маршруты ---
studentRouter.post('/register', async (req, res) => {
  const { name, email, phone, password, role } = req.body;

  if (!name || !email || !password || role !== 'student') {
    return res.status(400).json({ message: 'Barlyq óristerdi toltyryńyz jáne rol "student" boluy kerek.' });
  }

  try {
    let user = await User.findOne({ email });
    if (user) {
      return res.status(409).json({ message: 'Bul elektrondyq poshta buryn tirkelgen.' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    user = new User({
      name,
      email,
      phone,
      password: hashedPassword,
      role: 'student'
    });

    await user.save();

    res.status(201).json({
      message: 'Student sátti tirkeldi.',
      user: { name: user.name, email: user.email, role: user.role, _id: user._id }
    });
  } catch (error) {
    console.error('Student tirkelu qatesi:', error);
    res.status(500).json({ message: 'Tirkelu kezinde server qatesi oryn aldy.' });
  }
});

// Профильді жаңарту
studentRouter.put('/update-profile/:id', async (req, res) => {
  try {
    const { name, phone } = req.body;
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id, 
      { name, phone }, 
      { new: true }
    );
    res.json(updatedUser);
  } catch (error) {
    res.status(500).json({ message: "Қате орын алды" });
  }
});

// 📸 Студент аватаркасын жүктеу
studentRouter.post('/upload-avatar/:id', upload.single('avatar'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: 'Сурет таңдалмады' });

    const avatarUrl = `http://localhost:3000/uploads/${req.file.filename}`;
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { avatar: avatarUrl },
      { new: true }
    );

    res.json({ message: 'Сәтті жүктелді', avatar: avatarUrl });
  } catch (error) {
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});

studentRouter.get('/schedules/:id', async (req, res) => {
  try {
    // Студенттің ID-і бойынша сабақтарды табамыз және репетитордың атын қосамыз
    const lessons = await Lesson.find({ studentId: req.params.id })
                                .populate('tutorId', 'name subject avatar')
                                .sort({ date: 1, time: 1 });
    res.json(lessons);
  } catch (error) {
    res.status(500).json({ message: 'Кестені алу қатесі' });
  }
});
 // Өзінен басқа адамның (серіктестің) ID-ін анықтау partnerId: { $first: { $cond: [{ $eq: ["$sender", userId] }, "$receiverId", "$senderId"] } } }} ]);
// Студенттің қатысқан барлық чаттарын алу
studentRouter.get('/my-chats/:id', async (req, res) => {
  try {
    const userId = req.params.id; // Бұл жерде ID репетитордікі де, студенттікі де болуы мүмкін

    const chatList = await Message.aggregate([
      {
        $match: {
          $or: [ { senderId: userId }, { receiverId: userId } ] // Кім жіберсе де, осы адам қатысқан чаттарды тап
        }
      },
      { $sort: { createdAt: -1 } },
      {
        $group: {
          _id: "$room",
          lastMessage: { $first: "$text" },
          time: { $first: "$createdAt" },
          partnerId: {
            $first: {
              $cond: [{ $eq: ["$senderId", userId] }, "$receiverId", "$senderId"]
            }
          }
        }
      }
    ]);

    const detailedChats = await Promise.all(chatList.map(async (chat) => {
      const partner = await User.findById(chat.partnerId).select('name avatar');
      return {
        ...chat,
        partnerName: partner ? partner.name : "Пайдаланушы",
        avatar: partner ? partner.avatar : ""
      };
    }));

    res.json(detailedChats);
  } catch (error) {
    res.status(500).json({ message: "Чаттарды алу қатесі" });
  }
});


// 🎓 Барлық репетиторларды алу (Студент үшін)
studentRouter.get('/tutors', async (req, res) => {
  try {
    // Ролі 'tutor' болатын барлық қолданушыларды табамыз
    const tutors = await User.find({ role: 'tutor' }).select('-password'); // Құпия сөзді жібермейміз
    res.json(tutors);
  } catch (error) {
    res.status(500).json({ message: "Репетиторларды алу қатесі" });
  }
});
// --- Студент кіру маршруты ---
studentRouter.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Elektrondyq poshta men qupia sózdi engizińiz.' });
  }

  try {
    const user = await User.findOne({ email, role: 'student' });

    if (!user) {
      return res.status(401).json({ message: 'Qoldanushy tabylmady nemese ol student emes.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: 'Qupia sóz qate.' });
    }

    res.status(200).json({
      message: `Sátti kiru! Qosh keldińiz, ${user.name}.`,
      user: { name: user.name, email: user.email, role: user.role, _id: user._id }
    });
  } catch (error) {
    console.error('Kiru qatesi:', error);
    res.status(500).json({ message: 'Kiru kezinde server qatesi oryn aldy.' });
  }
});

// 🎓 Студенттің статистикасын/профилін алу (Осы жоқтықтан "Жүктелуде" болып тұрды)
studentRouter.get('/stats/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'Студент табылмады' });
    }
    
    // Flutter күтіп отырған деректерді жібереміз
    res.json({
      name: user.name,
      avatar: user.avatar || "",
      email: user.email,
      phone: user.phone || ""
    });
  } catch (error) {
    console.error('Студент дерегін алу қатесі:', error);
    res.status(500).json({ message: 'Сервер қатесі' });
  }
});


app.use('/student', studentRouter);

// =================================================================
// 🚀 Серверді іске қосу
// =================================================================
server.listen(PORT, () => {
  console.log(`✅ Server iske qosyldy: http://localhost:${PORT}`);
  console.log('Flutter qoldanbasymen bailanysqa daiyn.');
});