import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Function(List<Map<String, dynamic>>) onCartChanged;
  final VoidCallback onClearCart;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final double Function() cartTotalGetter;

  const CartScreen({
    super.key,
    required this.cart,
    required this.onCartChanged,
    required this.onClearCart,
    required this.isDark,
    required this.onToggleTheme,
    required this.cartTotalGetter,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> get cart => widget.cart;

  void increase(int index) {
    final copy = List<Map<String, dynamic>>.from(cart);
    copy[index]['quantity'] += 1;
    widget.onCartChanged(copy);
  }

  void decrease(int index) {
    final copy = List<Map<String, dynamic>>.from(cart);
    if (copy[index]['quantity'] > 1) {
      copy[index]['quantity'] -= 1;
    } else {
  copy.removeAt(index);
    }
    widget.onCartChanged(copy);
  }

  double total() {
    double t = 0;
    for (final it in cart) {
      final price = (it['price'] as num?)?.toDouble() ?? 0;
      final qty = (it['quantity'] as num?)?.toInt() ?? 0;
      t += price * qty;
    }
    return t;
  }

  void checkout() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 56),
        content: const Text('Order Completed!'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onCartChanged([]); // clear cart
              Navigator.of(c).pop(); // close dialog
              Navigator.of(context).pop(); // go back to menu
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your Cart'),
          Text('Total: ₹${total().toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
        ]),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Light mode' : 'Dark mode',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
          if (cart.isNotEmpty)
            IconButton(
              tooltip: 'Clear Cart',
        onPressed: () { widget.onClearCart(); setState(() {}); },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: cart.isEmpty
      ? const Center(child: Text('Cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, i) {
                      final item = cart[i];
                      return Card(margin: const EdgeInsets.all(8), child: ListTile(
                        leading: item['image_url'] != null && item['image_url'].toString().isNotEmpty
                            ? Image.network(item['image_url'], width: 50, height: 50, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood))
                            : const Icon(Icons.fastfood, size: 40),
                        title: Text(item['name'] ?? ''),
                        subtitle: Text('₹${item['price']}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(icon: const Icon(Icons.remove), onPressed: () => decrease(i)),
                          Text('${item['quantity']}'),
                          IconButton(icon: const Icon(Icons.add), onPressed: () => increase(i)),
                        ]),
                      ));
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.3),
                    border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(.4))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Total: ₹${total().toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton.icon(
                        onPressed: checkout,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Checkout'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
