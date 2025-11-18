import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_keyboard.dart';

/// Экран конвертации объёма
/// Позволяет конвертировать между л (литр), мл (миллилитр), м³ (кубический метр)
class VolumeConversionScreen extends StatefulWidget {
  const VolumeConversionScreen({super.key});

  @override
  _VolumeConversionScreenState createState() => _VolumeConversionScreenState();
}

class _VolumeConversionScreenState extends State<VolumeConversionScreen> {
  // Выбранная единица измерения "ОТ"
  String selectedUnitFrom = 'л';
  // Выбранная единица измерения "В"
  String selectedUnitTo = 'мл';
  // Активное поле ввода (from или to)
  String activeField = 'from';
  // Значение входного числа
  String inputValue = '0';
  // Значение преобразованного числа
  String convertedValue = '0';

  /// Функция преобразования единиц объёма
  /// Переводит значение inputValue из selectedUnitFrom в selectedUnitTo
  void _updateConversion() {
    // Получаем числовое значение из строки
    double input = double.tryParse(inputValue) ?? 0.0;
    setState(() {
      // Если единицы одинаковые - результат равен входному значению
      if (selectedUnitFrom == selectedUnitTo) {
        convertedValue = _formatNumber(input);
      }
      // Преобразование литры -> миллилитры (1 л = 1000 мл)
      else if (selectedUnitFrom == 'л' && selectedUnitTo == 'мл') {
        convertedValue = _formatNumber(input * 1000);
      }
      // Преобразование литры -> кубические метры (1 л = 0.001 м³)
      else if (selectedUnitFrom == 'л' && selectedUnitTo == 'м³') {
        convertedValue = _formatNumber(input / 1000);
      }
      // Преобразование миллилитры -> литры (1 мл = 0.001 л)
      else if (selectedUnitFrom == 'мл' && selectedUnitTo == 'л') {
        convertedValue = _formatNumber(input / 1000);
      }
      // Преобразование миллилитры -> кубические метры (1 мл = 0.000001 м³)
      else if (selectedUnitFrom == 'мл' && selectedUnitTo == 'м³') {
        convertedValue = _formatNumber(input / 1000000);
      }
      // Преобразование кубические метры -> литры (1 м³ = 1000 л)
      else if (selectedUnitFrom == 'м³' && selectedUnitTo == 'л') {
        convertedValue = _formatNumber(input * 1000);
      }
      // Преобразование кубические метры -> миллилитры (1 м³ = 1000000 мл)
      else if (selectedUnitFrom == 'м³' && selectedUnitTo == 'мл') {
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
    // Список доступных единиц для объёма
    final units = ['л', 'мл', 'м³'];
    // Показываем диалоговое окно с выбором
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

    // Если пользователь выбрал единицу (не закрыл диалог)
    if (selectedUnit != null) {
      setState(() {
        // Обновляем соответствующую единицу
        if (isFrom) {
          selectedUnitFrom = selectedUnit;
        } else {
          selectedUnitTo = selectedUnit;
        }
        // Пересчитываем результат с новыми единицами
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
        title: Text('Перерасчёт объёма'),
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
