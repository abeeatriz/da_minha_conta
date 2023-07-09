import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/model/conta.dart';
import 'package:da_minha_conta/utils.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';

class EditarConta extends StatefulWidget {
  final Conta conta;

  const EditarConta({required this.conta, Key? key}) : super(key: key);

  @override
  EditarContaState createState() => EditarContaState();
}

class EditarContaState extends State<EditarConta> {
  late TextEditingController _saldoController;
  late TextEditingController _descricaoController;
  final _formKey = GlobalKey<FormState>();

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
  void initState() {
    super.initState();
    _saldoController = MoneyMaskedTextController(
      decimalSeparator: ',',
      initialValue: widget.conta.saldo,
    );
    _descricaoController.text = widget.conta.descricao;
    _banco = widget.conta.banco;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Conta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (_formKey.currentState?.validate() == true) {
                double saldo =
                    double.parse(formatarSeparador(_saldoController.text));
                String descricao = _descricaoController.text;
                String banco = _banco ?? 'Outro';

                Conta conta = Conta(
                  id: widget.conta.id,
                  saldo: saldo,
                  descricao: descricao,
                  banco: banco,
                );

                int linhasAfetadas = await ContaDAO(DatabaseHelper())
                    .updateConta(conta);

                if (linhasAfetadas != 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registro atualizado com sucesso!'),
                      ),
                    );
                  });
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Falha ao atualizar o registro.'),
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
