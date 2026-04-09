class Onboard {
  final String image, title, subtitle;

  Onboard({required this.image, required this.title, required this.subtitle});
}

final List<Onboard> demoData = [
  Onboard(
    image: "assets/images/girl.jpg",
    title: "Welcome to GCOMMERC",
    subtitle: "Change the quality of your appearance\nwith GCOMMERC now!",
  ),
  Onboard(
    image: "assets/images/orange.jpg",
    title: "New Perspectives",
    subtitle: "Discover the latest trends in fashion\nand style today.",
  ),
  Onboard(
    image: "assets/images/hot.jpg",
    title: "Premium Quality",
    subtitle: "Experience luxury with our handpicked\ncollections.",
  ),
];
