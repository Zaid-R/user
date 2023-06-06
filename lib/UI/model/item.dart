// ignore_for_file: public_member_api_docs, sort_constructors_first
class Item {
  String name;
  double price;
  int quantity;
  Item({
    required this.name,
    required this.price,
    required this.quantity,
  });

  Item copyWith(String name,double price,int newQuantity) {
    return Item(name: name, price: price, quantity: newQuantity);
  }
}
