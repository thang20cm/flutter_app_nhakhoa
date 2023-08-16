import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/':(context) => DangNhap(),
      '/home': (context) {
      final userId = ModalRoute.of(context)?.settings.arguments as String?;
      return HomeUser(userId: userId ?? ''); // Truyền userId vào trang HomeUser
    },
       '/doanh thu công việc': (context) => doanhthucongviec(userId: ModalRoute.of(context)!.settings.arguments as String),
  '/máy móc': (context) => maymoc(userId: ModalRoute.of(context)!.settings.arguments as String),
  '/dụng cụ': (context) => dungcu(userId: ModalRoute.of(context)!.settings.arguments as String),
  '/vật liệu': (context) => vatlieu(userId: ModalRoute.of(context)!.settings.arguments as String),
      '/themmaymoc': (context) => themmaymoc(idPhieumaymoc: ModalRoute.of(context)!.settings.arguments as String),
      '/themdoanhthu': (context) => themdoanhthu(idPhieudoanhthu: ModalRoute.of(context)!.settings.arguments as String),
      '/themdungcu': (context) => themdungcu(idPhieudungcu: ModalRoute.of(context)!.settings.arguments as String),
       '/themvatlieu': (context) => themvatlieu(idPhieuvatlieu: ModalRoute.of(context)!.settings.arguments as String),  // Đăng ký giao diện menu 4
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
  

  List<String> danhSachSudungDoanhThu = [];

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
         List<String> danhSachDoanhThu = data
          .where((item) => item['uid'] == widget.userId) // Lọc theo uid
          .map((item) => "${item['ngayNhapPhieu']} - ${item['idPhieudoanhthu']}")
          .toList();
        setState(() {
          this.danhSachSudungDoanhThu = danhSachDoanhThu;
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
  itemCount: danhSachSudungDoanhThu.length,
  itemBuilder: (context, index) {
    return InkWell(
      onTap: () async {
       
        // Chuyển hướng tới trang chitietphieumaymoc khi nhấn vào phần tử trong RecyclerView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:(context) =>
            chitietphieudoanhthu(ngayPhieu: danhSachSudungDoanhThu[index],idPhieudoanhthu:danhSachSudungDoanhThu[index].split(' - ')[1],
           ),
          ),
        );
      },
      child: ListTile(
        title: Text(danhSachSudungDoanhThu[index]), // Hiển thị thông tin máy móc (thay bằng thông tin thực tế của bạn)
      ),
    );
  },
),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          themphieudoanhthu();
           ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
        content: Text('Thêm thành công!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating, // Hiển thị phía trên
        backgroundColor: Colors.green, // Thay đổi màu nền
      ),
    );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// Chua xong......
class DoanhThuData {
  String Thoigiannhanviec;
  String Khachhangmaso;
  String Noidung;
 String Namesanpham;
 String Soluong;
 String idphieudoanhthuu;

  DoanhThuData({
    required this.Thoigiannhanviec,
    required this.Khachhangmaso,
    required this.Noidung,
    required this.Namesanpham,
    required this.Soluong,
    required this.idphieudoanhthuu,
  });
}

class chitietphieudoanhthu extends StatefulWidget {
  final String ngayPhieu;
  final String idPhieudoanhthu;


  chitietphieudoanhthu({required this.ngayPhieu,required this.idPhieudoanhthu});

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
      String uri = "http://buffquat13.000webhostapp.com/get_doanhthu.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<DoanhThuData> doanhThuList = data.map((item) => DoanhThuData(
              idphieudoanhthuu: item['idPhieudoanhthu'],
              Thoigiannhanviec: item['Thoigiannhanviec'],
              Khachhangmaso: item['KhachangMaso'],
              Noidung: item['Noidung'],
              Namesanpham: item['Tensanpham'],
              Soluong: item['Soluong'],
             
            )).toList();

        setState(() {
          danhSachDoanhThu = doanhThuList.where((doanhThu) => doanhThu.idphieudoanhthuu == widget.idPhieudoanhthu).toList();
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
          title: Text(danhSachDoanhThu[index].Thoigiannhanviec),
          subtitle: Text(danhSachDoanhThu[index].Namesanpham),
          // Hiển thị thông tin máy móc (thay bằng thông tin thực tế của bạn)
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        bool success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => themdoanhthu(
              idPhieudoanhthu: widget.idPhieudoanhthu,
            ),
          ),
        );
        if (success == true) {
          fetchDataSudungDoanhThu();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thêm thành công!'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating, // Hiển thị phía trên
              backgroundColor: Colors.green, // Thay đổi màu nền
            ),
          );
        }
      },
      child: Icon(Icons.add),
    ),
  );
}

}



class themdoanhthu extends StatefulWidget {
 
 final String idPhieudoanhthu;
  themdoanhthu({required this.idPhieudoanhthu});
  
  @override
  _ThemDoanhThuScreenState createState() => _ThemDoanhThuScreenState();
}


class _ThemDoanhThuScreenState extends State<themdoanhthu>{

        TextEditingController khachhangmaso = TextEditingController();
        TextEditingController noidung = TextEditingController();
        TextEditingController tensanpham = TextEditingController();
        TextEditingController soluong = TextEditingController();
        TextEditingController thoigiannhanviec = TextEditingController();
   

 @override
  void initState(){
    super.initState();
    setNgayNhapPhieu();
  }
  void setNgayNhapPhieu(){
     DateTime now = DateTime.now();
    // Gán giá trị ngày tháng năm vào trường ngaynhapphieu
    thoigiannhanviec.text = "${now.hour}:${now.minute}";
  }
  Future<void> insertrecorddoanhthu(String idPhieudoanhthu) async {
    if(khachhangmaso.text!="" || noidung.text!= "" || tensanpham.text!=""||soluong.text!=""){
      try{

        String uri = "http://buffquat13.000webhostapp.com/doanhthu.php";

        var res=await http.post(Uri.parse(uri),body: {
           "idPhieudoanhthu": idPhieudoanhthu,
          "thoigiannhanviec":thoigiannhanviec.text,
          "khachhangmaso":khachhangmaso.text,
          "noidung":noidung.text,
          "tensanpham":tensanpham.text,
          "soluong":soluong.text,
         
          
        });
        var response = jsonDecode(res.body);
        if(response["Success"]=="true"){
          print("Them doanh thu thanh cong!");
          khachhangmaso.text="";
          noidung.text="";
          tensanpham.text="";
          soluong.text="";

          Navigator.pop(context, true);
         
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
          'Thêm tiến trình doanh thu: ${widget.idPhieudoanhthu}',
          style: TextStyle(fontSize: 19),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: khachhangmaso,
              decoration: InputDecoration(labelText: 'Khách hàng - Mã số'),
            ),
            TextFormField(
              controller: noidung,
              decoration: InputDecoration(labelText: 'Nội dung'),
            ),
            TextFormField(
              controller: tensanpham,
              decoration: InputDecoration(labelText: 'Tên sản phẩm'),
            ),
             TextFormField(
              controller: soluong,
              decoration: InputDecoration(labelText: 'Số lượng'),
            ),
          
            // TextFormField(
            //   controller: ngaynhapphieu,
            //   decoration: InputDecoration(labelText: 'Ngay nhap phieu'),
            //   enabled: false,
            // ),
           ElevatedButton(
              onPressed: () {
                insertrecorddoanhthu(widget.idPhieudoanhthu);
              },
              child: Text("Thêm"),
            ),

          ],
       ),
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
             ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
        content: Text('Thêm thành công!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating, // Hiển thị phía trên
        backgroundColor: Colors.green, // Thay đổi màu nền
      ),
    );
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
      onPressed: () async {
        bool success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => themmaymoc(
              idPhieumaymoc: widget.idPhieumaymoc,
            ),
          ),
        );
        if (success == true) {
          fetchDataSudungMayMoc();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thêm thành công!'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating, // Hiển thị phía trên
              backgroundColor: Colors.green, // Thay đổi màu nền
            ),
          );
        }
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

         Navigator.pop(context, true);

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

////////////////////////////////////////// Start Dụng cụ
class dungcu extends StatefulWidget {
  final String userId;

  dungcu({required this.userId});
  @override
  _DungCuScreenState createState() => _DungCuScreenState();

}

class _DungCuScreenState extends State<dungcu> {

  TextEditingController ngaynhapphieu = TextEditingController();
  

  List<String> danhSachSudungDungCu = [];

  @override
  void initState(){
    super.initState();
    setNgayNhapPhieu();
    getphieudungcu();
  }
  void setNgayNhapPhieu(){
     DateTime now = DateTime.now();

    // Gán giá trị ngày tháng năm vào trường ngaynhapphieu
    ngaynhapphieu.text = "${now.day}/${now.month}/${now.year}";
    
  }

 Future<void> themphieudungcu() async {
    if(ngaynhapphieu.text!=""){
      try{

        String uri = "http://buffquat13.000webhostapp.com/themphieudungcu.php";

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
    getphieudungcu();
    
  }

  Future<void> getphieudungcu() async {
    try {
      String uri = "http://buffquat13.000webhostapp.com/get_phieudungcu.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
         List<String> danhSachDungCu = data
          .where((item) => item['uid'] == widget.userId) // Lọc theo uid
          .map((item) => "${item['Ngaynhapphieu']} - ${item['idPhieudungcu']}")
          .toList();
        setState(() {
          this.danhSachSudungDungCu = danhSachDungCu;
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
  itemCount: danhSachSudungDungCu.length,
  itemBuilder: (context, index) {
    return InkWell(
      onTap: () async {
       
        // Chuyển hướng tới trang chitietphieumaymoc khi nhấn vào phần tử trong RecyclerView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:(context) =>
            chitietphieudungcu(ngayPhieu: danhSachSudungDungCu[index],idPhieudungcu:danhSachSudungDungCu[index].split(' - ')[1],
           ),
          ),
        );
      },
      child: ListTile(
        title: Text(danhSachSudungDungCu[index]), // Hiển thị thông tin máy móc (thay bằng thông tin thực tế của bạn)
      ),
    );
  },
),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          themphieudungcu();
             ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
        content: Text('Thêm thành công!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating, // Hiển thị phía trên
        backgroundColor: Colors.green, // Thay đổi màu nền
      ),
    );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


class DungCuData {
  String Tensanpham;
  String Tondaungay;
  String Soluongsudung;
 String Conlaicuoingay;
 String idphieudungcuu;

  DungCuData({
    required this.Tensanpham,
    required this.Tondaungay,
    required this.Soluongsudung,
    required this.Conlaicuoingay,
    required this.idphieudungcuu,
  });
}

class chitietphieudungcu extends StatefulWidget {
  final String ngayPhieu;
  final String idPhieudungcu;


  chitietphieudungcu({required this.ngayPhieu,required this.idPhieudungcu});

  @override
  _chitietphieudungcuState createState() => _chitietphieudungcuState();
}

class _chitietphieudungcuState extends State<chitietphieudungcu> {
  List<DungCuData> danhSachDungCu = [];

  @override
  void initState() {
    super.initState();
    fetchDataSudungDungCu();
  }

  Future<void> fetchDataSudungDungCu() async {
    try {
      String uri = "http://buffquat13.000webhostapp.com/get_dungcu.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<DungCuData> dungCuList = data.map((item) => DungCuData(
              idphieudungcuu: item['idPhieudungcu'],
              Tensanpham: item['Tensp'],
              Tondaungay: item['Tondaungay'],
              Soluongsudung: item['Soluongsudung'],
              Conlaicuoingay: item['Conlaicuoingay'],
             
            )).toList();

        setState(() {
          danhSachDungCu = dungCuList.where((dungcu) => dungcu.idphieudungcuu == widget.idPhieudungcu).toList();
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
        itemCount: danhSachDungCu.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(danhSachDungCu[index].Tensanpham),
            subtitle: Text(danhSachDungCu[index].Conlaicuoingay),
            
            // Hiển thị thông tin máy móc (thay bằng thông tin thực tế của bạn)
          );
        },
      ),
          floatingActionButton: FloatingActionButton(
      onPressed: () async {
        bool success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => themdungcu(
              idPhieudungcu: widget.idPhieudungcu,
            ),
          ),
        );
        if (success == true) {
          fetchDataSudungDungCu();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thêm thành công!'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating, // Hiển thị phía trên
              backgroundColor: Colors.green, // Thay đổi màu nền
            ),
          );
        }
      },
      child: Icon(Icons.add),
    ),


    );
  }
}



class themdungcu extends StatefulWidget {
 
 final String idPhieudungcu;
  themdungcu({required this.idPhieudungcu});
  
  @override
  _ThemDungCuScreenState createState() => _ThemDungCuScreenState();
}


class _ThemDungCuScreenState extends State<themdungcu>{

        TextEditingController thoigiannhapphieu = TextEditingController();
        TextEditingController tensanpham = TextEditingController();
        TextEditingController tondaungay = TextEditingController();
        TextEditingController soluongsudung = TextEditingController();
        TextEditingController conlaicuoingay = TextEditingController();
       
   

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
  Future<void> insertrecorddungcu(String idPhieudungcu) async {
    if(tensanpham.text!="" || tondaungay.text!= "" || soluongsudung.text!=""||conlaicuoingay.text!=""){
      try{

        String uri = "http://buffquat13.000webhostapp.com/dungcu.php";

        var res=await http.post(Uri.parse(uri),body: {
            "idPhieudungcu": idPhieudungcu,
            "thoigiannhapphieu":thoigiannhapphieu.text,
            "tensp":tensanpham.text,
            "tondaungay":tondaungay.text,
            "soluongsudung":soluongsudung.text,
            "conlaicuoingay":conlaicuoingay.text,
         
          
        });
        var response = jsonDecode(res.body);
        if(response["Success"]=="true"){
          print("Them doanh thu thanh cong!");
          tensanpham.text="";
          tondaungay.text="";
          soluongsudung.text="";
          conlaicuoingay.text="";

          Navigator.pop(context,true);
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
          'Thêm tiến trình doanh thu: ${widget.idPhieudungcu}',
          style: TextStyle(fontSize: 19),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: tensanpham,
              decoration: InputDecoration(labelText: 'Tên sản phẩm'),
            ),
            TextFormField(
              controller: tondaungay,
              decoration: InputDecoration(labelText: 'Tồn đầu ngày'),
            ),
            TextFormField(
              controller: soluongsudung,
              decoration: InputDecoration(labelText: 'Số lượng sử dụng'),
            ),
             TextFormField(
              controller: conlaicuoingay,
              decoration: InputDecoration(labelText: 'Còn lại cuối ngày'),
            ),
          
            // TextFormField(
            //   controller: ngaynhapphieu,
            //   decoration: InputDecoration(labelText: 'Ngay nhap phieu'),
            //   enabled: false,
            // ),
           ElevatedButton(
              onPressed: () {
                insertrecorddungcu(widget.idPhieudungcu);
              },
              child: Text("Thêm"),
            ),

          ],
       ),
      ),
    );
  }
}


//////////////////////////////////////////////// End dụng cụ

///////////////////////////////////////////// Start Vật liệu
class vatlieu extends StatefulWidget {
  final String userId;

  vatlieu({required this.userId});
  @override
  _VatLieuScreenState createState() => _VatLieuScreenState();

}

class _VatLieuScreenState extends State<vatlieu> {

  TextEditingController ngaynhapphieu = TextEditingController();
  

  List<String> danhSachSudungVatLieu = [];

  @override
  void initState(){
    super.initState();
    setNgayNhapPhieu();
    getphieuvatlieu();
  }
  void setNgayNhapPhieu(){
     DateTime now = DateTime.now();

    // Gán giá trị ngày tháng năm vào trường ngaynhapphieu
    ngaynhapphieu.text = "${now.day}/${now.month}/${now.year}";
    
  }

 Future<void> themphieuvatlieu() async {
    if(ngaynhapphieu.text!=""){
      try{

        String uri = "http://buffquat13.000webhostapp.com/themphieuvatlieu.php";

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
    getphieuvatlieu();
    
  }

  Future<void> getphieuvatlieu() async {
    try {
      String uri = "http://buffquat13.000webhostapp.com/get_phieuvatlieu.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
         List<String> danhSachVatLieu = data
          .where((item) => item['uid'] == widget.userId) // Lọc theo uid
          .map((item) => "${item['Ngaynhapphieu']} - ${item['idPhieuvatlieu']}")
          .toList();
        setState(() {
          this.danhSachSudungVatLieu = danhSachVatLieu;
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
        title: Text('Danh sách phiếu vật liệu'),
      ),
      body: ListView.builder(
  itemCount: danhSachSudungVatLieu.length,
  itemBuilder: (context, index) {
    return InkWell(
      onTap: () async {
       
        // Chuyển hướng tới trang chitietphieumaymoc khi nhấn vào phần tử trong RecyclerView
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:(context) =>
            chitietphieuvatlieu(ngayPhieu: danhSachSudungVatLieu[index],idPhieuvatlieu:danhSachSudungVatLieu[index].split(' - ')[1],
           ),
          ),
        );
      },
      child: ListTile(
        title: Text(danhSachSudungVatLieu[index]), // Hiển thị thông tin máy móc (thay bằng thông tin thực tế của bạn)
      ),
    );
  },
),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          themphieuvatlieu();
             ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
        content: Text('Thêm thành công!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating, // Hiển thị phía trên
        backgroundColor: Colors.green, // Thay đổi màu nền
      ),
    );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


class VatLieuData {
  String Thoigiannhapphieu;
  String Tensanpham;
  String Tondaungay;
  String Khachhangmaso;
  String Soluongsudung;
 String Conlaicuoingay;
 String idphieuvatlieuu;

  VatLieuData({
    required this.Thoigiannhapphieu,
    required this.Tensanpham,
    required this.Tondaungay,
    required this.Khachhangmaso,
    required this.Soluongsudung,
    required this.Conlaicuoingay,
    required this.idphieuvatlieuu,
  });
}

class chitietphieuvatlieu extends StatefulWidget {
  final String ngayPhieu;
  final String idPhieuvatlieu;


  chitietphieuvatlieu({required this.ngayPhieu,required this.idPhieuvatlieu});

  @override
  _chitietphieuvatlieuState createState() => _chitietphieuvatlieuState();
}

class _chitietphieuvatlieuState extends State<chitietphieuvatlieu> {
 



  List<VatLieuData> danhSachVatLieu = [];

  @override
  void initState(){
    super.initState();
    fetchDataSudungVatLieu();
  }

  Future<void> fetchDataSudungVatLieu() async {
    try {
      String uri = "http://buffquat13.000webhostapp.com/get_vatlieu.php";
      var response = await http.get(Uri.parse(uri));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<VatLieuData> vatLieuList = data.map((item) => VatLieuData(
              idphieuvatlieuu: item['idPhieuvatlieu'],
              Thoigiannhapphieu: item['Thoigiannhapphieu'],
              Tensanpham: item['Tensp'],
              Tondaungay: item['Tondaungay'],
              Khachhangmaso: item['KhachangMaso'],
              Soluongsudung: item['Soluongsudung'],
              Conlaicuoingay: item['Conlaicuoingay'], 
            )).toList();

        setState(() {
          danhSachVatLieu = vatLieuList.where((vatlieu) => vatlieu.idphieuvatlieuu == widget.idPhieuvatlieu).toList();
        });
      } else {
        print("Lỗi khi lấy dữ liệu từ bảng sudungvatlieu: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu từ bảng sudungvatlieu: $e");
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Phiếu vật liệu: ${widget.ngayPhieu}',
        style: TextStyle(fontSize: 19),
      ),
    ),
    body: ListView.builder(
      itemCount: danhSachVatLieu.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(danhSachVatLieu[index].Thoigiannhapphieu),
          subtitle: Text(danhSachVatLieu[index].Tensanpham),
          // Hiển thị thông tin máy móc (thay bằng thông tin thực tế của bạn)
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        bool success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => themvatlieu(
              idPhieuvatlieu: widget.idPhieuvatlieu,
            ),
          ),
        );
        if (success == true) {
          fetchDataSudungVatLieu();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thêm thành công!'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating, // Hiển thị phía trên
              backgroundColor: Colors.green, // Thay đổi màu nền
            ),
          );
        }
      },
      child: Icon(Icons.add),
    ),
  );
}

}




class themvatlieu extends StatefulWidget {
 
 final String idPhieuvatlieu;
  themvatlieu({required this.idPhieuvatlieu});
  
  @override
  _ThemVatLieuScreenState createState() => _ThemVatLieuScreenState();
}


class _ThemVatLieuScreenState extends State<themvatlieu>{

        TextEditingController thoigiannhapphieu = TextEditingController();
        TextEditingController tensanpham = TextEditingController();
        TextEditingController tondaungay = TextEditingController();
        TextEditingController khachhangmaso = TextEditingController();
        TextEditingController soluongsudung = TextEditingController();
        TextEditingController conlaicuoingay = TextEditingController();
       
     
   

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
  Future<void> insertrecordvatlieu(String idPhieuvatlieu) async {
    if(tensanpham.text!="" || tondaungay.text!= "" || soluongsudung.text!=""||conlaicuoingay.text!=""||khachhangmaso!=""){
      try{

        String uri = "http://buffquat13.000webhostapp.com/vatlieu.php";

        var res=await http.post(Uri.parse(uri),body: {
            "idPhieuvatlieu": idPhieuvatlieu,
            "thoigiannhapphieu":thoigiannhapphieu.text,
            "tensp":tensanpham.text,
            "tondaungay":tondaungay.text,
            "khachhangmaso":khachhangmaso.text,
            "soluongsudung":soluongsudung.text,
            "conlaicuoingay":conlaicuoingay.text,
         
          
        });
        var response = jsonDecode(res.body);
        if(response["Success"]=="true"){
          print("Them vật liệu thanh cong!");
          tensanpham.text="";
          tondaungay.text="";
          khachhangmaso.text="";
          soluongsudung.text="";
          conlaicuoingay.text="";
      
         Navigator.pop(context, true);
        }
        else{
          print("Lỗi!");
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
          'Thêm tiến trình vật liệu: ${widget.idPhieuvatlieu}',
          style: TextStyle(fontSize: 19),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: tensanpham,
              decoration: InputDecoration(labelText: 'Tên sản phẩm'),
            ),
            TextFormField(
              controller: tondaungay,
              decoration: InputDecoration(labelText: 'Tồn đầu ngày'),
            ),
             TextFormField(
              controller: khachhangmaso,
              decoration: InputDecoration(labelText: 'Khách hàng mã số'),
            ),
            TextFormField(
              controller: soluongsudung,
              decoration: InputDecoration(labelText: 'Số lượng sử dụng'),
            ),
             TextFormField(
              controller: conlaicuoingay,
              decoration: InputDecoration(labelText: 'Còn lại cuối ngày'),
            ),
          
            // TextFormField(
            //   controller: ngaynhapphieu,
            //   decoration: InputDecoration(labelText: 'Ngay nhap phieu'),
            //   enabled: false,
            // ),
           ElevatedButton(
              onPressed: () {
                insertrecordvatlieu(widget.idPhieuvatlieu);
              },
              child: Text("Thêm"),
            ),

          ],
       ),
      ),
    );
  }
}


///////////////////////////////////////////// End Vật liệu



class DangNhap extends StatefulWidget {
  @override
  _DangNhapState createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool showError = false;
  bool showProgressBar = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      String savedEmail = prefs.getString('email') ?? '';

      setState(() {
        email.text = savedEmail;
      });
    });
  }

  Future<void> login(BuildContext context) async {
    if (email.text.isNotEmpty && password.text.isNotEmpty) {
      try {
        setState(() {
          showProgressBar = true;
        });

        String uri = "http://buffquat13.000webhostapp.com/login.php";

        var res = await http.post(Uri.parse(uri), body: {
          "email": email.text,
          "password": password.text,
        });

        var response = jsonDecode(res.body);

        setState(() {
          showProgressBar = false;
        });

        if (response["Success"] == true) {
          String userId = response['uid'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
          await prefs.setString('email', email.text);

          Navigator.pushReplacementNamed(context, '/home', arguments: userId);
        } else {
          setState(() {
            showError = true;
            errorMessage = response["Message"];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print("Lỗi: $e");
        setState(() {
          showProgressBar = false;
        });
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
      body: Stack(
        children: [
          Column(
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
                  obscureText: true,
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
            ],
          ),
          Visibility(
            visible: showProgressBar,
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Đang xử lý...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
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
  late String Batdaulamviec;
  
    // Trạng thái làm việc

      @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        Batdaulamviec = prefs.getString('startWorkTime') ?? '';
        isWorking = Batdaulamviec.isNotEmpty;
        isEndButtonDisabled = !isWorking;
      });
    });
  }

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
            onPressed: isWorking ? null : () {
            startWorkTime();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã bắt đầu giờ làm việc!'),
                duration: Duration(seconds: 2),
            ),
          );
        },
          child: Text("Bắt đầu làm việc"),
  );
} else if (index == menuItems.length + 1) {
  return ElevatedButton(
    onPressed: isEndButtonDisabled ? null : () => showEndConfirmation(),
    
    child: Text("Kết thúc làm việc"),
  );
}
 else {
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('startWorkTime', Batdaulamviec);

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

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('startWorkTime');

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
                ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
          content: Text('Đã kết thúc giờ làm việc!'),
          duration: Duration(seconds: 2),
         backgroundColor: Colors.purpleAccent, // Màu tím nhạt

        ),
      );
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
