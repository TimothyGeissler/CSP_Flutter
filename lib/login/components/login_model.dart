

class Login{
  bool error;
  User user;

  Login({this.error, this.user});

  factory Login.fromJson(Map<String, dynamic> parsedJson) {
    return Login(
      error: parsedJson['error'],
      user: User.fromJson(parsedJson['user'])
    );
  }
}

class User{
  String holding_id, lcs, name, email, api_token, license, smtp_host,
      smtp_pass, smtp_port, smtp_avatar, smtp_avatar_width, smtp_avatar_height,
      smtp_active, sms_user, sms_pass, smtp_signature, created_at, updated_at;
  int id, smtp_tls;

  User({
    this.id,
    this.holding_id,
    this.lcs,
    this.name,
    this.email,
    this.api_token,
    this.license,
    this.smtp_host,
    this.smtp_pass,
    this.smtp_port,
    this.smtp_tls,
    this.smtp_avatar,
    this.smtp_avatar_width,
    this.smtp_avatar_height,
    this.smtp_active,
    this.sms_user,
    this.sms_pass,
    this.smtp_signature,
    this.created_at,
    this.updated_at});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      holding_id: json['holding_id'],
      lcs: json['lcs'],
      name: json['name'],
      email: json['email'],
      api_token: json['api_token'],
      license: json['license'],
      smtp_host: json['smtp_host'],
      smtp_pass: json['smtp_pass'],
      smtp_port: json['smtp_port'],
      smtp_tls: json['smtp_tls'],
      smtp_avatar:  json['smtp_avatar'],
      smtp_avatar_width: json['smtp_avatar_width'],
      smtp_avatar_height: json['smtp_avatar_height'],
      smtp_active: json['smtp_active'],
      sms_user: json['sms_user'],
      sms_pass: json['sms_pass'],
      smtp_signature: json['smtp_signature'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }


}