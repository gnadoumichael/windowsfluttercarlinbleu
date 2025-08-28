import 'dart:async';
import 'dart:io';
import 'package:carlinbleu/entity/Besoins.dart';
import 'package:carlinbleu/entity/Fichier.dart';
import 'package:carlinbleu/entity/Contact.dart';
import 'package:carlinbleu/entity/Service.dart';
import 'package:carlinbleu/entity/Corbeille.dart';
import 'package:carlinbleu/entity/User.dart';
import 'package:carlinbleu/entity/Intervenant.dart';
import 'package:carlinbleu/entity/MaterielChantier.dart';
import 'package:carlinbleu/entity/Todo.dart';
import 'package:carlinbleu/entity/Alerte.dart';
import 'package:html/parser.dart';
import 'package:internet_file/internet_file.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:carlinbleu/entity/Article.dart';
import 'package:carlinbleu/entity/Section.dart';
import 'package:carlinbleu/entity/Ligne.dart';
import 'package:carlinbleu/entity/Devis.dart';
import 'package:carlinbleu/entity/Personnel.dart';
import 'package:carlinbleu/entity/Caisse.dart';
import 'package:carlinbleu/entity/Commande.dart';
import 'package:carlinbleu/entity/Planning.dart';
import 'package:carlinbleu/entity/Valider.dart';
import 'package:carlinbleu/entity/Sousfamille.dart';
import 'package:carlinbleu/entity/Client.dart';
import 'package:carlinbleu/entity/Materiel.dart';
import 'package:carlinbleu/entity/Inventaire.dart';
import 'package:carlinbleu/entity/Chat.dart';
import 'package:pdfx/pdfx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:carlinbleu/entity/Chantier.dart';
import 'package:carlinbleu/entity/Decompte.dart';
import 'package:carlinbleu/entity/Facture.dart';
import 'package:carlinbleu/entity/Tache.dart';
import 'package:carlinbleu/entity/Historique.dart';
import 'package:carlinbleu/entity/Beneficiaire.dart';
import 'package:carlinbleu/entity/MaterielBeneficiaire.dart';
import 'package:carlinbleu/entity/MatHistorique.dart';
import 'package:carlinbleu/entity/Famille.dart';
import 'package:carlinbleu/entity/Fournisseur.dart';
import 'package:carlinbleu/entity/Droit.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';



class ShoPdf extends StatelessWidget {
  ShoPdf({required this.link, required this.title});

  final String link;
  final String title;

  @override
  Widget build(BuildContext context) {
    final pdfPinchController = PdfControllerPinch(
        document: PdfDocument.openData(InternetFile.get(link))
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: PdfViewPinch(
          controller: pdfPinchController,
        ),
      ),
    );
  }
}

class CustomTabIndicator extends Decoration {
  @override
  _CustomPainter createBoxPainter([VoidCallback? onChanged]) {
    return new _CustomPainter(this, onChanged!);
  }
}
class _CustomPainter extends BoxPainter {
  final CustomTabIndicator decoration;

  _CustomPainter(this.decoration, VoidCallback onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);


    final Rect rect = Offset(offset.dx, (configuration.size!.height / 6)) &
        Size(configuration.size!.width, 30);
    Size(configuration.size!.width, 10);
    final Paint paint = Paint();
    paint.color = Color(0xff4e73df);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(20.0)), paint);
  }
}

formatDate(String da)  async {
  await initializeDateFormatting('fr_FR', '');
  DateTime  dat = DateTime.parse(da);
  return DateFormat('EEE d MMM ' 'y ' ' HH:mm', 'fr_FR').format(dat);
}

formateDate(String da) {
  initializeDateFormatting('en', '');
  var dato = da.replaceAll("T", " ").replaceAll("-07:00", "");
  dato = DateFormat("yyyy-MM-dd hh:mm:ss").parse(dato).toString().replaceAll(".000", "");
  DateTime  dat = DateTime.parse(dato);
  return dat;
}

formateur(double b) {
  var f = NumberFormat.decimalPattern('fr_fr');
  String a;
  a = f.format(b);
  return a.replaceAll(',', ' ').replaceAll('.', ',');
}
formateuse(String b) {
  var a = getDouble(b);
  if (a == 0) {
    a = a.toStringAsFixed(2);
    return a.replaceAll(',', ' ').replaceAll('.', ',');
  } else {
    final oCcy = NumberFormat.currency(
        locale: 'fr',
        customPattern: '#,### \u00a4',
        symbol: ' ',
        decimalDigits: 2);
    a = oCcy.format(a);
    return a;
  }
}
getDouble(String b) {
  double a;
  if (b == "null") {
    a = 0.00;
  } else {
    a = double.parse(b);
  }
  return a;
}
getDoubleadd(String b, String c) {
  double a;
  double aa;
  double aaa;
  if (b == "null") {
    aa = 0;
  } else {
    aa = double.parse(b);
  }

  if (c == "null") {
    aaa = 0;
  } else {
    aaa = double.parse(c);
  }

  a = aa - aaa;
  return a;
}
getDoubler(int b) {
  double a;
  a = double.parse(b.toString());
  return a;
}
getDataChantier(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];

  Uri url = Uri.parse("https://carlinbleu.com/api/chantier/$id");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };
  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body);
    return jsonResponse;
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Valider>> getDataValider() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];
  List? shchantier = [];
  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse(
      "https://carlinbleu.com/api/valider/chantier/${shchantier![0]}");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((valider) => Valider.fromJson(valider)).toList();
  } else {
    throw Exception('Failed');
  }
}
Future<List<Valider>> getDataValiderMois(String mois) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];

  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse(
      "https://carlinbleu.com/api/valider/mois/$mois");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((valider) => Valider.fromJson(valider)).toList();
  } else {
    throw Exception('Failed');
  }
}
Future<List<Contact>> getDataContact() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];
  List? shchantier = [];

  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url =
      Uri.parse("https://carlinbleu.com/api/contacts/client/${shchantier![0]}");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Contact.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}


Future<List<Client>> getAllClients() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/client/ios/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };
  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Client.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
getAllCorbeille() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];

  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/corbeilles");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((corb) => Corbeille.fromJson(corb)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Famille>> getDataFamillesArticles() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/article/famille/python/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Famille.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Sousfamille>> getDataSousFamilles() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/article/sousfamille/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Sousfamille.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Article>> getAllArticles() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;

  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/article/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((ar) => Article.fromJson(ar)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Chantier>> getDataChantiers() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/chantier/ios/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Chantier.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<Chantier> getDataChantiersPersonnelles() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/personnel/get/chantier");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    return Chantier.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Droit>> getDroitComptable() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/droits/comptable/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Droit.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Tache>> getDataTaches() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/planning/tache/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Tache.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Todo>> getDataTodos() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/todo/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Todo.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Planning>> getDataPlannings() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/planning/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Planning.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Materiel>> getDataMateriels() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/materiel/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Materiel.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Famille>> getDataFamilles() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/materiel/famille/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Famille.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Fournisseur>> getDataFournisseurs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/materiel/fournisseur/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Fournisseur.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Fournisseur>> getDataFournisseursArticle() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/article/fournisseur/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Fournisseur.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Fournisseur>> getDataPrestataires() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/fournisseur/prestataires/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Fournisseur.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Fournisseur>> getDataFournisseursMateriaux() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/fournisseur/fournes/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Fournisseur.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Fichier>> getDataFichiers() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/fichier/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Fichier.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<MaterielChantier>> getDataMaterielChantiers() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/materiel/matchan/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => MaterielChantier.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<MaterielBeneficiaire>> getDataMaterielBeneficiaire() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/materiel/matbenef/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => MaterielBeneficiaire.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Beneficiaire>> getDataBeneficiaires() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/materiel/benef/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Beneficiaire.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Historique>> getDataHistorique() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/planning/historique/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Historique.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<MatHistorique>> getDataMatHistorique() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/materiel/mathisto/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => MatHistorique.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Personnel>> getDataPersonnel() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/personnel/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Personnel.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }

}
Future<List<User>> getDataUsers() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/user/getusers");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => User.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Service>> getDataServices() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/personnel/service/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Service.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Corbeille>> getDataCorbeille() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/corbeille/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Corbeille.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}


Future<List<Chantier>> getDataChantierCorbeille() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/corbeille/chantier/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Chantier.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Section>> getDataSections() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/planning/section/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Section.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
getDataLigneCaisse() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? shcaisse = [];
  List? shchantier = [];
  String estMaster = "";
  shcaisse = (prefs.getStringList('shCaisse') ?? ' ') as List?;
  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  estMaster = (prefs.getString('estMaster') ?? ' ');
  List? usere = [];

  if (estMaster == "oui") {
    usere = (prefs.getStringList('master') ?? '') as List?;
  } else {
    usere = (prefs.getStringList('usere') ?? '') as List?;
  }

  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/lignecaisse");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
        "numcaisse": shcaisse![1],
        "idchantier": shchantier![0],
      }));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => new Ligne.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Caisse>> getDataCaisse() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  List? shchantier = [];
  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/caisse/chantier/${shchantier![0]}");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => Caisse.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Caisse>> getChargesInternes() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/caisse/charges/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => Caisse.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<Caisse> getDataOneCaisse(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/caisse/get/$id");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    return Caisse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Caisse>> getDataCaisses(String mois) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  List? shchantier = [];
  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/caisse/mois/$mois");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => Caisse.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Caisse>> getTravauxCaisse() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];

  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/caisse/travaux");

  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
      }));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((d) => Caisse.fromJson(d)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }

}
Future<List<Devis>> getDataDevis() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];
  List? shchantier = [];

  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/devis/chantier/${shchantier![0]}");

  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
      }));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((d) => Devis.fromJson(d)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Devis>> getTravauxDevis() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];
  List? shchantier = [];

  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/devis/travaux");

  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
      }));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((d) => Devis.fromJson(d)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Devis>> getDataDevisChantier(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];
  List? shchantier = [];

  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/devis/chantier/$id");

  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
      }));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((d) => Devis.fromJson(d)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<Map<String, dynamic>> getDaDevis(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];

  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/devis/get/$id");

  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
      }));
  if (response.statusCode == 200) {
    return json.decode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Decompte>> getDataDecompte() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  List? shchantier = [];
  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/decompte/chantier/${shchantier![0]}");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
      }));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((d) => Decompte.fromJson(d)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Commande>> getDataCommande(String typ) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];
  List? shchantier = [];

  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;

  String token = usere![3];

  Uri url = Uri.parse("https://carlinbleu.com/api/commande/chantier/${shchantier![0]}/$typ");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => Commande.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Commande>> getTravauxCommande() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];

  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/commande/travaux");

  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
      }));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((d) => Commande.fromJson(d)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }

}
Future<List<Commande>> getDataLivraison() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];
  List? shchantier = [];

  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];

  Uri url = Uri.parse("https://carlinbleu.com/api/commande/chantier/${shchantier![0]}/none");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => Commande.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Intervenant>> getDataInterve() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  List? shchantier = [];
  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse(
      "https://carlinbleu.com/api/intervenant/chantier/${shchantier![0]}/interve" );var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
      }));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => Intervenant.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Intervenant>> getDataOperation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];
  List? shchantier = [];

  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse(
      "https://carlinbleu.com/api/intervenant/chantier/${shchantier![0]}/oper" );
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
      }));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => Intervenant.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Intervenant>> getDataAll() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];
  List? shchantier = [];
  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse(
      "https://carlinbleu.com/api/intervenant/chantier/${shchantier![0]}/all" );
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };
  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
      }));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => Intervenant.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
getInterveCaisse(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];

  String check = (prefs.getString('estMaster') ?? '');

  if (check == 'oui') {
    usere = (prefs.getStringList('master') ?? '') as List?;
  } else {
    usere = (prefs.getStringList('usere') ?? '') as List?;
  }
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/intervenant/caisses/$id");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => new Caisse.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Inventaire>> getInventaireArticle() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];
  List? shchantier = [];

  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;

  String token = usere![3];

  Uri url = Uri.parse(
      "https://carlinbleu.com/api/inventaire/chantier/${shchantier![0]}");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => Inventaire.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
Future<List<Facture>> getDataFactures() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List? usere = [];
  List? shchantier = [];

  shchantier = (prefs.getStringList('shChantier') ?? ' ') as List?;
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/facture/chantier/${shchantier![0]}");

  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers,
      body: json.encode({
        "username": usere[2],
      }));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((fa) => Facture.fromJson(fa)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}

Future<List<Chat>> getDataChat() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/chat/get/${usere[6]}");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };
  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));
  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => Chat.fromJson(json)).toList();
  } else {
    throw Exception('');
  }
}
Future<List<Alerte>> getAlertes() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? []) as List?;

  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/alerte/get/${usere[6]}");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };
  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((json) => Alerte.fromJson(json)).toList();
  } else {
    List jsonResponse = [];
    return jsonResponse.map((json) => Alerte.fromJson(json)).toList();
  }
}
getUserName() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var usere = (prefs.getStringList('usere') ?? '') as List?;
        return usere;
      }
Future<List<Besoins>> getDataBesoins() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List? usere = [];
  usere = (prefs.getStringList('usere') ?? '') as List?;
  String token = usere![3];
  Uri url = Uri.parse("https://carlinbleu.com/api/besoins/ios/get");
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  };

  http.Response response = await http.post(url,
      headers: headers, body: json.encode({"username": usere[2]}));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((c) => Besoins.fromJson(c)).toList();
  } else {
    throw Exception('Failed to load jobs from API');
  }
}
parseHtmlString(String htmlString) {
  var document = parse(htmlString);
  String? parsedString = parse(document.body?.text).documentElement?.text;
  return parsedString?.split(new RegExp(r'(?:\r?\n|\r)'))
      .where((s) => s.trim().isNotEmpty)
      .join('\n');
}
