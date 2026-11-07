class Producto {
  final String nombre, descripcion, categoria;
  final double precio;
  final String imagenIcon;

  Producto(this.nombre, this.descripcion, this.categoria, this.precio, this.imagenIcon);
}

class Pedido {
  final String id, nombreCliente, producto, observaciones, estado;
  final int cantidad;
  final double precioUnitario, total;
  final DateTime fechaCreacion;

  Pedido({
    required this.id, required this.nombreCliente, required this.producto,
    required this.cantidad, required this.precioUnitario, required this.total,
    required this.observaciones, required this.fechaCreacion, required this.estado,
  });

  Map<String, dynamic> toMap() => {
    'nombreCliente': nombreCliente,
    'producto': producto,
    'cantidad': cantidad,
    'precioUnitario': precioUnitario,
    'total': total,
    'observaciones': observaciones,
    'fechaCreacion': fechaCreacion.toIso8601String(),
    'estado': estado,
  };

  factory Pedido.fromFirestore(Map<String, dynamic> data, String id) {
    return Pedido(
      id: id,
      nombreCliente: data['nombreCliente'] ?? '',
      producto: data['producto'] ?? '',
      cantidad: data['cantidad'] ?? 1,
      precioUnitario: (data['precioUnitario'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      observaciones: data['observaciones'] ?? '',
      fechaCreacion: DateTime.parse(data['fechaCreacion']),
      estado: data['estado'] ?? 'Registrado',
    );
  }
}

// Datos locales de prueba solicitados
final List<Producto> catalogoLocal = [
  Producto('Café Americano', 'Clásico café negro', 'Caliente', 35.0, '☕'),
  Producto('Capuchino', 'Espresso con leche espumada', 'Caliente', 55.0, '☕'),
  Producto('Frappé Mocha', 'Café helado con chocolate', 'Frío', 75.0, '🥤'),
  Producto('Croissant', 'Pan hojaldrado de mantequilla', 'Alimentos', 40.0, '🥐'),
];