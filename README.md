# Registros de Sentimiento

Una aplicación Flutter para llevar un registro de sentimientos como parte de un programa de terapia de adicciones.

## Características

- **Wizard de Registro**: Formulario paso a paso para crear nuevos registros con los siguientes campos:
  - Motivo: ¿Qué provocó el sentimiento/pensamiento/comportamiento?
  - Sentimiento: Selección de una lista completa de sentimientos de "El Emocionario" con búsqueda y capacidad de agregar nuevos
  - Pensamiento: ¿Qué pensamiento tuviste?
  - Comportamiento: ¿Cómo te comportaste?
  - Consecuencia: ¿Cuál es la consecuencia de tu comportamiento?

- **Lista de Registros**: Visualiza todos tus registros ordenados por fecha de creación

- **Detalle y Edición**: Ve los detalles completos de cada registro y edítalos o elimínalos según sea necesario

- **Almacenamiento Local**: Todos los datos se guardan localmente en SQLite

- **Widget Reutilizable**: El wizard está implementado como un widget independiente que puede ser reutilizado

- **Widget de Pantalla de Inicio (Android)**: Widget para la pantalla de inicio de Android que permite:
  - Acceso rápido para crear nuevos registros
  - Visualización del último registro guardado
  - Actualización automática cuando se crean/editan/eliminan registros

## Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── models/
│   └── registro.dart           # Modelo de datos para Registro
├── database/
│   └── database_helper.dart    # Helper para SQLite
├── utils/
│   ├── sentimientos.dart       # Lista de sentimientos de "El Emocionario"
│   └── widget_helper.dart      # Helper para actualizar el widget de pantalla de inicio
├── widgets/
│   └── registro_wizard.dart    # Widget del wizard (REUTILIZABLE)
└── screens/
    ├── home_screen.dart        # Pantalla principal con tabs
    ├── list_screen.dart        # Pantalla de lista de registros
    └── detail_screen.dart      # Pantalla de detalle/edición
```

## Cómo Usar

### Requisitos

- Flutter SDK 3.0.0 o superior
- Dart 3.0.0 o superior

### Instalación

1. Clona el repositorio
2. Ejecuta `flutter pub get` para instalar las dependencias
3. Ejecuta `flutter run` para iniciar la aplicación

### Instalación del Widget de Pantalla de Inicio (Android)

1. Una vez instalada la app en tu dispositivo Android, mantén presionado en un espacio vacío de la pantalla de inicio
2. Selecciona "Widgets" del menú
3. Busca "Registros de Sentimiento"
4. Arrastra el widget a tu pantalla de inicio
5. El widget mostrará:
   - Botón "Nuevo Registro" que abre la app directamente en el wizard
   - Información del último registro guardado
6. El widget se actualiza automáticamente cada vez que creas, editas o eliminas un registro

### Uso del Widget Wizard

El widget `RegistroWizard` puede ser usado de forma independiente:

```dart
import 'package:registros_sentimiento/widgets/registro_wizard.dart';

// Para crear un nuevo registro
RegistroWizard(
  onComplete: () {
    // Callback cuando se complete el registro
  },
)

// Para editar un registro existente
RegistroWizard(
  existingRegistro: miRegistro,
  onComplete: () {
    // Callback cuando se complete la edición
  },
)
```

## Dependencias

- `sqflite`: Base de datos SQLite local
- `path_provider`: Acceso a rutas del sistema de archivos
- `path`: Manipulación de rutas
- `intl`: Formateo de fechas
- `home_widget`: Soporte para widgets de pantalla de inicio en Android/iOS

## Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.
