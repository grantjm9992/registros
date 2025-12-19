import 'package:flutter/material.dart';
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
  final TextEditingController _sentimientoSearchController = TextEditingController();

  Set<String> _selectedSentimientos = {};
  List<String> _allSentimientos = [];
  List<String> _filteredSentimientos = [];
  bool _sentimientosLoaded = false;

  @override
  void initState() {
    super.initState();
    // Initialize immediately with predefined list
    _allSentimientos = [...sentimientosEmocionario];
    _filteredSentimientos = [...sentimientosEmocionario];
    _sentimientosLoaded = true;

    // Then load custom ones
    _loadSentimientos();

    if (widget.existingRegistro != null) {
      _motivoController.text = widget.existingRegistro!.motivo;
      _selectedSentimientos = widget.existingRegistro!.sentimientos.toSet();
      _pensamientoController.text = widget.existingRegistro!.pensamiento;
      _comportamientoController.text = widget.existingRegistro!.comportamiento;
      _consecuenciaController.text = widget.existingRegistro!.consecuencia;
    }
  }

  Future<void> _loadSentimientos() async {
    final customSentimientos = await DatabaseHelper.instance.getCustomSentimientos();
    setState(() {
      _allSentimientos = [...sentimientosEmocionario, ...customSentimientos];
      _allSentimientos.sort();
      _filteredSentimientos = _allSentimientos;
    });
  }

  void _filterSentimientos(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSentimientos = _allSentimientos;
      } else {
        _filteredSentimientos = _allSentimientos
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _motivoController.dispose();
    _pensamientoController.dispose();
    _comportamientoController.dispose();
    _consecuenciaController.dispose();
    _sentimientoSearchController.dispose();
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
      sentimientos: _selectedSentimientos.toList(),
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
      _sentimientoSearchController.clear();
      setState(() {
        _selectedSentimientos.clear();
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
        children: [
          // Search field
          TextField(
            controller: _sentimientoSearchController,
            decoration: InputDecoration(
              hintText: 'Buscar o añadir sentimiento...',
              border: const OutlineInputBorder(),
              suffixIcon: _sentimientoSearchController.text.isNotEmpty &&
                      !_allSentimientos.contains(_sentimientoSearchController.text)
                  ? IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: () async {
                        final newSentimiento = _sentimientoSearchController.text;
                        await DatabaseHelper.instance.addCustomSentimiento(newSentimiento);
                        await _loadSentimientos();
                        setState(() {
                          _selectedSentimientos.add(newSentimiento);
                          _sentimientoSearchController.clear();
                        });
                      },
                      tooltip: 'Añadir nuevo sentimiento',
                    )
                  : null,
            ),
            onChanged: (value) {
              _filterSentimientos(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),

          // Selected chips section - constrained height
          if (_selectedSentimientos.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 100),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selectedSentimientos.map((s) => Chip(
                    label: Text(
                      s,
                      style: const TextStyle(fontSize: 13),
                    ),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onDeleted: () {
                      setState(() {
                        _selectedSentimientos.remove(s);
                      });
                    },
                  )).toList(),
                ),
              ),
            ),

          if (_selectedSentimientos.isNotEmpty)
            const SizedBox(height: 12),

          // Checkbox list - takes remaining space
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _filteredSentimientos.isEmpty
                  ? const Center(
                      child: Text('No se encontraron sentimientos'),
                    )
                  : ListView.builder(
                      itemCount: _filteredSentimientos.length,
                      itemBuilder: (context, index) {
                        final sentimiento = _filteredSentimientos[index];
                        final isSelected = _selectedSentimientos.contains(sentimiento);

                        return CheckboxListTile(
                          title: Text(sentimiento),
                          value: isSelected,
                          activeColor: Theme.of(context).primaryColor,
                          dense: true,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedSentimientos.add(sentimiento);
                              } else {
                                _selectedSentimientos.remove(sentimiento);
                              }
                            });
                          },
                        );
                      },
                    ),
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
