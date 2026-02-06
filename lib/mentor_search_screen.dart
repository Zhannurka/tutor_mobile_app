import 'package:flutter/material.dart';


// Түстерді және жалпы стильдерді қайта пайдалану үшін
const Color primaryGreen = Color(0xFF38B08B);
const Color primaryBlue = Color(0xFF4C75FF); // Сүзгі батырмалары үшін

// --- 1. ДЕРЕКТЕР МОДЕЛІ (Сүзгілер мен Дағдылар) ---
class MentorData {
  final String name;
  final String title;
  final String rate;
  final String specialization;
  final Color avatarColor;

  MentorData({
    required this.name,
    required this.title,
    required this.rate,
    required this.specialization,
    required this.avatarColor,
  });
}

// --------------------------------------------------
// Динамикалық сүзгілер үшін деректер құрылымы
// --------------------------------------------------
const Map<String, List<String>> specializationSkills = {
  'Школьные предметы': [
    'Математика',
    'Алгебра',
    'Геометрия',
    'Физика',
    'Химия',
    'Биология',
    'География',
    'История',
    'Казахский язык',
    'Русский язык',
    'Английский язык',
    'Литература',
    'Информатика',
  ],
  'Программирование и IT': [
    'Разработка моб. приложений (Flutter, Kotlin, Swift)',
    'Веб-разработка (HTML, CSS, JS, React, Django)',
    'Java / Python / C++ / C#',
    'Разработка игр (Unity, Unreal Engine)',
    'Кибербезопасность',
    'Анализ данных / Data Science',
    'Искусственный интеллект (AI, ML)',
    'SQL и базы данных',
  ],
  'Экономика и Бизнес': [
    'Экономика',
    'Финансы и бухгалтерия',
    'Маркетинг',
    'Менеджмент',
    'Предпринимательство',
    'Бизнес-аналитика',
  ],
  'Гуманитарные науки': [
    'Социология',
    'Психология',
    'Философия',
    'Политология',
    'Право / Юриспруденция',
  ],
  'Творчество и Дизайн': [
    'Графический дизайн (Photoshop, Illustrator, Figma)',
    'UX/UI-дизайн',
    '3D-моделирование',
    'Музыка (гитара, фортепиано, вокал)',
    'Рисование и живопись',
    'Фото- и видеомонтаж',
  ],
  'Языки': [
    'Английский',
    'Немецкий',
    'Французский',
    'Турецкий',
    'Корейский',
    'Китайский',
    'Арабский',
    'Испанский',
  ],
  'Личностное развитие': [
    'Ораторское искусство',
    'Тайм-менеджмент',
    'Лидерство',
    'Soft Skills',
    'Психология общения',
  ],
  'Подготовка к экзаменам': [
    'ЕНТ / SAT / IELTS / TOEFL',
    'Подготовка к колледжу или университету',
    'Вступительные экзамены',
  ],
};

// Студенттердің басты бетіндегі репетиторлардың мысал деректері
final List<MentorData> mockMentors = [
  MentorData(
    name: 'Төлеубай Аяужан',
    title: 'Социология',
    rate: '\$15k-25k/mo',
    specialization: 'Гуманитарные науки',
    avatarColor: Colors.blue.shade300,
  ),
  MentorData(
    name: 'Тайлақ Мадина',
    title: 'История Казахстана',
    rate: '\$10k-15k/mo',
    specialization: 'Школьные предметы',
    avatarColor: Colors.red.shade300,
  ),
  MentorData(
    name: 'Нұртас Жанерке',
    title: 'Flutter',
    rate: '\$10k-20k/mo',
    specialization: 'Программирование и IT',
    avatarColor: primaryGreen,
  ),
  MentorData(
    name: 'Иқамбаева Айым',
    title: 'Физика',
    rate: '\$10k-20k/mo',
    specialization: 'Гуманитарные науки',
    avatarColor: Colors.purple.shade300,
  ),
];

// --- 2. БАСТЫ ЭКРАН (MentorsScreen) ---
class MentorsScreen extends StatefulWidget {
  const MentorsScreen({super.key});

  @override
  State<MentorsScreen> createState() => _MentorsScreenState();
}

class _MentorsScreenState extends State<MentorsScreen> {
  String currentFilterSummary = '';

  void _openFilterDialog() async {
    final Map<String, dynamic>? result =
        await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return const FilterDialog();
          },
        );

    if (result != null) {
      setState(() {
        final specialization = result['specialization'] ?? 'Әркім';
        final skills = result['skills'] != null
            ? (result['skills'] as List).join(', ')
            : 'Жоқ';
        currentFilterSummary =
            'Фильтры были применены: $specialization, Навыки: $skills';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            toolbarHeight: 120,
            backgroundColor: Colors.white,
            title: const Text(
              'Все Репетиторы',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A38),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Поиск',
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _openFilterDialog,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (currentFilterSummary.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  currentFilterSummary,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final mentor = mockMentors[index];
              return _buildMentorCard(mentor);
            }, childCount: mockMentors.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ========================================================
      // 4. Төменгі Навигация (навигация қосылды)
      // ========================================================
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildMentorCard(MentorData mentor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: mentor.avatarColor,
              child: Text(
                mentor.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mentor.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2A38),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mentor.title,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      _buildPill(
                        mentor.specialization,
                        Colors.blue.shade100,
                        Colors.blue.shade800,
                      ),
                      _buildPill(
                        'Prototyping',
                        Colors.green.shade100,
                        Colors.green.shade800,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ========================================================
  // 4. Төменгі Навигация (навигация қосылды)
  // ========================================================
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // 🔹 Бұл экран — "Репетиторы"
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/studentHome');
          } else {
            debugPrint('Bottom Nav Item $index басылды');
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled, size: 28),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined, size: 28),
            label: 'Репетиторы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 28),
            label: 'Чаты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined, size: 28),
            label: 'Статьи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 28),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

// --- 3. ФИЛЬТР ДИАЛОГЫ (FilterDialog) ---
class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  bool highRating = false;
  String? selectedSpecialization;
  final Set<String> selectedSkills = {};

  Widget _buildRatingFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Рейтинг',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2A38),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Высокий рейтинг',
                style: TextStyle(color: Colors.grey),
              ),
              Switch(
                value: highRating,
                onChanged: (v) => setState(() => highRating = v),
                activeColor: primaryGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Специализация',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2A38),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: specializationSkills.keys.map((spec) {
            final selected = selectedSpecialization == spec;
            return ActionChip(
              label: Text(
                spec,
                style: TextStyle(color: selected ? Colors.white : Colors.black),
              ),
              backgroundColor: selected ? primaryBlue : Colors.grey.shade200,
              onPressed: () => setState(
                () => selectedSpecialization = selected ? null : spec,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillsFilter() {
    final List<String> availableSkills = selectedSpecialization != null
        ? specializationSkills[selectedSpecialization]!
        : [];

    if (availableSkills.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(
          'Чтобы увидеть навыки, выберите специализацию.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      children: availableSkills.map((skill) {
        final selected = selectedSkills.contains(skill);
        return ActionChip(
          label: Text(
            skill,
            style: TextStyle(color: selected ? Colors.white : Colors.black),
          ),
          backgroundColor: selected ? primaryGreen : Colors.grey.shade200,
          onPressed: () => setState(() {
            if (selected) {
              selectedSkills.remove(skill);
            } else {
              selectedSkills.add(skill);
            }
          }),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Фильтры',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingFilter(),
                  const Divider(),
                  _buildSpecializationFilter(),
                  const Divider(),
                  _buildSkillsFilter(),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: () => setState(() {
                    highRating = false;
                    selectedSpecialization = null;
                    selectedSkills.clear();
                  }),
                  child: const Text(
                    'Удалить все',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, {
                    'rating': highRating,
                    'specialization': selectedSpecialization,
                    'skills': selectedSkills.toList(),
                  }),
                  child: Text(
                    'Показать результаты (${mockMentors.length} раз)',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
