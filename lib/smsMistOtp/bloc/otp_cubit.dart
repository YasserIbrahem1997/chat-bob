import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart'as http;
part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit() : super(OtpInitial());

String baseUrl='https://smsmisr.com/api/v2/?';
sendRequest()async{
  try{

    var res=await http.post(Uri.parse(baseUrl),body: {
      "Username":"LUzwnRLx",
      "password":"so8ctbXj9s",
      "language":"2",
      "sender":"Codinga",
      "Mobile":"01100009486",
      "message":"this is test"
    });
    print(res.body);
  }catch(e){print(e.toString());}
}
}
