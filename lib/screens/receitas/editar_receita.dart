import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/dao/receita_dao.dart';
import 'package:da_minha_conta/dao/transacao_dao.dart';
import 'package:da_minha_conta/model/conta.dart';
import 'package:da_minha_conta/model/receita.dart';
import 'package:da_minha_conta/model/transacao.dart';
import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

class EditarReceita extends StatefulWidget {
  const EditarReceita(this.receita, {Key? key}) : super(key: key);

  final Receita receita;

  @override
  EditarReceitaState createState() => EditarReceitaState();
}

class EditarReceitaState extends State<EditarReceita> {
  final _formKey = GlobalKey<EditarReceitaFormState>();

  void saveReceita() {
    final formState = _formKey.currentState!;
    if (formState.validateForm()) {
      formState.updateReceita();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Receita'),
        backgroundColor: Colors.lightGreen[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveReceita,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: EditarReceitaForm(widget.receita, key: _formKey),
      ),
    );
  }
}

class EditarReceitaForm extends StatefulWidget {
  const EditarReceitaForm(this.receita, {Key? key}) : super(key: key);

  final Receita receita;

  @override
  EditarReceitaFormState createState() => EditarReceitaFormState();
}

class EditarReceitaFormState extends State<EditarReceitaForm> {
  final _formKey = GlobalKey<FormState>();
  late final _descricaoController = TextEditingController(text: widget.receita.transacao.descricao);
  late final _valorController = MoneyMaskedTextController(
    initialValue: widget.receita.transacao.valor,
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
  );
  late String _recorrencia = widget.receita.transacao.recorrencia;
  late DateTime _data = widget.receita.transacao.data;
  Conta? _conta;
  late String? _imagem = widget.receita.transacao.imagem;

  late int idTransacao = widget.receita.transacao.id!;
  late int idConta = widget.receita.conta.id!;

  List<Conta> _contaOptions = [];

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
    loadContas();
  }

  Future<void> loadContas() async {
    List<Conta> contas = await ContaDAO(DatabaseHelper()).getContas();
    setState(() {
      _contaOptions = contas;
      selectConta();
    });
  }

  void selectConta() {
    _conta = _contaOptions.firstWhere((conta) => conta.id == widget.receita.conta.id);
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

  void updateReceita() async {
    if (validateForm()) {
      final descricao = _descricaoController.text;
      final valor = _valorController.numberValue;
      final recorrencia = _recorrencia;
      final data = _data;
      final conta = _conta;
      final imagem = _imagem;

      Transacao transacao = Transacao(id: idTransacao, descricao: descricao, valor: valor, data: data, recorrencia: recorrencia, imagem: imagem);
      Receita receita = Receita(transacao: transacao, conta: conta!);
      DatabaseHelper db = DatabaseHelper();

      int linhasAfetadas = await ReceitaDAO(db, TransacaoDAO(db), ContaDAO(db)).atualizarReceita(receita);

      if (linhasAfetadas == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Receita atualizada com sucesso!',
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
          DropdownButtonFormField(
            decoration: const InputDecoration(labelText: 'Conta'),
            value: _conta,
            onChanged: (value) {
              setState(() {
                _conta = value as Conta;
              });
            },
            items: _contaOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option.descricao),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return 'Por favor, selecione a conta';
              }
              return null;
            },
          ),
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
