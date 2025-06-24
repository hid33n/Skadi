import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/barcode_scanner_service.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../models/product.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
// Importar dart:html solo en web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final BarcodeScannerService _scannerService = BarcodeScannerService();
  MobileScannerController? _scannerController;
  bool _isScanning = true;
  bool _isProcessing = false;
  String? _lastScannedCode;
  bool _scannerReady = false;
  String? _scannerError;
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Si es móvil o web móvil, inicializar el escáner automáticamente
    if (_shouldShowCameraButton()) {
      _initializeScanner();
    }
    // Enfocar el campo de texto automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _barcodeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    super.dispose();
  }

  bool _isMobile() {
    if (kIsWeb) {
      // Detección básica de web móvil
      final userAgent = html.window.navigator.userAgent.toLowerCase();
      return userAgent.contains('android') || userAgent.contains('iphone') || userAgent.contains('ipad');
    } else {
      return Platform.isAndroid || Platform.isIOS;
    }
  }

  bool _shouldShowCameraButton() {
    // Mostrar botón de cámara en móvil nativo o web móvil
    return _isMobile();
  }

  Future<void> _initializeScanner() async {
    try {
      final hasPermission = await _scannerService.requestCameraPermission();
      if (!hasPermission) {
        if (mounted) {
          setState(() {
            _scannerError = 'Permiso de cámara denegado.';
          });
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permiso de cámara requerido'),
              content: Text(kIsWeb
                  ? 'Debes permitir el acceso a la cámara en tu navegador para escanear códigos de barras. Si ya lo negaste, revisa la configuración del sitio.'
                  : 'Debes permitir el acceso a la cámara para escanear códigos de barras.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        }
        return;
      }

      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      if (mounted) {
        setState(() {
          _scannerReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scannerError = 'Error al inicializar la cámara: \\n${e.toString()}';
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error al inicializar la cámara'),
            content: Text('Ocurrió un error al intentar acceder a la cámara.\n\n${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || !_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null || barcode.rawValue == _lastScannedCode) return;

    setState(() {
      _isProcessing = true;
      _lastScannedCode = barcode.rawValue;
    });

    _processBarcode(barcode.rawValue!);
  }

  Future<void> _processBarcode(String barcode) async {
    try {
      // Verificar si el producto ya existe
      final existingProducts = context.read<ProductViewModel>().products;
      final existingProduct = _scannerService.getProductByBarcode(barcode, existingProducts);

      if (existingProduct != null) {
        // Producto ya existe - mostrar información
        _showExistingProductDialog(existingProduct);
      } else {
        // Producto nuevo - obtener información y crear
        await _createNewProductFromBarcode(barcode);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Error procesando código de barras: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showExistingProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Producto Encontrado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${product.name}'),
            const SizedBox(height: 8),
            Text('Precio: \$${product.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Stock: ${product.stock}'),
            const SizedBox(height: 8),
            Text('Código: ${product.barcode}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(product);
            },
            child: const Text('Seleccionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewProductFromBarcode(String barcode) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Obteniendo información del producto...'),
            ],
          ),
        ),
      );

      // Obtener información del producto
      final productInfo = await _scannerService.getProductInfoFromBarcode(barcode);
      
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo de carga
      }

      if (productInfo != null) {
        // Mostrar formulario para completar información
        _showProductFormDialog(barcode, productInfo);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo de carga
        CustomSnackBar.showError(
          context: context,
          message: 'Error obteniendo información del producto: ${e.toString()}',
        );
      }
    }
  }

  void _showProductFormDialog(String barcode, Map<String, dynamic> productInfo) {
    final nameController = TextEditingController(text: productInfo['name'] ?? '');
    final descriptionController = TextEditingController(text: productInfo['description'] ?? '');
    final priceController = TextEditingController(
      text: (productInfo['suggested_price'] as num?)?.toString() ?? '0.0'
    );
    final stockController = TextEditingController(text: '0');
    final minStockController = TextEditingController(text: '5');
    final maxStockController = TextEditingController(text: '100');

    String? selectedCategoryId;
    final categories = context.read<CategoryViewModel>().categories;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuevo Producto Escaneado'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Código de barras: $barcode'),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio *',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Inicial',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: minStockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Mínimo',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: maxStockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock Máximo',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Categoría *',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedCategoryId,
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty || selectedCategoryId == null) {
                  CustomSnackBar.showError(
                    context: context,
                    message: 'Por favor completa los campos requeridos',
                  );
                  return;
                }

                try {
                  final product = Product(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    price: double.tryParse(priceController.text) ?? 0.0,
                    stock: int.tryParse(stockController.text) ?? 0,
                    minStock: int.tryParse(minStockController.text) ?? 5,
                    maxStock: int.tryParse(maxStockController.text) ?? 100,
                    categoryId: selectedCategoryId!,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    barcode: barcode,
                    imageUrl: productInfo['image_url'],
                    attributes: productInfo['attributes'],
                  );

                  final success = await context.read<ProductViewModel>().addProduct(product);
                  
                  if (success && mounted) {
                    Navigator.of(context).pop(); // Cerrar formulario
                    Navigator.of(context).pop(product); // Retornar producto creado
                    
                    CustomSnackBar.showSuccess(
                      context: context,
                      message: 'Producto creado exitosamente',
                    );
                  }
                } catch (e) {
                  CustomSnackBar.showError(
                    context: context,
                    message: 'Error creando producto: ${e.toString()}',
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _onBarcodeSubmitted(String barcode) {
    if (barcode.trim().isEmpty) return;
    _processBarcode(barcode.trim());
    _barcodeController.clear();
    _barcodeFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código de Barras'),
        actions: [
          if (_shouldShowCameraButton() && _scannerError != null)
            IconButton(
              icon: const Icon(Icons.camera_alt),
              tooltip: 'Reintentar escanear con cámara',
              onPressed: () async {
                setState(() {
                  _scannerReady = false;
                  _scannerError = null;
                });
                await _initializeScanner();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _barcodeController,
              focusNode: _barcodeFocusNode,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Escanea o ingresa el código de barras',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code_scanner),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: _onBarcodeSubmitted,
              onEditingComplete: () => _onBarcodeSubmitted(_barcodeController.text),
            ),
            const SizedBox(height: 24),
            if (_scannerError != null && _shouldShowCameraButton())
              Text(_scannerError!, style: const TextStyle(color: Colors.red)),
            if (_scannerReady && _shouldShowCameraButton())
              Expanded(
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                ),
              ),
            if (!_scannerReady && _shouldShowCameraButton() && _scannerError == null)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 16),
            const Text(
              'Coloca el código de barras dentro del marco o usa un lector USB para escanear.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final scanAreaSize = size.width * 0.7;
    final scanAreaRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize * 0.6,
    );

    // Dibujar esquinas del marco de escaneo
    const cornerLength = 30.0;
    const cornerThickness = 4.0;

    // Esquina superior izquierda
    canvas.drawLine(
      Offset(scanAreaRect.left, scanAreaRect.top + cornerLength),
      Offset(scanAreaRect.left, scanAreaRect.top),
      paint..strokeWidth = cornerThickness,
    );
    canvas.drawLine(
      Offset(scanAreaRect.left, scanAreaRect.top),
      Offset(scanAreaRect.left + cornerLength, scanAreaRect.top),
      paint..strokeWidth = cornerThickness,
    );

    // Esquina superior derecha
    canvas.drawLine(
      Offset(scanAreaRect.right - cornerLength, scanAreaRect.top),
      Offset(scanAreaRect.right, scanAreaRect.top),
      paint..strokeWidth = cornerThickness,
    );
    canvas.drawLine(
      Offset(scanAreaRect.right, scanAreaRect.top),
      Offset(scanAreaRect.right, scanAreaRect.top + cornerLength),
      paint..strokeWidth = cornerThickness,
    );

    // Esquina inferior izquierda
    canvas.drawLine(
      Offset(scanAreaRect.left, scanAreaRect.bottom - cornerLength),
      Offset(scanAreaRect.left, scanAreaRect.bottom),
      paint..strokeWidth = cornerThickness,
    );
    canvas.drawLine(
      Offset(scanAreaRect.left, scanAreaRect.bottom),
      Offset(scanAreaRect.left + cornerLength, scanAreaRect.bottom),
      paint..strokeWidth = cornerThickness,
    );

    // Esquina inferior derecha
    canvas.drawLine(
      Offset(scanAreaRect.right - cornerLength, scanAreaRect.bottom),
      Offset(scanAreaRect.right, scanAreaRect.bottom),
      paint..strokeWidth = cornerThickness,
    );
    canvas.drawLine(
      Offset(scanAreaRect.right, scanAreaRect.bottom - cornerLength),
      Offset(scanAreaRect.right, scanAreaRect.bottom),
      paint..strokeWidth = cornerThickness,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 