import 'package:flutter/material.dart';

enum ActionType { buyNow, addToCart }

class ViewProduct extends StatefulWidget {
  const ViewProduct({super.key});

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {

  //To be changed based on backend data -- Dev Marc
  // This is a placeholder for the product data. In a real application, this would be fetched from a backend service.
  bool _showVariations = false;
  ActionType _actionType = ActionType.buyNow;
  String _selectedColor = 'Grey';
  int _quantity = 1;
  final List<String> _colors = ['Grey', 'Blue', 'Green', 'Pink', 'Khaki', 'Black', 'Purple'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Main product view
          SafeArea(
            child: Column(
              children: [
                // Header with search bar and back button
                _buildHeader(),
                
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image
                        Container(
                          height: 400,
                          width: double.infinity,
                          color: Colors.white,
                          child: Stack(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/tshirt.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Text('T-shirt Image'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // White gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.center,
                                    colors: [
                                      Colors.white.withOpacity(0.7),
                                      Colors.white.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Product details
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and price
                              const Text(
                                'UNIQLO TSHIRT',
                                style: TextStyle(
                                  color: Color(0xFF4080FF),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '₱ 500.00',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              // Location and rating
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'LSPU Santa Cruz',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const Spacer(),
                                  _buildRatingStars(4.5),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '4.5',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '| 46.5k Orders',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              
                              // Seller info
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      radius: 20,
                                      child: const Text(
                                        'M',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Shop ni Marc',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Online',
                                        style: TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Description
                              const SizedBox(height: 16),
                              const Text(
                                'Lorem ipsum dolor sit amet. Sit nesciunt assumenda eos quis expedita aut sunt culpa. Qui alias eius est sint molestiae est sint error sed illo galisum. Eum voluptatem aliquid et delectus voluptates aut corporis atque id sunt maxime eos consequuntur inventore.',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'A quis dolorum eum reprehenderit temporibus quo nesciunt maxime quo voluptatem velit hic perferendis doloremque.',
                                style: TextStyle(color: Colors.grey),
                              ),
                              
                              const SizedBox(height: 80), // Space for bottom buttons
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom action buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.storefront_outlined),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003D99),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _actionType = ActionType.buyNow;
                        });
                        _toggleVariationsPanel();
                      },
                      child: const Text('BUY NOW'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4080FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _actionType = ActionType.addToCart;
                        });
                        _toggleVariationsPanel();
                      },
                      child: const Text('ADD TO CART'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Darkened overlay when variations panel is visible
          if (_showVariations)
            AnimatedOpacity(
              opacity: _showVariations ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: _toggleVariationsPanel,
                child: Container(
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          
          // Variations panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showVariations ? 0 : -400,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // Close button and image preview
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Image.asset(
                          'assets/images/tshirt.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text('T-shirt'));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '₱500.00',
                              style: TextStyle(
                                color: Color(0xFF4080FF),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              '₱1000.00',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _selectedColor,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _toggleVariationsPanel,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Variations
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Variations',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Color options wrapped to multiple rows
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedColor == color 
                                ? const Color(0xFF4080FF) 
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              color,
                              style: TextStyle(
                                color: _selectedColor == color 
                                    ? Colors.white 
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const Spacer(),
                  
                  // Total and quantity
                  Row(
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '₱1000.00',
                        style: TextStyle(
                          color: Color(0xFF4080FF),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              },
                            ),
                            Text(
                              _quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Place order button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _actionType == ActionType.buyNow 
                            ? const Color(0xFF003D99) 
                            : const Color(0xFF4080FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        // Place order or add to cart logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _actionType == ActionType.buyNow
                                  ? 'Order placed for $_quantity $_selectedColor shirt(s)'
                                  : 'Added $_quantity $_selectedColor shirt(s) to cart'
                            ),
                          ),
                        );
                        _toggleVariationsPanel();
                      },
                      child: Text(
                        _actionType == ActionType.buyNow ? 'PLACE ORDER' : 'ADD TO CART',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.chat_outlined,
            color: Colors.blue[700],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = rating - fullStars >= 0.5;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }
  
  void _toggleVariationsPanel() {
    setState(() {
      _showVariations = !_showVariations;
    });
  }
}
