import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> units = [
    {
      'title': 'Длина',
      'route': '/length',
      'icon': Icons.straighten,
      'color': Colors.blue,
    },
    {
      'title': 'Площадь',
      'route': '/area',
      'icon': Icons.square_foot,
      'color': Colors.pink,
    },
    {
      'title': 'Объём',
      'route': '/volume',
      'icon': Icons.water_drop,
      'color': Colors.cyan,
    },
    {
      'title': 'Скорость',
      'route': '/speed',
      'icon': Icons.speed,
      'color': Colors.purple,
    },
    {
      'title': 'Масса',
      'route': '/mass',
      'icon': Icons.fitness_center,
      'color': Colors.green,
    },
    {
      'title': 'Температура',
      'route': '/temperature',
      'icon': Icons.thermostat,
      'color': Colors.orange,
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredUnits = units
        .where(
          (unit) =>
              unit['title'].toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Конвертер величин',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Поле поиска
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Поиск единиц...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Сетка категорий
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: filteredUnits.length,
              itemBuilder: (context, index) {
                final unit = filteredUnits[index];
                return GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, unit['route'] as String),
                  child: Container(
                    decoration: BoxDecoration(
                      color: unit['color'] as Color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (unit['color'] as Color).withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          unit['icon'] as IconData,
                          size: 45,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          unit['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
