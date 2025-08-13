import 'dart:io';

import 'package:mysql_client/mysql_client.dart';

const String dbhost = 'localhost';
const int dbport = 3306;
const String dbUser = 'gabriel';
const String dbPassword = 'senha';

const String dbDataBaseName = 'biblioteca';

void main() async {
  final conn = await _conectarNoBanco();
  if (conn == null) {
    print('Não foi possível estabelecer conexão com o banco de dados.');
    return;
  }

  print('Conectado ao banco de dados');

  try {
    print('\n--- Incluindo Livro ---');
    await _incluirLivro(
      conn,
      'As Louras Tranças de Um Careca',
      'Winston Churchill',
    );
  } catch (erro) {
    print('Ocorreu na inclusão do livro: $erro');
  }

  try {
    print('\n--- Listando Livros ---');
    await _listarLivros(conn);
  } catch (erro) {
    print('Ocorreu na listagem dos livros: $erro');
  } finally {
    await conn.close();
    print('Conexão com o MySQL fechada.');
  }
}

Future<MySQLConnection?> _conectarNoBanco() async {
  try {
    final conn = await MySQLConnection.createConnection(
      host: dbhost,
      port: dbport,
      userName: dbUser,
      databaseName: dbDataBaseName,
      password: dbPassword,
      secure: false, //remove restrição de acesso do senai
    );
    await conn.connect();
    return conn;
  } catch (e) {
    print('Erro ao conectar: $e');
    return null;
  }
}

Future<void> _incluirLivro(
  MySQLConnection conn,
  String titulo,
  String autor,
) async {
  try {
    var result = await conn.execute(
      'insert into livro (titulo,autor) values (:titulo,:autor)',
      {'titulo': titulo, 'autor': autor},
    );
    print('Livro incluido com sucesso');
  } catch (erro) {
    print('Inclusão com problema $erro');
  }
}

Future<void> _listarLivros(MySQLConnection conn) async {
  try {
    var resultado = await conn.execute(
      'select idlivro,titulo,autor from livro order by idlivro',
    );

    if (resultado.rows.isEmpty) {
      print('Cara. Não achei nada');
      return;
    }

    for (var linha in resultado.rows) {
      final id = linha.typedColByName<int>('idlivro');
      final titulo = linha.typedColByName<String>('titulo');
      final autor = linha.typedColByName<String>('autor');
      print('Id: $id, Titulo: $titulo,  Autor: $autor');
    }
  } catch (erro) {
    print('Erro ao listar livros $erro');
  }
}
