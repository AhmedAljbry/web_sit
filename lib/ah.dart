import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:cloud_firestore/cloud_firestore.dart';

class GenerateIdsScreen extends StatefulWidget {
  @override
  _GenerateIdsScreenState createState() => _GenerateIdsScreenState();
}

class _GenerateIdsScreenState extends State<GenerateIdsScreen> {
  var uuid = Uuid();
  bool isLoading = false;
  double progress = 0.0;
  bool isCancelled = false;
  TextEditingController countController = TextEditingController();

  // دالة لتوليد المعرفات
  List<String> generateIds(int count) {
    List<String> ids = [];
    for (int i = 0; i < count; i++) {
      String id = uuid.v4().replaceAll('-', '').substring(0, 12);
      ids.add(id);
    }
    return ids;
  }

  // دالة لحفظ المعرفات في Excel باستخدام syncfusion_flutter_xlsio
  Future<void> saveToExcel(List<String> ids) async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // إضافة العناوين في الصف الأول
    sheet.getRangeByName('A1').setText('ID');
    sheet.getRangeByName('B1').setText('Timestamp');

    // إضافة المعرفات والوقت
    for (int i = 0; i < ids.length; i++) {
      sheet.getRangeByIndex(i + 1, 1).setText(ids[i]);
      sheet.getRangeByIndex(i + 1, 2).setText(DateTime.now().toString());
    }

    // حفظ الملف في التخزين المحلي
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تعذر الوصول إلى مجلد التخزين")));
      return;
    }

    String filePath = '${directory.path}/generated_ids.xlsx';
    final List<int> bytes = workbook.saveAsStream();
    final File file = File(filePath);
    await file.writeAsBytes(bytes);
    workbook.dispose();

    // إظهار رسالة للمستخدم بعد الحفظ
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم حفظ ملف Excel بنجاح")));
  }

  // دالة لحفظ المعرفات في Firestore
  Future<void> saveToFirestore(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }

    CollectionReference idsCollection = FirebaseFirestore.instance.collection('ids');

    // رفع المعرفات إلى Firestore
    for (int i = 0; i < ids.length; i++) {
      String id = ids[i];
      await idsCollection.doc(id).set({
        'id': id,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // تحديث التقدم
      setState(() {
        progress = (i + 1) / ids.length;
      });
    }
  }

  // طلب إذن التخزين
  Future<bool> requestPermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  // دالة لمعالجة العملية
  Future<void> handleGenerateAndSave() async {
    int count = int.tryParse(countController.text) ?? 0;
    if (count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("يرجى إدخال رقم صحيح")));
      return;
    }

    bool hasPermission = await requestPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("إذن الوصول للتخزين مرفوض")));
      return;
    }

    setState(() {
      isLoading = true;
      isCancelled = false;
      progress = 0.0;
    });

    List<String> ids = generateIds(count);

    // حفظ المعرفات في Firestore
    await saveToFirestore(ids);

    // حفظ المعرفات في ملف Excel
    await saveToExcel(ids);

    setState(() {
      isLoading = false;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("تم الحفظ بنجاح"),
          content: Text("تم حفظ $count معرف في Firestore و Excel بنجاح."),
          actions: <Widget>[
            TextButton(
              child: Text("موافق"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("توليد معرفات وحفظها في Firestore و Excel")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "أدخل عدد المعرفات",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? Column(
              children: [
                Text("جاري الرفع إلى Firestore و Excel..."),
                SizedBox(height: 10),
                LinearProgressIndicator(value: progress),
                SizedBox(height: 10),
                Text("${(progress * 100).toStringAsFixed(1)}%"),
                SizedBox(height: 20),
              ],
            )
                : ElevatedButton(
              onPressed: handleGenerateAndSave,
              child: Text("توليد وحفظ المعرفات"),
            ),
          ],
        ),
      ),
    );
  }
}
