import 'package:flutter/material.dart';
import 'package:coba/edit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController namaController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  late dynamic db = null;
  List<Map<String, Object?>> barang = [];

  @override
  void initState() {
    super.initState();
    setupDatabase();
  }

  void setupDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'barang_db.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE barang(id INTEGER PRIMARY KEY, Nama_Barang TEXT, Jumlah_Barang TEXT, Harga_Barang TEXT)',
        );
      },
      version: 1,
    );
    db = await database;

    retrieve();
  }

  void save() async {
    if (namaController.text.isEmpty ||
        jumlahController.text.isEmpty ||
        hargaController.text.isEmpty) {
    
        final snackBar = SnackBar(
        content: Text('Nama Barang, Jumlah Barang, Atau Harga Barang Tidak Boleh Kosong!'),
        );
        ScaffoldMessenger.of(this.context).showSnackBar(snackBar);
        return;
    }

    await db.insert(
      'barang',
      {
        "Nama_Barang": namaController.text,
        "Jumlah_Barang": jumlahController.text,
        "Harga_Barang": hargaController.text,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    namaController.clear();
    jumlahController.clear();
    hargaController.clear();
    retrieve();
  }

  void retrieve() async {
    final List<Map<String, Object?>> barang = await db.query('barang');
    setState(() {
      this.barang = barang;
    });
  }

void deleteRow(id) async {
  showDialog(
    context: this.context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Konfirmasi"),
        content: Text("Apakah Anda yakin ingin menghapus barang ini?"),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await db.delete(
                'barang',
                where: 'id = ?',
                whereArgs: [id],
              );
              retrieve();
              Navigator.of(context).pop(); 
            },
            child: Text("Ya"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            child: Text("Tidak"),
          ),
        ],
      );
    },
  );
}

  void editRow(int id) {
    Navigator.push(
      this.context,
      MaterialPageRoute(builder: (context) => EditPage(id: id)),
    
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Input Data Barang"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
              this.context,
              MaterialPageRoute(builder: (context) => Home()),
              );
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: "Nama Barang",
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Jumlah Barang",
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Harga Barang",
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: save,
              child: Text("Simpan Data Barang"),
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Nama Barang')),
                      DataColumn(label: Text('Jumlah Barang')),
                      DataColumn(label: Text('Harga Barang')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: barang.map((e) {
                      return DataRow(
                        cells: [
                          DataCell(Text(e['Nama_Barang'].toString())),
                          DataCell(Text(e['Jumlah_Barang'].toString())),
                          DataCell(Text(e['Harga_Barang'].toString())),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    editRow(e['id'] as int);
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    deleteRow(e['id'] as int);
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}