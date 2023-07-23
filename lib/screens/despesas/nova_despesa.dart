import 'dart:io';
import 'package:da_minha_conta/dao/categoria_dao.dart';
import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/dao/despesa_conta_dao.dart';
import 'package:da_minha_conta/dao/despesa_dao.dart';
import 'package:da_minha_conta/dao/transacao_dao.dart';
import 'package:da_minha_conta/model/categoria.dart';
import 'package:da_minha_conta/model/conta.dart';
import 'package:da_minha_conta/model/depesaConta.dart';
import 'package:da_minha_conta/model/despesa.dart';
import 'package:da_minha_conta/model/transacao.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class NovaDespesa extends StatefulWidget {
  const NovaDespesa({Key? key}) : super(key: key);

  @override
  NovaDespesaState createState() => NovaDespesaState();
}

class NovaDespesaState extends State<NovaDespesa> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();

  final TextEditingController _descricaoController = TextEditingController();
  final _valorController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
  );

  List<Categoria> _categorias = [];
  List<Conta> _contas = [];
  DateTime _data = DateTime.now();
  String _recorrencia = 'Única';
  Categoria? _categoriaSelecionada;
  File? _imagemSelecionada;
  Conta? _contaSelecionada;

  final List<String> _recorrenciaOptions = [
    'Única',
    'Diária',
    'Semanal',
    'Mensal',
    'Anual',
  ];

  @override
  void initState() {
    super.initState();
    carregarContas();
    carregarCategorias();
  }

  Future<void> carregarContas() async {
    List<Conta> contas = await ContaDAO(_db).getContas();

    setState(() {
      _contas = contas;
    });
  }

  Future<void> carregarCategorias() async {
    List<Categoria> categorias = await CategoriaDAO(_db).getCategorias();

    setState(() {
      _categorias = categorias;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _data) {
      setState(() {
        _data = picked;
      });
    }
  }

  void saveDespesaCartao() async {
    if (_formKey.currentState!.validate()) {
      final descricao = _descricaoController.text;
      final valor = _valorController.numberValue;
      final recorrencia = _recorrencia;
      final data = _data;

      Transacao transacao = Transacao(descricao: descricao, valor: valor, data: data, recorrencia: recorrencia);
      Despesa despesa = Despesa(transacao: transacao, categoria: _categoriaSelecionada!);
      DespesaConta despesaConta = DespesaConta(despesa: despesa, conta: _contaSelecionada!);

      int idInserido = await DespesaContaDAO(_db, DespesaDAO(_db, TransacaoDAO(_db), CategoriaDAO(_db)), ContaDAO(_db))
          .insertDespesaConta(despesaConta);

      if (idInserido != 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Despesa inserida com sucesso! ID: $idInserido',
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
  }

  Future<void> _selectImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagemSelecionada = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Despesa de Conta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveDespesaCartao,
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
                  labelText: 'Descrição',
                ),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Por favor, informe a descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Valor'),
                controller: _valorController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Por favor, informe o valor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Text(DateFormat('dd/MM/yyyy').format(_data)),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Recorrência'),
                value: _recorrencia,
                onChanged: (value) {
                  setState(() {
                    _recorrencia = value ?? _recorrenciaOptions.first;
                  });
                },
                items: _recorrenciaOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione a recorrência';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<Categoria>(
                value: _categoriaSelecionada,
                onChanged: (categoria) {
                  setState(() {
                    _categoriaSelecionada = categoria;
                  });
                },
                items: _categorias.map((categoria) {
                  return DropdownMenuItem<Categoria>(
                    value: categoria,
                    child: Text(categoria.descricao),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                ),
                validator: (categoria) {
                  if (categoria == null) {
                    return 'Por favor, selecione uma categoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<Conta>(
                value: _contaSelecionada,
                onChanged: (conta) {
                  setState(() {
                    _contaSelecionada = conta;
                  });
                },
                items: _contas.map((conta) {
                  return DropdownMenuItem<Conta>(
                    value: conta,
                    child: Text(conta.descricao),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Conta',
                ),
                validator: (conta) {
                  if (conta == null || conta.id == null) {
                    return 'Por favor, selecione uma conta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  _selectImage();
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Anexar imagem'),
                  child: _imagemSelecionada != null ? Image.file(_imagemSelecionada!) : const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
