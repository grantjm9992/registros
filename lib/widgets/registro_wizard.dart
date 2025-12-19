import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../models/registro.dart';
import '../database/database_helper.dart';
import '../utils/sentimientos.dart';
import '../utils/widget_helper.dart';

class RegistroWizard extends StatefulWidget {
  final Registro? existingRegistro;
  final VoidCallback? onComplete;

  const RegistroWizard({
    Key? key,
    this.existingRegistro,
    this.onComplete,
  }) : super(key: key);

  @override
  State<RegistroWizard> createState() => _RegistroWizardState();
}

class _RegistroWizardState extends State<RegistroWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Controllers for text fields
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _pensamientoController = TextEditingController();
  final TextEditingController _comportamientoController = TextEditingController();
  final TextEditingController _consecuenciaController = TextEditingController();

  List<String> _selectedSentimientos = [];
  List<MultiSelectItem<String>> _sentimientoItems = [];

  @override
  void initState() {
    super.initState();

    if (widget.existingRegistro != null) {
      _motivoController.text = widget.existingRegistro!.motivo;
      _selectedSentimientos = widget.existingRegistro!.sentimientos;
      _pensamientoController.text = widget.existingRegistro!.pensamiento;
      _comportamientoController.text = widget.existingRegistro!.comportamiento;
      _consecuenciaController.text = widget.existingRegistro!.consecuencia;
    }

    _loadSentimientos();
  }

  Future<void> _loadSentimientos() async {
    final customSentimientos = await DatabaseHelper.instance.getCustomSentimientos();
    final allSentimientos = [...sentimientosEmocionario, ...customSentimientos];
    allSentimientos.sort();

    setState(() {
      _sentimientoItems = allSentimientos
          .map((s) => MultiSelectItem<String>(s, s))
          .toList();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _motivoController.dispose();
    _pensamientoController.dispose();
    _comportamientoController.dispose();
    _consecuenciaController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveRegistro();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveRegistro() async {
    // Validar que todos los campos estén llenos
    if (_motivoController.text.isEmpty ||
        _selectedSentimientos.isEmpty ||
        _pensamientoController.text.isEmpty ||
        _comportamientoController.text.isEmpty ||
        _consecuenciaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final registro = Registro(
      id: widget.existingRegistro?.id,
      motivo: _motivoController.text,
      sentimientos: _selectedSentimientos,
      pensamiento: _pensamientoController.text,
      comportamiento: _comportamientoController.text,
      consecuencia: _consecuenciaController.text,
      createdAt: widget.existingRegistro?.createdAt,
    );

    if (widget.existingRegistro != null) {
      await DatabaseHelper.instance.updateRegistro(registro);
    } else {
      await DatabaseHelper.instance.createRegistro(registro);
    }

    // Update home screen widget
    await WidgetHelper.updateWidget();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro guardado exitosamente')),
      );

      // Limpiar formulario
      _motivoController.clear();
      _pensamientoController.clear();
      _comportamientoController.clear();
      _consecuenciaController.clear();
      setState(() {
        _selectedSentimientos = [];
        _currentStep = 0;
      });
      _pageController.jumpToPage(0);

      widget.onComplete?.call();
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _motivoController.text.isNotEmpty;
      case 1:
        return _selectedSentimientos.isNotEmpty;
      case 2:
        return _pensamientoController.text.isNotEmpty;
      case 3:
        return _comportamientoController.text.isNotEmpty;
      case 4:
        return _consecuenciaController.text.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),

        // Step content
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMotivoStep(),
              _buildSentimientoStep(),
              _buildPensamientoStep(),
              _buildComportamientoStep(),
              _buildConsecuenciaStep(),
            ],
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                ElevatedButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                )
              else
                const SizedBox.shrink(),
              ElevatedButton.icon(
                onPressed: _canProceed() ? _nextStep : null,
                icon: Icon(_currentStep < 4 ? Icons.arrow_forward : Icons.check),
                label: Text(_currentStep < 4 ? 'Siguiente' : 'Guardar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotivoStep() {
    return _buildStepContainer(
      title: 'Motivo',
      description: '¿Qué provocó el sentimiento/pensamiento/comportamiento?',
      child: TextField(
        controller: _motivoController,
        decoration: const InputDecoration(
          hintText: 'Escribe el motivo...',
          border: OutlineInputBorder(),
        ),
        maxLines: 8,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildSentimientoStep() {
    return _buildStepContainer(
      title: 'Sentimientos',
      description: 'Selecciona uno o más sentimientos que experimentaste',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Multi-select field with search
          MultiSelectDialogField<String>(
            items: _sentimientoItems,
            title: const Text('Sentimientos'),
            selectedColor: Theme.of(context).primaryColor,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.grey[400]!,
                width: 1,
              ),
            ),
            buttonIcon: const Icon(Icons.arrow_drop_down),
            buttonText: Text(
              _selectedSentimientos.isEmpty
                  ? 'Selecciona sentimientos...'
                  : '${_selectedSentimientos.length} seleccionados',
              style: TextStyle(
                color: _selectedSentimientos.isEmpty ? Colors.grey[600] : Colors.black87,
                fontSize: 16,
              ),
            ),
            searchable: true,
            searchHint: 'Buscar sentimientos...',
            confirmText: const Text('CONFIRMAR'),
            cancelText: const Text('CANCELAR'),
            initialValue: _selectedSentimientos,
            onConfirm: (values) {
              setState(() {
                _selectedSentimientos = values;
              });
            },
            chipDisplay: MultiSelectChipDisplay<String>(
              onTap: (value) {
                setState(() {
                  _selectedSentimientos.remove(value);
                });
              },
              chipColor: Theme.of(context).primaryColor.withOpacity(0.2),
              textStyle: const TextStyle(color: Colors.black87),
            ),
          ),

          const SizedBox(height: 16),

          // Option to add custom sentimiento
          OutlinedButton.icon(
            onPressed: () async {
              final controller = TextEditingController();
              final result = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Añadir sentimiento personalizado'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe el sentimiento...',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.none,
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCELAR'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          Navigator.pop(context, controller.text.trim().toLowerCase());
                        }
                      },
                      child: const Text('AÑADIR'),
                    ),
                  ],
                ),
              );

              if (result != null) {
                // Check if it already exists
                final exists = _sentimientoItems.any((item) => item.value == result);
                if (exists) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Este sentimiento ya existe')),
                    );
                  }
                } else {
                  // Add to database and reload
                  await DatabaseHelper.instance.addCustomSentimiento(result);
                  await _loadSentimientos();
                  setState(() {
                    _selectedSentimientos.add(result);
                  });
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Añadir sentimiento personalizado'),
          ),

          const SizedBox(height: 16),

          // Info text
          if (_selectedSentimientos.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Toca el campo de arriba para seleccionar uno o más sentimientos',
                      style: TextStyle(color: Colors.blue[900], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPensamientoStep() {
    return _buildStepContainer(
      title: 'Pensamiento',
      description: '¿Qué pensamiento tuviste?',
      child: TextField(
        controller: _pensamientoController,
        decoration: const InputDecoration(
          hintText: 'Escribe tu pensamiento...',
          border: OutlineInputBorder(),
        ),
        maxLines: 8,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildComportamientoStep() {
    return _buildStepContainer(
      title: 'Comportamiento',
      description: '¿Cómo te comportaste?',
      child: TextField(
        controller: _comportamientoController,
        decoration: const InputDecoration(
          hintText: 'Escribe tu comportamiento...',
          border: OutlineInputBorder(),
        ),
        maxLines: 8,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildConsecuenciaStep() {
    return _buildStepContainer(
      title: 'Consecuencia',
      description: '¿Cuál es la consecuencia de tu comportamiento?',
      child: TextField(
        controller: _consecuenciaController,
        decoration: const InputDecoration(
          hintText: 'Escribe la consecuencia...',
          border: OutlineInputBorder(),
        ),
        maxLines: 8,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required String description,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
