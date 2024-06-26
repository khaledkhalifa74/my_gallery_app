import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_gallery/core/utils/api_service.dart';
import 'package:my_gallery/features/Authentication/data/models/login_model.dart';
import 'package:my_gallery/features/Authentication/presentation/manager/auth_cubit/auth_state.dart';
import 'package:my_gallery/core/utils/globals.dart' as globals;

class AuthCubit extends Cubit<AuthState>{
  AuthCubit() : super (AuthInitial());

  static AuthCubit get(context) => BlocProvider.of(context);

  Future<void> loginUser({required String email, required String password}) async {
    emit(LoginLoading());
    try {
      Response response = await ApiService.postData(
        contentType: 'multipart/form-data',
        url: 'auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        LoginModel loginModel = LoginModel.fromJson(response.data);
        if(loginModel.token == null){
          emit(LoginFailure(errorMessage: 'Invalid Credentials'));
        }else{
          globals.token = loginModel.token ?? '';
          globals.userData = loginModel.user;
          // CasheHelper.saveData(key: 'login', value: true); //save user
          emit(LoginSuccess(loginModel));
        }
      }
    }
    on Exception catch (e) {
      emit(LoginFailure(errorMessage: e.toString()));
    }
  }
}