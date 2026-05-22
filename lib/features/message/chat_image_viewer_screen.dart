import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class ChatImageViewerScreen extends StatefulWidget {
  const ChatImageViewerScreen({super.key, 
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<ChatImageViewerScreen> createState() => _ChatImageViewerScreenState();
}

class _ChatImageViewerScreenState extends State<ChatImageViewerScreen> {
  bool _isSaving = false;
  bool _isSharing = false;
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  Future<void> _saveImageToGallery() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final File cachedFile = await _getCachedImageFile();
      final Uint8List bytes = await cachedFile.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Cached image is empty.');
      }

      final Map<dynamic, dynamic>? result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: 'chat_image_${DateTime.now().millisecondsSinceEpoch}',
      );

      final dynamic isSuccess = result?['isSuccess'] ?? result?['success'];
      if (isSuccess == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery.')),
        );
      } else {
        throw Exception('Failed to save image to gallery.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  Future<File> _getCachedImageFile() async {
    return DefaultCacheManager().getSingleFile(widget.imageUrl);
  }

  Future<void> _shareImage() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final File cachedFile = await _getCachedImageFile();
      final XFile file = XFile(cachedFile.path);

      final RenderBox? box = context.findRenderObject() as RenderBox?;
      final Rect? shareOrigin = box != null && box.hasSize
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await Share.shareXFiles(
        <XFile>[file],
        text: 'Shared from Crew Support',
        sharePositionOrigin: shareOrigin,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _showImageActions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.download_rounded, color: Colors.white),
                title: const Text(
                  'Save to gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _saveImageToGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: Colors.white),
                title: const Text(
                  'Share image',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _shareImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;

    final Matrix4 current = _transformationController.value;
    final bool isZoomed = current != Matrix4.identity();

    if (isZoomed) {
      _transformationController.value = Matrix4.identity();
      return;
    }

    final Offset position = _doubleTapDetails!.localPosition;
    const double scale = 2.5;

    _transformationController.value = Matrix4.identity()
      ..translate(-position.dx * (scale - 1), -position.dy * (scale - 1))
      ..scale(scale);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isSharing ? null : _shareImage,
            icon: _isSharing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.share_rounded),
            tooltip: 'Share image',
          ),
          IconButton(
            onPressed: _isSaving ? null : _saveImageToGallery,
            icon: _isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.download_rounded),
            tooltip: 'Save to gallery',
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragEnd: (details) {
            final bool isZoomed = _transformationController.value != Matrix4.identity();
            if (!isZoomed && (details.primaryVelocity ?? 0) > 500) {
              Navigator.of(context).maybePop();
            }
          },
          onDoubleTapDown: (details) {
            _doubleTapDetails = details;
          },
          onDoubleTap: _handleDoubleTap,
          onLongPress: _showImageActions,
          child: Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.8,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.contain,
                progressIndicatorBuilder: (ctx, url, downloadProgress) {
                  return Center(
                    child: SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: downloadProgress.progress,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorWidget: (ctx, url, error) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white70,
                          size: 42,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Unable to load image',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}