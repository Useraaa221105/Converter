import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_keyboard.dart';

/// Экран конвертации площади
/// Позволяет конвертировать между м², см², км²
class AreaConversionScreen extends StatefulWidget {
  const AreaConversionScreen({super.key});

  @override
  _AreaConversionScreenState createState() => _AreaConversionScreenState();
}

class _AreaConversionScreenState extends State<AreaConversionScreen> {
  // Выбранная единица измерения "ОТ"
  String selectedUnitFrom = 'м²';
  // Выбранная единица измерения "В"
  String selectedUnitTo = 'см²';
  // Активное поле ввода (from или to)
  String activeField = 'from';
  // Значение входного числа
  String inputValue = '0';
  // Значение преобразованного числа
  String convertedValue = '0';

  /// Функция преобразования единиц площади
  /// Переводит значение inputValue из selectedUnitFrom в selectedUnitTo
  void _updateConversion() {
    // Получаем числовое значение из строки
    double input = double.tryParse(inputValue) ?? 0.0;
    setState(() {
      // Если единицы одинаковые - результат равен входному значению
      if (selectedUnitFrom == selectedUnitTo) {
        convertedValue = _formatNumber(input);
      }
      // Преобразование сантиметры² -> метры²
      else if (selectedUnitFrom == 'см²' && selectedUnitTo == 'м²') {
        convertedValue = _formatNumber(input / 10000);
      }
      // Преобразование сантиметры² -> километры²
      else if (selectedUnitFrom == 'см²' && selectedUnitTo == 'км²') {
        convertedValue = _formatNumber(input / 10000000000);
      }
      // Преобразование метры² -> сантиметры²
      else if (selectedUnitFrom == 'м²' && selectedUnitTo == 'см²') {
        convertedValue = _formatNumber(input * 10000);
      }
      // Преобразование метры² -> километры²
      else if (selectedUnitFrom == 'м²' && selectedUnitTo == 'км²') {
        convertedValue = _formatNumber(input / 1000000);
      }
      // Преобразование километры² -> сантиметры²
      else if (selectedUnitFrom == 'км²' && selectedUnitTo == 'см²') {
        convertedValue = _formatNumber(input * 10000000000);
      }
      // Преобразование километры² -> метры²
      else if (selectedUnitFrom == 'км²' && selectedUnitTo == 'м²') {
        convertedValue = _formatNumber(input * 1000000);
      }
    });
  }

  /// Форматирование числа с удалением лишних нулей
  /// Пример: 100.000000 -> 100
  String _formatNumber(double number) {
    return number
        .toStringAsFixed(6) // Устанавливаем 6 знаков после запятой
        .replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), ''); // Удаляем нули в конце
  }

  /// Копирование результата в буфер обмена
  /// При успехе показывает уведомление SnackBar
  void _copyToClipboard() {
    // Устанавливаем текст в буфер обмена системы
    Clipboard.setData(ClipboardData(text: convertedValue));
    // Показываем уведомление пользователю
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Скопировано: $convertedValue'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Обработчик нажатий кнопок на клавиатуре
  /// key - нажатая кнопка (цифра, точка, C, DEL и т.д.)
  void _handleKeyPress(String key) {
    setState(() {
      // Кнопка "C" - очистка (reset на 0)
      if (key == 'C') {
        inputValue = '0';
      }
      // Кнопка "DEL" - удаление последнего символа
      else if (key == 'DEL') {
        inputValue = inputValue.length > 1
            ? inputValue.substring(0, inputValue.length - 1)
            : '0';
      }
      // Точка - разделитель для десятичных чисел
      // Не добавляем точку, если она уже есть
      else if (key == '.' && inputValue.contains('.')) {
        return;
      }
      // Для остальных символов (цифры) добавляем их
      else {
        // Если первое значение 0 - заменяем его, иначе добавляем к концу
        inputValue = inputValue == '0' ? key : inputValue + key;
      }
      // Пересчитываем результат конвертации
      _updateConversion();
    });
  }

  /// Диалог выбора единицы измерения
  /// isFrom = true -> выбираем единицу "ОТ"
  /// isFrom = false -> выбираем единицу "В"
  Future<void> _selectUnit(BuildContext context, bool isFrom) async {
    final units = ['м²', 'см²', 'км²'];
    final selectedUnit = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          'Выберите единицу',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: units
            .map((unit) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, unit),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ))
            .toList(),
      ),
    );

    if (selectedUnit != null) {
      setState(() {
        if (isFrom) {
          selectedUnitFrom = selectedUnit;
        } else {
          selectedUnitTo = selectedUnit;
        }
        _updateConversion();
      });
    }
  }

  /// Обмен единиц местами (swap)
  /// Переводит "ОТ" в "В" и наоборот
  void _swapUnits() {
    setState(() {
      // Используем временную переменную для обмена
      String temp = selectedUnitFrom;
      selectedUnitFrom = selectedUnitTo;
      selectedUnitTo = temp;
      // Пересчитываем результат
      _updateConversion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Перерасчёт площади'),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          // ПОЛЕ "ОТ"
          GestureDetector(
            onTap: () {
              setState(() {
                activeField = 'from';
              });
            },
            child: ListTile(
              title: Text(
                selectedUnitFrom,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: Text(
                inputValue,
                style: TextStyle(
                  color: activeField == 'from' ? Colors.orange : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onTap: () => _selectUnit(context, true),
            ),
          ),
          // ПОЛЕ "В"
          GestureDetector(
            onTap: () {
              setState(() {
                activeField = 'to';
              });
            },
            child: ListTile(
              title: Text(
                selectedUnitTo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: Text(
                convertedValue,
                style: TextStyle(
                  color: activeField == 'to' ? Colors.orange : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              onTap: () => _selectUnit(context, false),
            ),
          ),
          Spacer(),
          CustomKeyboard(
            onKeyPressed: _handleKeyPress,
            onSwapPressed: _swapUnits,
            onCopyPressed: _copyToClipboard,
          ),
        ],
      ),
    );
  }
}
