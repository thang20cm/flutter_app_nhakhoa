import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/':(context) => DangNhap(),
      '/dangky':(context)=>DangKy(),
      '/home': (context) {
      final userId = ModalRoute.of(context)?.settings.arguments as String?;
      return HomeUser(userId: userId ?? ''); // Truyền userId vào trang HomeUser
    },
       '/doanh thu công việc': (context) => doanhthucongviec(userId: ModalRoute.of(context)!.settings.arguments as String),
  '/máy móc': (context) => maymoc(userId: ModalRoute.of(context)!.settings.arguments as String),
  '/dụng cụ': (context) => dungcu(userId: ModalRoute.of(context)!.settings.arguments as String),
  '/vật liệu': (context) => vatlieu(userId: ModalRoute.of(context)!.settings.arguments as String),
      '/themmaymoc': (context) => themmaymoc(idPhieumaymoc: ModalRoute.of(context)!.settings.arguments as String), // Đăng ký giao diện menu 4
    },
  ));
}

class doanhthucongviec extends StatefulWidget {
  final String userId;

  doanhthucongviec({required this.userId});
  @override
  _DoanhThuScreenState createState() => _DoanhThuScreenState();

}

class _DoanhThuScreenState extends State<doanhthucongviec> {

  TextEditingController ngaynhapphieu = TextEditingController();
  

  List<String> danhSachSudungMayMoc = [];

  @override
  void initState(){
    super.initState();
    setNgayNhapPhieu();
    getphieudoanhthu();
  }
  void setNgayNhapPhieu(){
     DateTime now = DateTime.now();

    // Gán giá trị ngày tháng năm vào trường ngaynhapphieu
    ngaynhapphieu.text = "${now.day}/${now.month}/${now.year}";
    
  }

 Future<void> themphieudoanhthu() async {
    if(ngaynhapphieu.text!=""){
      try{

        String uri = "http://buffquat13.000webhostapp.com/themphieudoanhthu.php";

        var res=await http.post(Uri.parse(uri),body: {
          "ngaynhapphieu":ngaynhapphieu.text,
          "uid":widget.userId,
         
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
    getphieudoanhthu();
    
  }

  Future<void> getphieudoanhthu() async {
    try {
      String uri = "http://buffquat13.000webhostapp.com/get_phieudoanhthu.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
         List<String> danhSachMayMoc = data
          .where((item) => item['uid'] == widget.userId) // Lọc theo uid
          .map((item) => "${item['ngayNhapPhieu']} - ${item['idPhieudoanhthu']}")
          .toList();
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
        title: Text('Danh sách phiếu doanh thu'),
      ),
      body: ListView.builder(
  itemCount: danhSachSudungMayMoc.length,
  itemBuilder: (context, index) {
    return InkWell(
      onTap: () async {
       
        // Chuyển hướng tới trang chitietphieumaymoc khi nhấn vào phần tử trong RecyclerView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:(context) =>
            chitietphieudoanhthu(ngayPhieu: danhSachSudungMayMoc[index],idPhieumaymoc:danhSachSudungMayMoc[index].split(' - ')[1],
           ),
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
          themphieudoanhthu();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// Chua xong......
class DoanhThuData {
  String tenMayMoc;
  String tinhTrang;
  String ngayNhapPhieu;
 String idChitietPhieumaymoc;

  DoanhThuData({
    required this.tenMayMoc,
    required this.tinhTrang,
    required this.ngayNhapPhieu,
    required this.idChitietPhieumaymoc,
  });
}

class chitietphieudoanhthu extends StatefulWidget {
  final String ngayPhieu;
  final String idPhieumaymoc;


  chitietphieudoanhthu({required this.ngayPhieu,required this.idPhieumaymoc});

  @override
  _chitietphieudoanhthuState createState() => _chitietphieudoanhthuState();
}

class _chitietphieudoanhthuState extends State<chitietphieudoanhthu> {
  List<DoanhThuData> danhSachDoanhThu = [];

  @override
  void initState() {
    super.initState();
    fetchDataSudungDoanhThu();
  }

  Future<void> fetchDataSudungDoanhThu() async {
    try {
      String uri = "http://buffquat13.000webhostapp.com/get_phieudoanhthu.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<DoanhThuData> doanhThuList = data.map((item) => DoanhThuData(
              tenMayMoc: item['tenMayMoc'],
              tinhTrang: item['tinhtrangCuoiNgay'],
              ngayNhapPhieu: item['ngayNhapPhieu'],
              idChitietPhieumaymoc: item['idPhieumaymoc'],
            )).toList();

        setState(() {
          danhSachDoanhThu = doanhThuList.where((doanhThu) => doanhThu.idChitietPhieumaymoc == widget.idPhieumaymoc).toList();
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
          'Phiếu doanh thu: ${widget.ngayPhieu}',
          style: TextStyle(fontSize: 19),
        ),
      ),
      body: ListView.builder(
        itemCount: danhSachDoanhThu.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(danhSachDoanhThu[index].tenMayMoc),
            subtitle: Text(danhSachDoanhThu[index].ngayNhapPhieu),
            // Hiển thị thông tin máy móc (thay bằng thông tin thực tế của bạn)
          );
        },
      ),
     floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => themmaymoc(
          idPhieumaymoc: widget.idPhieumaymoc,
        ),
      ),
    );
  },
  child: Icon(Icons.add),
),

    );
  }
}



////////////////////////////////////////////////////////// Start Phieu may moc
class maymoc extends StatefulWidget {
  final String userId;

  maymoc({required this.userId});
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

        String uri = "http://buffquat13.000webhostapp.com/themphieumaymoc.php";

        var res=await http.post(Uri.parse(uri),body: {
          "ngaynhapphieu":ngaynhapphieu.text,
          "uid":widget.userId,
         
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
      String uri = "http://buffquat13.000webhostapp.com/get_phieumaymoc.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
         List<String> danhSachMayMoc = data
          .where((item) => item['uid'] == widget.userId) // Lọc theo uid
          .map((item) => "${item['ngayNhapPhieu']} - ${item['idPhieumaymoc']}")
          .toList();
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
        title: Text('Danh sách phiếu máy móc'),
      ),
      body: ListView.builder(
  itemCount: danhSachSudungMayMoc.length,
  itemBuilder: (context, index) {
    return InkWell(
      onTap: () async {
       
        // Chuyển hướng tới trang chitietphieumaymoc khi nhấn vào phần tử trong RecyclerView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:(context) =>
            chitietphieumaymoc(ngayPhieu: danhSachSudungMayMoc[index],idPhieumaymoc:danhSachSudungMayMoc[index].split(' - ')[1],
           ),
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
 String idChitietPhieumaymoc;

  MayMocData({
    required this.tenMayMoc,
    required this.tinhTrang,
    required this.ngayNhapPhieu,
    required this.idChitietPhieumaymoc,
  });
}

class chitietphieumaymoc extends StatefulWidget {
  final String ngayPhieu;
  final String idPhieumaymoc;


  chitietphieumaymoc({required this.ngayPhieu,required this.idPhieumaymoc});

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
      String uri = "http://buffquat13.000webhostapp.com/get_maymoc.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<MayMocData> mayMocList = data.map((item) => MayMocData(
              tenMayMoc: item['tenMayMoc'],
              tinhTrang: item['tinhtrangCuoiNgay'],
              ngayNhapPhieu: item['ngayNhapPhieu'],
              idChitietPhieumaymoc: item['idPhieumaymoc'],
            )).toList();

        setState(() {
          danhSachMayMoc = mayMocList.where((mayMoc) => mayMoc.idChitietPhieumaymoc == widget.idPhieumaymoc).toList();
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
            subtitle: Text(danhSachMayMoc[index].ngayNhapPhieu),
            // Hiển thị thông tin máy móc (thay bằng thông tin thực tế của bạn)
          );
        },
      ),
     floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => themmaymoc(
          idPhieumaymoc: widget.idPhieumaymoc,
        ),
      ),
    );
  },
  child: Icon(Icons.add),
),

    );
  }
}






class themmaymoc extends StatefulWidget {
 
 final String idPhieumaymoc;
  themmaymoc({required this.idPhieumaymoc});
  
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
    thoigiannhapphieu.text = "${now.hour}:${now.minute}";
  }
  Future<void> insertrecordmaymoc(String idPhieumaymoc) async {
    if(tenmaymoc.text!="" || tinhtrang.text!= "" || tondaungay.text!=""||khachhangmaso.text!="" || soluongsudung.text!= "" || conlaicuoingay.text!=""||tinhtrangcuoingay.text!=""||thoigiannhapphieu.text!=""){
      try{

        String uri = "http://buffquat13.000webhostapp.com/maymoc.php";

        var res=await http.post(Uri.parse(uri),body: {
          "tenmaymoc":tenmaymoc.text,
          "tinhtrang":tinhtrang.text,
          "tondaungay":tondaungay.text,
          "khachhangmaso":khachhangmaso.text,
          "soluongsudung":soluongsudung.text,
          "conlaicuoingay":conlaicuoingay.text,
          "tinhtrangcuoingay":tinhtrangcuoingay.text,
          "ngaynhapphieu": thoigiannhapphieu.text,
          "idPhieumaymoc": idPhieumaymoc,
          
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
         title: Text(
          'Them máy móc: ${widget.idPhieumaymoc}',
          style: TextStyle(fontSize: 19),
        ),
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
                insertrecordmaymoc(widget.idPhieumaymoc);
              },
              child: Text("Thêm"),
            ),

          ],
       ),
      ),
    );
  }
}
////////////////////////////////////////////////////////// End Phieu may moc
class dungcu extends StatelessWidget {
  final String userId;
  dungcu({required this.userId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dung cu' +userId),
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
  final String userId;

  vatlieu({required this.userId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vat lieu'+userId),
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

        String uri = "http://buffquat13.000webhostapp.com/insert_record.php";

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
        String uri = "http://buffquat13.000webhostapp.com/login.php";

        var res = await http.post(Uri.parse(uri), body: {
          "email": email.text,
          "password": password.text,
        });

        var response = jsonDecode(res.body);
 
        if (response["Success"] == true) { // Thay đổi kiểu dữ liệu ở đây
          print("Đăng nhập thành công!");
          String userId = response['uid'];
          print('id user la: '+userId);
          Navigator.pushReplacementNamed(context, '/home',arguments: userId,); 
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


class HomeUser extends StatefulWidget {
  final String userId;

  HomeUser({required this.userId});

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  final List<String> menuItems = ['Doanh thu công việc', 'Máy móc', 'Dụng cụ', 'Vật liệu'];

  bool isWorking = false;
  bool isEndButtonDisabled = true;
  late String Batdaulamviec;  // Trạng thái làm việc

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang chủ'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Hiển thị 2 cột
          crossAxisSpacing: 10.0, // Khoảng cách giữa các cột
          mainAxisSpacing: 10.0, // Khoảng cách giữa các dòng
        ),
        itemCount: menuItems.length + 2, // Thêm 2 nút
        itemBuilder: (context, index) {
          if (index == menuItems.length) {
            return ElevatedButton(
              onPressed: isWorking ? null : () => startWorkTime(),
              child: Text("Bắt đầu làm việc"),
            );
          } else if (index == menuItems.length + 1) {
            return ElevatedButton(
              onPressed: isEndButtonDisabled ? null : () => showEndConfirmation(),
              child: Text("Kết thúc làm việc"),
            );
          } else {
            return GestureDetector(
              onTap: () {
                _navigateToMenuScreen(context, index);
              },
              child: Container(
                color: Colors.blueGrey,
                child: Center(
                  child: Text(
                    menuItems[index],
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> startWorkTime() async {
    try {
      DateTime now = DateTime.now();
      Batdaulamviec = "${now.hour}:${now.minute}";

      setState(() {
        isWorking = true;
        isEndButtonDisabled = false;
      });

      print("Bắt đầu làm việc: $Batdaulamviec");
    } catch (e) {
      print(e);
    }
  }

  Future<void> endWorkTime() async {
    try {
      DateTime now = DateTime.now();
      String KetThuclamviec = "${now.hour}:${now.minute}";
      String Ngaylamviec = "${now.day}/${now.month}/${now.year}";

      setState(() {
        isWorking = false;
        isEndButtonDisabled = true;
      });

      String uri = "http://buffquat13.000webhostapp.com/themngaylamviec.php";
      var res = await http.post(Uri.parse(uri), body: {
        "ngaylamviec": Ngaylamviec,
        "thoigianbatdau": Batdaulamviec,
        "thoigianketthuc": KetThuclamviec,
        "uid": widget.userId,
      });

      var response = jsonDecode(res.body);
      if (response["Success"] == "true") {
        print("Thêm thời gian kết thúc làm việc thành công!");
      } else {
        print("Lỗi khi thêm thời gian kết thúc làm việc!");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> showEndConfirmation() async {
    bool shouldEndWork = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận kết thúc làm việc'),
          content: Text('Bạn có chắc muốn kết thúc làm việc?'),
          actions: <Widget>[
            TextButton(
              child: Text('Không'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Có'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldEndWork) {
      endWorkTime();
    }
  }

  void _navigateToMenuScreen(BuildContext context, int index) {
    String menuName = menuItems[index];
    Navigator.pushNamed(context, '/${menuName.toLowerCase()}', arguments: widget.userId);
  }
}
