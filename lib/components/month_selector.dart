import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatelessWidget {
  final int thisYear = DateTime.now().year;
  final DateTime selectedMonth;
  final Function(DateTime) onPreviousMonthPressed;
  final Function() onCurrentMonthPressed;
  final Function(DateTime) onNextMonthPressed;

  MonthSelector({
    Key? key,
    required this.selectedMonth,
    required this.onPreviousMonthPressed,
    required this.onCurrentMonthPressed,
    required this.onNextMonthPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () {
            final previousMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
            onPreviousMonthPressed(previousMonth);
          },
        ),
        TextButton(
            onPressed: () {
              onCurrentMonthPressed();
            },
            style: ButtonStyle(fixedSize: MaterialStateProperty.resolveWith<Size?>((states) => const Size.fromWidth(112))),
            child: Text(
              DateFormat(thisYear == selectedMonth.year ? 'MMMM' : 'MMMM yyyy', 'pt_BR').format(selectedMonth),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () {
            final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
            onNextMonthPressed(nextMonth);
          },
        ),
      ],
    );
  }
}
