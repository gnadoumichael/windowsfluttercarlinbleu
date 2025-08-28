import 'dart:convert';
import 'dart:io';
import 'package:carlinbleu/entity/Bon.dart';
import 'package:carlinbleu/entity/Chantier.dart';
import 'package:carlinbleu/entity/Client.dart';
import 'package:carlinbleu/entity/Devis.dart';
import 'package:carlinbleu/entity/Relever.dart';
import 'package:carlinbleu/entity/Valider.dart';
import 'package:carlinbleu/js/fonctions.dart';
import 'package:carlinbleu/paniers/listeChantiers.dart';
import 'package:carlinbleu/sqlite/database_helper.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Pages
import 'package:carlinbleu/pages/pageAgenda.dart';
import 'package:carlinbleu/pages/pageArticle.dart';
import 'package:carlinbleu/pages/pageChantier.dart';
import 'package:carlinbleu/pages/pageChantiers.dart';
import 'package:carlinbleu/pages/pageChat.dart';
import 'package:carlinbleu/pages/pageCorbeille.dart';
import 'package:carlinbleu/pages/pageFichiers.dart';
import 'package:carlinbleu/pages/pageHistorique.dart';
import 'package:carlinbleu/pages/pageMateriel.dart';
import 'package:carlinbleu/pages/pageParametre.dart';
import 'package:carlinbleu/pages/pagePersonnel.dart';
import 'package:carlinbleu/pages/pagePlanning.dart';
import 'package:carlinbleu/pages/pageTravaux.dart';

// Paniers
import 'package:carlinbleu/paniers/start.dart';
import 'package:carlinbleu/paniers/welcome.dart';
import 'package:carlinbleu/paniers/login.dart';

// Services
import 'package:carlinbleu/services/locale_provider.dart';
import 'package:carlinbleu/l10n/app_localizations.dart';
import 'package:win32_registry/win32_registry.dart';

// =========================
//   ROUTES CENTRALISÉES
// =========================
class AppRoutes {
  static const login = '/login';
  static const welcome = '/welcome';
  static const start = '/start';
  static const chantiers = '/chantiers';
  static const chantier = '/chantier';
  static const articles = '/articles';
  static const planning = '/planning';
  static const historiques = '/historiques';
  static const materiels = '/materiels';
  static const fichiers = '/fichiers';
  static const travaux = '/travaux';
  static const personnel = '/personnel';
  static const parametre = '/parametre';
  static const corbeille = '/corbeille';
  static const chat = '/chat';
  static const agenda = '/agenda';
}

// =========================
//     POINT D'ENTRÉE
// =========================
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void addToStartup() {
  try {
    final exePath = Platform.resolvedExecutable;

    final key = Registry.openPath(
      RegistryHive.currentUser,
      path: r"Software\Microsoft\Windows\CurrentVersion\Run",
      desiredAccessRights: AccessRights.allAccess,
    );

    key.createValue(
      RegistryValue(
        "CarlinbleuApp", // nom de ta clé
        RegistryValueType.string,
        exePath, // chemin vers ton exe Flutter compilé
      ),
    );

    key.close();
    print("✅ Carlinbleu ajouté au démarrage Windows !");
  } catch (e) {
    print("❌ Erreur ajout démarrage: $e");
  }
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // 🔹 Appelle la fonction d’ajout au démarrage
    addToStartup();
  }
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    String jsonString = args[2];
    Map<String, dynamic> arges = jsonDecode(jsonString);
    if(arges["args1"] == "chantiers"){
      runApp(
        ChantierDetail(
            windowController: WindowController.fromWindowId(windowId),
            chantier: Chantier.fromJson(arges["args2"]),
            client: Client.fromJson(arges["args3"]),
            deviss: (arges['args4'] as List)
              .map((e) => Devis.fromJson(e as Map<String, dynamic>))
              .toList(),
            bons: (arges['args5'] as List)
            .map((e) => Bon.fromJson(e as Map<String, dynamic>))
            .toList()
        ),
      );
    }
  } else {
    runApp(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const Main(),
      ),
    );
  }
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      locale: localeProvider.locale,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Carlinbleu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => Login(),
        AppRoutes.welcome: (_) => Welcome(),
        AppRoutes.start: (_) => Start(),
        AppRoutes.chantiers: (_) => PageChantiers(),
        AppRoutes.chantier: (_) => PageChantier(),
        AppRoutes.articles: (_) => PageArticle(),
        AppRoutes.planning: (_) => PagePlanning(),
        AppRoutes.historiques: (_) => PageHistorique(),
        AppRoutes.materiels: (_) => PageMateriel(),
        AppRoutes.fichiers: (_) => PageFichiers(),
        AppRoutes.travaux: (_) => PageTravaux(),
        AppRoutes.personnel: (_) => PagePersonnel(),
        AppRoutes.parametre: (_) => PageParametre(),
        AppRoutes.corbeille: (_) => PageCorbeille(),
        AppRoutes.chat: (_) => PageChat(),
        AppRoutes.agenda: (_) => PageAgenda(),
      },
      home: const Login(),
    );
  }
}

class ChantierDetail extends StatefulWidget {
  const ChantierDetail({
    Key? key,
    required this.windowController,
    required this.chantier,
    required this.client,
    required this.deviss,
    required this.bons
  }) : super(key: key);

  final WindowController windowController;
  final Chantier chantier;
  final Client client;
  final List<Devis> deviss;
  final List<Bon> bons;

  @override
  _ChantierDetailState createState() => _ChantierDetailState();
}

class _ChantierDetailState extends State<ChantierDetail> {
  Chantier? chantier;
  Client? client;
  List<Devis> listDevis = [];
  List<Bon> listBons = [];
  List<Relever> listRelevers = [];
  List<Valider> listValiders = [];

  @override
  void initState() {
    super.initState();

    // ⚡ Récupération des données du widget
    chantier = widget.chantier;
    client   = widget.client;
    listRelevers = (chantier!.releves as List)
        .map((e) => Relever.fromJson(e))
        .toList();
    listValiders = (chantier!.validers as List)
        .map((e) => Valider.fromJson(e))
        .toList();
    listDevis = widget.deviss;
    listBons = widget.bons;
    print(listBons.length);
    }

  @override
  Widget build(BuildContext context) {
    // ⚡ si pas encore chargé => loader
    if (chantier == null || client == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    double depenses  = getDoublu(chantier!.bonprestataires) + getDoublu(chantier!.bonfournisseurs) + getDoublu(chantier!.chargechantiers);
    double depensesregler  = getDoublu(chantier!.paieprestataires) + getDoublu(chantier!.paiefournisseurs) + getDoublu(chantier!.chargepaiechantiers);
    double solde = depenses - depensesregler;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 1500,
                height: 3000,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.fromLTRB(20,33,30,30),
                decoration: BoxDecoration(
                  color: const Color(0xF1CCCCE0),
                  borderRadius: const BorderRadius.all(Radius.circular(15)), // Bords arrondis
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Colonne gauche
                        Flexible(
                          flex: 5, // poids de la colonne gauche
                          child: Column(
                            children: [
                              Container(
                                height: 180,
                                width: double.infinity,
                                margin: const EdgeInsets.only(right: 15),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xff4e73df),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Center(
                                      child: Text(
                                        chantier!.nomchantier.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Center(
                                      child: Text(
                                        client!.nomclient.toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.yellow,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Center(
                                      child: Text(
                                        "AVANCEMENT DU CHANTIER: 68,36%",
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                    const Center(
                                      child: Text(
                                        "(Selon les décomptes validés et factures d'acompte)",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 470,
                                margin: const EdgeInsets.fromLTRB(0, 10, 15, 0),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child:  Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const InfoRow(icon: Icons.assignment, label: "RÉFÉRENCE CONTRAT"),
                                    Text((chantier!.contrat == "null") ? "-" : chantier!.contrat),
                                    const SizedBox(height: 10),
                                    const InfoRow(icon: Icons.person, label: "CHEFS DU CHANTIER"),
                                    const Text("GNADOU MICHAEL"), // si tu veux aussi gérer null: pareil
                                    const SizedBox(height: 10),
                                    const InfoRow(icon: Icons.notes, label: "DESCRIPTION"),
                                    Text((chantier!.description == "null") ? "-" : parseHtmlString(chantier!.description)),
                                    const SizedBox(height: 10),
                                    const InfoRow(icon: Icons.alarm, label: "DÉBUT / FIN"),
                                    Text("${(chantier!.ddebut == "null") ? "-" : DateFormat('dd/MM/yyyy').format(DateTime.parse(chantier!.ddebut))} / ${(chantier!.dfin == null || chantier!.dfin == "null") ? "-" : DateFormat('dd/MM/yyyy').format(DateTime.parse(chantier!.dfin))}"),
                                    const SizedBox(height: 10),
                                    const InfoRow(icon: Icons.location_on, label: "LOCALISATION"),
                                    Text((chantier!.localisation == "null") ? "-" : chantier!.localisation),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 16), // petite séparation
                        // Colonne droite
                        Flexible(
                          flex: 7, // poids de la colonne droite
                          child: Column(
                            children: [
                              // Cartes financières
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  FinancialCard(
                                      title: "DEVIS VALIDÉS",
                                      total: formater(chantier!.cout),
                                      regle: formater(chantier!.reglement),
                                      reste: formater(
                                          (getDoublu(chantier!.cout) - getDoublu(chantier!.reglement))
                                              .toString()),
                                      color: Colors.blue),
                                  FinancialCard(
                                      title: "BONS FOURNISSEURS",
                                      total: formater(chantier!.bonfournisseurs),
                                      regle: formater(chantier!.paiefournisseurs),
                                      reste: formater(
                                          (getDoublu(chantier!.bonfournisseurs) -
                                              getDoublu(chantier!.paiefournisseurs))
                                              .toString()),
                                      color: Colors.green),
                                  FinancialCard(
                                      title: "BONS PRESTATAIRES",
                                      total: formater(chantier!.bonprestataires),
                                      regle: formater(chantier!.paieprestataires),
                                      reste: formater(
                                          (getDoublu(chantier!.bonprestataires) -
                                              getDoublu(chantier!.paieprestataires))
                                              .toString()),
                                      color: Colors.orange),
                                  FinancialCard(
                                      title: "CHARGES DIVERSES",
                                      total: formater(chantier!.chargechantiers),
                                      regle: formater(chantier!.chargepaiechantiers),
                                      reste: formater(
                                          (getDoublu(chantier!.chargechantiers) -
                                              getDoublu(chantier!.chargepaiechantiers))
                                              .toString()),
                                      color: Colors.purple),
                                  FinancialCard(
                                      title: "DÉPENSES TOTALES",
                                      total: formater(depenses.toString()),
                                      regle: formater(depensesregler.toString()),
                                      reste: formater(solde.toString()),
                                      color: Colors.red),
                                  FinancialCarde(
                                      title: "RECAP CHANTIER",
                                      reglement: formater(chantier!.reglement),
                                      depense: formater(depensesregler.toString()),
                                      caisse: formater(
                                          (getDoublu(chantier!.reglement) -
                                              getDoublu(depensesregler.toString()))
                                              .toString()),
                                      color: Colors.teal),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Boutons
                              Wrap(
                                children: [
                                  for (var btn in [
                                    {'label': 'RÈGLEMENT', 'color': Colors.teal, 'onTap': () => print('RÈGLEMENT')},
                                    {'label': 'BON DE SUIVI', 'color': Colors.teal, 'onTap': () => print('BON DE SUIVI')},
                                    {'label': 'BON FOURNISSEUR', 'color': Colors.blueGrey, 'onTap': () => print('BON FOURNISSEUR')},
                                    {'label': 'BON DE LIVRAISON', 'color': Colors.teal, 'onTap': () => print('BON DE LIVRAISON')},
                                    {'label': 'SUIVI DE STOCK', 'color': Colors.teal, 'onTap': () => print('SUIVI DE STOCK')},
                                    {'label': 'PAIE FOURNISSEUR', 'color': Colors.blueGrey, 'onTap': () => print('PAIE FOURNISSEUR')},
                                    {'label': 'DEVIS', 'color': Colors.blueAccent, 'onTap': () => print('DEVIS')},
                                    {'label': 'FACTURE', 'color': Colors.blueAccent, 'onTap': () => print('FACTURE')},
                                    {'label': 'BON PRESTATAIRE', 'color': const Color(0xff4e73df), 'onTap': () => print('BON PRESTATAIRE')},
                                    {'label': 'DÉCOMPTE', 'color': Colors.blueAccent, 'onTap': () => print('DÉCOMPTE')},
                                    {'label': 'CHARGES DIVERSES', 'color': Colors.blueAccent, 'onTap': () => print('CHARGES DIVERSES')},
                                    {'label': 'PAIE PRESTATAIRE', 'color': const Color(0xff4e73df), 'onTap': () => print('PAIE PRESTATAIRE')},
                                  ])
                                    Container(
                                      width: 250,
                                      height: 40,
                                      padding: const EdgeInsets.all(5),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: btn['color'] as Color,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0)),
                                        ),
                                        onPressed: btn['onTap'] as void Function()?,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            btn['label'] as String,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AccordionRelever(listValiders: listValiders),
                          const SizedBox(height: 5),
                          AccordionDevis(listDevis: listDevis),
                          const SizedBox(height: 20),
                          AccordionBonFou(listBons: listBons),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}


class SuiviValideSource extends DataTableSource {
  final List<Bon> allData;
  final List<Bon> filteredData;
  final BuildContext context;
  final Set<int> _selectedRows = {};

  SuiviValideSource(List<Bon> data, this.context)
      : allData = data,
        filteredData = List.from(data);

  void filter(String query) {
    query = query.toLowerCase();
    filteredData.clear();
    if (query.isEmpty) {
      filteredData.addAll(allData);
    } else {
      filteredData.addAll(allData.where((item) {
        final allValues = [
          item.numbon ?? "",
          item.date?.toString() ?? "",
          item.totalht?.toString() ?? "",
          item.totalttc?.toString() ?? "",
          item.bonreference ?? "",
          item.dobyuser?["nom"] ?? "",
          item.dobyuser?["prenoms"] ?? "",
        ].join(" ").toLowerCase();
        return allValues.contains(query);
      }));
    }
    notifyListeners(); // informe le PaginatedDataTable2
  }

  @override
  DataRow? getRow(int index) {
    if (index >= filteredData.length) return null;
    final item = filteredData[index];

    double regler = 0;
    double solde = 0;

    return DataRow(
      selected: _selectedRows.contains(index),
      onSelectChanged: (selected) {
        if (selected == true) {
          _selectedRows.add(index);
        } else {
          _selectedRows.remove(index);
        }
        notifyListeners();
      },
      cells: [
        DataCell(Text(DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(item.date.toString())))),
        DataCell(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.center, // Alignement vertical
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.blue),
                    iconSize: 20,
                    tooltip: 'Dévalider',
                    padding: EdgeInsets.zero, // Retire le padding par défaut
                    constraints:
                    const BoxConstraints(), // Supprime les contraintes de taille
                    onPressed: () {},
                  ),
                  const SizedBox(width: 6), // Espace entre l’icône et le texte
                  Text(
                    item.numbon,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalht.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalttc.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(regler.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(solde.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(Text("${parseHtmlString(item.bonreference)}",
            style: const TextStyle(fontSize: 13))),
        DataCell(Text(
          "${item.dobyuser["nom"].toString().toUpperCase()} ${item.dobyuser["prenoms"].toString().toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        )),
      ],
    );
  }

  @override
  int get rowCount => filteredData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;
}
class SuiviNonValideSource extends DataTableSource {
  final List<Bon> allData;
  List<Bon> filteredData;
  final BuildContext context;

  final Set<int> _selectedRows = {}; // pour stocker les lignes sélectionnées

  SuiviNonValideSource(List<Bon> data, this.context)
      : allData = data,
        filteredData = List.from(data);

  void filter(String query) {
    query = query.toLowerCase();
    filteredData.clear();
    if (query.isEmpty) {
      filteredData.addAll(allData);
    } else {
      filteredData.addAll(allData.where((item) {
        final allValues = [
          item.numbon ?? "",
          item.date?.toString() ?? "",
          item.totalht?.toString() ?? "",
          item.totalttc?.toString() ?? "",
          item.bonreference ?? "",
          item.dobyuser?["nom"] ?? "",
          item.dobyuser?["prenoms"] ?? "",
        ].join(" ").toLowerCase();
        return allValues.contains(query);
      }));
    }
    notifyListeners(); // informe le PaginatedDataTable2
  }

  @override
  DataRow? getRow(int index) {
    if (index >= filteredData.length) return null;
    final item = filteredData[index];

    double regler = 0;
    double solde = 0;

    return DataRow(
      selected: _selectedRows.contains(index),
      onSelectChanged: (selected) {
        if (selected == true) {
          _selectedRows.add(index);
        } else {
          _selectedRows.remove(index);
        }
        notifyListeners();
      },
      cells: [
        DataCell(Text(DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(item.date.toString())))),
        DataCell(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.center, // Alignement vertical
                children: [
                  IconButton(
                    icon:
                    const Icon(Icons.check_circle, color: Colors.blueGrey),
                    iconSize: 20,
                    tooltip: 'Dévalider',
                    padding: EdgeInsets.zero, // Retire le padding par défaut
                    constraints:
                    const BoxConstraints(), // Supprime les contraintes de taille
                    onPressed: () {},
                  ),
                  const SizedBox(width: 6), // Espace entre l’icône et le texte
                  Text(
                    item.numbon,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalht.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalttc.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(regler.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(solde.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(Text("${parseHtmlString(item.bonreference)}",
            style: const TextStyle(fontSize: 13))),
        DataCell(Text(
          "${item.dobyuser["nom"].toString().toUpperCase()} ${item.dobyuser["prenoms"].toString().toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        )),
      ],
    );
  }

  @override
  int get rowCount => filteredData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;
}
class AccordionSuivi extends StatefulWidget {
  final List<Bon> listSuivi;
  const AccordionSuivi({super.key, required this.listSuivi});

  @override
  State<AccordionDevis> createState() => AccordionDevisState();
}
class AccordionSuiviState extends State<AccordionDevis> {
  late TextEditingController searchControllerValide;
  late TextEditingController searchControllerNonValide;

  String filter = '';

  late DevisValideSource devValideSource;
  List<Devis> valideDevis = [];

  late DevisNonValideSource devNonValideSource;
  List<Devis> nonValideDevis = [];

  @override
  void initState() {
    super.initState();
    searchControllerValide = TextEditingController();
    searchControllerNonValide = TextEditingController();
    searchControllerValide = TextEditingController();
    searchControllerNonValide = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchControllerValide.dispose();
    searchControllerNonValide.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double vatotalHT = 0;
    double vatotalTTC = 0;
    double varegler = 0;
    double vasolde = 0;

    double vantotalHT = 0;
    double vantotalTTC = 0;
    double vanregler = 0;
    double vansolde = 0;

    valideDevis.clear();
    nonValideDevis.clear();

    for (var i = 0; i < widget.listDevis.length; i++) {
      if (widget.listDevis[i].etat == "valide") {
        valideDevis.add(widget.listDevis[i]);
        vatotalHT = vatotalHT + getDoublu(widget.listDevis[i].totalht);
        vatotalTTC = vatotalTTC + getDoublu(widget.listDevis[i].totalttc);
        List<Map<String, dynamic>> relevers = widget.listDevis[i].relevers;
        relevers.forEach((relever) {
          if (relever['type'] == 3) {
            final montant = relever['montant'] ?? 0;
            varegler += montant is String
                ? double.tryParse(montant) ?? 0
                : montant.toDouble();
          }
        });
      }
      if (widget.listDevis[i].etat == "save") {
        nonValideDevis.add(widget.listDevis[i]);
        vantotalHT = vantotalHT + getDoublu(widget.listDevis[i].totalht);
        vantotalTTC = vantotalTTC + getDoublu(widget.listDevis[i].totalttc);
        List<Map<String, dynamic>> relevers = widget.listDevis[i].relevers;
        relevers.forEach((relever) {
          if (relever['type'] == 3) {
            final montant = relever['montant'] ?? 0;
            vanregler += montant is String
                ? double.tryParse(montant) ?? 0
                : montant.toDouble();
          }
        });
      }
    }
    vasolde = vatotalTTC - varegler;
    vasolde = vantotalTTC - vanregler;

    devValideSource = DevisValideSource(valideDevis, context);
    devNonValideSource = DevisNonValideSource(nonValideDevis, context);

    final ScrollController scrollUn = ScrollController();
    final ScrollController scrollDeux = ScrollController();

    return ExpansionTile(
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      backgroundColor: const Color(0xff4e73df),
      collapsedBackgroundColor: const Color(0xff4e73df),
      title: Container(
        color: const Color(0xff4e73df),
        child: const Text("2-Devis", style: TextStyle(color: Colors.white)),
      ),
      children: [
        Container(
            color: Colors.white,
            margin: const EdgeInsets.fromLTRB(1, 0, 1, 1),
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Column(
              children: [
                SizedBox(
                  height: 500,
                  child: Scrollbar(
                    controller: scrollUn,
                    thumbVisibility: true, // Toujours visible
                    trackVisibility: true, // Montre la piste
                    child: SingleChildScrollView(
                      controller: scrollUn,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                          width: 1300,
                          child: PaginatedDataTable2(
                            header: Row(
                              children: [
                                Text(
                                  " [ ${valideDevis.length} DEVIS VALIDÉS ]",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                  width: 250,
                                  height: 42,
                                  child: TextField(
                                    controller: searchControllerValide,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: InputDecoration(
                                      hintText: 'Recherche...',
                                      prefixIcon: const Icon(Icons.search),
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 12),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      devValideSource.filter(value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 50),
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.blueGrey),
                                  iconSize: 20,
                                  tooltip: 'Dévalider',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  iconSize: 20,
                                  tooltip: 'Supprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Excel (FontAwesome)
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.fileExcel,
                                      color: Colors.green),
                                  iconSize: 20,
                                  tooltip: 'Exporter en Excel',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // PDF
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf,
                                      color: Colors.redAccent),
                                  iconSize: 20,
                                  tooltip: 'Exporter en PDF',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Imprimer
                                IconButton(
                                  icon: const Icon(Icons.print,
                                      color: Colors.blue),
                                  iconSize: 20,
                                  tooltip: 'Imprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            headingRowColor:
                            WidgetStateProperty.all(Colors.blue[100]),
                            columns: const [
                              DataColumn2(
                                  fixedWidth: 85,
                                  label: Text("DATE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 150,
                                  label: Text("N° DEVIS",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL HT",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL TTC",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("RÉGLÉ(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("SOLDE(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  label: Text("RÉFÉRENCE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 170,
                                  label: Text("CRÉÉ PAR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                            ],
                            source: devValideSource,
                            dataRowHeight: 38,
                            headingRowHeight: 40,
                            columnSpacing: 16,
                            horizontalMargin: 12,
                            rowsPerPage:
                            valideDevis.length.clamp(1, 10).toInt(),
                            border:
                            TableBorder.all(color: Colors.grey.shade300),
                            showFirstLastButtons: true,
                            showCheckboxColumn: true,
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2, child: SizedBox()), // DATE + N°DEVIS
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL HT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vatotalHT.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL TTC",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vatotalTTC.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX RÉGLÉ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(varegler.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX SOLDE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vasolde.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                          flex: 2, child: SizedBox()), // REF + CRÉÉ PAR
                    ],
                  ),
                ), // LES TOTAUX DE VALIDER
                const SizedBox(height: 50),
                SizedBox(
                  height: 500,
                  child: Scrollbar(
                    controller: scrollDeux,
                    thumbVisibility: true, // Toujours visible
                    trackVisibility: true, // Montre la piste
                    child: SingleChildScrollView(
                      controller: scrollDeux,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                          width: 1300,
                          child: PaginatedDataTable2(
                            header: Row(
                              children: [
                                Text(
                                  " [ ${nonValideDevis.length} DEVIS NON VALIDÉS ]",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                    width: 250,
                                    height: 42,
                                    child: TextField(
                                      controller: searchControllerNonValide,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        hintText: 'Recherche...',
                                        prefixIcon: const Icon(Icons.search),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 12),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        devNonValideSource.filter(value);
                                      },
                                    )),
                                const SizedBox(width: 50),
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.blueGrey),
                                  iconSize: 20,
                                  tooltip: 'Dévalider',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  iconSize: 20,
                                  tooltip: 'Supprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Excel (FontAwesome)
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.fileExcel,
                                      color: Colors.green),
                                  iconSize: 20,
                                  tooltip: 'Exporter en Excel',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // PDF
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf,
                                      color: Colors.redAccent),
                                  iconSize: 20,
                                  tooltip: 'Exporter en PDF',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Imprimer
                                IconButton(
                                  icon: const Icon(Icons.print,
                                      color: Colors.blue),
                                  iconSize: 20,
                                  tooltip: 'Imprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            headingRowColor:
                            WidgetStateProperty.all(Colors.blue[100]),
                            columns: const [
                              DataColumn2(
                                  fixedWidth: 85,
                                  label: Text("DATE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 150,
                                  label: Text("N° DEVIS",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL HT",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL TTC",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("RÉGLÉ(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("SOLDE(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  label: Text("RÉFÉRENCE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 170,
                                  label: Text("CRÉÉ PAR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                            ],
                            source: devNonValideSource,
                            dataRowHeight: 38,
                            headingRowHeight: 40,
                            columnSpacing: 16,
                            horizontalMargin: 12,
                            rowsPerPage: nonValideDevis.length.clamp(1, 10),
                            border:
                            TableBorder.all(color: Colors.grey.shade300),
                            showFirstLastButtons: true,
                            showCheckboxColumn: true,
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2, child: SizedBox()), // DATE + N°DEVIS
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL HT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vantotalHT.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL TTC",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vantotalTTC.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX RÉGLÉ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vanregler.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX SOLDE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vansolde.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                          flex: 2, child: SizedBox()), // REF + CRÉÉ PAR
                    ],
                  ),
                ),
              ],
            )),
      ],
    );
  }
}

class BonsValideSource extends DataTableSource {
  final List<Bon> allData;
  final List<Bon> filteredData;
  final BuildContext context;
  final Set<int> _selectedRows = {};

  BonsValideSource(List<Bon> data, this.context)
      : allData = data,
        filteredData = List.from(data);

  void filter(String query) {
    query = query.toLowerCase();
    filteredData.clear();
    if (query.isEmpty) {
      filteredData.addAll(allData);
    } else {
      filteredData.addAll(allData.where((item) {
        final allValues = [
          item.numbon ?? "",
          item.date.toString() ?? "",
          item.totalht.toString() ?? "",
          item.totalttc.toString() ?? "",
          item.bonreference ?? "",
          item.dobyuser?["nom"] ?? "",
          item.dobyuser?["prenoms"] ?? "",
        ].join(" ").toLowerCase();
        return allValues.contains(query);
      }));
    }
    notifyListeners(); // informe le PaginatedDataTable2
  }

  @override
  DataRow? getRow(int index) {
    if (index >= filteredData.length) return null;
    final item = filteredData[index];

    double regler = 0;
    double solde = 0;

    return DataRow(
      selected: _selectedRows.contains(index),
      onSelectChanged: (selected) {
        if (selected == true) {
          _selectedRows.add(index);
        } else {
          _selectedRows.remove(index);
        }
        notifyListeners();
      },
      cells: [
        DataCell(Text(DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(item.date.toString())))),
        DataCell(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.center, // Alignement vertical
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.blue),
                    iconSize: 20,
                    tooltip: 'Dévalider',
                    padding: EdgeInsets.zero, // Retire le padding par défaut
                    constraints:
                    const BoxConstraints(), // Supprime les contraintes de taille
                    onPressed: () {},
                  ),
                  const SizedBox(width: 6), // Espace entre l’icône et le texte
                  Text(
                    item.numbon,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalht.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalttc.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(regler.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(solde.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(Text("${parseHtmlString(item.bonreference)}",
            style: const TextStyle(fontSize: 13))),
        DataCell(Text(
          "${item.dobyuser["nom"].toString().toUpperCase()} ${item.dobyuser["prenoms"].toString().toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        )),
      ],
    );
  }

  @override
  int get rowCount => filteredData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;
}
class BonsNonValideSource extends DataTableSource {
  final List<Bon> allData;
  List<Bon> filteredData;
  final BuildContext context;

  final Set<int> _selectedRows = {}; // pour stocker les lignes sélectionnées

  BonsNonValideSource(List<Bon> data, this.context)
      : allData = data,
        filteredData = List.from(data);

  void filter(String query) {
    query = query.toLowerCase();
    filteredData.clear();
    if (query.isEmpty) {
      filteredData.addAll(allData);
    } else {
      filteredData.addAll(allData.where((item) {
        final allValues = [
          item.numbon ?? "",
          item.date.toString() ?? "",
          item.totalht.toString() ?? "",
          item.totalttc.toString() ?? "",
          item.bonreference ?? "",
          item.dobyuser?["nom"] ?? "",
          item.dobyuser?["prenoms"] ?? "",
        ].join(" ").toLowerCase();
        return allValues.contains(query);
      }));
    }
    notifyListeners(); // informe le PaginatedDataTable2
  }

  @override
  DataRow? getRow(int index) {
    if (index >= filteredData.length) return null;
    final item = filteredData[index];

    double regler = 0;
    double solde = 0;

    return DataRow(
      selected: _selectedRows.contains(index),
      onSelectChanged: (selected) {
        if (selected == true) {
          _selectedRows.add(index);
        } else {
          _selectedRows.remove(index);
        }
        notifyListeners();
      },
      cells: [
        DataCell(Text(DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(item.date.toString())))),
        DataCell(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.center, // Alignement vertical
                children: [
                  IconButton(
                    icon:
                    const Icon(Icons.check_circle, color: Colors.blueGrey),
                    iconSize: 20,
                    tooltip: 'Dévalider',
                    padding: EdgeInsets.zero, // Retire le padding par défaut
                    constraints:
                    const BoxConstraints(), // Supprime les contraintes de taille
                    onPressed: () {},
                  ),
                  const SizedBox(width: 6), // Espace entre l’icône et le texte
                  Text(
                    item.numbon,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalht.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalttc.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(regler.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(solde.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(Text("${parseHtmlString(item.bonreference)}",
            style: const TextStyle(fontSize: 13))),
        DataCell(Text(
          "${item.dobyuser["nom"].toString().toUpperCase()} ${item.dobyuser["prenoms"].toString().toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        )),
      ],
    );
  }

  @override
  int get rowCount => filteredData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;
}
class AccordionBonFou extends StatefulWidget {
  final List<Bon> listBons;
  const AccordionBonFou({super.key, required this.listBons});

  @override
  State<AccordionBonFou> createState() => AccordionBonFouState();
}
class AccordionBonFouState extends State<AccordionBonFou> {
  late TextEditingController searchControllerValide;
  late TextEditingController searchControllerNonValide;

  String filter = '';

  late BonsValideSource boValideSource;
  List<Bon> valideBons = [];

  late BonsNonValideSource boNonValideSource;
  List<Bon> nonValideBons = [];

  @override
  void initState() {
    super.initState();
    searchControllerValide = TextEditingController();
    searchControllerNonValide = TextEditingController();
    searchControllerValide = TextEditingController();
    searchControllerNonValide = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchControllerValide.dispose();
    searchControllerNonValide.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double vatotalHT = 0;
    double vatotalTTC = 0;
    double varegler = 0;
    double vasolde = 0;

    double vantotalHT = 0;
    double vantotalTTC = 0;
    double vanregler = 0;
    double vansolde = 0;

    valideBons.clear();
    nonValideBons.clear();

    for (var i = 0; i < widget.listBons.length; i++) {
      if (widget.listBons[i].etat == "valide") {
        valideBons.add(widget.listBons[i]);
        vatotalHT = vatotalHT + getDoublu(widget.listBons[i].totalht);
        vatotalTTC = vatotalTTC + getDoublu(widget.listBons[i].totalttc);
      }
      if (widget.listBons[i].etat == "save") {
        nonValideBons.add(widget.listBons[i]);
        vantotalHT = vantotalHT + getDoublu(widget.listBons[i].totalht);
        vantotalTTC = vantotalTTC + getDoublu(widget.listBons[i].totalttc);
      }
    }
    vasolde = vatotalTTC - varegler;
    vasolde = vantotalTTC - vanregler;

    boValideSource = BonsValideSource(valideBons, context);
    boNonValideSource = BonsNonValideSource(nonValideBons, context);

    final ScrollController scrollUn = ScrollController();
    final ScrollController scrollDeux = ScrollController();

    return ExpansionTile(
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      backgroundColor: const Color(0xff4e73df),
      collapsedBackgroundColor: const Color(0xff4e73df),
      title: Container(
        color: const Color(0xff4e73df),
        child: const Text("4-Bons fournisseurs", style: TextStyle(color: Colors.white)),
      ),
      children: [
        Container(
            color: Colors.white,
            margin: const EdgeInsets.fromLTRB(1, 0, 1, 1),
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Column(
              children: [
                SizedBox(
                  height: 500,
                  child: Scrollbar(
                    controller: scrollUn,
                    thumbVisibility: true, // Toujours visible
                    trackVisibility: true, // Montre la piste
                    child: SingleChildScrollView(
                      controller: scrollUn,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                          width: 1300,
                          child: PaginatedDataTable2(
                            header: Row(
                              children: [
                                Text(
                                  " [ ${valideBons.length} BONS FOURNISSEURS VALIDÉS ]",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                  width: 250,
                                  height: 42,
                                  child: TextField(
                                    controller: searchControllerValide,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: InputDecoration(
                                      hintText: 'Recherche...',
                                      prefixIcon: const Icon(Icons.search),
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 12),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      boValideSource.filter(value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 50),
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.blueGrey),
                                  iconSize: 20,
                                  tooltip: 'Dévalider',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  iconSize: 20,
                                  tooltip: 'Supprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Excel (FontAwesome)
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.fileExcel,
                                      color: Colors.green),
                                  iconSize: 20,
                                  tooltip: 'Exporter en Excel',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // PDF
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf,
                                      color: Colors.redAccent),
                                  iconSize: 20,
                                  tooltip: 'Exporter en PDF',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Imprimer
                                IconButton(
                                  icon: const Icon(Icons.print,
                                      color: Colors.blue),
                                  iconSize: 20,
                                  tooltip: 'Imprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            headingRowColor:
                            WidgetStateProperty.all(Colors.blue[100]),
                            columns: const [
                              DataColumn2(
                                  fixedWidth: 85,
                                  label: Text("DATE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 150,
                                  label: Text("N° DEVIS",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL HT",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL TTC",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("RÉGLÉ(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("SOLDE(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  label: Text("RÉFÉRENCE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 170,
                                  label: Text("CRÉÉ PAR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                            ],
                            source: boValideSource,
                            dataRowHeight: 38,
                            headingRowHeight: 40,
                            columnSpacing: 16,
                            horizontalMargin: 12,
                            rowsPerPage:
                            valideBons.length.clamp(1, 10).toInt(),
                            border:
                            TableBorder.all(color: Colors.grey.shade300),
                            showFirstLastButtons: true,
                            showCheckboxColumn: true,
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2, child: SizedBox()), // DATE + N°DEVIS
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL HT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vatotalHT.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL TTC",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vatotalTTC.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX RÉGLÉ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(varegler.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX SOLDE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vasolde.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                          flex: 2, child: SizedBox()), // REF + CRÉÉ PAR
                    ],
                  ),
                ), // LES TOTAUX DE VALIDER
                const SizedBox(height: 50),
                SizedBox(
                  height: 500,
                  child: Scrollbar(
                    controller: scrollDeux,
                    thumbVisibility: true, // Toujours visible
                    trackVisibility: true, // Montre la piste
                    child: SingleChildScrollView(
                      controller: scrollDeux,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                          width: 1300,
                          child: PaginatedDataTable2(
                            header: Row(
                              children: [
                                Text(
                                  " [ ${nonValideBons.length} BONS FOURNISSEURS NON VALIDÉS ]",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                    width: 250,
                                    height: 42,
                                    child: TextField(
                                      controller: searchControllerNonValide,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        hintText: 'Recherche...',
                                        prefixIcon: const Icon(Icons.search),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 12),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        boNonValideSource.filter(value);
                                      },
                                    )),
                                const SizedBox(width: 50),
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.blueGrey),
                                  iconSize: 20,
                                  tooltip: 'Dévalider',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  iconSize: 20,
                                  tooltip: 'Supprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Excel (FontAwesome)
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.fileExcel,
                                      color: Colors.green),
                                  iconSize: 20,
                                  tooltip: 'Exporter en Excel',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // PDF
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf,
                                      color: Colors.redAccent),
                                  iconSize: 20,
                                  tooltip: 'Exporter en PDF',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Imprimer
                                IconButton(
                                  icon: const Icon(Icons.print,
                                      color: Colors.blue),
                                  iconSize: 20,
                                  tooltip: 'Imprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            headingRowColor:
                            WidgetStateProperty.all(Colors.blue[100]),
                            columns: const [
                              DataColumn2(
                                  fixedWidth: 85,
                                  label: Text("DATE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 150,
                                  label: Text("N° DEVIS",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL HT",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL TTC",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("RÉGLÉ(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("SOLDE(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  label: Text("RÉFÉRENCE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 170,
                                  label: Text("CRÉÉ PAR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                            ],
                            source: boNonValideSource,
                            dataRowHeight: 38,
                            headingRowHeight: 40,
                            columnSpacing: 16,
                            horizontalMargin: 12,
                            rowsPerPage: nonValideBons.length.clamp(1, 10),
                            border:
                            TableBorder.all(color: Colors.grey.shade300),
                            showFirstLastButtons: true,
                            showCheckboxColumn: true,
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2, child: SizedBox()), // DATE + N°DEVIS
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL HT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vantotalHT.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL TTC",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vantotalTTC.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX RÉGLÉ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vanregler.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX SOLDE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vansolde.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                          flex: 2, child: SizedBox()), // REF + CRÉÉ PAR
                    ],
                  ),
                ),
              ],
            )),
      ],
    );
  }
}

class BonPrestaValideSource extends DataTableSource {
  final List<Bon> allData;
  final List<Bon> filteredData;
  final BuildContext context;
  final Set<int> _selectedRows = {};

  BonPrestaValideSource(List<Bon> data, this.context)
      : allData = data,
        filteredData = List.from(data);

  void filter(String query) {
    query = query.toLowerCase();
    filteredData.clear();
    if (query.isEmpty) {
      filteredData.addAll(allData);
    } else {
      filteredData.addAll(allData.where((item) {
        final allValues = [
          item.numbon ?? "",
          item.date?.toString() ?? "",
          item.totalht?.toString() ?? "",
          item.totalttc?.toString() ?? "",
          item.bonreference ?? "",
          item.dobyuser?["nom"] ?? "",
          item.dobyuser?["prenoms"] ?? "",
        ].join(" ").toLowerCase();
        return allValues.contains(query);
      }));
    }
    notifyListeners(); // informe le PaginatedDataTable2
  }

  @override
  DataRow? getRow(int index) {
    if (index >= filteredData.length) return null;
    final item = filteredData[index];

    double regler = 0;
    double solde = 0;

    return DataRow(
      selected: _selectedRows.contains(index),
      onSelectChanged: (selected) {
        if (selected == true) {
          _selectedRows.add(index);
        } else {
          _selectedRows.remove(index);
        }
        notifyListeners();
      },
      cells: [
        DataCell(Text(DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(item.date.toString())))),
        DataCell(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.center, // Alignement vertical
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.blue),
                    iconSize: 20,
                    tooltip: 'Dévalider',
                    padding: EdgeInsets.zero, // Retire le padding par défaut
                    constraints:
                    const BoxConstraints(), // Supprime les contraintes de taille
                    onPressed: () {},
                  ),
                  const SizedBox(width: 6), // Espace entre l’icône et le texte
                  Text(
                    item.numbon,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalht.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalttc.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(regler.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(solde.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(Text("${parseHtmlString(item.bonreference)}",
            style: const TextStyle(fontSize: 13))),
        DataCell(Text(
          "${item.dobyuser["nom"].toString().toUpperCase()} ${item.dobyuser["prenoms"].toString().toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        )),
      ],
    );
  }

  @override
  int get rowCount => filteredData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;
}
class BonPrestaNonValideSource extends DataTableSource {
  final List<Bon> allData;
  List<Bon> filteredData;
  final BuildContext context;

  final Set<int> _selectedRows = {}; // pour stocker les lignes sélectionnées

  BonPrestaNonValideSource(List<Bon> data, this.context)
      : allData = data,
        filteredData = List.from(data);

  void filter(String query) {
    query = query.toLowerCase();
    filteredData.clear();
    if (query.isEmpty) {
      filteredData.addAll(allData);
    } else {
      filteredData.addAll(allData.where((item) {
        final allValues = [
          item.numbon ?? "",
          item.date?.toString() ?? "",
          item.totalht?.toString() ?? "",
          item.totalttc?.toString() ?? "",
          item.bonreference ?? "",
          item.dobyuser?["nom"] ?? "",
          item.dobyuser?["prenoms"] ?? "",
        ].join(" ").toLowerCase();
        return allValues.contains(query);
      }));
    }
    notifyListeners(); // informe le PaginatedDataTable2
  }

  @override
  DataRow? getRow(int index) {
    if (index >= filteredData.length) return null;
    final item = filteredData[index];

    double regler = 0;
    double solde = 0;

    return DataRow(
      selected: _selectedRows.contains(index),
      onSelectChanged: (selected) {
        if (selected == true) {
          _selectedRows.add(index);
        } else {
          _selectedRows.remove(index);
        }
        notifyListeners();
      },
      cells: [
        DataCell(Text(DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(item.date.toString())))),
        DataCell(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.center, // Alignement vertical
                children: [
                  IconButton(
                    icon:
                    const Icon(Icons.check_circle, color: Colors.blueGrey),
                    iconSize: 20,
                    tooltip: 'Dévalider',
                    padding: EdgeInsets.zero, // Retire le padding par défaut
                    constraints:
                    const BoxConstraints(), // Supprime les contraintes de taille
                    onPressed: () {},
                  ),
                  const SizedBox(width: 6), // Espace entre l’icône et le texte
                  Text(
                    item.numbon,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalht.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalttc.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(regler.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(solde.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(Text("${parseHtmlString(item.bonreference)}",
            style: const TextStyle(fontSize: 13))),
        DataCell(Text(
          "${item.dobyuser["nom"].toString().toUpperCase()} ${item.dobyuser["prenoms"].toString().toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        )),
      ],
    );
  }

  @override
  int get rowCount => filteredData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;
}
class AccordionBonPresta extends StatefulWidget {
  final List<Bon> listSuivi;
  const AccordionBonPresta({super.key, required this.listSuivi});

  @override
  State<AccordionDevis> createState() => AccordionDevisState();
}
class AccordionBonPrestaState extends State<AccordionDevis> {
  late TextEditingController searchControllerValide;
  late TextEditingController searchControllerNonValide;

  String filter = '';

  late DevisValideSource devValideSource;
  List<Devis> valideDevis = [];

  late DevisNonValideSource devNonValideSource;
  List<Devis> nonValideDevis = [];

  @override
  void initState() {
    super.initState();
    searchControllerValide = TextEditingController();
    searchControllerNonValide = TextEditingController();
    searchControllerValide = TextEditingController();
    searchControllerNonValide = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchControllerValide.dispose();
    searchControllerNonValide.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double vatotalHT = 0;
    double vatotalTTC = 0;
    double varegler = 0;
    double vasolde = 0;

    double vantotalHT = 0;
    double vantotalTTC = 0;
    double vanregler = 0;
    double vansolde = 0;

    valideDevis.clear();
    nonValideDevis.clear();

    for (var i = 0; i < widget.listDevis.length; i++) {
      if (widget.listDevis[i].etat == "valide") {
        valideDevis.add(widget.listDevis[i]);
        vatotalHT = vatotalHT + getDoublu(widget.listDevis[i].totalht);
        vatotalTTC = vatotalTTC + getDoublu(widget.listDevis[i].totalttc);
        List<Map<String, dynamic>> relevers = widget.listDevis[i].relevers;
        relevers.forEach((relever) {
          if (relever['type'] == 3) {
            final montant = relever['montant'] ?? 0;
            varegler += montant is String
                ? double.tryParse(montant) ?? 0
                : montant.toDouble();
          }
        });
      }
      if (widget.listDevis[i].etat == "save") {
        nonValideDevis.add(widget.listDevis[i]);
        vantotalHT = vantotalHT + getDoublu(widget.listDevis[i].totalht);
        vantotalTTC = vantotalTTC + getDoublu(widget.listDevis[i].totalttc);
        List<Map<String, dynamic>> relevers = widget.listDevis[i].relevers;
        relevers.forEach((relever) {
          if (relever['type'] == 3) {
            final montant = relever['montant'] ?? 0;
            vanregler += montant is String
                ? double.tryParse(montant) ?? 0
                : montant.toDouble();
          }
        });
      }
    }
    vasolde = vatotalTTC - varegler;
    vasolde = vantotalTTC - vanregler;

    devValideSource = DevisValideSource(valideDevis, context);
    devNonValideSource = DevisNonValideSource(nonValideDevis, context);

    final ScrollController scrollUn = ScrollController();
    final ScrollController scrollDeux = ScrollController();

    return ExpansionTile(
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      backgroundColor: const Color(0xff4e73df),
      collapsedBackgroundColor: const Color(0xff4e73df),
      title: Container(
        color: const Color(0xff4e73df),
        child: const Text("2-Devis", style: TextStyle(color: Colors.white)),
      ),
      children: [
        Container(
            color: Colors.white,
            margin: const EdgeInsets.fromLTRB(1, 0, 1, 1),
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Column(
              children: [
                SizedBox(
                  height: 500,
                  child: Scrollbar(
                    controller: scrollUn,
                    thumbVisibility: true, // Toujours visible
                    trackVisibility: true, // Montre la piste
                    child: SingleChildScrollView(
                      controller: scrollUn,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                          width: 1300,
                          child: PaginatedDataTable2(
                            header: Row(
                              children: [
                                Text(
                                  " [ ${valideDevis.length} DEVIS VALIDÉS ]",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                  width: 250,
                                  height: 42,
                                  child: TextField(
                                    controller: searchControllerValide,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: InputDecoration(
                                      hintText: 'Recherche...',
                                      prefixIcon: const Icon(Icons.search),
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 12),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      devValideSource.filter(value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 50),
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.blueGrey),
                                  iconSize: 20,
                                  tooltip: 'Dévalider',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  iconSize: 20,
                                  tooltip: 'Supprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Excel (FontAwesome)
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.fileExcel,
                                      color: Colors.green),
                                  iconSize: 20,
                                  tooltip: 'Exporter en Excel',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // PDF
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf,
                                      color: Colors.redAccent),
                                  iconSize: 20,
                                  tooltip: 'Exporter en PDF',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Imprimer
                                IconButton(
                                  icon: const Icon(Icons.print,
                                      color: Colors.blue),
                                  iconSize: 20,
                                  tooltip: 'Imprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            headingRowColor:
                            WidgetStateProperty.all(Colors.blue[100]),
                            columns: const [
                              DataColumn2(
                                  fixedWidth: 85,
                                  label: Text("DATE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 150,
                                  label: Text("N° DEVIS",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL HT",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL TTC",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("RÉGLÉ(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("SOLDE(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  label: Text("RÉFÉRENCE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 170,
                                  label: Text("CRÉÉ PAR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                            ],
                            source: devValideSource,
                            dataRowHeight: 38,
                            headingRowHeight: 40,
                            columnSpacing: 16,
                            horizontalMargin: 12,
                            rowsPerPage:
                            valideDevis.length.clamp(1, 10).toInt(),
                            border:
                            TableBorder.all(color: Colors.grey.shade300),
                            showFirstLastButtons: true,
                            showCheckboxColumn: true,
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2, child: SizedBox()), // DATE + N°DEVIS
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL HT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vatotalHT.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL TTC",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vatotalTTC.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX RÉGLÉ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(varegler.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX SOLDE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vasolde.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                          flex: 2, child: SizedBox()), // REF + CRÉÉ PAR
                    ],
                  ),
                ), // LES TOTAUX DE VALIDER
                const SizedBox(height: 50),
                SizedBox(
                  height: 500,
                  child: Scrollbar(
                    controller: scrollDeux,
                    thumbVisibility: true, // Toujours visible
                    trackVisibility: true, // Montre la piste
                    child: SingleChildScrollView(
                      controller: scrollDeux,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                          width: 1300,
                          child: PaginatedDataTable2(
                            header: Row(
                              children: [
                                Text(
                                  " [ ${nonValideDevis.length} DEVIS NON VALIDÉS ]",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                    width: 250,
                                    height: 42,
                                    child: TextField(
                                      controller: searchControllerNonValide,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        hintText: 'Recherche...',
                                        prefixIcon: const Icon(Icons.search),
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 0, horizontal: 12),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        devNonValideSource.filter(value);
                                      },
                                    )),
                                const SizedBox(width: 50),
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.blueGrey),
                                  iconSize: 20,
                                  tooltip: 'Dévalider',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  iconSize: 20,
                                  tooltip: 'Supprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Excel (FontAwesome)
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.fileExcel,
                                      color: Colors.green),
                                  iconSize: 20,
                                  tooltip: 'Exporter en Excel',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // PDF
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf,
                                      color: Colors.redAccent),
                                  iconSize: 20,
                                  tooltip: 'Exporter en PDF',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Imprimer
                                IconButton(
                                  icon: const Icon(Icons.print,
                                      color: Colors.blue),
                                  iconSize: 20,
                                  tooltip: 'Imprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            headingRowColor:
                            WidgetStateProperty.all(Colors.blue[100]),
                            columns: const [
                              DataColumn2(
                                  fixedWidth: 85,
                                  label: Text("DATE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 150,
                                  label: Text("N° DEVIS",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL HT",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL TTC",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("RÉGLÉ(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("SOLDE(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  label: Text("RÉFÉRENCE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 170,
                                  label: Text("CRÉÉ PAR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                            ],
                            source: devNonValideSource,
                            dataRowHeight: 38,
                            headingRowHeight: 40,
                            columnSpacing: 16,
                            horizontalMargin: 12,
                            rowsPerPage: nonValideDevis.length.clamp(1, 10),
                            border:
                            TableBorder.all(color: Colors.grey.shade300),
                            showFirstLastButtons: true,
                            showCheckboxColumn: true,
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2, child: SizedBox()), // DATE + N°DEVIS
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL HT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vantotalHT.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL TTC",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vantotalTTC.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX RÉGLÉ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vanregler.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX SOLDE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vansolde.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                          flex: 2, child: SizedBox()), // REF + CRÉÉ PAR
                    ],
                  ),
                ),
              ],
            )),
      ],
    );
  }
}

class DevisValideSource extends DataTableSource {
  final List<Devis> allData;
  final List<Devis> filteredData;
  final BuildContext context;
  final Set<int> _selectedRows = {};

  DevisValideSource(List<Devis> data, this.context)
      : allData = data,
        filteredData = List.from(data);

  void filter(String query) {
    query = query.toLowerCase();
    filteredData.clear();
    if (query.isEmpty) {
      filteredData.addAll(allData);
    } else {
      filteredData.addAll(allData.where((item) {
        final allValues = [
          item.iddevis ?? "",
          item.date?.toString() ?? "",
          item.totalht?.toString() ?? "",
          item.totalttc?.toString() ?? "",
          item.devreference ?? "",
          item.dobyuser?["nom"] ?? "",
          item.dobyuser?["prenoms"] ?? "",
        ].join(" ").toLowerCase();
        return allValues.contains(query);
      }));
    }
    notifyListeners(); // informe le PaginatedDataTable2
  }

  @override
  DataRow? getRow(int index) {
    if (index >= filteredData.length) return null;
    final item = filteredData[index];

    double regler = 0;
    for (var relever in item.relevers) {
      if (relever['type'] == 3) {
        final montant = relever['montant'] ?? 0;
        regler += montant is String
            ? double.tryParse(montant) ?? 0
            : montant.toDouble();
      }
    }
    double solde = getDoublu(item.totalttc) - regler;

    return DataRow(
      selected: _selectedRows.contains(index),
      onSelectChanged: (selected) {
        if (selected == true) {
          _selectedRows.add(index);
        } else {
          _selectedRows.remove(index);
        }
        notifyListeners();
      },
      cells: [
        DataCell(Text(DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(item.date.toString())))),
        DataCell(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                DevisDialog(context, item);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Alignement vertical
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.blue),
                    iconSize: 20,
                    tooltip: 'Dévalider',
                    padding: EdgeInsets.zero, // Retire le padding par défaut
                    constraints:
                        const BoxConstraints(), // Supprime les contraintes de taille
                    onPressed: () {},
                  ),
                  const SizedBox(width: 6), // Espace entre l’icône et le texte
                  Text(
                    item.iddevis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalht.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalttc.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(regler.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(solde.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(Text("${parseHtmlString(item.devreference)}",
            style: const TextStyle(fontSize: 13))),
        DataCell(Text(
          "${item.dobyuser["nom"].toString().toUpperCase()} ${item.dobyuser["prenoms"].toString().toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        )),
      ],
    );
  }

  @override
  int get rowCount => filteredData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;
}
class DevisNonValideSource extends DataTableSource {
  final List<Devis> allData;
  List<Devis> filteredData;
  final BuildContext context;

  final Set<int> _selectedRows = {}; // pour stocker les lignes sélectionnées

  DevisNonValideSource(List<Devis> data, this.context)
      : allData = data,
        filteredData = List.from(data);

  void filter(String query) {
    query = query.toLowerCase();
    filteredData.clear();
    if (query.isEmpty) {
      filteredData.addAll(allData);
    } else {
      filteredData.addAll(allData.where((item) {
        final allValues = [
          item.iddevis ?? "",
          item.date?.toString() ?? "",
          item.totalht?.toString() ?? "",
          item.totalttc?.toString() ?? "",
          item.devreference ?? "",
          item.dobyuser?["nom"] ?? "",
          item.dobyuser?["prenoms"] ?? "",
        ].join(" ").toLowerCase();
        return allValues.contains(query);
      }));
    }
    notifyListeners(); // informe le PaginatedDataTable2
  }

  @override
  DataRow? getRow(int index) {
    if (index >= filteredData.length) return null;
    final item = filteredData[index];
    List<Map<String, dynamic>> relevers = item.relevers;
    double regler = 0;
    relevers.forEach((relever) {
      if (relever['type'] == 3) {
        final montant = relever['montant'] ?? 0;
        regler += montant is String
            ? double.tryParse(montant) ?? 0
            : montant.toDouble();
      }
    });
    double solde = getDoublu(item.totalttc) - regler;

    return DataRow(
      selected: _selectedRows.contains(index),
      onSelectChanged: (selected) {
        if (selected == true) {
          _selectedRows.add(index);
        } else {
          _selectedRows.remove(index);
        }
        notifyListeners();
      },
      cells: [
        DataCell(Text(DateFormat('dd/MM/yyyy')
            .format(DateTime.parse(item.date.toString())))),
        DataCell(
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                DevisDialog(context, item);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Alignement vertical
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.check_circle, color: Colors.blueGrey),
                    iconSize: 20,
                    tooltip: 'Dévalider',
                    padding: EdgeInsets.zero, // Retire le padding par défaut
                    constraints:
                        const BoxConstraints(), // Supprime les contraintes de taille
                    onPressed: () {},
                  ),
                  const SizedBox(width: 6), // Espace entre l’icône et le texte
                  Text(
                    item.iddevis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalht.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.yellow.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(item.totalttc.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(regler.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              formater(solde.toString()),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ),
        DataCell(Text("${parseHtmlString(item.devreference)}",
            style: const TextStyle(fontSize: 13))),
        DataCell(Text(
          "${item.dobyuser["nom"].toString().toUpperCase()} ${item.dobyuser["prenoms"].toString().toUpperCase()}",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        )),
      ],
    );
  }

  @override
  int get rowCount => filteredData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;
}
class AccordionDevis extends StatefulWidget {
  final List<Devis> listDevis;
  const AccordionDevis({super.key, required this.listDevis});

  @override
  State<AccordionDevis> createState() => AccordionDevisState();
}
class AccordionDevisState extends State<AccordionDevis> {
  late TextEditingController searchControllerValide;
  late TextEditingController searchControllerNonValide;

  String filter = '';

  late DevisValideSource devValideSource;
  List<Devis> valideDevis = [];

  late DevisNonValideSource devNonValideSource;
  List<Devis> nonValideDevis = [];

  @override
  void initState() {
    super.initState();
    searchControllerValide = TextEditingController();
    searchControllerNonValide = TextEditingController();
    searchControllerValide = TextEditingController();
    searchControllerNonValide = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    searchControllerValide.dispose();
    searchControllerNonValide.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double vatotalHT = 0;
    double vatotalTTC = 0;
    double varegler = 0;
    double vasolde = 0;

    double vantotalHT = 0;
    double vantotalTTC = 0;
    double vanregler = 0;
    double vansolde = 0;

    valideDevis.clear();
    nonValideDevis.clear();

    for (var i = 0; i < widget.listDevis.length; i++) {
      if (widget.listDevis[i].etat == "valide") {
        valideDevis.add(widget.listDevis[i]);
        vatotalHT = vatotalHT + getDoublu(widget.listDevis[i].totalht);
        vatotalTTC = vatotalTTC + getDoublu(widget.listDevis[i].totalttc);
        List<Map<String, dynamic>> relevers = widget.listDevis[i].relevers;
        relevers.forEach((relever) {
          if (relever['type'] == 3) {
            final montant = relever['montant'] ?? 0;
            varegler += montant is String
                ? double.tryParse(montant) ?? 0
                : montant.toDouble();
          }
        });
      }
      if (widget.listDevis[i].etat == "save") {
        nonValideDevis.add(widget.listDevis[i]);
        vantotalHT = vantotalHT + getDoublu(widget.listDevis[i].totalht);
        vantotalTTC = vantotalTTC + getDoublu(widget.listDevis[i].totalttc);
        List<Map<String, dynamic>> relevers = widget.listDevis[i].relevers;
        relevers.forEach((relever) {
          if (relever['type'] == 3) {
            final montant = relever['montant'] ?? 0;
            vanregler += montant is String
                ? double.tryParse(montant) ?? 0
                : montant.toDouble();
          }
        });
      }
    }
    vasolde = vatotalTTC - varegler;
    vasolde = vantotalTTC - vanregler;

    devValideSource = DevisValideSource(valideDevis, context);
    devNonValideSource = DevisNonValideSource(nonValideDevis, context);

    final ScrollController scrollUn = ScrollController();
    final ScrollController scrollDeux = ScrollController();

    return ExpansionTile(
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      backgroundColor: const Color(0xff4e73df),
      collapsedBackgroundColor: const Color(0xff4e73df),
      title: Container(
        color: const Color(0xff4e73df),
        child: const Text("2-Devis", style: TextStyle(color: Colors.white)),
      ),
      children: [
        Container(
            color: Colors.white,
            margin: const EdgeInsets.fromLTRB(1, 0, 1, 1),
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Column(
              children: [
                SizedBox(
                  height: 500,
                  child: Scrollbar(
                    controller: scrollUn,
                    thumbVisibility: true, // Toujours visible
                    trackVisibility: true, // Montre la piste
                    child: SingleChildScrollView(
                      controller: scrollUn,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                          width: 1300,
                          child: PaginatedDataTable2(
                            header: Row(
                              children: [
                                Text(
                                  " [ ${valideDevis.length} DEVIS VALIDÉS ]",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                  width: 250,
                                  height: 42,
                                  child: TextField(
                                    controller: searchControllerValide,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: InputDecoration(
                                      hintText: 'Recherche...',
                                      prefixIcon: const Icon(Icons.search),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 12),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      devValideSource.filter(value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 50),
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.blueGrey),
                                  iconSize: 20,
                                  tooltip: 'Dévalider',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  iconSize: 20,
                                  tooltip: 'Supprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Excel (FontAwesome)
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.fileExcel,
                                      color: Colors.green),
                                  iconSize: 20,
                                  tooltip: 'Exporter en Excel',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // PDF
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf,
                                      color: Colors.redAccent),
                                  iconSize: 20,
                                  tooltip: 'Exporter en PDF',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Imprimer
                                IconButton(
                                  icon: const Icon(Icons.print,
                                      color: Colors.blue),
                                  iconSize: 20,
                                  tooltip: 'Imprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            headingRowColor:
                                WidgetStateProperty.all(Colors.blue[100]),
                            columns: const [
                              DataColumn2(
                                  fixedWidth: 85,
                                  label: Text("DATE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 150,
                                  label: Text("N° DEVIS",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL HT",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL TTC",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("RÉGLÉ(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("SOLDE(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  label: Text("RÉFÉRENCE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 170,
                                  label: Text("CRÉÉ PAR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                            ],
                            source: devValideSource,
                            dataRowHeight: 38,
                            headingRowHeight: 40,
                            columnSpacing: 16,
                            horizontalMargin: 12,
                            rowsPerPage:
                                valideDevis.length.clamp(1, 10).toInt(),
                            border:
                                TableBorder.all(color: Colors.grey.shade300),
                            showFirstLastButtons: true,
                            showCheckboxColumn: true,
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2, child: SizedBox()), // DATE + N°DEVIS
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL HT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vatotalHT.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL TTC",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vatotalTTC.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX RÉGLÉ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(varegler.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX SOLDE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vasolde.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                          flex: 2, child: SizedBox()), // REF + CRÉÉ PAR
                    ],
                  ),
                ), // LES TOTAUX DE VALIDER
                const SizedBox(height: 50),
                SizedBox(
                  height: 500,
                  child: Scrollbar(
                    controller: scrollDeux,
                    thumbVisibility: true, // Toujours visible
                    trackVisibility: true, // Montre la piste
                    child: SingleChildScrollView(
                      controller: scrollDeux,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                          width: 1300,
                          child: PaginatedDataTable2(
                            header: Row(
                              children: [
                                Text(
                                  " [ ${nonValideDevis.length} DEVIS NON VALIDÉS ]",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                SizedBox(
                                    width: 250,
                                    height: 42,
                                    child: TextField(
                                      controller: searchControllerNonValide,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: InputDecoration(
                                        hintText: 'Recherche...',
                                        prefixIcon: const Icon(Icons.search),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 12),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        devNonValideSource.filter(value);
                                      },
                                    )),
                                const SizedBox(width: 50),
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.blueGrey),
                                  iconSize: 20,
                                  tooltip: 'Dévalider',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  iconSize: 20,
                                  tooltip: 'Supprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Excel (FontAwesome)
                                IconButton(
                                  icon: const FaIcon(FontAwesomeIcons.fileExcel,
                                      color: Colors.green),
                                  iconSize: 20,
                                  tooltip: 'Exporter en Excel',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // PDF
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf,
                                      color: Colors.redAccent),
                                  iconSize: 20,
                                  tooltip: 'Exporter en PDF',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 6),

                                // Imprimer
                                IconButton(
                                  icon: const Icon(Icons.print,
                                      color: Colors.blue),
                                  iconSize: 20,
                                  tooltip: 'Imprimer',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            headingRowColor:
                                WidgetStateProperty.all(Colors.blue[100]),
                            columns: const [
                              DataColumn2(
                                  fixedWidth: 85,
                                  label: Text("DATE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 150,
                                  label: Text("N° DEVIS",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL HT",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("TOTAL TTC",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("RÉGLÉ(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 140,
                                  label: Text("SOLDE(TTC)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  label: Text("RÉFÉRENCE",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                              DataColumn2(
                                  fixedWidth: 170,
                                  label: Text("CRÉÉ PAR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500))),
                            ],
                            source: devNonValideSource,
                            dataRowHeight: 38,
                            headingRowHeight: 40,
                            columnSpacing: 16,
                            horizontalMargin: 12,
                            rowsPerPage: nonValideDevis.length.clamp(1, 10),
                            border:
                                TableBorder.all(color: Colors.grey.shade300),
                            showFirstLastButtons: true,
                            showCheckboxColumn: true,
                          )),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Expanded(
                          flex: 2, child: SizedBox()), // DATE + N°DEVIS
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL HT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vantotalHT.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX TOTAL TTC",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vantotalTTC.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX RÉGLÉ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vanregler.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white60,
                            borderRadius: BorderRadius.circular(
                                8), // <-- Bordure arrondie
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 1,
                                  blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "TOTAUX SOLDE",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formater(vansolde.toString()),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                          flex: 2, child: SizedBox()), // REF + CRÉÉ PAR
                    ],
                  ),
                ),
              ],
            )),
      ],
    );
  }
}

class ReleverDataSource extends DataTableSource {
  final List<Valider> data;
  final Set<int> _selectedRows = {}; // indices sélectionnés

  ReleverDataSource(this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];
    final isSelected = _selectedRows.contains(index);

    Color? bgColor;
    if (item.type == 3) {
      bgColor = Colors.green.withOpacity(0.2);
    } else if (item.type == 1) {
      bgColor = Colors.blue.withOpacity(0.05);
    }

    return DataRow.byIndex(
      index: index,
      selected: isSelected,
      onSelectChanged: (selected) {
        if (selected == null) return;
        if (selected) {
          _selectedRows.add(index);
        } else {
          _selectedRows.remove(index);
        }
        notifyListeners(); // 🔑 important pour mettre à jour la table
      },
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) => bgColor,
      ),
      cells: [
        DataCell(Text(
          DateFormat('dd/MM/yyyy').format(DateTime.parse(item.date.toString())),
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        )),
        DataCell(Text(
          item.operation.toString(),
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        )),
        DataCell(Align(
          alignment: Alignment.centerRight,
          child: Text(
            formater(item.debit.toString()),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        )),
        DataCell(Align(
          alignment: Alignment.centerRight,
          child: Text(
            formater(item.credit.toString()),
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        )),
        DataCell(Text("${item.dobyuser["nom"]}")),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => _selectedRows.length;

  // 🔥 méthode pour récupérer les lignes sélectionnées
  List<Valider> getSelectedRows() {
    return _selectedRows.map((i) => data[i]).toList();
  }
}
class AccordionRelever extends StatefulWidget {
  List<Valider> listValiders = [];
  AccordionRelever({super.key, required this.listValiders});

  @override
  State<AccordionRelever> createState() => AccordionReleverState();
}
class AccordionReleverState extends State<AccordionRelever> {
  late TextEditingController searchController;
  late ReleverDataSource releveSource;
  List<Valider> validers = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    validers = widget.listValiders.where((r) => r.type == 1 || r.type == 3).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scroll = ScrollController();

    // ✅ Filtrage de la liste


    // ✅ Nombre d’éléments
    int count = validers.length;

    // ✅ Sommes sorties / entrées
    double totalSorties = validers.fold(0.0, (sum, e) => sum + (double.tryParse(e.debit.toString()) ?? 0.0)); // si null ou invalide → 0
    double totalEntrees = validers.fold(0.0, (sum, e) => sum + (double.tryParse(e.credit.toString()) ?? 0.0));

    return ExpansionTile(
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      backgroundColor: const Color(0xff4e73df),
      collapsedBackgroundColor: const Color(0xff4e73df),
      title: Container(
        color: const Color(0xff4e73df),
        child: const Text("1- Relevé du chantier",
            style: TextStyle(color: Colors.white)),
      ),
      children: [
        Container(
          color: Colors.white,
          margin: const EdgeInsets.fromLTRB(1, 0, 1, 1),
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Column(
            children: [
              SizedBox(
                height: 500,
                child: Scrollbar(
                  controller: scroll,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: scroll,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1300,
                      child: PaginatedDataTable2(
                        header: Row(
                          children: [
                            Text(
                              " [ $count éléments ]",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 250,
                              height: 42,
                              child: TextField(
                                controller: searchController,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'Recherche...',
                                  prefixIcon: const Icon(Icons.search),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 12),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        headingRowColor:
                            WidgetStateProperty.all(Colors.blue[100]),
                        columns: const [
                          DataColumn2(
                              fixedWidth: 90,
                              label: Text("Date",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn2(
                              fixedWidth: 500,
                              label: Text("OPÉRATIONS",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn2(
                              fixedWidth: 150,
                              label: Text("SORTIES",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn2(
                              fixedWidth: 150,
                              label: Text("ENTRÉES",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn2(
                              label: Text("VALIDÉ PAR",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        source: ReleverDataSource(validers),
                        dataRowHeight: 38,
                        headingRowHeight: 40,
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        rowsPerPage: 25,
                        border: TableBorder.all(color: Colors.grey.shade300),
                        showFirstLastButtons: true,
                        showCheckboxColumn: true,
                      ),
                    ),
                  ),
                ),
              ),

              // ✅ Section Totaux
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Expanded(flex: 2, child: SizedBox()),
                    Expanded(
                      flex: 6,
                      child: _buildTotalBox("TOTAUX SORTIES", totalSorties),
                    ),
                    Expanded(
                      flex: 6,
                      child: _buildTotalBox("TOTAUX ENTRÉES", totalEntrees),
                    ),
                    const Expanded(flex: 2, child: SizedBox()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBox(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 2),
        ],
      ),
      child: Column(
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              formater(value.toString()), // ✅ format 2 décimales
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoRow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Color(0xff4e73df)),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff4e73df),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}


