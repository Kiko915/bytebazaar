import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bytebazaar/utils/constants/colors.dart';
import 'package:bytebazaar/utils/constants/sizes.dart';
import 'package:bytebazaar/features/products/search_results_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  BColors.primary, // Start color
                  Color.fromARGB(255, 17, 56, 128), // End color (branding)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'Categories',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No categories found'));
          }
          final categories = snapshot.data!.docs;
          // Build a map of parentId -> List of categories
          Map<String, List<QueryDocumentSnapshot>> subCategories = {};
          List<QueryDocumentSnapshot> parentCategories = [];
          for (var doc in categories) {
            final parent = doc['parent'] ?? '';
            if (parent == "") {
              parentCategories.add(doc);
            } else {
              if (!subCategories.containsKey(parent)) {
                subCategories[parent] = [];
              }
              subCategories[parent]!.add(doc);
            }
          }
          return ListView.builder(
            itemCount: parentCategories.length,
            itemBuilder: (context, index) {
              final parent = parentCategories[index];
              final children = subCategories[parent.id] ?? [];
              return ExpansionTile(
                leading: Icon(Iconsax.category, color: BColors.primary),
                title: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchResultsScreen(
                          searchTerm: '',
                          category: parent['name'],
                        ),
                      ),
                    );
                  },
                  child: Text(parent['name'] ?? 'Category'),
                ),
                children: children
                    .map((child) => ListTile(
                          leading: const SizedBox(width: 24),
                          title: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SearchResultsScreen(
                                    searchTerm: '',
                                    category: child['name'],
                                  ),
                                ),
                              );
                            },
                            child: Text(child['name'] ?? 'Subcategory'),
                          ),
                        ))
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }
}
