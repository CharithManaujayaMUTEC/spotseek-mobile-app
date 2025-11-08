import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BulkInvitationScreen extends StatefulWidget {
  final VoidCallback? onBack;
  
  const BulkInvitationScreen({super.key, this.onBack});

  @override
  State<BulkInvitationScreen> createState() => _BulkInvitationScreenState();
}

class _BulkInvitationScreenState extends State<BulkInvitationScreen> {
  String? _selectedInvitationType;
  String? _selectedCategory;
  String? _uploadedFileName;
  File? _uploadedFile; 
  int? _fileSize;
  
  List<List<dynamic>>? _excelData;
  bool _isLoadingPreview = false;
  String? _previewError;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, color: textColor),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              const Text(
                'Bulk Invitation',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          _buildDownloadTemplateButton(),
          
          const SizedBox(height: 32),
          
          _buildDropdownField(
            hint: 'Invitation Type',
            value: _selectedInvitationType,
            items: ['Spotseeker Invitation', 'Special Invitation'],
            onChanged: (value) {
              setState(() {
                _selectedInvitationType = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildDropdownField(
            hint: 'Category',
            value: _selectedCategory,
            items: ['General Invitation', 'VIP Invitation', 'Backstage Invitation'],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildUploadArea(),
                    
          if (_isLoadingPreview) ...[
            const SizedBox(height: 24),
            const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
          ],
          
          if (_previewError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _previewError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          _buildGenerateButton(),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _parseExcelFile(File file) async {
    setState(() {
      _isLoadingPreview = true;
      _previewError = null;
    });

    try {
      print('Starting to parse Excel file...');
      var bytes = await file.readAsBytes();
      print('File bytes read: ${bytes.length}');
      
      var excel = Excel.decodeBytes(bytes);
      print('Excel decoded, number of sheets: ${excel.tables.length}');

      if (excel.tables.isEmpty) {
        throw Exception('No sheets found in the Excel file');
      }

      String sheetName;
      if (excel.tables.containsKey('Bulk Invitation Template')) {
        sheetName = 'Bulk Invitation Template';
      } else {
        var entry = excel.tables.entries.firstWhere((e) => e.value.rows.isNotEmpty, orElse: () => excel.tables.entries.first);
        sheetName = entry.key;
      }

      print('Reading sheet: $sheetName');
      var sheet = excel.tables[sheetName];

      if (sheet == null) {
        throw Exception('Sheet is null');
      }

      print('Sheet rows: ${sheet.rows.length}');
      print('Sheet maxRows: ${sheet.maxRows}');
      print('Sheet maxColumns: ${sheet.maxColumns}');

      if (sheet.rows.isEmpty) {
        throw Exception('Sheet is empty');
      }

      List<List<dynamic>> data = [];
      
      int maxColumns = 0;
      for (var row in sheet.rows) {
        if (row.length > maxColumns) {
          maxColumns = row.length;
        }
      }
      
      print('Max columns found: $maxColumns');
      
      for (var row in sheet.rows) {
        List<dynamic> rowData = [];
        
        for (int i = 0; i < maxColumns; i++) {
          if (i < row.length) {
            var cell = row[i];
            var cellValue = cell?.value;
            
            if (cellValue == null) {
              rowData.add('');
            } else if (cellValue is TextCellValue) {
              rowData.add(cellValue.value.toString());
            } else if (cellValue is IntCellValue) {
              rowData.add(cellValue.value.toString());
            } else if (cellValue is DoubleCellValue) {
              rowData.add(cellValue.value.toString());
            } else if (cellValue is FormulaCellValue) {
              rowData.add(cellValue.formula.toString());
            } else if (cellValue is BoolCellValue) {
              rowData.add(cellValue.value.toString());
            } else if (cellValue is DateCellValue) {
              rowData.add(cellValue.toString());
            } else {
              rowData.add(cellValue.toString());
            }
          } else {
            rowData.add('');
          }
        }
        
        data.add(rowData);
      }

      print('Data parsed successfully: ${data.length} rows x ${data.isNotEmpty ? data[0].length : 0} columns');
      
      if (data.isEmpty) {
        throw Exception('No data found in the sheet');
      }

      setState(() {
        _excelData = data;
        _isLoadingPreview = false;
      });

      print('Excel parsed successfully: ${data.length} rows, ${data[0].length} columns');
    } catch (e, stackTrace) {
      print('Error parsing Excel: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoadingPreview = false;
        _previewError = 'Failed to preview file: ${e.toString()}';
      });
    }
  }

  Widget _buildDownloadTemplateButton() {
    return GestureDetector(
      onTap: () async {
        await _downloadTemplate();
      },
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF221436),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(
                'assets/excel_icon.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Download Bulk Upload Template',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.download,
              color: textColor.withValues(alpha: 0.6),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      print('Android SDK version: $sdkInt');

      if (sdkInt >= 33) {
        return true;
      } else if (sdkInt >= 30) {
        var status = await Permission.manageExternalStorage.status;
        
        if (status.isGranted) {
          return true;
        }
        
        if (!mounted) return false;
        final shouldRequest = await _showPermissionDialog(
          'Storage Access Required',
          'This app needs access to storage to save the template file to your Downloads folder.',
        );
        
        if (!shouldRequest) return false;
        
        status = await Permission.manageExternalStorage.request();
        
        if (status.isPermanentlyDenied) {
          if (!mounted) return false;
          await _showSettingsDialog();
          return false;
        }
        
        return status.isGranted;
      } else {
        var status = await Permission.storage.status;
        
        if (status.isGranted) {
          return true;
        }
        
        if (!mounted) return false;
        final shouldRequest = await _showPermissionDialog(
          'Storage Access Required',
          'This app needs access to storage to save the template file.',
        );
        
        if (!shouldRequest) return false;
        
        status = await Permission.storage.request();
        
        if (status.isPermanentlyDenied) {
          if (!mounted) return false;
          await _showSettingsDialog();
          return false;
        }
        
        return status.isGranted;
      }
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }
    
  Future<bool> _showPermissionDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          title,
          style: const TextStyle(color: textColor),
        ),
        content: Text(
          message,
          style: TextStyle(color: textColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Allow',
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showSettingsDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Permission Required',
          style: TextStyle(color: textColor),
        ),
        content: Text(
          'Storage permission is required to save files. Please enable it in app settings.',
          style: TextStyle(color: textColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadTemplate() async {
    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating template...'),
          duration: Duration(seconds: 1),
        ),
      );

      var excel = Excel.createExcel();
      excel.delete('Sheet1');
      var sheet = excel['Bulk Invitation Template'];
      
      List<String> headers = [
        'Invitation Type',
        'Category',
        'Name',
        'Phone Number',
        'Invitation Count'
      ];
      
      CellStyle headerStyle = CellStyle(
        bold: true,
        fontSize: 12,
        fontColorHex: ExcelColor.white,
        backgroundColorHex: ExcelColor.fromHexString('#E50914'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
      
      for (int i = 0; i < headers.length; i++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }
      
      CellStyle exampleStyle = CellStyle(
        fontSize: 11,
        fontColorHex: ExcelColor.fromHexString('#666666'),
        horizontalAlign: HorizontalAlign.Left,
      );
      
      List<String> example1 = [
        'Spotseeker Invitation',
        'General Invitation',
        'John Doe',
        '94xxxxxxxxx',
        '5'
      ];
      
      for (int i = 0; i < example1.length; i++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
        cell.value = TextCellValue(example1[i]);
        cell.cellStyle = exampleStyle;
      }
      
      List<String> example2 = [
        'Special Invitation',
        'VIP Invitation',
        'Jane Smith',
        '94712345678',
        '3'
      ];
      
      for (int i = 0; i < example2.length; i++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2));
        cell.value = TextCellValue(example2[i]);
        cell.cellStyle = exampleStyle;
      }
      
      var instructionsSheet = excel['Instructions'];
      
      List<String> instructions = [
        'BULK INVITATION UPLOAD INSTRUCTIONS',
        '',
        '1. Invitation Type: Choose either "Spotseeker Invitation" or "Special Invitation"',
        '2. Category: Choose from "General Invitation", "VIP Invitation", or "Backstage Invitation"',
        '3. Name: Enter the full name of the invitee',
        '4. Phone Number: Enter phone number in format 94xxxxxxxxx',
        '5. Invitation Count: Enter a number between 1 and 5 (MAX 5)',
        '',
        'NOTES:',
        '- Do not modify the header row',
        '- Fill all columns for each row',
        '- Maximum file size: 100 MB',
        '- Remove example rows before uploading',
        '- Save file as .xlsx format',
      ];
      
      CellStyle instructionTitleStyle = CellStyle(
        bold: true,
        fontSize: 14,
        fontColorHex: ExcelColor.fromHexString('#E50914'),
      );
      
      CellStyle instructionStyle = CellStyle(
        fontSize: 11,
        fontColorHex: ExcelColor.black,
      );
      
      for (int i = 0; i < instructions.length; i++) {
        var cell = instructionsSheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
        cell.value = TextCellValue(instructions[i]);
        cell.cellStyle = i == 0 ? instructionTitleStyle : instructionStyle;
      }
      
      var fileBytes = excel.save();
      
      if (fileBytes == null) {
        throw Exception('Failed to generate file');
      }
      
      await _downloadForMobile(fileBytes);
      
    } catch (e) {
      print('Error downloading template: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download template: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
 
  Future<void> _downloadForMobile(List<int> fileBytes) async {
    try {
      if (Platform.isAndroid) {
        final hasPermission = await _requestStoragePermission();
        if (!hasPermission) {
          throw Exception('Storage permission is required to save files');
        }
      }
      
      Directory? directory;
      
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        if (sdkInt >= 30) {
          directory = await getExternalStorageDirectory();
          
          if (directory != null) {
            final downloadsPath = Directory('${directory.path}/Download');
            if (!await downloadsPath.exists()) {
              await downloadsPath.create(recursive: true);
            }
            directory = downloadsPath;
          }
        } else {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        throw Exception('Could not access storage directory');
      }
      
      String fileName = 'bulk_invitation_template_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      String filePath = '${directory.path}/$fileName';
      
      File file = File(filePath);
      await file.writeAsBytes(fileBytes);
      
      if (!await file.exists()) {
        throw Exception('File was not created successfully');
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template downloaded successfully!\nSaved to: ${directory.path}/$fileName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      
      print('Template saved to: $filePath');
      print('File size: ${await file.length()} bytes');
      
    } catch (e) {
      print('Error saving file: $e');
      rethrow;
    }
  }
    
  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          width: 1.3,
          color: hintTextColor.withValues(alpha: 0.12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textColor.withValues(alpha: 0.7),
            size: 24,
          ),
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(8),
          elevation: 8,
          style: const TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          menuMaxHeight: 300,
          itemHeight: 48,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  item,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: () async {
        if (_uploadedFileName == null) {
          await _pickFile();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: hintTextColor.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_uploadedFileName == null) ...[
              Text(
                'Upload Bulk File',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              Icon(
                Icons.cloud_upload_outlined,
                color: textColor.withValues(alpha: 0.6),
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Upload up to 1 supported files: Excel, CSV.\nMax 100 MB per file.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFBFBFBF).withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 110,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: Colors.black.withValues(alpha: 0.10),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                            bottomLeft: Radius.zero,
                            bottomRight: Radius.zero,
                          ),
                        ),
                      ),
                        child: _excelData != null && _excelData!.isNotEmpty
                            ? _buildCompactPreview()
                            : Center(
                                child: Icon(
                                  Icons.description_outlined,
                                  size: 48,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: const ShapeDecoration(
                          color: Color(0xFF280929),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.zero,
                              topRight: Radius.zero,
                              bottomLeft: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Image.asset(
                                'assets/excel_icon.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.insert_drive_file_outlined,
                                    color: primaryColor,
                                    size: 24,
                                  );
                                },
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _uploadedFileName!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Opacity(
                                    opacity: 0.60,
                                    child: Text(
                                      _fileSize != null ? _formatFileSize(_fileSize!) : 'Unknown size',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _uploadedFileName = null;
                                  _uploadedFile = null;
                                  _fileSize = null;
                                  _excelData = null;
                                  _previewError = null;
                                });
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: ShapeDecoration(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  shape: const OvalBorder(),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.white.withValues(alpha: 0.6),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
        withData: true,
        withReadStream: false,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        
        if (file.size > 100 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File size exceeds 100 MB limit'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        setState(() {
          _uploadedFileName = file.name;
          _fileSize = file.size;
          
          if (file.path != null) {
            _uploadedFile = File(file.path!);
          }
        });
        
        if (_uploadedFile != null) {
          await _parseExcelFile(_uploadedFile!);
        }
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File uploaded: ${file.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        print('File selected: ${file.name}');
        print('File size: ${_formatFileSize(file.size)}');
        print('File path: ${file.path}');
        
      } else {
        print('File selection canceled');
      }
    } catch (e) {
      print('Error picking file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
    
  Widget _buildGenerateButton() {
    return GestureDetector(
      onTap: () {
        if (_selectedInvitationType == null ||
            _selectedCategory == null ||
            _uploadedFileName == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all fields and upload a file'),
              backgroundColor: primaryColor,
            ),
          );
          return;
        }
        
        print('Generating bulk invitations...');
        print('Type: $_selectedInvitationType');
        print('Category: $_selectedCategory');
        print('File: $_uploadedFileName');
        
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            width: 1,
            color: primaryColor,
          ),
        ),
        child: const Center(
          child: Text(
            'Generate',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.32,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPreview() {
    if (_excelData == null || _excelData!.isEmpty) {
      return Center(
        child: Icon(
          Icons.description_outlined,
          size: 48,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      );
    }

    final headers = _excelData![0];
    final rows = _excelData!.length > 1 ? _excelData!.skip(1).take(2).toList() : <List<dynamic>>[];

    final borderColor = Colors.grey.withOpacity(0.28);

    return SizedBox(
      height: 110,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List<Widget>.generate(headers.length, (colIndex) {
            final headerText = headers[colIndex]?.toString() ?? '';
            final firstRowText = rows.isNotEmpty && colIndex < rows[0].length ? rows[0][colIndex]?.toString() ?? '' : '';
            final secondRowText = rows.length > 1 && colIndex < rows[1].length ? rows[1][colIndex]?.toString() ?? '' : '';

            return Container(
              constraints: const BoxConstraints(minWidth: 120),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
                    child: Text(
                      headerText,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
                    child: Text(
                      firstRowText,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (secondRowText.isNotEmpty)
                    Container(
                      width: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Text(
                        secondRowText,
                        style: const TextStyle(fontSize: 11, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

}