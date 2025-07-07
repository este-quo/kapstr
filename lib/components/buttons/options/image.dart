import 'package:flutter/material.dart';

class ImageOptionButton extends StatefulWidget {
  final String title;
  final String initialImagePath;
  final ValueChanged<String> onImageSelected;

  const ImageOptionButton({
    super.key,
    required this.title,
    required this.initialImagePath,
    required this.onImageSelected,
  });

  @override
  _ImageOptionButtonState createState() => _ImageOptionButtonState();
}

class _ImageOptionButtonState extends State<ImageOptionButton> {
  late String selectedImagePath;

  @override
  void initState() {
    super.initState();
    selectedImagePath = widget.initialImagePath;
  }

  Future<void> _selectImage() async {
    widget.onImageSelected(""); // Appel du callback pour notifier le changement
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectImage,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: selectedImagePath.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.initialImagePath),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: selectedImagePath.isEmpty ? Colors.grey[300] : null,
              ),
              child: selectedImagePath.isEmpty ? const Icon(Icons.image, color: Colors.grey) : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
