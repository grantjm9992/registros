import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/registro.dart';
import '../database/database_helper.dart';
import '../widgets/registro_wizard.dart';

class DetailScreen extends StatefulWidget {
  final Registro registro;

  const DetailScreen({
    Key? key,
    required this.registro,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Registro'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() => _isEditing = false);
            },
          ),
        ),
        body: RegistroWizard(
          existingRegistro: widget.registro,
          onComplete: () {
            setState(() => _isEditing = false);
            Navigator.pop(context, true);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Registro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() => _isEditing = true);
            },
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: _buildDetailView(),
    );
  }

  Widget _buildDetailView() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fecha
          Center(
            child: Text(
              dateFormat.format(widget.registro.createdAt),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sentimiento destacado
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              child: Text(
                widget.registro.sentimiento,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Motivo
          _buildSection(
            'Motivo',
            widget.registro.motivo,
            Icons.lightbulb_outline,
          ),
          const Divider(height: 32),

          // Pensamiento
          _buildSection(
            'Pensamiento',
            widget.registro.pensamiento,
            Icons.psychology_outlined,
          ),
          const Divider(height: 32),

          // Comportamiento
          _buildSection(
            'Comportamiento',
            widget.registro.comportamiento,
            Icons.directions_walk_outlined,
          ),
          const Divider(height: 32),

          // Consecuencia
          _buildSection(
            'Consecuencia',
            widget.registro.consecuencia,
            Icons.flag_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Registro'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este registro? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteRegistro(widget.registro.id!);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro eliminado')),
        );
      }
    }
  }
}
