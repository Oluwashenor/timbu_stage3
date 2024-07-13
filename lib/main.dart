import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'models/product.dart';
import 'network/network.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  List<Product> carts = [];
  Network network = Network();

  Future<List<Product>> fetchProducts() async {
    try {
      List<Product> ps = await network.fetchProducts();
      return ps;
    } catch (ex) {
      print(ex);
      return [];
    }
  }

  // @override
  // void initState() {
  //   fetchProducts();
  //   super.initState();
  // }

  showSnackBar(String message) {
    SnackBar snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  int currentScreen = 0;
  double total = 0;

  void removeFromCart(String productName) {
    showSnackBar("Removing $productName from cart");
    // Product product = myCart.firstWhere((x) => x.name == productName);
    // myCart.remove(product);
    //total -= product.amount;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Shopping"), actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ShoppingCart(
                              myCart: [],
                            )));
              },
              icon: const Icon(Icons.shopping_cart))
        ]),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).colorScheme.primary,
          currentIndex: currentScreen,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border_outlined), label: "Wishlist"),
            BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined), label: "Search"),
          ],
          onTap: (value) {
            setState(() {
              currentScreen = value;
            });
          },
        ),
        body: FutureBuilder(
            future: fetchProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No data available'),
                );
              } else {
                products = snapshot.data as List<Product>;
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome, Adesina'),
                      const SizedBox(
                        height: 10,
                      ),
                      const TextField(
                        decoration: InputDecoration(
                            label: Text('Search'),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)))),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Just for you',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 20),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    onPressed: () {},
                                    icon:
                                        const Icon(Icons.arrow_back_ios_sharp)),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                        Icons.arrow_forward_ios_sharp))
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 230,
                        width: double.infinity,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data?.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ProductWithPriceCard(
                                product: snapshot.data![index],
                              );
                            }),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Deals',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 20),
                          ),
                          Text(
                            'View all',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                fontSize: 20),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                          child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, childAspectRatio: 0.6),
                              itemCount: products.length - 2,
                              itemBuilder: (context, index) {
                                return ProductWithPriceCard(
                                  product: products[index],
                                );
                              }))
                    ],
                  ),
                );
              }
            }));
  }
}

class ProductWithPriceCard extends StatelessWidget {
  const ProductWithPriceCard({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    var image = 'https://api.timbu.cloud/images/${product.photos[0]?['url']}';
    return Container(
      width: 185,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(200)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(image, width: 180, height: 150)),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(product.name as String,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      "${product.currentPrice[0].ngn.first}",
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                OutlinedButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xff408C2B),
                      ),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  Network network = Network();
  List<Product> products = [];

  Future<List<Product>> fetchProducts() async {
    try {
      List<Product> ps = await network.fetchProducts();
      return ps;
    } catch (ex) {
      print(ex);
      return [];
    }
  }

  @override
  void initState() {
    fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No data available'),
          );
        } else {
          return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                return ProductWidget(
                    product: snapshot.data![index], index: index);
              });
        }
      },
    );
  }
}

class ProductWidget extends StatelessWidget {
  const ProductWidget(
      {super.key,
      required this.product,
      this.cartItem = false,
      required this.index});

  final Product product;
  final bool cartItem;
  final int index;

  @override
  Widget build(BuildContext context) {
    var image = 'https://api.timbu.cloud/images/${product.photos[0]?['url']}';
    return ListTile(
      leading: Image.network(image, width: 50, height: 200),
      title: Text(product.name as String),
      subtitle: Text("${product.currentPrice[0].ngn.first}"),
    );
  }
}

class ShoppingCart extends StatelessWidget {
  const ShoppingCart({super.key, required this.myCart});

  final List<Product> myCart;
//  final Function(String) buttonPressed;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
      ),
      body: Column(children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_checkout_outlined,
                    size: 60,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Your cart is empty",
                    style: TextStyle(fontSize: 25),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Explore our collection today and start your journey towards radiant beauty. Your workspace will thank you",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  OutlinedButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          backgroundColor: const Color(0xff408C2B),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)))),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'Start Shopping',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
}

class CheckOutScreen extends StatelessWidget {
  const CheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Thank you for shopping with us"),
      ),
    );
  }
}
