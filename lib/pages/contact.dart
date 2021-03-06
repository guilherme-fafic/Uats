import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:whats_clone/bloc/contacts_bloc.dart';
import 'package:whats_clone/controller/auth_controller.dart';
import 'package:whats_clone/model/contact.dart';

class ContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Contatos'),
          actions: _actions()
        ),
        body: _body(context)
    );
  }

  _actions() {
    return <Widget>[

    ];
  }

  _userNotFoundAlert(context) => AlertDialog(
    title: Text('Usuário não encontrado.'),
    actions: <Widget>[
      FlatButton(
        onPressed: (){
          Navigator.of(context).pop();
        },
        child: Text('OK'),
      )
    ],

  );

  _startChatTile(context) => InkWell(
    onTap: () async {
      String email = await showDialog(
        context: context,
        builder: (buildContext){
          return StartChatDialog();
        }
      );

      if(email != null && email.isNotEmpty && (await Auth.getInstance().getCurrentUser()).email != email){
        final user = await BlocProvider.getBloc<ContactsBloc>().findUser(email);

        if(user != null) {
          Navigator.of(context).pop(user);
        }else{
          showDialog(
              context: context,
              builder: (context) => _userNotFoundAlert(context)
          );
        }
      }
    },
    child: ListTile(
      leading: CircleAvatar(
        child: Padding(
          padding: const EdgeInsets.only(right: 2.0, bottom: 2.0),
          child: Icon(Icons.person_add),
        ),
      ),
      title: Text('Adicionar Contato'),
    ),
  );

  List _functionsTiles(context) => <Widget>[
    _startChatTile(context)
  ];

  _body(context) {
    final contactBloc = BlocProvider.getBloc<ContactsBloc>();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: StreamBuilder(
        initialData: contactBloc.initialData(),
        stream: contactBloc.stream,
        builder: (context, snap) {
          if(snap.hasData) {
            final tiles = _functionsTiles(context);
            return ListView.builder(
              itemCount: snap.data.length + tiles.length,
              itemBuilder: (context, index) {
                if (index < tiles.length) return tiles[index];
                return _contactTile(context, snap.data[index - tiles.length]);
              },
            );
          }else {
            return Center(
              child: CircularProgressIndicator(
                value: null,
              ),
            );
          }
        },
      ),
    );
  }


  _contactTile(context, Contact contact) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(contact);
      },
      child: ListTile(
        leading: CircleAvatar(
          child: Text(contact.name[0]),
        ),
        title: Text(contact.name),
      ),
    );
  }
}



class StartChatDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: (){
                  Navigator.of(context).pop(null);
                },
                icon: Icon(Icons.close),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              alignment: Alignment.centerLeft,
              child: Text('Adicionar Contato', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),)
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email'
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: (){
                    Navigator.of(context).pop(null);
                  },
                  child: Text('CANCELAR'),
                ),
                FlatButton(
                  onPressed: (){
                    Navigator.of(context).pop(_controller.text);
                  },
                  child: Text('INICIAR', style: TextStyle(
                    color: Colors.blue
                  ),),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
