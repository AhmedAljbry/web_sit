import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
class RechargeScreen extends StatefulWidget {
  @override
  _RechargeScreenState createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> with SingleTickerProviderStateMixin {
  TextEditingController _controller = TextEditingController();
  var formcontroller = GlobalKey<FormState>();
  String _message = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  void _checkAndUseCard(String number) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
      await FirebaseFirestore.instance.collection('ids').doc(number).get();

      if (doc.exists && doc.data() != null) {
        print("تم العثور على الكود: ${doc.data()}");

        DateTime usageDate = DateTime.now();

        setState(() {
          _message =
          "✅ المنتج أصلي، تاريخ الإدخال: ${doc.data()?['timestamp']}, تاريخ الاستخدام: $usageDate";
        });

        await FirebaseFirestore.instance.collection('used_codes').doc(number).set({
          'id': doc.data()?['id'],
          'timestamp': doc.data()?['timestamp'],
          'usage_date': usageDate.toString(),
        });

        await FirebaseFirestore.instance.collection('ids').doc(number).delete();
      } else {
        DocumentSnapshot<Map<String, dynamic>> usedDoc =
        await FirebaseFirestore.instance.collection('used_codes').doc(number).get();

        if (usedDoc.exists) {
          setState(() {
            _message = "❌ الكود قد تم استخدامه من قبل!";
          });
        } else {
          setState(() {
            _message = "❌ الكود غير موجود!";
          });
        }
      }
    } catch (e) {
      print("حدث خطأ أثناء جلب البيانات: $e");
      setState(() {
        _message = "❌ حدث خطأ أثناء البحث عن الكود!";
      });
    }
  }

  String? validateCard(String? value) {
    if (value == null || value.isEmpty) {
      return "يرجى إدخال الرقم";
    } else if (value.length != 12) {
      return "الرقم يجب أن يكون 12 خانة";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Card(
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: formcontroller,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: _fadeAnimation.value,
                              duration: Duration(seconds: 1),
                              child: Image.asset(
                                "image/image1.png",
                                height: screenHeight * 0.2,
                              ),
                            ),
                            SizedBox(height: 20),
                            ScaleTransition(
                              scale: _fadeAnimation,
                              child: Text(
                                "Sumifun",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                "وداعًا لألم المفاصل والتهابات العظام! الحل الأمثل لاستعادة حركتك بحرية.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "أدخل رقم الكود",
                                icon: Icon(Icons.vpn_key, color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: validateCard,
                            ),
                            SizedBox(height: 20),
                            AnimatedContainer(
                              duration: Duration(seconds: 1),
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (formcontroller.currentState?.validate() ?? false) {
                                    _checkAndUseCard(_controller.text.trim());
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.amber[50],
                                ),
                                child: Text("تحقق", style: TextStyle(fontSize: 18)),
                              ),
                            ),
                            SizedBox(height: 20),
                            AnimatedOpacity(
                              opacity: _fadeAnimation.value,
                              duration: Duration(seconds: 1),
                              child: Text(
                                _message,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _message.startsWith("✅") ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 1,
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: "https://i0.wp.com/souqwaffar.com/sa/2/wp-content/uploads/2025/01/b3467916-acba-4b3b-a520-5ef338aca673.jpg?w=1080&ssl=1",
                          height: screenHeight * 0.25,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.flutter_dash,
                              size: 50,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    flex: 1,
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: "https://img.joomcdn.net/6398913775252591ad05101d7decf9317d2f14b1_original.jpeg",
                          height: screenHeight * 0.25,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.flutter_dash,
                              size: 50,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    flex: 1,
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: "https://img.joomcdn.net/7137889a047e45783ed1eb7fd18a1fa17841635f_original.jpeg",
                          height: screenHeight * 0.25,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.flutter_dash,
                              size: 50,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  color: Colors.white,
                  width: screenWidth * 0.80,
                  height: screenHeight * 0.30,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: screenWidth * 0.30,
                        height: screenHeight * 0.50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x26000000),
                              blurRadius: 8,
                              offset: const Offset(4, 4),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(
                              "https://i0.wp.com/souqwaffar.com/sa/2/wp-content/uploads/2025/01/b3467916-acba-4b3b-a520-5ef338aca673.jpg?w=1080&ssl=1",
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "إشترِ الآن لأفضل العروض!",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "تسوق الآن واستفد من الخصومات الكبيرة على جميع المنتجات. شحن مجاني وخدمة عملاء على مدار الساعة.",
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
