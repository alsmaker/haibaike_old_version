import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {

    if(newValue.selection.baseOffset == 0){
      print(newValue.selection.baseOffset);
      return newValue.copyWith(text: '');
    } else if(newValue.text.compareTo(oldValue.text) != 0) {
      int selectionIndexFromTheRight = newValue.text.length - newValue.selection.end;
      final formatter = NumberFormat('#,###');
      int value = int.parse(newValue.text.replaceAll(formatter.symbols.GROUP_SEP, ''));
      String newText = formatter.format(value);

      return newValue.copyWith(
          text: newText,
          selection: new TextSelection.collapsed(offset: newText.length-selectionIndexFromTheRight));
    } else {
      return newValue;
    }
  }
}