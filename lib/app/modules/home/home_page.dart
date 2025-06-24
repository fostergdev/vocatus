import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/widgets/custom_square_button.dart';
import './home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.2,
            children: List.generate(6, (index) {
              return CustomSquareButton(
                text: _getButtonText(index),
                icon: _getButtonIcon(index),
                onPressed: () => _onButtonPressed(context, index),
                elevation: 4.0,
              );
            }),
          ),
        ),
      ),
    );
  }

  String _getButtonText(int index) {
    switch (index) {
      case 0:
        return 'Chamada';
      case 1:
        return 'Turmas';
      case 2:
        return 'Horário';
      case 3:
        return 'Disciplinas';
      case 4:
        return 'Relatórios';
      case 5:
        return 'Histórico';
      default:
        return '';
    }
  }

  IconData _getButtonIcon(int index) {
    switch (index) {
      case 0:
        return Icons.check_circle_outline;
      case 1:
        return Icons.group;
      case 2:
        return Icons.schedule;
      case 3:
        return Icons.library_books;
      case 4:
        return Icons.assignment;
      case 5:
        return Icons.history;
      default:
        return Icons.help;
    }
  }

  void _onButtonPressed(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/attendance/select');
        break;
      case 1:
        Navigator.pushNamed(context, '/classes/home');
        break;
      case 2:
        Navigator.pushNamed(context, '/grade/home');
        break;
      case 3:
        Navigator.pushNamed(context, '/disciplines/home');
        break;
      case 4:
        Navigator.pushNamed(context, '/reports/home');
        break;
      case 5:
        Navigator.pushNamed(context, '/history/home');
        break;
    }
  }
}
