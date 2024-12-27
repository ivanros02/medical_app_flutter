import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class PacientesService {
  Future<Map<String, dynamic>> getPaciente(int idPaciente) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_paciente.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_paciente': idPaciente}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['paciente'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Error de conexión con el servidor');
    }
  }
}
