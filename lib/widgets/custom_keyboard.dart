import 'package:flutter/material.dart';

/// Пользовательская клавиатура для конвертера
/// Содержит цифры 0-9, точку, операции и функциональные кнопки
class CustomKeyboard extends StatelessWidget {
  // Функция вызывается при нажатии на цифру/символ
  final Function(String) onKeyPressed;
  // Функция вызывается при нажатии на кнопку обмена единиц (swap)
  final Function() onSwapPressed;
  // Функция вызывается при нажатии на кнопку копирования
  final Function() onCopyPressed;

  const CustomKeyboard({super.key, 
    required this.onKeyPressed,
    required this.onSwapPressed,
    required this.onCopyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      // Количество столбцов в сетке клавиатуры
      crossAxisCount: 4,
      // Не занимаем больше места чем нужно
      shrinkWrap: true,
      // Отступ вокруг клавиатуры
      padding: const EdgeInsets.all(10),
      // Расстояние между кнопками по вертикали
      mainAxisSpacing: 8,
      // Расстояние между кнопками по горизонтали
      crossAxisSpacing: 8,
      // Массив кнопок в порядке отображения
      children: [
        // Ряд 1: 7, 8, 9, C
        _buildButton('7', () => onKeyPressed('7')),
        _buildButton('8', () => onKeyPressed('8')),
        _buildButton('9', () => onKeyPressed('9')),
        _buildButton(
            'C', () => onKeyPressed('C'), Colors.red), // Красная кнопка очистки

        // Ряд 2: 4, 5, 6, копирование
        _buildButton('4', () => onKeyPressed('4')),
        _buildButton('5', () => onKeyPressed('5')),
        _buildButton('6', () => onKeyPressed('6')),
        _buildIconButton(Icons.content_copy, onCopyPressed,
            Colors.blue), // Кнопка копирования в буфер обмена

        // Ряд 3: 1, 2, 3, DEL
        _buildButton('1', () => onKeyPressed('1')),
        _buildButton('2', () => onKeyPressed('2')),
        _buildButton('3', () => onKeyPressed('3')),
        _buildButton('<--', () => onKeyPressed('DEL'),
            Colors.orange), // Оранжевая кнопка удаления

        // Ряд 4: 00, 0, точка, обмен единиц
        _buildButton('00', () => onKeyPressed('00')),
        _buildButton('0', () => onKeyPressed('0')),
        _buildButton(
            '.', () => onKeyPressed('.')), // Точка для десятичных чисел
        _buildIconButton(Icons.swap_horiz, onSwapPressed,
            Colors.green), // Зеленая кнопка обмена единиц
      ],
    );
  }

  /// Создание обычной кнопки с текстом
  /// text - текст на кнопке
  /// onPressed - функция вызова при нажатии
  /// color - цвет фона кнопки
  Widget _buildButton(String text, Function() onPressed,
      [Color? color = Colors.grey]) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // Цвет фона кнопки (серый по умолчанию)
        backgroundColor: color,
        // Скругленные углы кнопки
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      // Текст на кнопке
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  /// Создание кнопки с иконкой
  /// icon - иконка для отображения
  /// onPressed - функция вызова при нажатии
  /// color - цвет фона кнопки
  Widget _buildIconButton(IconData icon, Function() onPressed,
      [Color? color = Colors.grey]) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // Цвет фона кнопки
        backgroundColor: color,
        // Скругленные углы кнопки
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      // Иконка на кнопке
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
