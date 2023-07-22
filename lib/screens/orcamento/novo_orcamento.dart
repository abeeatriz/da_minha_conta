import 'package:da_minha_conta/dao/categoria_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/dao/orcamento_dao.dart';
import 'package:da_minha_conta/model/categoria.dart';
import 'package:da_minha_conta/model/orcamento.dart';
import 'package:da_minha_conta/utils.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';

class NovoOrcamento extends StatefulWidget {
  const NovoOrcamento({Key? key}) : super(key: key);

  @override
  NovoOrcamentoState createState() => NovoOrcamentoState();
}

class NovoOrcamentoState extends State<NovoOrcamento> {
  final _formKey = GlobalKey<FormState>();
  final _databaseHelper = DatabaseHelper();
  final TextEditingController _saldoController = MoneyMaskedTextController(
    decimalSeparator: ',',
  );
  final TextEditingController _descricaoController = TextEditingController();
  List<Categoria> _categorias = [];
  Categoria? _categoria;

  Future<void> carregarCategorias() async {
    List<Categoria> catgorias = await CategoriaDAO(_databaseHelper).getCategorias();

    setState(() {
      _categorias = catgorias;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Conta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (_formKey.currentState?.validate() == true) {
                double saldo = double.parse(formatarSeparador(_saldoController.text));
                String descricao = _descricaoController.text;
                Categoria categoria = _categoria!;

                Orcamento orcamento = Orcamento(descricao: descricao, valor: saldo, categoria: categoria);

                int idInserido = await OrcamentoDAO(_databaseHelper, CategoriaDAO(_databaseHelper)).inserirOrcamento(orcamento);

                if (idInserido != 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Orçamento inserido com sucesso! ID: $idInserido',
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
              DropdownButtonFormField<Categoria>(
                decoration: const InputDecoration(labelText: 'Categoria'),
                value: _categoria,
                onChanged: (value) {
                  setState(() {
                    _categoria = value;
                  });
                },
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria.descricao),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione a categoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _saldoController,
                decoration: const InputDecoration(
                  labelText: 'Saldo',
                  prefixText: 'R\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Por favor, informe o saldo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                ),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Por favor, informe a descrição';
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
