import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DateRangePickerWidget extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const DateRangePickerWidget({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeSelected,
  });

  @override
  State<DateRangePickerWidget> createState() => _DateRangePickerWidgetState();
}

class _DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedPeriod = 'all'; // all, today, week, month, year, custom

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  void _selectPeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      final now = DateTime.now();

      switch (period) {
        case 'today':
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'week':
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _startDate = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'all':
          _startDate = null;
          _endDate = null;
          break;
        case 'custom':
          // Le custom sera géré par le picker manuel
          break;
      }

      if (period != 'custom') {
        widget.onDateRangeSelected(_startDate, _endDate);
      }
    });
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPeriod = 'custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
      widget.onDateRangeSelected(_startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Période',
          style: TextStyle(
            fontFamily: 'AmazonEmberDisplay',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPeriodChip('Tout', 'all'),
            _buildPeriodChip('Aujourd\'hui', 'today'),
            _buildPeriodChip('Cette semaine', 'week'),
            _buildPeriodChip('Ce mois', 'month'),
            _buildPeriodChip('Cette année', 'year'),
            _buildPeriodChip('Personnalisé', 'custom', onTap: _pickDateRange),
          ],
        ),
        if (_selectedPeriod == 'custom' && _startDate != null && _endDate != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}',
                    style: const TextStyle(
                      fontFamily: 'AmazonEmberDisplay',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
                  onPressed: _pickDateRange,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPeriodChip(String label, String value, {VoidCallback? onTap}) {
    final isSelected = _selectedPeriod == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (onTap != null) {
          onTap();
        } else {
          _selectPeriod(value);
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontFamily: 'AmazonEmberDisplay',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: isSelected ? Colors.white : Colors.grey[700],
      ),
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}
