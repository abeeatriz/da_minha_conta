import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onPreviousMonthPressed;
  final Function() onCurrentMonthPressed;
  final Function(DateTime) onNextMonthPressed;

  const MonthSelector({
    Key? key,
    required this.selectedMonth,
    required this.onPreviousMonthPressed,
    required this.onCurrentMonthPressed,
    required this.onNextMonthPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          child: Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            onCurrentMonthPressed();
          },
        ),
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
