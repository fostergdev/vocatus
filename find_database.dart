import 'dart:io';

void main() async {
  print('🔍 Procurando por arquivos de banco Vocatus...\n');
  
  // Caminhos comuns onde o Flutter pode criar bancos
  final possiblePaths = [
    // Linux paths
    '${Platform.environment['HOME']}/.local/share/vocatus/databases/',
    '${Platform.environment['HOME']}/snap/flutter/common/databases/',
    '${Platform.environment['HOME']}/Documents/databases/',
    // Android emulator paths
    '${Platform.environment['HOME']}/.android/avd/',
    // Current directory
    './databases/',
  ];
  
  print('📂 Verificando caminhos possíveis:');
  for (final path in possiblePaths) {
    print('   Verificando: $path');
    final dir = Directory(path);
    if (await dir.exists()) {
      print('   ✅ Diretório existe');
      try {
        final files = await dir.list().toList();
        if (files.isNotEmpty) {
          print('   📁 Arquivos encontrados:');
          for (final file in files) {
            print('      - ${file.path}');
          }
        } else {
          print('   📂 Diretório vazio');
        }
      } catch (e) {
        print('   ❌ Erro ao listar arquivos: $e');
      }
    } else {
      print('   ❌ Diretório não existe');
    }
    print('');
  }
  
  // Busca recursiva por arquivos .db
  print('🔍 Buscando arquivos .db recursivamente...');
  final homeDir = Directory(Platform.environment['HOME']!);
  
  try {
    await for (final entity in homeDir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.db')) {
        final stat = await entity.stat();
        print('📄 Arquivo DB encontrado: ${entity.path}');
        print('   Tamanho: ${stat.size} bytes');
        print('   Modificado: ${stat.modified}');
        print('');
      }
    }
  } catch (e) {
    print('❌ Erro durante busca recursiva: $e');
  }
  
  // Verificar se há processos flutter em execução
  print('🔍 Verificando processos Flutter...');
  try {
    final result = await Process.run('pgrep', ['-f', 'flutter']);
    if (result.exitCode == 0) {
      print('✅ Processos Flutter encontrados:');
      print(result.stdout);
    } else {
      print('❌ Nenhum processo Flutter encontrado');
    }
  } catch (e) {
    print('⚠️  Não foi possível verificar processos: $e');
  }
}
