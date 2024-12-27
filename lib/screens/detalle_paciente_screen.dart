import 'package:flutter/material.dart';

class DetallePacienteScreen extends StatelessWidget {
  final Map<String, dynamic> paciente;

  const DetallePacienteScreen({super.key, required this.paciente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle del Paciente',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[50], // Fondo azul muy claro
        foregroundColor: Colors.blue[800], // Texto e íconos en azul oscuro
        elevation: 0, // Sin sombra para un diseño minimalista
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var entry in _pacienteInfo.entries)
              _buildInfoTile(entry.key, entry.value),
          ],
        ),
      ),
      backgroundColor: Colors.blue[50], // Fondo general azul muy claro
    );
  }

  Widget _buildInfoTile(String title, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.blue[100], // Fondo de tarjeta en azul claro
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800], // Azul oscuro para el título
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'No disponible',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue[900], // Azul aún más oscuro para los valores
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String?> get _pacienteInfo => {
        'Nombre': paciente['nombre'],
        'Documento': paciente['nro_doc']?.toString() ?? 'No registrado',
        'Domicilio': paciente['domicilio'] ?? 'No registrado',
        'Teléfono': paciente['telefono']?.toString() ?? 'No registrado',
        'Fecha de Nacimiento': paciente['fecha_nac'] ?? 'No registrada',
      };
}
