import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Importe Get para usar Get.back()

class CustomErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmButtonText; // Opcional: para customizar o texto do botão

  const CustomErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent, // Torna o fundo transparente
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(
            left: 20,
            top: 45 + 20, // Altura do ícone + padding
            right: 20,
            bottom: 20,
          ),
          margin: const EdgeInsets.only(top: 45), // Espaço para o ícone no topo
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 10),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent, // Cor para destacar o erro
                ),
              ),
              const SizedBox(height: 15),
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Get.back(); // Fecha o diálogo usando GetX
                  },
                  child: Text(
                    confirmButtonText ?? 'Ok',
                    style: const TextStyle(fontSize: 18, color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.redAccent, // Cor do círculo do ícone
            radius: 45,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(45)),
              child: Icon(
                Icons.error_outline, // Ícone de erro
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ),
      ],
    );
  }
}