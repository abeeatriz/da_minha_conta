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

class NovaReceita extends StatefulWidget {
  @override
  _NovaReceitaState createState() => _NovaReceitaState();
}

class _NovaReceitaState extends State<NovaReceita> {
  final _formKey = GlobalKey<NovaReceitaFormState>();

  void saveReceita() {
    if (_formKey.currentState!.validateForm()) {
      final formState = _formKey.currentState!;
      formState.saveReceita();

      // Restante da lógica para salvar a receita no banco de dados
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Receita'),
        backgroundColor: Colors.lightGreen[800],
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveReceita,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: NovaReceitaForm(key: _formKey),
      ),
    );
  }
}

class NovaReceitaForm extends StatefulWidget {
  const NovaReceitaForm({Key? key}) : super(key: key);

  @override
  NovaReceitaFormState createState() => NovaReceitaFormState();
}

class NovaReceitaFormState extends State<NovaReceitaForm> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
  );
  String _recorrencia = 'Única';
  DateTime _data = DateTime.now();
  Conta? _conta;
  String? _imagem;

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

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  bool validateForm() {
    return _formKey.currentState!.validate();
  }

  void saveReceita() async {
    if (validateForm()) {
      final descricao = _descricaoController.text;
      final valor = _valorController.numberValue;
      final recorrencia = _recorrencia;
      final data = _data;
      final conta = _conta;
      final imagem = _imagem;

      Transacao transacao = Transacao(descricao: descricao, valor: valor, data: data, recorrencia: recorrencia, imagem: imagem);
      Receita receita = Receita(transacao: transacao, conta: conta!);
      DatabaseHelper db = DatabaseHelper();

      int idInserido = await ReceitaDAO(db, TransacaoDAO(db), ContaDAO(db)).inserirReceita(receita);

      if (idInserido != 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Registro inserido com sucesso! ID: $idInserido',
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

  Future<void> loadContas() async {
    // Lógica para buscar as contas do banco de dados
    List<Conta> contas = await ContaDAO(DatabaseHelper()).getContas();

    setState(() {
      _contaOptions = contas;
    });
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
            decoration: InputDecoration(labelText: 'Descrição'),
            validator: (value) {
              if (value?.isEmpty == true) {
                return 'Por favor, insira a descrição';
              }
              return null;
            },
            controller: _descricaoController,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Valor'),
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
                hintText: _data == null ? 'Selecione uma data' : _data.toString(),
              ),
              child: SizedBox(
                child: Text(
                  _data != null ? '${_data.day}/${_data.month}/${_data.year}' : 'Nenhuma data selecionada',
                ),
              ),
            ),
          ),
          DropdownButtonFormField(
            decoration: InputDecoration(labelText: 'Conta'),
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
              decoration: InputDecoration(
                labelText: 'Anexar imagem',
                hintText: _imagem == null ? 'Selecione uma imagem' : 'Imagem selecionada',
              ),
              child: SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}
