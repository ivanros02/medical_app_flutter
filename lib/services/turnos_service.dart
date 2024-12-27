import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils/constants.dart';

class TurnosService {
  Future<List<dynamic>> getTurnos(int idProf) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_turnos.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_prof': idProf}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['turnos'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Error de conexión con el servidor');
    }
  }

  Future<List<dynamic>> getProfesionales() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_profesionales.php'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['profesionales'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Error de conexión con el servidor');
    }
  }
}
