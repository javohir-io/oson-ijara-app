import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A chip that opens a bottom sheet with a single-select list of options.
/// Shows [label] when nothing is picked, or "label: value" once selected.
class SelectableDropdownChip extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onSelected;

  const SelectableDropdownChip({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  bool get _isActive => value != null && value != options.first;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => _OptionSheet(title: label, options: options, current: value),
        );
        if (result != null) onSelected(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: _isActive ? AppColors.navyTint : AppColors.ivory,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _isActive ? AppColors.oceanBlue : AppColors.divider, width: _isActive ? 1.4 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isActive ? '$label: $value' : label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _isActive ? AppColors.navy : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _isActive ? AppColors.oceanBlue : AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _OptionSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? current;

  const _OptionSheet({required this.title, required this.options, required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(22),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, i) {
                  final o = options[i];
                  final selected = o == (current ?? options.first);
                  return ListTile(
                    onTap: () => Navigator.of(context).pop(o),
                    title: Text(o, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: AppColors.textPrimary)),
                    trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.oceanBlue) : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// A chip that opens a bottom sheet with a multi-select checklist.
class MultiSelectChip extends StatelessWidget {
  final String label;
  final Set<String> selected;
  final List<String> options;
  final ValueChanged<Set<String>> onChanged;

  const MultiSelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = selected.isNotEmpty;
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<Set<String>>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => _MultiOptionSheet(title: label, options: options, initial: selected),
        );
        if (result != null) onChanged(result);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isActive ? AppColors.navyTint : AppColors.ivory,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: isActive ? AppColors.oceanBlue : AppColors.divider, width: isActive ? 1.4 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isActive ? '$label (${selected.length})' : label,
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: isActive ? AppColors.navy : AppColors.textPrimary),
            ),
            const SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: isActive ? AppColors.oceanBlue : AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _MultiOptionSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final Set<String> initial;

  const _MultiOptionSheet({required this.title, required this.options, required this.initial});

  @override
  State<_MultiOptionSheet> createState() => _MultiOptionSheetState();
}

class _MultiOptionSheetState extends State<_MultiOptionSheet> {
  late Set<String> _temp = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.ivory, borderRadius: BorderRadius.circular(22)),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.options.length,
                itemBuilder: (context, i) {
                  final o = widget.options[i];
                  final selected = _temp.contains(o);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (v) => setState(() => v == true ? _temp.add(o) : _temp.remove(o)),
                    title: Text(o, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                    activeColor: AppColors.navy,
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _temp = {}),
                      child: const Text("Tozalash"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_temp),
                      child: const Text("Qo'llash"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberSelectorRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final int max;

  const NumberSelectorRow({super.key, required this.selected, required this.onChanged, this.max = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(max, (i) {
        final n = i + 1;
        final isSelected = n == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onChanged(n),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.navy : AppColors.ivory,
                border: Border.all(color: isSelected ? AppColors.navy : AppColors.divider),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.navy.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))]
                    : null,
              ),
              child: Text(
                '$n',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class DetailTag extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? value;

  const DetailTag({super.key, this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.oceanBlue),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: value == null ? label : '$label: ',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  if (value != null)
                    TextSpan(text: value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
