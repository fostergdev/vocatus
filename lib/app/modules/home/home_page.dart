import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vocatus/app/core/widgets/custom_square_button.dart';
import './home_controller.dart'; // Mantenha este import se tiver um HomeController

class HomePage extends GetView<HomeController> {
  // Se não tiver HomeController, pode ser StatelessWidget
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Acesse o ColorScheme do tema atual
    final ColorScheme colorScheme = Theme.of(context).colorScheme;


    // Defina as cores do gradiente com base no ColorScheme
    // Para o tema claro, será um roxo claro para branco/fundo
    // Para o tema escuro, pode ser um cinza escuro para preto, ou um roxo escuro para cinza escuro
    List<Color> gradientColors;
    if (Theme.of(context).brightness == Brightness.dark) {
      gradientColors = [
        colorScheme.surfaceContainerHighest, // Uma cor de superfície mais escura
        colorScheme
            .surface, // Cor de fundo do tema escuro (geralmente preto ou cinza bem escuro)
      ];
    } else {
      gradientColors = [
        colorScheme.primary.withValues(alpha: 
          0.05,
        ), // Um tom muito claro da cor primária
        colorScheme
            .surface, // Cor de fundo do tema claro (geralmente branco ou cinza claro)
      ];
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors, // Use as cores dinâmicas
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
                context, // Passe o contexto para o CustomSquareButton
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
                () => Get.toNamed('/grade/home'),
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

  // Modifique _buildMenuButton para aceitar context e usar cores do tema
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
