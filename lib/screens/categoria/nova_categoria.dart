import 'package:da_minha_conta/dao/categoria_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/model/categoria.dart';
import 'package:flutter/material.dart';

class NovaCategoria extends StatefulWidget {
  const NovaCategoria({Key? key}) : super(key: key);

  @override
  NovaCategoriaState createState() => NovaCategoriaState();
}

class NovaCategoriaState extends State<NovaCategoria> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descricaoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Categoria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (_formKey.currentState?.validate() == true) {
                String descricao = _descricaoController.text;

                Categoria categoria = Categoria(descricao: descricao);

                int idInserido = await CategoriaDAO(DatabaseHelper()).inserirCategoria(categoria);

                if (idInserido != 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Categoria inserida com sucesso! ID: $idInserido',
                        ),
                      ),
                    );
                  });
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Falha ao inserir o registro.',
                        ),
                      ),
                    );
                  });
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                ),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Por favor, informe a categoria';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
