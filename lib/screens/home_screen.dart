import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../services/turnos_service.dart';
import '../services/pacientes_service.dart';
import 'detalle_paciente_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TurnosService _turnosService = TurnosService();
  final PacientesService _pacientesService = PacientesService();
  int? _selectedProfessional;
  List<dynamic> _profesionales = [];
  bool _isLoading = true;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadProfesionales();
  }

  Future<void> _loadProfesionales() async {
    try {
      final profesionales = await _turnosService.getProfesionales();
      setState(() {
        _profesionales = profesionales;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTurnos() async {
    debugPrint(
        'Iniciando carga de turnos para el profesional $_selectedProfessional');
    if (_selectedProfessional == null) {
      debugPrint('No se ha seleccionado ningún profesional');
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      final List<dynamic> turnos =
          await _turnosService.getTurnos(_selectedProfessional!);
      debugPrint('Turnos recibidos: $turnos');
      // Convertir la lista de turnos a un mapa
      final Map<DateTime, List<dynamic>> eventos = {};
      for (var turno in turnos) {
        final DateTime fecha = DateTime.parse(turno['fecha']).toLocal();
        final DateTime fechaNormalizada =
            DateTime(fecha.year, fecha.month, fecha.day);
        if (eventos[fechaNormalizada] == null) {
          eventos[fechaNormalizada] = [];
        }
        eventos[fechaNormalizada]!.add(turno);
      }
      debugPrint('Eventos procesados: $eventos');
      setState(() {
        _events = eventos;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error al cargar turnos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar turnos: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onProfessionalSelected(int? professionalId) {
    debugPrint('Profesional seleccionado: $professionalId');
    setState(() {
      _selectedProfessional = professionalId;
    });
    _loadTurnos();
  }

  Future<void> _showPacienteDetails(int idPaciente) async {
    debugPrint('Cargando detalles para el paciente con ID: $idPaciente');
    try {
      final paciente = await _pacientesService.getPaciente(idPaciente);
      debugPrint('Datos del paciente recibidos: $paciente');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetallePacienteScreen(paciente: paciente),
        ),
      );
    } catch (e) {
      debugPrint('Error al cargar los detalles del paciente: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el paciente: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Turnos',
          style: TextStyle(color: Colors.blue[800]),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Dropdown para seleccionar profesional
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownSearch<int?>(
              popupProps: PopupProps.dialog(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Buscar Profesional',
                  ),
                ),
              ),
              items: _profesionales.map((profesional) {
                // Retornar lista de IDs (int?)
                return int.tryParse(profesional['id_prof'].toString());
              }).toList(),
              selectedItem: _selectedProfessional,
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Seleccionar Profesional",
                  contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                  border: OutlineInputBorder(),
                ),
              ),
              onChanged: _onProfessionalSelected,
              itemAsString: (int? id) {
                // Asegúrate de que el ID no sea nulo
                if (id == null) return '';
                final profesional = _profesionales.firstWhere(
                  (prof) => int.tryParse(prof['id_prof'].toString()) == id,
                  orElse: () => {
                    'nombreYapellido': 'Desconocido'
                  }, // Manejo de caso no encontrado
                );
                return profesional['nombreYapellido'] ?? 'Desconocido';
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: DateTime.now(),
                    eventLoader: (day) {
                      final DateTime fechaNormalizada =
                          DateTime(day.year, day.month, day.day);
                      debugPrint(
                          'Cargando eventos para el día: $fechaNormalizada');
                      final events = _events[fechaNormalizada] ?? [];
                      debugPrint(
                          'Eventos para el día $fechaNormalizada: $events');
                      return events;
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue[300],
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue[800],
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: Colors.blue[900],
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          debugPrint('Eventos para el día $date: $events');
                          return Positioned(
                            right: 1,
                            bottom: 1,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.blue[900],
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      final DateTime fechaNormalizada = DateTime(
                          selectedDay.year, selectedDay.month, selectedDay.day);
                      final turnos = _events[fechaNormalizada] ?? [];
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Turnos'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: turnos.map((turno) {
                                // Verificamos que 'turno' sea un Map y manejamos el acceso a las claves.
                                if (turno is! Map ||
                                    turno['paciente'] == null) {
                                  return ListTile(
                                    title: Text('Datos inválidos'),
                                    subtitle: Text(
                                        'No se pudo mostrar la información del turno.'),
                                  );
                                }

                                final String nombrePaciente =
                                    turno['paciente'] ?? 'Desconocido';
                                final String horaTurno =
                                    turno['hora'] ?? 'Sin hora';
                                final int idPaciente = turno[
                                    'id_paciente']; // Asegúrate de que 'id_paciente' esté presente en los datos del turno

                                debugPrint(
                                    'ID del paciente seleccionado: $idPaciente');

                                return ListTile(
                                  title: Text(nombrePaciente),
                                  subtitle: Text(horaTurno),
                                  onTap: () {
                                    Navigator.pop(context); // Cierra el diálogo
                                    _showPacienteDetails(
                                        idPaciente); // Carga los detalles del paciente
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          backgroundColor: Colors.blue[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      backgroundColor: Colors.blue[50],
    );
  }
}
