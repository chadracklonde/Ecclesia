import 'package:ecclesia/features/members/domain/usecases/generate_matricule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final generateMatricule = GenerateMatricule();

  group('GenerateMatricule', () {
    test('produit le format CODE-ANNÉE-SÉQUENCE avec séquence sur 4 chiffres',
        () {
      final result =
          generateMatricule(churchCode: 'RTC', year: 2026, sequence: 42);
      expect(result, 'RTC-2026-0042');
    });

    test('met le code église en majuscules', () {
      final result =
          generateMatricule(churchCode: 'rtc', year: 2026, sequence: 1);
      expect(result, 'RTC-2026-0001');
    });

    test('ne tronque pas une séquence au-delà de 4 chiffres', () {
      final result =
          generateMatricule(churchCode: 'RTC', year: 2026, sequence: 12345);
      expect(result, 'RTC-2026-12345');
    });

    test('lève une erreur si le code église est vide', () {
      expect(
        () => generateMatricule(churchCode: '', year: 2026, sequence: 1),
        throwsArgumentError,
      );
    });

    test('lève une erreur si la séquence est inférieure à 1', () {
      expect(
        () => generateMatricule(churchCode: 'RTC', year: 2026, sequence: 0),
        throwsArgumentError,
      );
    });
  });
}
