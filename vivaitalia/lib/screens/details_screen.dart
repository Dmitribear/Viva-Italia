import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('О стране')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Италия: краткий гид',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10),
          Text(
            'Италия — государство на юге Европы, омываемое Средиземным морем. '
                'Столица — Рим. Население — около 60 млн. Официальный язык — итальянский, валюта — евро. '
                'Страна известна наследием Римской империи, эпохой Возрождения, кухней и модой.',
            style: TextStyle(fontSize: 15.5, height: 1.5),
          ),
          SizedBox(height: 14),
          Text(
            'Региональные различия',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            '• Север: Альпы, озёра Комо и Гарда, Милан — столица индустрии и моды.\n'
                '• Центр: Тоскана, Рим, Умбрия — история, вино, холмы и музеи.\n'
                '• Юг: Кампания, Калабрия, Апулия — море, вулканы, лимончелло.\n'
                '• Острова: Сицилия и Сардиния — курассао морей, крепкие традиции и кухня.',
            style: TextStyle(fontSize: 15.5, height: 1.5),
          ),
          SizedBox(height: 14),
          Text(
            'Что попробовать',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Пицца Маргарита (Неаполь), паста карбонара (Рим), флорентийский стейк, '
                'ризотто с шафраном (Милан), канноли (Сицилия), тирадито и бесконечный эспрессо.',
            style: TextStyle(fontSize: 15.5, height: 1.5),
          ),
          SizedBox(height: 14),
          Text(
            'Практика',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Лучшее время — весна и начало осени. В музеях покупайте билеты онлайн. '
                'В воскресенье многие лавки закрыты, в августе — отпускной сезон. '
                'Чаевые необязательны, сервис обычно включён.',
            style: TextStyle(fontSize: 15.5, height: 1.5),
          ),
        ],
      ),
    );
  }
}
