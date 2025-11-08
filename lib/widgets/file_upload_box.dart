import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spotseeker_app/utils/colors.dart';

class FileUploadBox extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> allowedExtensions;
  final int maxSizeMB;
  final Function(File file)? onFilePicked;
  final Function()? onFileRemoved;
  final File? initialFile;

  const FileUploadBox({
    super.key,
    required this.title,
    this.subtitle,
    this.allowedExtensions = const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    this.maxSizeMB = 10,
    this.onFilePicked,
    this.onFileRemoved,
    this.initialFile,
  });

  @override
  State<FileUploadBox> createState() => _FileUploadBoxState();
}

class _FileUploadBoxState extends State<FileUploadBox> {
  File? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
  }

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        
        // Check file size
        final fileSizeInBytes = await file.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        
        if (fileSizeInMB > widget.maxSizeMB) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File size must be less than ${widget.maxSizeMB}MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() => _selectedFile = file);
        widget.onFilePicked?.call(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removeFile() {
    setState(() => _selectedFile = null);
    widget.onFileRemoved?.call();
  }

  String _getFileName() {
    if (_selectedFile == null) return '';
    return _selectedFile!.path.split('/').last;
  }

  String _getFileSize() {
    if (_selectedFile == null) return '';
    final bytes = _selectedFile!.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isLoading ? null : _pickFile,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: _selectedFile != null
                ? Colors.green.withValues(alpha: 0.5)
                : Colors.deepPurple.shade300.withValues(alpha: 0.4),
          ),
        ),
        child: _selectedFile == null
            ? _buildUploadPrompt()
            : _buildFilePreview(),
      ),
    );
  }

  Widget _buildUploadPrompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: textColor, fontSize: 14),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            ),
          )
        else
          const Icon(Icons.cloud_upload_outlined, color: hintTextColor, size: 40),
        const SizedBox(height: 10),
        Text(
          widget.subtitle ??
              'Upload 1 supported file: ${widget.allowedExtensions.join(', ').toUpperCase()}. Max ${widget.maxSizeMB}MB.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: hintTextColor, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildFilePreview() {
    final fileName = _getFileName();
    final fileSize = _getFileSize();
    final extension = fileName.split('.').last.toLowerCase();
    
    IconData fileIcon;
    Color iconColor;
    
    if (extension == 'pdf') {
      fileIcon = Icons.picture_as_pdf;
      iconColor = Colors.red;
    } else if (['doc', 'docx'].contains(extension)) {
      fileIcon = Icons.description;
      iconColor = Colors.blue;
    } else if (['jpg', 'jpeg', 'png'].contains(extension)) {
      fileIcon = Icons.image;
      iconColor = Colors.green;
    } else {
      fileIcon = Icons.insert_drive_file;
      iconColor = Colors.grey;
    }

    return Row(
      children: [
        Icon(fileIcon, color: iconColor, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: const TextStyle(color: textColor, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                fileSize,
                style: const TextStyle(color: hintTextColor, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: _removeFile,
        ),
      ],
    );
  }
}
