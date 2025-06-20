import 'dart:io';
import 'package:args/args.dart';
import 'package:ecommerce_cli/models/user.dart';
import 'package:ecommerce_cli/services/product_service.dart';
import 'package:ecommerce_cli/services/user_service.dart';
import 'package:ecommerce_cli/services/cart_service.dart';
import 'package:ecommerce_cli/services/order_service.dart';
import 'package:ecommerce_cli/services/purchase_order_service.dart';

void main(List<String> arguments) async {
  final productService = ProductService();
  final userService = UserService();
  final cartService = CartService(productService);
  final orderService = OrderService(productService);
  final purchaseOrderService = PurchaseOrderService(productService);

  await productService.loadProducts();
  await userService.loadUsers();
  await orderService.loadOrders();
  await purchaseOrderService.loadPurchaseOrders();

  print('\n🛍️ Welcome to MK Store\n');

  User? currentUser;
  while (currentUser == null) {
    currentUser = await handleLogin(userService);
  }

  if (currentUser.role == 'admin') {
    await handleAdminMenu(productService, purchaseOrderService, userService);
  } else {
    await handleCustomerMenu(productService, cartService, orderService, currentUser);
  }
}

Future<User?> handleLogin(UserService userService) async {
  print('1. Login');
  print('2. Create new account (press c)');
  print('3. Exit');
  stdout.write('Enter choice: ');
  final choice = stdin.readLineSync()?.trim() ?? '';

  switch (choice) {
    case '1':
      stdout.write('Username: ');
      final username = stdin.readLineSync()?.trim() ?? '';
      stdout.write('Password: ');
      final password = stdin.readLineSync()?.trim() ?? '';
      final user = await userService.login(username, password);
      if (user == null) {
        print('❌ Invalid username or password.');
        return null;
      }
      print('✅ Logged in as ${user.username} (${user.role})');
      return user;
    case '2':
    case 'c':
      stdout.write('Enter new username: ');
      final username = _readNonEmptyInput('Username cannot be empty.');
      stdout.write('Enter password: ');
      final password = _readNonEmptyInput('Password cannot be empty.');
      stdout.write('Enter role (admin/customer): ');
      final role = _readNonEmptyInput('Role must be admin or customer.');
      if (role != 'admin' && role != 'customer') {
        print('❌ Role must be admin or customer.');
        return null;
      }
      await userService.addUser(username, password, role);
      print('✅ Account created. Please login.');
      return null;
    case '3':
      print('👋 Exiting...');
      exit(0);
    default:
      print('❌ Invalid choice.');
      return null;
  }
}

Future<void> handleAdminMenu(ProductService productService, PurchaseOrderService purchaseOrderService, UserService userService) async {
  final parser = ArgParser()
    ..addCommand('list-products')
    ..addCommand('add-product')
    ..addCommand('update-product')
    ..addCommand('delete-product')
    ..addCommand('search-products')
    ..addCommand('purchase-order')
    ..addCommand('list-users')
    ..addCommand('update-user')
    ..addCommand('delete-user')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage help');

  while (true) {
    print('\n📋 Admin Menu');
    print('Commands: list-products, add-product, update-product, delete-product, search-products, purchase-order, list-users, update-user, delete-user, --help');
    stdout.write('Enter command: ');
    final input = stdin.readLineSync()?.trim() ?? '';
    try {
      final results = parser.parse(input.split(' '));
      if (results.wasParsed('help')) {
        printAdminUsage(parser);
        continue;
      }
      if (results.command == null) {
        print('❌ Invalid command.');
        printAdminUsage(parser);
        continue;
      }

      switch (results.command!.name) {
        case 'list-products':
          productService.listProducts();
          break;
        case 'add-product':
          await handleAddProduct(productService);
          break;
        case 'update-product':
          await handleUpdateProduct(productService);
          break;
        case 'delete-product':
          await handleDeleteProduct(productService);
          break;
        case 'search-products':
          handleSearchProduct(productService, results.command!.rest);
          break;
        case 'purchase-order':
          await handleCreatePurchaseOrder(productService, purchaseOrderService);
          break;
        case 'list-users':
          userService.listUsers();
          break;
        case 'update-user':
          await handleUpdateUser(userService);
          break;
        case 'delete-user':
          await handleDeleteUser(userService);
          break;
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}

Future<void> handleCustomerMenu(ProductService productService, CartService cartService, OrderService orderService, User user) async {
  final parser = ArgParser()
    ..addCommand('list-products')
    ..addCommand('search-products')
    ..addCommand('add-to-cart')
    ..addCommand('view-cart')
    ..addCommand('remove-from-cart')
    ..addCommand('checkout')
    ..addCommand('view-orders')
    ..addCommand('filter-orders')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage help');

  while (true) {
    print('\n🛒 Customer Menu');
    print('Commands: list-products, search-products, add-to-cart, view-cart, remove-from-cart, checkout, view-orders, filter-orders, --help');
    stdout.write('Enter command: ');
    final input = stdin.readLineSync()?.trim() ?? '';
    try {
      final results = parser.parse(input.split(' '));
      if (results.wasParsed('help')) {
        printCustomerUsage(parser);
        continue;
      }
      if (results.command == null) {
        print('❌ Invalid command.');
        printCustomerUsage(parser);
        continue;
      }

      switch (results.command!.name) {
        case 'list-products':
          productService.listProducts();
          break;
        case 'search-products':
          handleSearchProduct(productService, results.command!.rest);
          break;
        case 'add-to-cart':
          await handleAddToCart(productService, cartService, user);
          break;
        case 'view-cart':
          cartService.viewCart(user.id);
          break;
        case 'remove-from-cart':
          await handleRemoveFromCart(cartService, user);
          break;
        case 'checkout':
          await handleCheckout(cartService, orderService, user);
          break;
        case 'view-orders':
          orderService.viewOrders(user.id);
          break;
        case 'filter-orders':
          await handleFilterOrders(orderService, user);
          break;
      }
    } catch (e) {
      print('❌ Error: $e');
    }
  }
}

void printAdminUsage(ArgParser parser) {
  print('\n📋 Admin Menu');
  print('Usage: <command>');
  print('\nCommands:');
  print('  list-products      List all products');
  print('  add-product        Add a new product');
  print('  update-product     Update an existing product');
  print('  delete-product     Delete a product');
  print('  search-products <query> Search products by name');
  print('  purchase-order     Create a new purchase order');
  print('  list-users         List all users');
  print('  update-user        Update user information');
  print('  delete-user        Delete a user');
  print('\nOptions:');
  print(parser.usage);
}

void printCustomerUsage(ArgParser parser) {
  print('\n🛒 Customer Menu');
  print('Usage: <command>');
  print('\nCommands:');
  print('  list-products      List all products');
  print('  search-products <query> Search products by name');
  print('  add-to-cart        Add products to cart');
  print('  view-cart         View your cart');
  print('  remove-from-cart  Remove products from cart');
  print('  checkout          Checkout and place order');
  print('  view-orders       View your order history');
  print('  filter-orders     Filter orders by date');
  print('\nOptions:');
  print(parser.usage);
}

Future<void> handleAddProduct(ProductService service) async {
  print('Enter product name: ');
  final name = _readNonEmptyInput('Name cannot be empty.');
  print('Enter price: ');
  final price = _readDoubleInput('Invalid price. Enter a number.');
  print('Enter stock: ');
  final stock = _readIntInput('Invalid stock. Enter a whole number.');
  print('Enter category (optional, press Enter to skip): ');
  final category = stdin.readLineSync() ?? '';

  await service.addProduct(name, price, stock, category);
}

Future<void> handleUpdateProduct(ProductService service) async {
  service.listProducts();
  if (service.products.isEmpty) {
    print('⚠️ No products to update.');
    return;
  }

  print('Enter product number to update: ');
  final index = _readIntInput('Invalid number.') - 1;
  if (index < 0 || index >= service.products.length) {
    print('❌ Invalid product number.');
    return;
  }

  try {
    print('Enter new name (press Enter to keep "${service.products[index].name}"): ');
    final name = stdin.readLineSync() ?? service.products[index].name;
    print('Enter new price (press Enter to keep ${service.products[index].price}): ');
    final priceInput = stdin.readLineSync() ?? '';
    final price = priceInput.isNotEmpty
        ? _parseDouble(priceInput, 'Please enter a valid price.')
        : service.products[index].price;
    print('Enter new stock (press Enter to keep ${service.products[index].stock}): ');
    final stockInput = stdin.readLineSync() ?? '';
    final stock = stockInput.isNotEmpty
        ? _parseInt(stockInput, 'Please enter a valid stock quantity.')
        : service.products[index].stock;
    print('Enter new category (press Enter to keep "${service.products[index].category}"): ');
    final category = stdin.readLineSync() ?? service.products[index].category;

    await service.updateProduct(index, name, price, stock, category);
  } catch (e) {
    print('❌ Failed to update product: $e');
  }
}

Future<void> handleDeleteProduct(ProductService service) async {
  service.listProducts();
  if (service.products.isEmpty) return;

  print('Enter product number to delete: ');
  final index = _readIntInput('Invalid number.') - 1;
  if (index < 0 || index >= service.products.length) {
    print('❌ Invalid product number.');
    return;
  }

  await service.deleteProduct(index);
}

void handleSearchProduct(ProductService service, List<String> query) {
  if (query.isEmpty) {
    print('❌ Please provide a search query.');
    return;
  }
  service.searchProducts(query.join(' '));
}

Future<void> handleCreatePurchaseOrder(ProductService productService, PurchaseOrderService poService) async {
  productService.listProducts();
  if (productService.products.isEmpty) {
    print('⚠️ No products available to create a purchase order.');
    return;
  }

  final items = <String, int>{};
  print('\n📦 Enter products for purchase order (enter 0 to finish):');
  while (true) {
    print('Select product number (1-${productService.products.length}, 0 to finish): ');
    final index = _readIntInput('Invalid number.') - 1;
    if (index == -1) break; // User entered 0
    if (index < 0 || index >= productService.products.length) {
      print('❌ Invalid product number.');
      continue;
    }

    print('Enter quantity for ${productService.products[index].name}: ');
    final quantity = _readIntInput('Invalid quantity. Enter a positive number.');
    if (quantity <= 0) {
      print('❌ Quantity must be greater than 0.');
      continue;
    }

    final productId = productService.products[index].id;
    items[productId] = (items[productId] ?? 0) + quantity;
  }

  if (items.isEmpty) {
    print('⚠️ No items added to purchase order.');
    return;
  }

  await poService.createPurchaseOrder(items);
  print('✅ Purchase order created. Use "fulfill-purchase-order" to update stock.');
}

Future<void> handleUpdateUser(UserService service) async {
  service.listUsers();
  if (service.users.isEmpty) {
    print('⚠️ No users to update.');
    return;
  }

  print('Enter user number to update: ');
  final index = _readIntInput('Invalid number.') - 1;
  if (index < 0 || index >= service.users.length) {
    print('❌ Invalid user number.');
    return;
  }

  try {
    print('Enter new username (press Enter to keep "${service.users[index].username}"): ');
    final username = stdin.readLineSync() ?? service.users[index].username;
    print('Enter new password (press Enter to keep current): ');
    final passwordInput = stdin.readLineSync() ?? '';
    final password = passwordInput.isNotEmpty ? passwordInput : service.users[index].password;
    print('Enter new role (admin/customer, press Enter to keep "${service.users[index].role}"): ');
    final roleInput = stdin.readLineSync() ?? '';
    final role = roleInput.isNotEmpty
        ? (roleInput == 'admin' || roleInput == 'customer' ? roleInput : throw Exception('Role must be admin or customer.'))
        : service.users[index].role;

    await service.updateUser(index, username, password, role);
  } catch (e) {
    print('❌ Failed to update user: $e');
  }
}

Future<void> handleDeleteUser(UserService service) async {
  service.listUsers();
  if (service.users.isEmpty) return;

  print('Enter user number to delete: ');
  final index = _readIntInput('Invalid number.') - 1;
  if (index < 0 || index >= service.users.length) {
    print('❌ Invalid user number.');
    return;
  }

  await service.deleteUser(index);
}

Future<void> handleAddToCart(ProductService productService, CartService cartService, User user) async {
  productService.listProducts();
  if (productService.products.isEmpty) {
    print('⚠️ No products available to add to cart.');
    return;
  }

  print('\n🛒 Add products to cart (enter 0 to finish):');
  while (true) {
    print('Select product number (1-${productService.products.length}, 0 to finish): ');
    final index = _readIntInput('Invalid number.') - 1;
    if (index == -1) break; // User entered 0
    if (index < 0 || index >= productService.products.length) {
      print('❌ Invalid product number.');
      continue;
    }

    print('Enter quantity for ${productService.products[index].name}: ');
    final quantity = _readIntInput('Invalid quantity. Enter a positive number.');
    if (quantity <= 0) {
      print('❌ Quantity must be greater than 0.');
      continue;
    }

    await cartService.addToCart(user.id, productService.products[index].id, quantity);
  }
}

Future<void> handleRemoveFromCart(CartService cartService, User user) async {
  cartService.viewCart(user.id);
  if (!cartService.hasCart(user.id)) return;

  print('Enter item number to remove: ');
  final index = _readIntInput('Invalid number.') - 1;
  await cartService.removeFromCart(user.id, index);
}

Future<void> handleCheckout(CartService cartService, OrderService orderService, User user) async {
  cartService.viewCart(user.id);
  if (!cartService.hasCart(user.id)) return;

  print('Proceed to checkout? (y/n): ');
  final confirm = stdin.readLineSync()?.trim().toLowerCase() ?? '';
  if (confirm != 'y') {
    print('Checkout cancelled.');
    return;
  }

  await orderService.createOrder(user.id, cartService.getCart(user.id));
  cartService.clearCart(user.id);
  print('✅ Order placed successfully.');
}

Future<void> handleFilterOrders(OrderService orderService, User user) async {
  print('Enter date (YYYY-MM-DD) to filter orders (press Enter for all orders): ');
  final dateInput = stdin.readLineSync() ?? '';
  if (dateInput.isEmpty) {
    orderService.viewOrders(user.id);
  } else {
    try {
      final date = DateTime.parse(dateInput);
      orderService.filterOrdersByDate(user.id, date);
    } catch (e) {
      print('❌ Invalid date format. Use YYYY-MM-DD.');
    }
  }
}

String _readNonEmptyInput(String errorMessage) {
  String? input;
  do {
    input = stdin.readLineSync();
    if (input == null || input.trim().isEmpty) {
      print('❌ $errorMessage');
    }
  } while (input == null || input.trim().isEmpty);
  return input.trim();
}

double _readDoubleInput(String errorMessage) {
  while (true) {
    final input = stdin.readLineSync() ?? '';
    final value = double.tryParse(input);
    if (value != null && value >= 0) return value;
    print('❌ $errorMessage');
  }
}

int _readIntInput(String errorMessage) {
  while (true) {
    final input = stdin.readLineSync() ?? '';
    final value = int.tryParse(input);
    if (value != null && value >= 0) return value;
    print('❌ $errorMessage');
  }
}

double _parseDouble(String input, String errorMessage) {
  final value = double.tryParse(input);
  if (value != null && value >= 0) return value;
  throw FormatException(errorMessage);
}

int _parseInt(String input, String errorMessage) {
  final value = int.tryParse(input);
  if (value != null && value >= 0) return value;
  throw FormatException(errorMessage);
}