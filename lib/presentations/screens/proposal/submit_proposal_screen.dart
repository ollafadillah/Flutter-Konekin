import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../providers/proposal_provider.dart';

class SubmitProposalScreen extends StatefulWidget {
  final String projectId;
  const SubmitProposalScreen({super.key, required this.projectId});

  @override
  State<SubmitProposalScreen> createState() => _SubmitProposalScreenState();
}

class _SubmitProposalScreenState extends State<SubmitProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _bidAmountController = TextEditingController();
  final _coverLetterController = TextEditingController();
  final _portfolioLinkController = TextEditingController();
  final _estimatedDaysController = TextEditingController();

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final proposalData = {
      'projectId': widget.projectId,
      'bidAmount': double.parse(_bidAmountController.text),
      'coverLetter': _coverLetterController.text,
      'portfolioLink': _portfolioLinkController.text.isNotEmpty 
          ? _portfolioLinkController.text 
          : null,
      'estimatedDays': int.parse(_estimatedDaysController.text),
    };
    
    final provider = Provider.of<ProposalProvider>(context, listen: false);
    final success = await provider.submitProposal(proposalData);
    
    if (mounted) {
      if (success) {
        Helpers.showSuccess(context, 'Proposal berhasil dikirim');
        Navigator.pop(context, true);
      } else {
        Helpers.showError(context, provider.errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProposalProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajukan Proposal'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HARGA PENAWARAN',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bidAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '0',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Harga harus diisi';
                        if (double.tryParse(value) == null) return 'Masukkan angka valid';
                        if (double.parse(value) <= 0) return 'Harga harus lebih dari 0';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Estimated Days
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMASI WAKTU PENGERJAAN',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _estimatedDaysController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Jumlah hari',
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Harus diisi';
                              if (int.tryParse(value) == null) return 'Masukkan angka';
                              if (int.parse(value) <= 0) return 'Minimal 1 hari';
                              return null;
                            },
                          ),
                        ),
                        const Text('hari', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Cover Letter
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SURAT PENAWARAN',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _coverLetterController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: 'Jelaskan mengapa Anda cocok untuk proyek ini...',
                        border: InputBorder.none,
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Surat penawaran harus diisi';
                        if (value.length < 50) return 'Minimal 50 karakter';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Portfolio Link (Optional)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LINK PORTOFOLIO (Opsional)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _portfolioLinkController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        hintText: 'https://portofolio-anda.com',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.link, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Tips Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: AppTheme.warningColor),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tips: Tawarkan harga yang kompetitif dan jelaskan pengalaman Anda secara detail untuk meningkatkan peluang diterima.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: provider.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Kirim Proposal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}