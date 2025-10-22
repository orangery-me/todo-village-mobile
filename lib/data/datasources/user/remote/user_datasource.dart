
import 'package:injectable/injectable.dart';
import 'package:todo_village_mobile/common/constants/endpoints.dart';
import 'package:todo_village_mobile/common/helpers/dio_helper.dart';
import 'package:todo_village_mobile/data/dtos/auth/login_by_email_request_dto.dart';
import 'package:todo_village_mobile/data/dtos/auth/login_response_dto.dart';
import 'package:todo_village_mobile/data/models/user_model.dart';

@lazySingleton
class UserRemoteDataSource {
  UserRemoteDataSource({required DioHelper dioHelper}) : _dioHelper = dioHelper;

  final DioHelper _dioHelper;

  Future<LoginResponseDTO> loginByEmail(LoginByEmailRequestDTO params) async {
    final response = await _dioHelper.post(
      Endpoints.login,
      data: params.toJson(),
    );

    // final user = await getUser();

    return LoginResponseDTO(
      // user: user,
      refreshToken: response.data['data']['refreshToken'] as String,
      accessToken: response.data['data']['accessToken'] as String,
      expiresIn: response.data['data']['expires_in'] as int,
    );
  }

  Future<UserModel> getUser() async {
    final response = await _dioHelper.get(
      Endpoints.getUser,
    );

    return UserModel.fromJson(response.data['data']);
  }
}
