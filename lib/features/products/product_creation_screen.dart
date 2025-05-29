import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bytebazaar/common/widgets/b_feedback.dart';

class ProductCreationScreen extends StatefulWidget {
  final String shopId;
  final String? productId;
  final Map<String, dynamic>? productData;
  const ProductCreationScreen({Key? key, required this.shopId, this.productId, this.productData}) : super(key: key);

  static Future<bool?> show(BuildContext context, {required String shopId, String? productId, Map<String, dynamic>? productData}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductCreationScreen(shopId: shopId, productId: productId, productData: productData),
      ),
    );
  }

  @override
  State<ProductCreationScreen> createState() => _ProductCreationScreenState();
}

class _ProductCreationScreenState extends State<ProductCreationScreen> {
  String _toStr(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is int || v is double) return v.toString();
    return '';
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  List<File> _imageFiles = [];
  List<String> _initialImageUrls = [];
  bool _saving = false;

  // Variations: each is a map {name, price, stock, sku}
  List<Map<String, dynamic>> _variations = [];
  bool _hasVariations = false;

  // Single variation fields
  final TextEditingController _singlePriceController = TextEditingController();
  final TextEditingController _singleStockController = TextEditingController();
  final TextEditingController _singleSkuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      final data = widget.productData!;
      _nameController.text = data['name'] ?? '';
      _descController.text = data['description'] ?? '';
      _categoryController.text = data['category'] ?? '';
      _weightController.text = _toStr(data['shipping']?['weight']);
      _lengthController.text = _toStr(data['shipping']?['dimensions']?['length']);
      _widthController.text = _toStr(data['shipping']?['dimensions']?['width']);
      _heightController.text = _toStr(data['shipping']?['dimensions']?['height']);

      if (data['images'] != null && data['images'] is List) {
        _initialImageUrls = List<String>.from(data['images']);
      }
      if (data['variations'] != null && data['variations'] is List && (data['variations'] as List).length > 1) {
        _hasVariations = true;
        _variations = List<Map<String, dynamic>>.from(data['variations']);
      } else if (data['variations'] != null && data['variations'] is List && (data['variations'] as List).isNotEmpty) {
        final v = Map<String, dynamic>.from((data['variations'] as List).first);
        _singlePriceController.text = v['price']?.toString() ?? '';
        _singleStockController.text = v['stock']?.toString() ?? '';
        _singleSkuController.text = v['sku']?.toString() ?? '';
      }
    }
  }

  void _addVariation() {
    setState(() {
      _variations.add({'name': '', 'price': '', 'stock': '', 'sku': ''});
    });
  }

  void _removeVariation(int i) {
    setState(() {
      _variations.removeAt(i);
    });
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      final appDir = await getApplicationDocumentsDirectory();
      final List<File> copiedFiles = [];
      for (final x in picked) {
        if (x.path.isNotEmpty && File(x.path).existsSync()) {
          final fileName = x.path.split('/').last;
          final newPath = '${appDir.path}/product_${DateTime.now().millisecondsSinceEpoch}_$fileName';
          final newFile = await File(x.path).copy(newPath);
          copiedFiles.add(newFile);
        }
      }
      if (copiedFiles.isEmpty) {
        BFeedback.show(context, message: 'No valid images found. Please try again.', type: BFeedbackType.error);
        return;
      }
      setState(() {
        // Add only new files not already in _imageFiles
        for (final file in copiedFiles) {
          if (!_imageFiles.any((f) => f.path == file.path)) {
            _imageFiles.add(file);
          }
        }
      });
    }
  }

  void _removeImage(int i) {
    setState(() {
      _imageFiles.removeAt(i);
    });
  }

  bool _validateVariations() {
    for (final v in _variations) {
      if ((v['name'] as String).trim().isEmpty) return false;
      final price = double.tryParse(v['price'].toString());
      final stock = int.tryParse(v['stock'].toString());
      if (price == null || price <= 0) return false;
      if (stock == null || stock < 0) return false;
      if ((v['sku'] as String).trim().isEmpty) return false;
    }
    return true;
  }

  Future<void> _saveProduct() async {
    bool valid = _formKey.currentState!.validate() && (_imageFiles.isNotEmpty || _initialImageUrls.isNotEmpty);
    if (_hasVariations) {
      valid = valid && _variations.isNotEmpty && _validateVariations();
    } else {
      final price = double.tryParse(_singlePriceController.text.trim());
      final stock = int.tryParse(_singleStockController.text.trim());
      valid = valid && price != null && price > 0 && stock != null && stock >= 0 && _singleSkuController.text.trim().isNotEmpty;
    }
    if (!valid) {
      BFeedback.show(context, message: 'Please fill all required fields and fix errors.', type: BFeedbackType.error);
      return;
    }
    setState(() { _saving = true; });
    try {
      // Upload all new images
      List<String> imageUrls = List<String>.from(_initialImageUrls);
      // Only upload files that still exist
      final existingFiles = _imageFiles.where((f) => f.existsSync()).toList();
      if (existingFiles.length != _imageFiles.length) {
        BFeedback.show(context, message: 'Some selected images could not be found and will be skipped.', type: BFeedbackType.warning);
      }
      for (final file in existingFiles) {
        final ref = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
        await ref.putFile(file);
        imageUrls.add(await ref.getDownloadURL());
      }
      // Prepare variations
      List<Map<String, dynamic>> variations;
      if (_hasVariations) {
        variations = _variations.map((v) => {
          'name': v['name'],
          'price': double.tryParse(v['price'].toString()),
          'stock': int.tryParse(v['stock'].toString()),
          'sku': v['sku'],
        }).toList();
      } else {
        variations = [
          {
            'name': _nameController.text.trim(),
            'price': double.tryParse(_singlePriceController.text.trim()),
            'stock': int.tryParse(_singleStockController.text.trim()),
            'sku': _singleSkuController.text.trim(),
          }
        ];
      }
      // Prepare shipping info
      final weight = double.tryParse(_weightController.text.trim());
      final length = double.tryParse(_lengthController.text.trim());
      final width = double.tryParse(_widthController.text.trim());
      final height = double.tryParse(_heightController.text.trim());
      final productMap = {
        'shopId': widget.shopId,
        'shopRef': FirebaseFirestore.instance.collection('shops').doc(widget.shopId),
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'category': _categoryController.text.trim(),
        'images': imageUrls,
        'variations': variations,
        'shipping': {
          'weight': weight,
          'dimensions': {
            'length': length,
            'width': width,
            'height': height,
          },
        },
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (widget.productId != null) {
        // Update
        await FirebaseFirestore.instance.collection('products').doc(widget.productId).update(productMap);
        if (mounted) {
          BFeedback.show(context, message: 'Product updated!', type: BFeedbackType.success);
          Navigator.of(context).pop(true);
        }
      } else {
        // Create
        productMap['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('products').add(productMap);
        if (mounted) {
          BFeedback.show(context, message: 'Product created!', type: BFeedbackType.success);
          Navigator.of(context).pop(true);
        }
      }
    } catch (e, stack) {
      print('Product save error: $e');
      print(stack);
      BFeedback.show(context, message: 'Error: ${e.toString()}', type: BFeedbackType.error);
    } finally {
      setState(() { _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId != null ? 'Edit Product' : 'Add Product'),
      ),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(22.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Product Images', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Add Images'),
                        ),
                        const SizedBox(width: 8),
                        Text('(${_imageFiles.length} selected)', style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_initialImageUrls.isNotEmpty || _imageFiles.isNotEmpty)
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _initialImageUrls.length + _imageFiles.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            if (i < _initialImageUrls.length) {
                              // Existing image from URL
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(_initialImageUrls[i], width: 90, height: 90, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() { _initialImageUrls.removeAt(i); });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              // New image from file
                              final fileIndex = i - _initialImageUrls.length;
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(_imageFiles[fileIndex], width: 90, height: 90, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(fileIndex),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    if (_imageFiles.isEmpty && !_saving)
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0, left: 2.0),
                        child: Text(
                          'At least one product image is required.',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Product Name *'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter product name' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Description *'),
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().length < 10 ? 'Enter at least 10 characters' : null,
                    ),
                    const SizedBox(height: 14),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final docs = snapshot.data!.docs;
                        // Separate parent and subcategories
                        final parentCategories = docs.where((doc) => (doc['parent'] ?? '') == '').toList();
                        final subCategories = docs.where((doc) => (doc['parent'] ?? '') != '').toList();
                        // Build a map of parentId to parent name
                        final parentIdToName = {for (var doc in parentCategories) doc.id: doc['name']};
                        // Build dropdown items
                        final List<DropdownMenuItem<String>> items = [];
                        final maxWidth = MediaQuery.of(context).size.width * 0.6;
                        for (final parent in parentCategories) {
                          items.add(DropdownMenuItem<String>(
                            value: parent['name'],
                            child: SizedBox(
                              width: maxWidth,
                              child: Text(
                                parent['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ));
                          // Add subcategories for this parent
                          for (final sub in subCategories.where((s) => s['parent'] == parent.id)) {
                            items.add(DropdownMenuItem<String>(
                              value: sub['name'],
                              child: SizedBox(
                                width: maxWidth,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 18),
                                  child: Text(
                                    '${parent['name']} > ${sub['name']}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ));
                          }
                        }
                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _categoryController.text.isNotEmpty ? _categoryController.text : null,
                          items: items,
                          onChanged: (val) {
                            setState(() {
                              _categoryController.text = val ?? '';
                            });
                          },
                          decoration: const InputDecoration(labelText: 'Category *'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Select category' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Text('Has Variations?', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Switch(
                          value: _hasVariations,
                          onChanged: (val) {
                            setState(() {
                              _hasVariations = val;
                              if (!val) _variations.clear();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_hasVariations) ...[
                      Row(
                        children: [
                          const Text('Variations', style: TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.green),
                            tooltip: 'Add Variation',
                            onPressed: _addVariation,
                          ),
                        ],
                      ),
                      if (_variations.isEmpty)
                        const Text('No variations added.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Column(
                        children: List.generate(_variations.length, (i) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: _variations[i]['name'],
                                          decoration: const InputDecoration(labelText: 'Name *'),
                                          onChanged: (v) => _variations[i]['name'] = v,
                                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Remove',
                                        onPressed: () => _removeVariation(i),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: _variations[i]['price']?.toString() ?? '',
                                          decoration: const InputDecoration(labelText: 'Price (₱) *'),
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          onChanged: (v) => _variations[i]['price'] = v,
                                          validator: (v) {
                                            final price = double.tryParse(v ?? '');
                                            if (price == null || price <= 0) return 'Enter valid price';
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: _variations[i]['stock']?.toString() ?? '',
                                          decoration: const InputDecoration(labelText: 'Stock *'),
                                          keyboardType: TextInputType.number,
                                          onChanged: (v) => _variations[i]['stock'] = v,
                                          validator: (v) {
                                            final stock = int.tryParse(v ?? '');
                                            if (stock == null || stock < 0) return 'Enter valid stock';
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: _variations[i]['sku']?.toString() ?? '',
                                          decoration: const InputDecoration(labelText: 'SKU *'),
                                          onChanged: (v) => _variations[i]['sku'] = v,
                                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter SKU' : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 18),
                    ] else ...[
                      const Text('Single Product Details', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _singlePriceController,
                              decoration: const InputDecoration(labelText: 'Price (₱) *'),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              validator: (v) {
                                final price = double.tryParse(v ?? '');
                                if (price == null || price <= 0) return 'Enter valid price';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _singleStockController,
                              decoration: const InputDecoration(labelText: 'Stock *'),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final stock = int.tryParse(v ?? '');
                                if (stock == null || stock < 0) return 'Enter valid stock';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _singleSkuController,
                              decoration: const InputDecoration(labelText: 'SKU *'),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Enter SKU' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],
                    const Text('Shipping Information', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: const InputDecoration(
                              labelText: 'Weight *',
                              suffixText: 'kg',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              final w = double.tryParse(v ?? '');
                              if (w == null || w <= 0) return 'Enter valid weight';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _lengthController,
                            decoration: const InputDecoration(
                              labelText: 'Length *',
                              suffixText: 'cm',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              final l = double.tryParse(v ?? '');
                              if (l == null || l <= 0) return 'Enter valid length';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _widthController,
                            decoration: const InputDecoration(
                              labelText: 'Width *',
                              suffixText: 'cm',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              final w = double.tryParse(v ?? '');
                              if (w == null || w <= 0) return 'Enter valid width';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              labelText: 'Height *',
                              suffixText: 'cm',
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              final h = double.tryParse(v ?? '');
                              if (h == null || h <= 0) return 'Enter valid height';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveProduct,
                        icon: const Icon(Icons.save),
                        label: Text(widget.productId != null ? 'Save Changes' : 'Save Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
