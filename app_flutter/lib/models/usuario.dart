class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String? senha; // não exibida na lista

  Usuario({this.id, required this.nome, required this.email, this.senha});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int?,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJsonCreate() {
    return {
      'nome': nome,
      'email': email,
      if (senha != null) 'senha': senha,
    };
  }
}
