import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'firebase_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const CatalogoScreen(), const PedidosScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.coffee),
            SizedBox(width: 10),
            Text('Café Express'),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4E342E),
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Mis Pedidos'),
        ],
      ),
    );
  }
}

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: catalogoLocal.length,
      itemBuilder: (context, index) {
        final p = catalogoLocal[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Text(p.imagenIcon, style: const TextStyle(fontSize: 40)),
            title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text('${p.categoria}\n${p.descripcion}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('\$${p.precio}', style: const TextStyle(color: Color(0xFF4E342E), fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrarPedidoScreen(producto: p))),
                  child: const Icon(Icons.add_circle, color: Color(0xFF4E342E)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RegistrarPedidoScreen extends StatefulWidget {
  final Producto producto;
  const RegistrarPedidoScreen({Key? key, required this.producto}) : super(key: key);

  @override
  State<RegistrarPedidoScreen> createState() => _RegistrarPedidoScreenState();
}

class _RegistrarPedidoScreenState extends State<RegistrarPedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  int _cantidad = 1;
  bool _isLoading = false;

  void _guardarPedido() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final pedido = Pedido(
          id: '',
          nombreCliente: _nombreCtrl.text,
          producto: widget.producto.nombre,
          cantidad: _cantidad,
          precioUnitario: widget.producto.precio,
          total: widget.producto.precio * _cantidad,
          observaciones: _obsCtrl.text.isEmpty ? 'Ninguna' : _obsCtrl.text,
          fechaCreacion: DateTime.now(),
          estado: 'Registrado',
        );
        await FirebaseService().registrarPedido(pedido);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Pedido registrado con éxito!')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedir ${widget.producto.nombre}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Tu Nombre', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cantidad:', style: TextStyle(fontSize: 18)),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() { if (_cantidad > 1) _cantidad--; })),
                      Text('$_cantidad', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _cantidad++)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _obsCtrl,
                decoration: const InputDecoration(labelText: 'Observaciones (opcional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 30),
              Text('Total: \$${(widget.producto.precio * _cantidad).toStringAsFixed(2)}', 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)), textAlign: TextAlign.center),
              const SizedBox(height: 30),
              _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _guardarPedido,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                      child: const Text('Confirmar Pedido', style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Pedido>>(
      stream: FirebaseService().obtenerPedidos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No hay pedidos registrados.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final p = snapshot.data![index];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('${p.producto} (x${p.cantidad})', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Cliente: ${p.nombreCliente}\n${DateFormat('dd/MM/yyyy HH:mm').format(p.fechaCreacion)}\nObs: ${p.observaciones}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${p.total}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                    Text(p.estado, style: const TextStyle(color: Colors.orange, fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}