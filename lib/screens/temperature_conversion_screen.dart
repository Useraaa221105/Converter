import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_keyboard.dart';

/// Экран конвертации температуры
/// Позволяет конвертировать между °C (Цельсий), °F (Фаренгейт), K (Кельвин)
class TemperatureConversionScreen extends StatefulWidget {
  const TemperatureConversionScreen({super.key});

  @override
  _TemperatureConversionScreenState createState() =>
      _TemperatureConversionScreenState();
}

class _TemperatureConversionScreenState
    extends State<TemperatureConversionScreen> {
  // Выбранная единица измерения "ОТ"
  String selectedUnitFrom = '°C';
  // Выбранная единица измерения "В"
  String selectedUnitTo = '°F';
  // Активное поле ввода (from или to)
  String activeField = 'from';
  // Значение входного числа
  String inputValue = '0';
  // Значение преобразованного числа
  String convertedValue = '0';

  /// Функция преобразования единиц температуры
  /// Переводит значение inputValue из selectedUnitFrom в selectedUnitTo
  void _updateConversion() {
    // Получаем числовое значение из строки
    double input = double.tryParse(inputValue) ?? 0.0;
    setState(() {
      // Если единицы одинаковые - результат равен входному значению
      if (selectedUnitFrom == selectedUnitTo) {
        convertedValue = _formatNumber(input);
      }
      // Преобразование Цельсий -> Фаренгейт: (°C × 9/5) + 32 = °F
      else if (selectedUnitFrom == '°C' && selectedUnitTo == '°F') {
        convertedValue = _formatNumber((input * 9 / 5) + 32);
      }
      // Преобразование Цельсий -> Кельвин: °C + 273.15 = K
      else if (selectedUnitFrom == '°C' && selectedUnitTo == 'K') {
        convertedValue = _formatNumber(input + 273.15);
      }
      // Преобразование Фаренгейт -> Цельсий: (°F - 32) × 5/9 = °C
      else if (selectedUnitFrom == '°F' && selectedUnitTo == '°C') {
        convertedValue = _formatNumber((input - 32) * 5 / 9);
      }
      // Преобразование Фаренгейт -> Кельвин: ((°F - 32) × 5/9) + 273.15 = K
      else if (selectedUnitFrom == '°F' && selectedUnitTo == 'K') {
        convertedValue = _formatNumber((input - 32) * 5 / 9 + 273.15);
      }
      // Преобразование Кельвин -> Цельсий: K - 273.15 = °C
      else if (selectedUnitFrom == 'K' && selectedUnitTo == '°C') {
        convertedValue = _formatNumber(input - 273.15);
      }
      // Преобразование Кельвин -> Фаренгейт: ((K - 273.15) × 9/5) + 32 = °F
      else if (selectedUnitFrom == 'K' && selectedUnitTo == '°F') {
        convertedValue = _formatNumber((input - 273.15) * 9 / 5 + 32);
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
    final units = ['°C', '°F', 'K'];
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
        title: Text('Перерасчёт температуры'),
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
          // Занимаем оставшееся место между полями и клавиатурой
          Spacer(),
          // Пользовательская клавиатура с цифрами и функциями
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
