
import 'package:todo_village_mobile/app/app.dart';
import 'package:todo_village_mobile/bootstrap.dart';
import 'package:todo_village_mobile/flavors.dart';

Future<void> main() async {
  await bootstrap(
    () {
      return const App();
    },
    Flavor.DEV,
  );
}
