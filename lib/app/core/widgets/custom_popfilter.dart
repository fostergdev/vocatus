import 'package:flutter/material.dart';

class CustomPopupFilter extends StatelessWidget {
  final Widget icon;
  final bool initialActive;
  final int initialYear;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<int> onYearChanged;
  final List<int>? years;

  const CustomPopupFilter({
    super.key,
    this.icon = const Icon(Icons.filter_alt),
    required this.initialActive,
    required this.initialYear,
    required this.onActiveChanged,
    required this.onYearChanged,
    this.years,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: Colors.purple.shade800.withAlpha(235),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      icon: icon,
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          enabled: false, // Não fecha ao interagir
          child: StatefulBuilder(
            builder: (context, setState) {
              bool tempActive = initialActive;
              int tempYear = initialYear;
              final yearList = years ?? List.generate(10, (i) => DateTime.now().year - i);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    value: tempActive,
                    title: const Text('Mostrar apenas ativas', style: TextStyle(color: Colors.white)),
                    onChanged: (val) {
                      setState(() => tempActive = val!);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.white,
                    checkColor: Colors.purple,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Ano:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        dropdownColor: Colors.purple.shade900,
                        value: tempYear,
                        style: const TextStyle(color: Colors.white),
                        items: yearList
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString(), style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() => tempYear = val!);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      onActiveChanged(tempActive);
                      onYearChanged(tempYear);
                      Navigator.of(context).pop(); // Fecha o popup
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple.shade800,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Filtrar'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}