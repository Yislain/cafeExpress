import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registrarPedido(Pedido pedido) async {
    await _db.collection('pedidos').add(pedido.toMap());
  }

  Stream<List<Pedido>> obtenerPedidos() {
    return _db.collection('pedidos')
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Pedido.fromFirestore(doc.data(), doc.id))
        .toList());
  }
}