import 'dart:typed_data';

import 'package:flutter/material.dart';

class _FullscreenGallery extends StatefulWidget {
  final List<Uint8List> images;
  final int initialIndex;
  const _FullscreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.images.length,
            itemBuilder: (context, i) => Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: _MemoryImageWithFallback(
                  widget.images[i],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _current ? Colors.white : Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }
}

class GaleriaImagenes extends StatefulWidget {
  final List<Uint8List> imagenesBytes;
  final PageController controller;
  final void Function(int index)? onDelete;
  final bool editable;
  const GaleriaImagenes({
    required this.imagenesBytes,
    required this.controller,
    this.onDelete,
    this.editable = false,
  });

  @override
  State<GaleriaImagenes> createState() => _GaleriaImagenesState();
}

class _GaleriaImagenesState extends State<GaleriaImagenes> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final count = widget.imagenesBytes.length;
    if (count == 0) {
      return Container(
        color: Colors.black12,
        alignment: Alignment.center,
        child: const Text('Sin imágenes'),
      );
    }
    return Stack(
      children: [
        PageView.builder(
          controller: widget.controller,
          onPageChanged: (i) => setState(() => index = i),
          itemCount: count,
          itemBuilder: (context, i) => GestureDetector(
            onTap: () => _openFullScreen(i),
            child: _MemoryImageWithFallback(
              widget.imagenesBytes[i],
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (widget.editable && widget.onDelete != null)
          Positioned(
            top: 8,
            left: 8,
            child: Tooltip(
              message: 'Eliminar imagen',
              child: IconButton.filled(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.black54),
                ),
                onPressed: () => widget.onDelete!(index),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _go(-1),
            icon: const Icon(Icons.chevron_left, size: 36),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _go(1),
            icon: const Icon(Icons.chevron_right, size: 36),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              count,
              (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == index ? Colors.white : Colors.white54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _go(int delta) {
    final total = widget.imagenesBytes.length;
    if (total == 0) return;
    final next = (index + delta) % total;
    setState(() => index = (next + total) % total);
    widget.controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }
}

class _MemoryImageWithFallback extends StatelessWidget {
  final Uint8List bytes;

  final BoxFit fit;
  const _MemoryImageWithFallback(this.bytes, {this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      bytes,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset('assets/trial.png', fit: fit);
      },
    );
  }
}

extension on _GaleriaImagenesState {
  void _openFullScreen(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenGallery(
          images: widget.imagenesBytes,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}
