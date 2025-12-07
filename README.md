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

## Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── models/
│   └── registro.dart           # Modelo de datos para Registro
├── database/
│   └── database_helper.dart    # Helper para SQLite
├── utils/
│   └── sentimientos.dart       # Lista de sentimientos de "El Emocionario"
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

## Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.
