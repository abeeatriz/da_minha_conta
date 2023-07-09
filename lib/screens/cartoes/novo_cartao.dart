import 'package:da_minha_conta/dao/cartao_dao.dart';
import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/model/cartao.dart';
import 'package:da_minha_conta/model/conta.dart';
import 'package:da_minha_conta/utils.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';

class NovoCartao extends StatefulWidget {
  @override
  _NovoCartaoState createState() => _NovoCartaoState();
}

class _NovoCartaoState extends State<NovoCartao> {
  final _databaseHelper = DatabaseHelper();
  late final ContaDAO _contaDAO;

  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final TextEditingController _limiteController = MoneyMaskedTextController(
    decimalSeparator: ',',
  );
  int? _contaSelecionada;
  DateTime _dataVencimento = DateTime.now();

  List<Conta> _contas = [];

  @override
  void initState() {
    super.initState();
    carregarContas();
  }

  Future<void> carregarContas() async {
    _contaDAO = ContaDAO(_databaseHelper);
    List<Conta> contas = await _contaDAO.getContas();

    setState(() {
      _contas = contas;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _dataVencimento) {
      setState(() {
        _dataVencimento = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Novo Cartão'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                if (_formKey.currentState?.validate() == true) {
                  String descricao = _descricaoController.text;
                  double limite =
                      double.parse(formatarSeparador(_limiteController.text));
                  DateTime dataVencimento = _dataVencimento;
                  int? contaId = _contaSelecionada;

                  Conta? conta;

                  if (contaId != null) {
                    conta = await _contaDAO.getConta(contaId);
                  }

                  Cartao cartao = Cartao(
                      descricao: descricao,
                      limite: limite,
                      dataVencimento: dataVencimento,
                      conta: conta);

                  int idInserido = await CartaoDAO(_databaseHelper, _contaDAO)
                      .insertCartao(cartao);

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
              },
            ),
          ],
          backgroundColor: Colors.amberAccent[700]),
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
                controller: _limiteController,
                decoration: const InputDecoration(
                  labelText: 'Limite',
                  prefixText: 'R\$',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Dia do Vencimento',
                    hintText: 'Selecione uma data',
                  ),
                  child: Text(
                    '${_dataVencimento.day}/${_dataVencimento.month}/${_dataVencimento.year}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Conta'),
                value: _contaSelecionada,
                onChanged: (value) {
                  setState(() {
                    _contaSelecionada = value;
                  });
                },
                items: _contas.map((conta) {
                  return DropdownMenuItem(
                    value: conta.id,
                    child: Text(conta.descricao),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione a conta';
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
