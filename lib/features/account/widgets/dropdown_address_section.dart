import 'package:flutter/material.dart';

class DropdownAddressSection extends StatefulWidget {
  final List<String> countries;
  final String? selectedCountry;
  final ValueChanged<String?> onCountryChanged;
  final List<String> provinces;
  final String? selectedProvince;
  final ValueChanged<String?> onProvinceChanged;
  final List<String> cities;
  final String? selectedCity;
  final ValueChanged<String?> onCityChanged;

  const DropdownAddressSection({
    super.key,
    required this.countries,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.provinces,
    required this.selectedProvince,
    required this.onProvinceChanged,
    required this.cities,
    required this.selectedCity,
    required this.onCityChanged,
  });

  @override
  State<DropdownAddressSection> createState() => _DropdownAddressSectionState();
}

class _DropdownAddressSectionState extends State<DropdownAddressSection> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Country'),
          value: widget.selectedCountry,
          items: widget.countries.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: widget.onCountryChanged,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Province'),
          value: widget.selectedProvince,
          items: widget.provinces.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: widget.provinces.isNotEmpty ? widget.onProvinceChanged : null,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'City/Municipality'),
          value: widget.selectedCity,
          items: widget.cities.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: widget.cities.isNotEmpty ? widget.onCityChanged : null,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
