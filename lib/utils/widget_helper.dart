import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class WidgetHelper {
  static Future<void> updateWidget() async {
    try {
      // Get the most recent registro
      final registros = await DatabaseHelper.instance.readAllRegistros();

      String lastRegistroText = 'Sin registros';
      if (registros.isNotEmpty) {
        final lastRegistro = registros.first;
        final dateFormat = DateFormat('dd/MM HH:mm');
        lastRegistroText = 'Último: ${lastRegistro.sentimientosDisplay} - ${dateFormat.format(lastRegistro.createdAt)}';
      }

      // Save data to widget
      await HomeWidget.saveWidgetData<String>('last_registro', lastRegistroText);

      // Update the widget
      await HomeWidget.updateWidget(
        name: 'RegistroWidget',
        androidName: 'RegistroWidget',
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  static Future<void> initialize() async {
    // Register for background callbacks
    HomeWidget.setAppGroupId('group.com.registros.sentimiento');

    // Update widget on initialization
    await updateWidget();
  }

  static Future<String?> getInitialAction() async {
    try {
      final Uri? uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      return uri?.toString();
    } catch (e) {
      print('Error getting initial action: $e');
      return null;
    }
  }
}
