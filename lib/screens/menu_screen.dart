import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MenuScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Function(List<Map<String, dynamic>>) onCartChanged;
  final Set<int> favorites; // ids
  final void Function(int id) onToggleFavorite;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final double Function() cartTotalGetter;

  const MenuScreen({
    super.key,
    required this.cart,
    required this.onCartChanged,
    required this.favorites,
    required this.onToggleFavorite,
    required this.isDark,
    required this.onToggleTheme,
    required this.cartTotalGetter,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> menuItems = [];
  List<dynamic> filteredItems = [];
  String selectedCategory = 'All';
  String searchQuery = '';
  String sortMode = 'name'; // 'name' or 'price'

  final List<String> categories = ['All', 'Veg', 'Non-Veg', 'Drinks', 'Snacks'];
  bool loading = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchMenuItems();
  }

  // Pulls all rows from menu_items table
  Future<void> fetchMenuItems() async {
  try {
  // Debug: indicate fetch start
  // (In Flutter DevTools logging you should see these prints)
  // ignore: avoid_print
  print('[fetchMenuItems] starting fetch...');
          .select()
          .order('id');
  // ignore: avoid_print
  print('[fetchMenuItems] received ${data.length} rows');
      setState(() {
        menuItems = data;
        filteredItems = data;
      });
  applySortFilter();
    } catch (e) {
      // Provide clearer help if table does not exist (PGRST205) or similar
      final raw = e.toString();
            'Fix steps: Create table menu_items with columns id, name, price, image_url, category.\n'
            'Then insert sample rows. Pull to refresh after creating.';
      } else {
        errorMsg = 'Failed to load menu: $raw';
      }
  // ignore: avoid_print
  print('[fetchMenuItems][error] $raw');
      setState(() {});
    } finally {
      setState(() => loading = false);
    }
  }

  void filterItems() {
    final lowerSearch = searchQuery.toLowerCase();
    setState(() {
      filteredItems = menuItems.where((item) {
        final matchesCategory = selectedCategory == 'All' || item['category'] == selectedCategory;
        final matchesSearch = item['name'] != null &&
            item['name'].toString().toLowerCase().contains(lowerSearch);
        return matchesCategory && matchesSearch;
      }).toList();
    });
    applySortFilter();
  }

  void applySortFilter() {
    filteredItems.sort((a, b) {
      if (sortMode == 'price') {
        final pa = (a['price'] as num?)?.toDouble() ?? 0;
        final pb = (b['price'] as num?)?.toDouble() ?? 0;
        return pa.compareTo(pb);
      } else {
        return a['name'].toString().toLowerCase().compareTo(b['name'].toString().toLowerCase());
      }
    });
  }

  void addToCart(Map<String, dynamic> item) {
    final cartCopy = List<Map<String, dynamic>>.from(widget.cart);
    final idx = cartCopy.indexWhere((c) => c['id'] == item['id']);
    if (idx >= 0) {
      cartCopy[idx]['quantity'] += 1;
    } else {
      cartCopy.add({
        'id': item['id'],
        'name': item['name'],
        'price': item['price'],
        'image_url': item['image_url'],
        'quantity': 1,
      });
    }
    widget.onCartChanged(cartCopy);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['name']} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QuickBite Lite'),
            Text('Total: ₹${widget.cartTotalGetter().toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Light mode' : 'Dark mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
          PopupMenuButton<String>(
            tooltip: 'Sort',
            onSelected: (v) => setState(() {
              sortMode = v;
              applySortFilter();
            }),
            itemBuilder: (c) => [
              CheckedPopupMenuItem(
                  value: 'name', checked: sortMode == 'name', child: const Text('Sort by Name')),
              CheckedPopupMenuItem(
                  value: 'price', checked: sortMode == 'price', child: const Text('Sort by Price')),
            ],
            icon: const Icon(Icons.sort),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/cart'),
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0, top: 8, bottom: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_cart, size: 28),
                  Positioned(
                    right: 0,
                    top: 2,
                    child: Builder(
                      builder: (_) {
                        final totalQty = widget.cart.fold<int>(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));
                        if (totalQty == 0) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            totalQty.toString(),
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search food...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                searchQuery = val;
                filterItems();
              },
            ),
          ),
          // Category dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories
                  .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                selectedCategory = val;
                filterItems();
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchMenuItems,
              child: Builder(
                builder: (_) {
                  if (loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (errorMsg != null) {
                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                        ),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: fetchMenuItems,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ),
                      ],
                    );
                  }
                  if (filteredItems.isEmpty) return ListView(children: const [Padding(padding: EdgeInsets.all(24.0), child: Center(child: Text('No items found')))]);
                  return ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, i) {
                      final item = filteredItems[i];
                      final isFav = widget.favorites.contains(item['id'] as int? ?? -1);
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: item['image_url'] ?? '',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (c, _) => const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (c, _, __) => const Icon(Icons.fastfood),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(item['name'] ?? '')),
                                IconButton(
                                  onPressed: () => widget.onToggleFavorite(item['id'] as int),
                                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.redAccent : null),
                                  tooltip: isFav ? 'Unfavorite' : 'Favorite',
                                ),
                              ],
                            ),
                            subtitle: Text('₹${item['price']}'),
                            trailing: ElevatedButton(
                              onPressed: () => addToCart(item),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Add'),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
