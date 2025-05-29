import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryFilterDialog extends StatefulWidget {
  final String? selected;
  const CategoryFilterDialog({this.selected, Key? key}) : super(key: key);

  @override
  State<CategoryFilterDialog> createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<CategoryFilterDialog> {
  String? _category;
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _category = widget.selected;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('categories').get();
      final cats = snap.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': (data['name'] ?? '').toString().trim(),
          'parent': (data['parent'] ?? '').toString(),
        };
      }).toList();
      setState(() {
        _categories = cats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load categories.';
        _loading = false;
      });
    }
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    List<DropdownMenuItem<String>> items = [
      DropdownMenuItem(value: '', child: Text('All Categories')),
    ];
    // Parent categories first, then subcategories indented
    final parents = _categories.where((c) => c['parent'].isEmpty).toList();
    final children = _categories.where((c) => c['parent'].isNotEmpty).toList();
    for (final parent in parents) {
      items.add(DropdownMenuItem(
        value: parent['name'],
        child: Text(parent['name']),
      ));
      for (final child in children.where((c) => c['parent'] == parent['id'])) {
        items.add(DropdownMenuItem(
          value: child['name'],
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(child['name'], style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          ),
        ));
      }
    }
    // If no parents, just show all
    if (parents.isEmpty) {
      for (final cat in _categories) {
        items.add(DropdownMenuItem(
          value: cat['name'],
          child: Text(cat['name']),
        ));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Filter by Category'),
      content: _loading
          ? SizedBox(height: 64, child: Center(child: CircularProgressIndicator()))
          : _error != null
              ? SizedBox(height: 64, child: Center(child: Text(_error!, style: TextStyle(color: Colors.red))))
              : DropdownButton<String>(
                  isExpanded: true,
                  value: _category ?? '',
                  items: _buildDropdownItems(),
                  onChanged: (v) => setState(() => _category = v),
                ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_category),
          child: Text('Apply'),
        ),
      ],
    );
  }
}
