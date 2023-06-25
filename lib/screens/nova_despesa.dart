import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NovaDespesa extends StatefulWidget {
  @override
  _NovaDespesaState createState() => _NovaDespesaState();
}

class _NovaDespesaState extends State<NovaDespesa> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _descricaoController = TextEditingController();
  TextEditingController _valorController = TextEditingController();
  String? _contaSelecionada;
  String? _cartaoSelecionado;
  DateTime? _dataSelecionada;
  File? _imagemSelecionada;

  List<String> _contas = [
    'Conta 1',
    'Conta 2',
    'Conta 3'
  ]; // Exemplo de lista de contas
  List<String> _cartoes = [
    'Cartão 1',
    'Cartão 2',
    'Cartão 3'
  ]; // Exemplo de lista de cartões

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Processar o formulário
      // Aqui você pode salvar os dados no banco de dados ou realizar outras ações necessárias
      // Você pode acessar os valores dos campos usando os controladores ou as variáveis de estado (_descricaoController.text, _valorController.text, etc.)
      // Também pode acessar a imagem selecionada (_imagemSelecionada)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Despesa'),
        backgroundColor: Colors.red[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _descricaoController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma descrição';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _valorController,
                  decoration: InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um valor';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Conta'),
                  value: _contaSelecionada,
                  onChanged: (value) {
                    setState(() {
                      _contaSelecionada = value;
                    });
                  },
                  items: _contas.map((conta) {
                    return DropdownMenuItem<String>(
                      value: conta,
                      child: Text(conta),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione uma conta';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Cartão'),
                  value: _cartaoSelecionado,
                  onChanged: (value) {
                    setState(() {
                      _cartaoSelecionado = value;
                    });
                  },
                  items: _cartoes.map((cartao) {
                    return DropdownMenuItem<String>(
                      value: cartao,
                      child: Text(cartao),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione um cartão';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dataSelecionada != null
                            ? 'Data selecionada: ${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}'
                            : 'Nenhuma data selecionada',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
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
                      icon: Icon(Icons.image),
                      onPressed: _selectImage,
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
