import 'package:flutter/material.dart';
import '../models/filter_criteria.dart';
import '../theme/app_colors.dart';
import '../widgets/rounded_chip.dart';

class FilterScreen extends StatefulWidget {
  final FilterCriteria initial;
  const FilterScreen({super.key, this.initial = const FilterCriteria()});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const _locations = ['Barchasi', 'Yunusobod', 'Chirchiq', "Samarqand ko'chasi", "Mirzo Ulug'bek"];
  static const _amenityOptions = [
    "Wi-Fi", "Smart TV", "Konditsioner", "Basseyn", "Kir yuvish mashinasi",
    "Bolalar maydonchasi", "Milliy taomlar", "Talabalarga chegirma", "Yozish stoli",
  ];
  static const _floors = ['Barchasi', '1-3', '4-6', '7-10', '10+'];
  static const _renovations = ['Barchasi', 'Ideal', 'Yaxshi', "O'rtacha", 'Yomon'];
  static const _areas = ['Barchasi', '0-100 m²', '100-300 m²', '300-600 m²', '600+ m²'];

  late String _location = widget.initial.location;
  late Set<String> _amenities = {...widget.initial.amenities};
  late String _floorRange = widget.initial.floorRange;
  late String _renovation = widget.initial.renovation;
  late String _areaRange = widget.initial.areaRange;
  late bool _studentOnly = widget.initial.studentOnly;
  late RangeValues _priceRange = widget.initial.priceRange;
  late int _bedrooms = widget.initial.minBedrooms;
  late int _bathrooms = widget.initial.minBathrooms;

  String _fmt(double v) => v >= 1000000
      ? '${(v / 1000000).toStringAsFixed(v % 1000000 == 0 ? 0 : 1)}M'
      : '${(v / 1000).round()}K';

  void _reset() {
    setState(() {
      _location = 'Barchasi';
      _amenities = {};
      _floorRange = 'Barchasi';
      _renovation = 'Barchasi';
      _areaRange = 'Barchasi';
      _studentOnly = false;
      _priceRange = const RangeValues(150000, 90000000);
      _bedrooms = 1;
      _bathrooms = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text("FILTRLASH"),
        actions: [
          TextButton(onPressed: _reset, child: const Text("Tozalash")),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SelectableDropdownChip(
                    label: "Manzil",
                    value: _location,
                    options: _locations,
                    onSelected: (v) => setState(() => _location = v ?? 'Barchasi'),
                  ),
                  MultiSelectChip(
                    label: "Qulayliklar",
                    selected: _amenities,
                    options: _amenityOptions,
                    onChanged: (v) => setState(() => _amenities = v),
                  ),
                  SelectableDropdownChip(
                    label: "Qavat",
                    value: _floorRange,
                    options: _floors,
                    onSelected: (v) => setState(() => _floorRange = v ?? 'Barchasi'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SelectableDropdownChip(
                    label: "Ta'mir",
                    value: _renovation,
                    options: _renovations,
                    onSelected: (v) => setState(() => _renovation = v ?? 'Barchasi'),
                  ),
                  SelectableDropdownChip(
                    label: "Maydon",
                    value: _areaRange,
                    options: _areas,
                    onSelected: (v) => setState(() => _areaRange = v ?? 'Barchasi'),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Talaba", style: Theme.of(context).textTheme.titleMedium),
                  Switch(value: _studentOnly, onChanged: (v) => setState(() => _studentOnly = v)),
                ],
              ),
              const SizedBox(height: 18),
              Center(child: Text("Narx diapazoni", style: Theme.of(context).textTheme.headlineMedium)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${_fmt(_priceRange.start)} So'm", style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
                  Text("${_fmt(_priceRange.end)} So'm", style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
                ],
              ),
              RangeSlider(
                min: 150000,
                max: 90000000,
                values: _priceRange,
                onChanged: (v) => setState(() => _priceRange = v),
              ),
              const SizedBox(height: 16),
              Center(child: Text("Xonalar", style: Theme.of(context).textTheme.headlineMedium)),
              const SizedBox(height: 18),
              Text("Yotoqxonalar soni (kamida)", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              NumberSelectorRow(selected: _bedrooms, onChanged: (v) => setState(() => _bedrooms = v)),
              const SizedBox(height: 20),
              Text("Hammomlar soni (kamida)", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              NumberSelectorRow(selected: _bathrooms, onChanged: (v) => setState(() => _bathrooms = v)),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(FilterCriteria(
                    location: _location,
                    amenities: _amenities,
                    floorRange: _floorRange,
                    renovation: _renovation,
                    areaRange: _areaRange,
                    studentOnly: _studentOnly,
                    priceRange: _priceRange,
                    minBedrooms: _bedrooms,
                    minBathrooms: _bathrooms,
                  ));
                },
                child: const Text("TASDIQLASH"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
