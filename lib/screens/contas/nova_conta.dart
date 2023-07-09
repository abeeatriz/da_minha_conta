import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/model/conta.dart';
import 'package:da_minha_conta/utils.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';

class NovaConta extends StatefulWidget {
  
  const NovaConta({Key? key}) : super(key: key);

  @override
  NovaContaState createState() => NovaContaState();
}

class NovaContaState extends State<NovaConta> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _saldoController = MoneyMaskedTextController(
    decimalSeparator: ',',
  );
  final TextEditingController _descricaoController = TextEditingController();
  String? _banco;

  final List<String> _bancos = [
    'Banco do Brasil',
    'Itaú',
    'Bradesco',
    'Caixa Econômica',
    'Santander',
    'HSBC',
    'Citibank',
    'NuBank',
    'Inter',
    'Sicoob',
    'Outro',
  ];

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
                double saldo =
                    double.parse(formatarSeparador(_saldoController.text));
                String descricao = _descricaoController.text;
                String banco = _banco ?? 'Outro';

                Conta conta = Conta(saldo: saldo, descricao: descricao, banco: banco);

                int idInserido = await ContaDAO(DatabaseHelper())
                    .insertConta(conta);

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Banco'),
                value: _banco,
                onChanged: (value) {
                  setState(() {
                    _banco = value;
                  });
                },
                items: _bancos.map((banco) {
                  return DropdownMenuItem(
                    value: banco,
                    child: Text(banco),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione o banco';
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
