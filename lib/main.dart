import 'package:flutter/widgets.dart';

import 'app.dart';
import 'core/config/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppBootstrap.createDependencies();
  runApp(StudentManagerApp(dependencies: dependencies));
}
