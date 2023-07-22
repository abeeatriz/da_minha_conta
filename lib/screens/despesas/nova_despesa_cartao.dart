import 'dart:io';
import 'package:da_minha_conta/dao/cartao_dao.dart';
import 'package:da_minha_conta/dao/categoria_dao.dart';
import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/dao/despesa_cartao_dao.dart';
import 'package:da_minha_conta/dao/despesa_dao.dart';
import 'package:da_minha_conta/dao/transacao_dao.dart';
import 'package:da_minha_conta/model/cartao.dart';
import 'package:da_minha_conta/model/categoria.dart';
import 'package:da_minha_conta/model/despesa.dart';
import 'package:da_minha_conta/model/despesaCartao.dart';
import 'package:da_minha_conta/model/transacao.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class NovaDespesaCartao extends StatefulWidget {
  const NovaDespesaCartao({Key? key}) : super(key: key);

  @override
  NovaDespesaCartaoState createState() => NovaDespesaCartaoState();
}

class NovaDespesaCartaoState extends State<NovaDespesaCartao> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();

  final TextEditingController _descricaoController = TextEditingController();
  final _valorController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
  );

  List<Categoria> _categorias = [];
  List<Cartao> _cartoes = [];
  DateTime _data = DateTime.now();
  String _recorrencia = 'Única';
  Categoria? _categoriaSelecionada;
  Cartao? _cartaoSelecionado;
  File? _imagemSelecionada;

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
    carregarCartoes();
    carregarCategorias();
  }

  Future<void> carregarCartoes() async {
    ContaDAO contaDao = ContaDAO(_db);
    List<Cartao> cartoesDoBanco = await CartaoDAO(_db, contaDao).getCartoes();

    setState(() {
      _cartoes = cartoesDoBanco;
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
      DespesaCartao despesaCartao = DespesaCartao(despesa: despesa, cartao: _cartaoSelecionado!);

      int idInserido = await DespesaCartaoDAO(_db, DespesaDAO(_db, TransacaoDAO(_db), CategoriaDAO(_db)), CartaoDAO(_db, ContaDAO(_db)))
          .insertDespesaCartao(despesaCartao);

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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
        title: const Text('Nova Despesa de Cartão'),
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
              DropdownButtonFormField<Cartao>(
                value: _cartaoSelecionado,
                onChanged: (cartao) {
                  setState(() {
                    _cartaoSelecionado = cartao;
                  });
                },
                items: _cartoes.map((cartao) {
                  return DropdownMenuItem<Cartao>(
                    value: cartao,
                    child: Text(cartao.descricao),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Cartão',
                ),
                validator: (cartao) {
                  if (cartao == null || cartao.id == null) {
                    return 'Por favor, selecione um cartão';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                  children: [
                    Expanded(
                      child: Text(
                        _imagemSelecionada != null
                            ? 'Imagem selecionada'
                            : 'Nenhuma imagem selecionada',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _selectImage,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
