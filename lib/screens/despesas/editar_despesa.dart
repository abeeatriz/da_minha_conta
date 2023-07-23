import 'package:da_minha_conta/dao/cartao_dao.dart';
import 'package:da_minha_conta/dao/categoria_dao.dart';
import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/dao/despesa_cartao_dao.dart';
import 'package:da_minha_conta/dao/despesa_conta_dao.dart';
import 'package:da_minha_conta/dao/despesa_dao.dart';
import 'package:da_minha_conta/dao/transacao_dao.dart';
import 'package:da_minha_conta/model/cartao.dart';
import 'package:da_minha_conta/model/categoria.dart';
import 'package:da_minha_conta/model/conta.dart';
import 'package:da_minha_conta/model/depesaConta.dart';
import 'package:da_minha_conta/model/despesa.dart';
import 'package:da_minha_conta/model/despesaCartao.dart';
import 'package:da_minha_conta/model/transacao.dart';
import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

class EditarDespesa extends StatefulWidget {
  const EditarDespesa(this.despesa, {Key? key}) : super(key: key);

  final Despesa despesa;

  @override
  EditarDespesaState createState() => EditarDespesaState();
}

class EditarDespesaState extends State<EditarDespesa> {
  final _formKey = GlobalKey<EditarDespesaFormState>();

  void saveDespesa() {
    final formState = _formKey.currentState!;
    if (formState.validateForm()) {
      formState.updateDespesa();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Despesa'),
        backgroundColor: Colors.lightGreen[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveDespesa,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: EditarDespesaForm(widget.despesa, key: _formKey),
      ),
    );
  }
}

class EditarDespesaForm extends StatefulWidget {
  const EditarDespesaForm(this.despesa, {Key? key}) : super(key: key);

  final Despesa despesa;

  @override
  EditarDespesaFormState createState() => EditarDespesaFormState();
}

class EditarDespesaFormState extends State<EditarDespesaForm> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _db = DatabaseHelper();

  late final _descricaoController = TextEditingController(text: widget.despesa.transacao.descricao);
  late final _valorController = MoneyMaskedTextController(
    initialValue: widget.despesa.transacao.valor,
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
  );
  late String _recorrencia = widget.despesa.transacao.recorrencia;
  late DateTime _data = widget.despesa.transacao.data;
  Conta? _conta;
  Cartao? _cartao;
  late String? _imagem = widget.despesa.transacao.imagem;
  late final Categoria _categoria = widget.despesa.categoria;

  late int idTransacao = widget.despesa.transacao.id!;
  late int idDespesa = widget.despesa.id!;

  late DespesaConta? _despesaConta;
  late DespesaCartao? _despesaCartao;

  List<Conta> _contaOptions = [];
  List<Cartao> _cartaoOptions = [];

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
    loadDespesaDetails();
  }

  Future<void> loadDespesaDetails() async {
    DespesaContaDAO despesaContaDAO = DespesaContaDAO(_db, DespesaDAO(_db, TransacaoDAO(_db), CategoriaDAO(_db)), ContaDAO(_db));
    DespesaConta? despesaConta = await despesaContaDAO.getDespesaConta(idDespesa);
    if (despesaConta != null) {
      setState(() {
        _despesaConta = despesaConta;
        loadContas();
      });
    } else {
      DespesaCartaoDAO despesaCartaoDAO = DespesaCartaoDAO(_db, DespesaDAO(_db, TransacaoDAO(_db), CategoriaDAO(_db)), CartaoDAO(_db, ContaDAO(_db)));
      DespesaCartao? despesaCartao = await despesaCartaoDAO.getDespesaCartao(idDespesa);
      setState(() {
        _despesaCartao = despesaCartao;
        loadCartao();
      });
    }
  }

  Future<void> loadContas() async {
    List<Conta> contas = await ContaDAO(_db).getContas();
    setState(() {
      _contaOptions = contas;
      selectConta();
    });
  }

  Future<void> loadCartao() async {
    List<Cartao> cartoes = await CartaoDAO(_db, ContaDAO(_db)).getCartoes();
    setState(() {
      _cartaoOptions = cartoes;
      selectCartao();
    });
  }

  void selectConta() {
    _conta = _contaOptions.firstWhere((conta) => conta.id == _despesaConta!.conta.id);
  }

  void selectCartao() {
    _cartao = _cartaoOptions.firstWhere((cartao) => cartao.id == _despesaCartao!.cartao.id);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  bool validateForm() {
    return _formKey.currentState!.validate();
  }

  void updateDespesa() async {
    if (validateForm()) {
      final descricao = _descricaoController.text;
      final valor = _valorController.numberValue;
      final recorrencia = _recorrencia;
      final data = _data;
      final imagem = _imagem;
      final categoria = _categoria;

      Transacao transacao = Transacao(id: idTransacao, descricao: descricao, valor: valor, data: data, recorrencia: recorrencia, imagem: imagem);
      Despesa despesa = Despesa(id: idDespesa, transacao: transacao, categoria: categoria);

      int linhasAfetadas = 0;

      if (_conta != null) {
        DespesaConta despesaConta = DespesaConta(despesa: despesa, conta: _conta!);
        linhasAfetadas =
            await DespesaContaDAO(_db, DespesaDAO(_db, TransacaoDAO(_db), CategoriaDAO(_db)), ContaDAO(_db)).updateDespesaConta(despesaConta);
      } else {
        DespesaCartao despesaCartao = DespesaCartao(despesa: despesa, cartao: _cartao!);
        linhasAfetadas = await DespesaCartaoDAO(_db, DespesaDAO(_db, TransacaoDAO(_db), CategoriaDAO(_db)), CartaoDAO(_db, ContaDAO(_db)))
            .updateDespesaCartao(despesaCartao);
      }

      showDbResponse(linhasAfetadas);
    }
  }

  void showDbResponse(int linhasAfetadas) {
    if (linhasAfetadas > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Despesa atualizada com sucesso!',
            ),
          ),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Falha ao editar o registro.',
            ),
          ),
        );
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _data) {
      setState(() {
        _data = picked;
      });
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagem = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Descrição'),
            validator: (value) {
              if (value?.isEmpty == true) {
                return 'Por favor, insira a descrição';
              }
              return null;
            },
            controller: _descricaoController,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Valor'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty == true) {
                return 'Por favor, insira o valor';
              }
              return null;
            },
            controller: _valorController,
          ),
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
          InkWell(
            onTap: () {
              _selectDate();
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Data',
                hintText: _data.toString(),
              ),
              child: SizedBox(
                child: Text(
                  '${_data.day}/${_data.month}/${_data.year}',
                ),
              ),
            ),
          ),
          Offstage(
            offstage: _conta == null,
            child: DropdownButtonFormField<Conta>(
              decoration: const InputDecoration(labelText: 'Conta'),
              value: _conta,
              onChanged: (value) {
                setState(() {
                  _conta = value;
                });
              },
              items: _contaOptions.map((option) {
                return DropdownMenuItem<Conta>(
                  value: option,
                  child: Text(option.descricao),
                );
              }).toList(),
              validator: (value) {
                if (value == null && _cartao == null) {
                  return 'Por favor, selecione a conta';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16.0),
          Offstage(
            offstage: _cartao == null,
            child: DropdownButtonFormField<Cartao>(
              value: _cartao,
              onChanged: (cartao) {
                setState(() {
                  _cartao = cartao;
                });
              },
              items: _cartaoOptions.map((cartao) {
                return DropdownMenuItem<Cartao>(
                  value: cartao,
                  child: Text(cartao.descricao),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Cartão',
              ),
              validator: (value) {
                if (value == null && _conta == null) {
                  return 'Por favor, selecione um cartão';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16.0),
          InkWell(
            onTap: () {
              _selectImage();
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Anexar imagem'),
              child: _imagem != null ? Image.file(File(_imagem!)) : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
