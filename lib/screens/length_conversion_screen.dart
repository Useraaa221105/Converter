import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_keyboard.dart';

class LengthConversionScreen extends StatefulWidget {
  const LengthConversionScreen({super.key});

  @override
  _LengthConversionScreenState createState() => _LengthConversionScreenState();
}

class _LengthConversionScreenState extends State<LengthConversionScreen> {
  // Выбранная единица измерения "ОТ"
  String selectedUnitFrom = 'м';
  // Выбранная единица измерения "В"
  String selectedUnitTo = 'см';
  // Активное поле ввода (from или to)
  String activeField = 'from';
  // Значение входного числа
  String inputValue = '0';
  // Значение преобразованного числа
  String convertedValue = '0';

  /// Функция преобразования единиц измерения
  /// Переводит значение inputValue из selectedUnitFrom в selectedUnitTo
  void _updateConversion() {
    // Получаем числовое значение из строки
    double input = double.tryParse(inputValue) ?? 0.0;
    setState(() {
      // Если единицы одинаковые - результат равен входному значению
      if (selectedUnitFrom == selectedUnitTo) {
        convertedValue = _formatNumber(input);
      }
      // Преобразование метры -> сантиметры
      else if (selectedUnitFrom == 'м' && selectedUnitTo == 'см') {
        convertedValue = _formatNumber(input * 100);
      }
      // Преобразование метры -> миллиметры
      else if (selectedUnitFrom == 'м' && selectedUnitTo == 'мм') {
        convertedValue = _formatNumber(input * 1000);
      }
      // Преобразование сантиметры -> метры
      else if (selectedUnitFrom == 'см' && selectedUnitTo == 'м') {
        convertedValue = _formatNumber(input / 100);
      }
      // Преобразование сантиметры -> миллиметры
      else if (selectedUnitFrom == 'см' && selectedUnitTo == 'мм') {
        convertedValue = _formatNumber(input * 10);
      }
      // Преобразование миллиметры -> метры
      else if (selectedUnitFrom == 'мм' && selectedUnitTo == 'м') {
        convertedValue = _formatNumber(input / 1000);
      }
      // Преобразование миллиметры -> сантиметры
      else if (selectedUnitFrom == 'мм' && selectedUnitTo == 'см') {
        convertedValue = _formatNumber(input / 10);
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
  Future<void> _selectUnit(BuildContext context, bool isFrom) async {
    final units = ['м', 'см', 'мм'];
    final selectedUnit = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          'Выберите единицу',
          style: TextStyle(
            fontWeight: FontWeight.bold,  // ✅ Жирный заголовок
            fontSize: 16,
          ),
        ),
        children: units
            .map((unit) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, unit),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,  // ✅ Жирный текст
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
        title: Text('Перерасчёт длины'),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          // ПОЛЕ "ОТ" - входное значение
          GestureDetector(
            onTap: () {
              setState(() {
                activeField = 'from';
              });
            },
            child: ListTile(
              // Единица "ОТ" -  жирная
              title: Text(
                selectedUnitFrom,
                style: TextStyle(
                  fontWeight: FontWeight.bold, //  Жирная
                  fontSize: 16,
                ),
              ),
              // Входное значение -  жирное
              trailing: Text(
                inputValue,
                style: TextStyle(
                  color: activeField == 'from' ? Colors.orange : Colors.black,
                  fontWeight: FontWeight.bold, //  Жирное
                  fontSize: 18,
                ),
              ),
              onTap: () => _selectUnit(context, true),
            ),
          ),
          // ПОЛЕ "В" - результат конвертации
          GestureDetector(
            onTap: () {
              setState(() {
                activeField = 'to';
              });
            },
            child: ListTile(
              // Единица "В" - теперь жирная
              title: Text(
                selectedUnitTo,
                style: TextStyle(
                  fontWeight: FontWeight.bold, // ✅ Жирная
                  fontSize: 16,
                ),
              ),
              // Результат - теперь жирный
              trailing: Text(
                convertedValue,
                style: TextStyle(
                  color: activeField == 'to' ? Colors.orange : Colors.black,
                  fontWeight: FontWeight.bold, // ✅ Жирный
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
