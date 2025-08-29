import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf_convertor/services/pdf_security_service.dart';

class PdfPasswordScreen extends StatefulWidget {
  const PdfPasswordScreen({super.key});

  @override
  State<PdfPasswordScreen> createState() => _PdfPasswordScreenState();
}

class _PdfPasswordScreenState extends State<PdfPasswordScreen> {
  final _formAdd = GlobalKey<FormState>();
  final _formRemove = GlobalKey<FormState>();

  // Add password controllers
  final _userPwdCtrl = TextEditingController();
  final _ownerPwdCtrl = TextEditingController();
  bool _allowPrinting = false;
  bool _allowCopy = false;

  // Remove password controllers
  final _currentPwdCtrl = TextEditingController();

  bool _busyAdd = false;
  bool _busyRemove = false;

  String? _lastOutputPath;

  @override
  void dispose() {
    _userPwdCtrl.dispose();
    _ownerPwdCtrl.dispose();
    _currentPwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (!_formAdd.currentState!.validate()) return;
    setState(() => _busyAdd = true);

    final file = await PdfSecurityService.addPasswordToPdf(
      userPassword: _userPwdCtrl.text.trim(),
      ownerPassword: _ownerPwdCtrl.text.trim().isEmpty
          ? null
          : _ownerPwdCtrl.text.trim(),
      allowPrinting: _allowPrinting,
      allowCopy: _allowCopy,
    );

    setState(() {
      _busyAdd = false;
      _lastOutputPath = file?.path;
    });

    if (file == null && mounted) {
      _showSnack('Failed to secure PDF (cancelled or error).');
    } else if (mounted) {
      _showSnack('Secured PDF saved.');
    }
  }

  Future<void> _handleRemove() async {
    if (!_formRemove.currentState!.validate()) return;
    setState(() => _busyRemove = true);

    final file = await PdfSecurityService.removePasswordFromPdf(
      currentPassword: _currentPwdCtrl.text.trim(),
    );

    setState(() {
      _busyRemove = false;
      _lastOutputPath = file?.path;
    });

    if (file == null && mounted) {
      _showSnack('Failed to remove password (wrong password or error).');
    } else if (mounted) {
      _showSnack('Unlocked PDF saved.');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('PDF Password Protection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== Add Password Card =====
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formAdd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Password',
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Pick a PDF, set a password (AES-256). Optional owner password lets you change permissions later.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _userPwdCtrl,
                        decoration: const InputDecoration(
                          labelText: 'User Password *',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter a password';
                          }
                          if (v.trim().length < 4) {
                            return 'Use at least 4 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ownerPwdCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Owner Password (optional)',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Allow Printing'),
                              value: _allowPrinting,
                              onChanged: (v) =>
                                  setState(() => _allowPrinting = v ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Allow Copy'),
                              value: _allowCopy,
                              onChanged: (v) =>
                                  setState(() => _allowCopy = v ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _busyAdd ? null : _handleAdd,
                          icon: const Icon(Icons.lock),
                          label: _busyAdd
                              ? const Text('Securing...')
                              : const Text('Pick PDF & Add Password'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ===== Remove Password Card =====
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formRemove,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Remove Password',
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Pick a protected PDF and enter its current password to remove protection.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _currentPwdCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Current Password *',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Enter the current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _busyRemove ? null : _handleRemove,
                          icon: const Icon(Icons.lock_open),
                          label: _busyRemove
                              ? const Text('Unlocking...')
                              : const Text('Pick PDF & Remove Password'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_lastOutputPath != null)
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _lastOutputPath!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Open',
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => OpenFilex.open(_lastOutputPath!),
                      ),
                      IconButton(
                        tooltip: 'Share',
                        icon: const Icon(Icons.share),
                        onPressed: () => Share.shareXFiles(
                          [XFile(_lastOutputPath!)],
                          text: 'Here is your processed PDF',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
