import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/':(context) => DangNhap(),
      '/dangky':(context)=>DangKy(),
      '/home':(context)=>HomeUser(),
      '/doanhthucongviec': (context) => doanhthucongviec(), // Đăng ký giao diện menu 1
      '/maymoc': (context) => maymoc(), // Đăng ký giao diện menu 2
      '/dungcu': (context) => dungcu(), // Đăng ký giao diện menu 3
      '/vatlieu': (context) => vatlieu(),
      '/themmaymoc': (context) => themmaymoc(), // Đăng ký giao diện menu 4
    },
  ));
}

class doanhthucongviec extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doanh thu cong viec'),
      ),
      body: Center(
        child: Text(
          'Chào mừng bạn đến doanh thu cong viec!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}



//May moc
class maymoc extends StatefulWidget {
  @override
  _MayMocScreenState createState() => _MayMocScreenState();

}

class _MayMocScreenState extends State<maymoc> {

  TextEditingController ngaynhapphieu = TextEditingController();

  List<String> danhSachSudungMayMoc = [];

  @override
  void initState(){
    super.initState();
    setNgayNhapPhieu();
    getphieumaymoc();
  }
  void setNgayNhapPhieu(){
     DateTime now = DateTime.now();

    // Gán giá trị ngày tháng năm vào trường ngaynhapphieu
    ngaynhapphieu.text = "${now.day}/${now.month}/${now.year}";
  }

 Future<void> themphieumaymoc() async {
    if(ngaynhapphieu.text!=""){
      try{

        String uri = "http://10.0.2.2/ApiFlutter/themphieumaymoc.php";

        var res=await http.post(Uri.parse(uri),body: {
          "ngaynhapphieu":ngaynhapphieu.text,
        });
        var response = jsonDecode(res.body);
        if(response["Success"]=="true"){
          print("Them phieu may moc thanh cong!");
          ngaynhapphieu.text="";
        }
        else{
          print("Error!");
        }
      }
      catch(e){
        print(e);
      }

    }
    else{
      print("Lam on dien vao o trong");
    }
    getphieumaymoc();
  }

  Future<void> getphieumaymoc() async {
    try {
      String uri = "http://10.0.2.2/ApiFlutter/get_phieumaymoc.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<String> danhSachMayMoc = data.map((item) => "${item['ngayNhapPhieu']}").toList();
        


        setState(() {
          this.danhSachSudungMayMoc = danhSachMayMoc;
        });
      } else {
        print("Lỗi khi lấy dữ liệu từ bảng phieumaymoc: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu từ bảng phieumaymoc: $e");
    }
  }

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Máy móc'),
      ),
      body: ListView.builder(
  itemCount: danhSachSudungMayMoc.length,
  itemBuilder: (context, index) {
    return InkWell(
      onTap: () {
        // Chuyển hướng tới trang chitietphieumaymoc khi nhấn vào phần tử trong RecyclerView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:(context) =>
            chitietphieumaymoc(ngayPhieu: danhSachSudungMayMoc[index]),
          ),
        );
      },
      child: ListTile(
        title: Text(danhSachSudungMayMoc[index]), // Hiển thị thông tin máy móc (thay bằng thông tin thực tế của bạn)
      ),
    );
  },
),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          themphieumaymoc();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


class MayMocData {
  String tenMayMoc;
  String tinhTrang;
  String ngayNhapPhieu;

  MayMocData({
    required this.tenMayMoc,
    required this.tinhTrang,
    required this.ngayNhapPhieu,
  });
}

class chitietphieumaymoc extends StatefulWidget {
  final String ngayPhieu;

  chitietphieumaymoc({required this.ngayPhieu});

  @override
  _chitietphieumaymocState createState() => _chitietphieumaymocState();
}

class _chitietphieumaymocState extends State<chitietphieumaymoc> {
  List<MayMocData> danhSachMayMoc = [];

  @override
  void initState() {
    super.initState();
    fetchDataSudungMayMoc();
  }

  Future<void> fetchDataSudungMayMoc() async {
    try {
      String uri = "http://10.0.2.2/ApiFlutter/get_maymoc.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<MayMocData> mayMocList = data.map((item) => MayMocData(
              tenMayMoc: item['tenMayMoc'],
              tinhTrang: item['tinhtrangCuoiNgay'],
              ngayNhapPhieu: item['ngayNhapPhieu'],
            )).toList();

        setState(() {
          danhSachMayMoc = mayMocList;
        });
      } else {
        print("Lỗi khi lấy dữ liệu từ bảng sudungmaymoc: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu từ bảng sudungmaymoc: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Phiếu máy móc: ${widget.ngayPhieu}',
          style: TextStyle(fontSize: 19),
        ),
      ),
      body: ListView.builder(
        itemCount: danhSachMayMoc.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(danhSachMayMoc[index].tenMayMoc),
            subtitle: Text(danhSachMayMoc[index].tinhTrang),
            // Hiển thị thông tin máy móc (thay bằng thông tin thực tế của bạn)
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/themmaymoc');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}






class themmaymoc extends StatefulWidget {
  @override
  _ThemMayMocScreenState createState() => _ThemMayMocScreenState();
}


class _ThemMayMocScreenState extends State<themmaymoc>{

  TextEditingController tenmaymoc = TextEditingController();
  TextEditingController tinhtrang = TextEditingController();
  TextEditingController tondaungay = TextEditingController();
    TextEditingController khachhangmaso = TextEditingController();
  TextEditingController soluongsudung = TextEditingController();
  TextEditingController conlaicuoingay = TextEditingController();
   TextEditingController tinhtrangcuoingay = TextEditingController();
   TextEditingController thoigiannhapphieu = TextEditingController();

 @override
  void initState(){
    super.initState();
    setNgayNhapPhieu();
  }
  void setNgayNhapPhieu(){
     DateTime now = DateTime.now();

    // Gán giá trị ngày tháng năm vào trường ngaynhapphieu
    thoigiannhapphieu.text = "${now.day}/${now.month}/${now.year}";
  }
  Future<void> insertrecordmaymoc() async {
    if(tenmaymoc.text!="" || tinhtrang.text!= "" || tondaungay.text!=""||khachhangmaso.text!="" || soluongsudung.text!= "" || conlaicuoingay.text!=""||tinhtrangcuoingay.text!=""||thoigiannhapphieu.text!=""){
      try{

        String uri = "http://10.0.2.2/ApiFlutter/maymoc.php";

        var res=await http.post(Uri.parse(uri),body: {
          "tenmaymoc":tenmaymoc.text,
          "tinhtrang":tinhtrang.text,
          "tondaungay":tondaungay.text,
          "khachhangmaso":khachhangmaso.text,
          "soluongsudung":soluongsudung.text,
          "conlaicuoingay":conlaicuoingay.text,
          "tinhtrangcuoingay":tinhtrangcuoingay.text,
          "ngaynhapphieu": thoigiannhapphieu.text
        });
        var response = jsonDecode(res.body);
        if(response["Success"]=="true"){
          print("Them may moc thanh cong!");
          tenmaymoc.text="";
          tinhtrang.text="";
          tondaungay.text="";
          khachhangmaso.text="";
          soluongsudung.text="";
          conlaicuoingay.text="";
          tinhtrangcuoingay.text="";
        }
        else{
          print("Error!");
        }
      }
      catch(e){
        print(e);
      }

    }
    else{
      print("Lam on dien vao o trong");
    }
  }

 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm máy móc'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: tenmaymoc,
              decoration: InputDecoration(labelText: 'Ten may moc'),
            ),
            TextFormField(
              controller: tinhtrang,
              decoration: InputDecoration(labelText: 'tinh trang dau ngay'),
            ),
            TextFormField(
              controller: tondaungay,
              decoration: InputDecoration(labelText: 'Ton dau ngay'),
            ),
             TextFormField(
              controller: khachhangmaso,
              decoration: InputDecoration(labelText: 'Khach hang ma so'),
            ),
            TextFormField(
              controller: soluongsudung,
              decoration: InputDecoration(labelText: 'So luong su dung'),
            ),
            TextFormField(
              controller: conlaicuoingay,
              decoration: InputDecoration(labelText: 'Con lai cuoi ngay'),
            ),
             TextFormField(
              controller: tinhtrangcuoingay,
              decoration: InputDecoration(labelText: 'Tình trạng cuoi ngay'),
            ),
            // TextFormField(
            //   controller: ngaynhapphieu,
            //   decoration: InputDecoration(labelText: 'Ngay nhap phieu'),
            //   enabled: false,
            // ),
            ElevatedButton(
              onPressed: () {
                insertrecordmaymoc();
              },
              child: Text("Thêm"),
            ),
          ],
       ),
      ),
    );
  }
}
class dungcu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dung cu'),
      ),
      body: Center(
        child: Text(
          'Chào mừng bạn đến Dung cu!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class vatlieu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vat lieu'),
      ),
      body: Center(
        child: Text(
          'Chào mừng bạn đến Vat lieu!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});



//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

class DangKy extends StatelessWidget{

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> insertrecord() async {
    if(name.text!="" || email.text!= "" || password.text!=""){
      try{

        String uri = "http://10.0.2.2/ApiFlutter/insert_record.php";

        var res=await http.post(Uri.parse(uri),body: {
          "name":name.text,
          "email":email.text,
          "password":password.text
        });
        var response = jsonDecode(res.body);
        if(response["Success"]=="true"){
          print("Them thanh cong!");
          name.text="";
          email.text="";
          password.text="";
        }
        else{
          print("Error!");
        }
      }
      catch(e){
        print(e);
      }

    }
    else{
      print("Lam on dien vao o trong");
    }
  }

  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
        title: Text('Create Account'),
      ),
     body:Column(children: [
         Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        controller: name,
          decoration: InputDecoration(
            border: OutlineInputBorder(), label: Text('Nhập tên')),
        ),
      
        
      ),
      Container(
        
      margin: EdgeInsets.all(10),
      child: TextFormField(
        controller: email,
          decoration: InputDecoration(
            border: OutlineInputBorder(), label: Text('Nhập email')),
        ),
        
      ),
         Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        controller: password,
          decoration: InputDecoration(
            border: OutlineInputBorder(), label: Text('Nhập mật khẩu')),
        ),
        
      ),
      Container(
        margin: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: (){
            insertrecord();
          },
          child: Text("Save"),
        ),
      ),
         Container(
            margin: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              child: Text('Đăng nhập'),
            ),
          ),
      ]),
      ),
    );
  }
}



class DangNhap extends StatelessWidget {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> login(BuildContext context) async {
    if (email.text.isNotEmpty && password.text.isNotEmpty) { // Thay đổi điều kiện ở đây
      try {
        String uri = "http://10.0.2.2/ApiFlutter/login.php";

        var res = await http.post(Uri.parse(uri), body: {
          "email": email.text,
          "password": password.text,
        });

        var response = jsonDecode(res.body);
        if (response["Success"] == true) { // Thay đổi kiểu dữ liệu ở đây
          print("Đăng nhập thành công!");
          Navigator.pushReplacementNamed(context, '/home'); 
          // Chuyển sang trang chính của ứng dụng nếu đăng nhập thành công
        } else {
          print("Đăng nhập thất bại!");
        }
      } catch (e) {
        print("Lỗi: $e"); // In ra thông báo lỗi chi tiết
      }
    } else {
      print("Làm ơn điền vào ô trống");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            child: TextFormField(
              controller: email,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nhập email',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: TextFormField(
              controller: password,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nhập mật khẩu',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                login(context);
              },
              child: Text("Đăng nhập"),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/dangky');
              },
              child: Text('Dang ky'),
            ),
          ),
        ],
      ),
    );
  }
}

//Trang Home


class HomeUser extends StatelessWidget {
  final List<String> menuItems = ['doanhthucongviec', 'maymoc', 'dungcu', 'vatlieu']; // Tên các menu

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Hiển thị 2 cột
        crossAxisSpacing: 10.0, // Khoảng cách giữa các cột
        mainAxisSpacing: 10.0, // Khoảng cách giữa các dòng
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            // Xử lý sự kiện khi nhấp vào menu
            _navigateToMenuScreen(context, index);
          },
          child: Container(
            color: Colors.blueGrey, // Màu nền menu
            child: Center(
              child: Text(
                menuItems[index], // Hiển thị tên menu
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
  void _navigateToMenuScreen(BuildContext context, int index) {
    // Hàm chuyển hướng khi nhấp vào menu
    String menuName = menuItems[index];
    Navigator.pushNamed(context, '/${menuName.toLowerCase()}');
  }
}
