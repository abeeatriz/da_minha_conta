import 'package:da_minha_conta/dao/cartao_dao.dart';
import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/model/cartao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NovaDespesaCartao extends StatefulWidget {
  const NovaDespesaCartao({Key? key}) : super(key: key);

  @override
  NovaDespesaCartaoState createState() => NovaDespesaCartaoState();
}

class NovaDespesaCartaoState extends State<NovaDespesaCartao> {
  final _formKey = GlobalKey<FormState>();
  final _databaseHelper = DatabaseHelper();

  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final List<String> _categorias = ['Essencial', 'Educação', 'Lazer'];

  List<Cartao> _cartoes = [];
  DateTime _data = DateTime.now();
  bool _recorrenciaMensal = false;
  String? _categoriaSelecionada;
  Cartao? _cartaoSelecionado;

  @override
  void initState() {
    super.initState();
    carregarCartoes();
  }

  Future<void> carregarCartoes() async {
    ContaDAO contaDao = ContaDAO(_databaseHelper);
    List<Cartao> cartoesDoBanco = await CartaoDAO(_databaseHelper, contaDao).getCartoes();

    setState(() {
      _cartoes = cartoesDoBanco;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Despesa de Cartão'),
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
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$',
                ),
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
                  Text('Data: ${DateFormat('dd/MM/yyyy').format(_data)}'),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Checkbox(
                    value: _recorrenciaMensal,
                    onChanged: (value) {
                      setState(() {
                        _recorrenciaMensal = value ?? false;
                      });
                    },
                  ),
                  const Text('Recorrência Mensal'),
                ],
              ),
              const SizedBox(height: 16.0),
              // Inserir campo de imagem aqui
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                onChanged: (categoria) {
                  setState(() {
                    _categoriaSelecionada = categoria;
                  });
                },
                items: _categorias.map((categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                ),
                validator: (categoria) {
                  if (categoria == null || categoria.isEmpty) {
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    // Realizar o salvamento da despesa no banco de dados
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
