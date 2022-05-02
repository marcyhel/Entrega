
import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:alfred/src/type_handlers/websocket_type_handler.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert' show JSON;

void main() async {

  final app = Alfred();
  var db;

  try{
    db= await Db.create("mongodb+srv://marcyhel:042224@cluster0.wkuub.mongodb.net/myFirstDatabase?retryWrites=true&w=majority");
    await db.open();
  }catch(e){
    print("erro ao abrir o banco de dados");
  }
  app.get('/mg',(req, res)async{
    var dado = [];
    var coll = db.collection('bh_climas');
     await coll.find().forEach((e){
       print(e);
       dado.add({'nome':e['nome'],'cpf':e['cpf'],'email':e['email'],'pass':e['pass']});
     });
    return dado;
  });


  app.get('/mg/:nome',(req, res)async{
    
    req.params['nome'] != null;
    print(req.params['nome']);
    var dado = [];
    var coll = db.collection('bh_climas');
     await coll.find({'nome': req.params['nome']}).forEach((e){
       print(e);
       dado.add({'nome':e['nome'],'cpf':e['cpf'],'email':e['email'],'pass':e['pass']});
     });
    return dado;
  });

  
  app.get('/json', (req, res) => {'json_response': true});

  app.get('/html', (req, res) {
    res.headers.contentType = ContentType.html;
    return '<html><body><h1>Title!</h1></body></html>';
  });


  List<Sala> salas = [];
  var sala = Sala();

  app.get('/ws', (req, res) {
   
    return WebSocketSession(
      onOpen: (wd) {
       print("conect");
        wd.add(sala.clientes.length.toString());

        if (sala.clientes.length < 2) {
          sala.addCliente(wd);
        }
        if (sala.clientes.length == 2) {
          sala.sendAll("pronto");
          sala.escutar();
          salas.add(sala);
          sala = Sala();
        }
      },
      onClose: (wd) {
        //users.remove(ws);
        //users.forEach((user) => user.send('A user has left.'));
      },
      onMessage: (wd, dynamic data) async {
        print(data);
        //users.forEach((user) => user.send(data));
      },
    );
  });
  var port=int.parse(Platform.environment['PORT']??"3000");
  await app.listen(port); //Listening on port 3000
}





class Sala {
  List<WebSocket> clientes = [];
  List<String> nick = [];
  Sala() {}
  void escutar() {
    clientes.forEach((element) {
      element.listen((event) {
        print(event);
        // print("dd");
        sendOthers(event, element);
      });
    });
  }

  void sendOthers(String mensagem, WebSocket exeption) {
    clientes.forEach((element) {
      if (element != exeption) {
        element.add(mensagem);
      }
    });
  }

  void sendAll(String mensagem) {
    clientes.forEach((element) {
      element.add(mensagem);
    });
  }

  void addCliente(cliente) {
    clientes.add(cliente);
  }
}