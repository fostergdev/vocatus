import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/widgets/custom_square_button.dart';
import './home_controller.dart'; 

class HomePage extends GetView<HomeController> {
  
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
 
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    
    
    
    List<Color> gradientColors;
    if (Theme.of(context).brightness == Brightness.dark) {
      gradientColors = [
        colorScheme
            .surfaceContainerHighest, 
        colorScheme
            .surface, 
      ];
    } else {
      gradientColors = [
        colorScheme.primary.withValues(alpha: 
          0.05, 
        ),
        colorScheme
            .surface, 
      ];
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors, 
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.2,
            children: [
              _buildMenuButton(
                'Chamada',
                Icons.how_to_reg,
                () => Get.toNamed('/attendance/select'),
                context, 
              ),
              _buildMenuButton(
                'Turmas',
                Icons.school,
                () => Get.toNamed('/classes/home'),
                context,
              ),
              _buildMenuButton(
                'Alunos',
                Icons.person,
                () => Get.toNamed('/students/reports'),
                context,
              ),
              _buildMenuButton(
                'Horário',
                Icons.schedule,
                () => Get.toNamed('/schedule/home'),
                context,
              ),
              _buildMenuButton(
                'Disciplinas',
                Icons.book,
                () => Get.toNamed('/disciplines/home'),
                context,
              ),
              _buildMenuButton(
                'Configurações',
                Icons.settings,
                () => Get.toNamed('/settings'),
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildMenuButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
    BuildContext context,
  ) {
    return CustomSquareButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      elevation: 8.0,
    );
  }
}
