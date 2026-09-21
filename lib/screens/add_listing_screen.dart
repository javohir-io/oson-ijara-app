import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../data/property_store.dart';
import '../models/picked_image.dart';
import '../models/property.dart';
import '../services/api_exception.dart';
import '../services/auth_store.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/rounded_chip.dart';
import 'edit_profile_screen.dart';

class AddListingScreen extends StatefulWidget {
  /// When non-null, the screen opens pre-filled in "edit" mode for this
  /// property instead of creating a brand new listing.
  final Property? editing;

  const AddListingScreen({super.key, this.editing});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  late final _titleController = TextEditingController(text: widget.editing?.title ?? '');
  late final _descController = TextEditingController(text: widget.editing?.description ?? '');
  late final _priceController = TextEditingController(text: _numToText(widget.editing?.price));
  late final _addressController = TextEditingController(text: widget.editing?.location ?? '');
  late final _amenitiesController = TextEditingController(text: widget.editing?.amenities.join(', ') ?? '');
  late final _areaController = TextEditingController(text: _numToText(widget.editing?.area));
  late final _floorController = TextEditingController(text: widget.editing?.floor.toString() ?? '1');

  late int _bedrooms = widget.editing?.bedrooms ?? 1;
  late int _bathrooms = widget.editing?.bathrooms ?? 1;
  late String _renovation = widget.editing?.renovation ?? "O'rtacha";
  late String _priceUnit = widget.editing?.priceUnit ?? 'Oy';
  late bool _studentFriendly = widget.editing?.studentFriendly ?? false;
  late List<PropertyImage> _existingImages = List.of(widget.editing?.images ?? const []);
  final List<PickedImage> _pendingImages = [];
  bool _submitting = false;

  bool get _isEditing => widget.editing != null;

  static const _renovations = ['Ideal', 'Yaxshi', "O'rtacha", 'Yomon'];
  static const _priceUnits = ['Oy', 'Kun'];

  static String _numToText(num? value) {
    if (value == null) return '';
    return value == value.roundToDouble() ? value.round().toString() : value.toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _amenitiesController.dispose();
    _areaController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true, withData: true);
    if (result == null) return;
    final picked = result.files
        .where((f) => f.bytes != null)
        .map((f) => PickedImage(bytes: f.bytes!, filename: f.name))
        .toList();
    if (picked.isEmpty) return;
    setState(() => _pendingImages.addAll(picked));
  }

  Future<void> _removeExistingImage(PropertyImage image) async {
    try {
      await PropertyStore.instance.deleteImage(widget.editing!.id, image.id);
      if (mounted) setState(() => _existingImages.removeWhere((e) => e.id == image.id));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _pickNumber(String title, int current, ValueChanged<int> onPicked) async {
    int temp = current;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.ivory,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 18),
                  NumberSelectorRow(selected: temp, onChanged: (v) => setSheetState(() => temp = v)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      onPicked(temp);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Tanlash"),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _clearFields() {
    for (final c in [_titleController, _descController, _priceController, _addressController, _amenitiesController, _areaController]) {
      c.clear();
    }
    _floorController.text = '1';
    setState(() {
      _bedrooms = 1;
      _bathrooms = 1;
      _renovation = "O'rtacha";
      _priceUnit = 'Oy';
      _studentFriendly = false;
      _pendingImages.clear();
      _existingImages = [];
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.ivory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("E'lonni o'chirish"),
        content: const Text("Ushbu e'londan butunlay voz kechmoqchimisiz? Bu amalni bekor qilib bo'lmaydi."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Bekor qilish")),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB3261E)),
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      await PropertyStore.instance.deleteProperty(widget.editing!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("E'lon o'chirildi")));
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, sarlavha kiriting")),
      );
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, manzilni kiriting")),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim().replaceAll(' ', '').replaceAll(',', '.'));
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Narxni to'g'ri kiriting")),
      );
      return;
    }
    final area = double.tryParse(_areaController.text.trim().replaceAll(',', '.')) ?? 0;
    final floor = int.tryParse(_floorController.text.trim()) ?? 1;

    final amenities = _amenitiesController.text.trim().isEmpty
        ? const <String>[]
        : _amenitiesController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final payload = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'location': _addressController.text.trim(),
      'price': price,
      'price_unit': _priceUnit,
      'bedrooms': _bedrooms,
      'bathrooms': _bathrooms,
      'floor': floor,
      'area': area,
      'renovation': _renovation,
      'amenities': amenities,
      'student_friendly': _studentFriendly,
    };

    setState(() => _submitting = true);
    try {
      final Property saved;
      if (_isEditing) {
        saved = await PropertyStore.instance.updateProperty(widget.editing!.id, payload);
      } else {
        saved = await PropertyStore.instance.addProperty(payload);
      }

      String? imageWarning;
      if (_pendingImages.isNotEmpty) {
        try {
          await PropertyStore.instance.uploadImages(saved.id, _pendingImages);
        } on ApiException catch (e) {
          imageWarning = "E'lon saqlandi, lekin rasmlarni yuklashda xatolik: ${e.message}";
        }
      }

      if (!mounted) return;
      if (_isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(imageWarning ?? "E'lon yangilandi!")));
        Navigator.of(context).pop();
      } else {
        _clearFields();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(imageWarning ?? "E'lon muvaffaqiyatli joylashtirildi!")),
        );
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: AuthStore.instance,
        builder: (context, _) {
          final user = AuthStore.instance.currentUser;
          return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (_isEditing)
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
                Expanded(
                  child: Center(
                    child: Text(_isEditing ? "E'lonni tahrirlash" : "E'lon berish",
                        style: Theme.of(context).textTheme.displayMedium),
                  ),
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFB3261E)),
                    onPressed: _submitting ? null : _confirmDelete,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            CustomTextField(hint: "Sarlavha qo'shing...", controller: _titleController),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 26),
                margin: EdgeInsets.only(bottom: _existingImages.isEmpty && _pendingImages.isEmpty ? 16 : 10),
                decoration: BoxDecoration(
                  color: AppColors.mist,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.add_photo_alternate_outlined, color: AppColors.oceanBlue, size: 30),
                    SizedBox(height: 8),
                    Text("Uyingizning rasmini joylang", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
            if (_existingImages.isNotEmpty || _pendingImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._existingImages.map(
                        (img) => _imageThumb(
                          key: ValueKey('existing-${img.id}'),
                          child: Image.network(img.url, width: 90, height: 90, fit: BoxFit.cover),
                          onRemove: () => _removeExistingImage(img),
                        ),
                      ),
                      ..._pendingImages.asMap().entries.map(
                            (entry) => _imageThumb(
                              key: ValueKey('pending-${entry.key}'),
                              child: Image.memory(entry.value.bytes, width: 90, height: 90, fit: BoxFit.cover),
                              onRemove: () => setState(() => _pendingImages.removeAt(entry.key)),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            CustomTextField(hint: "Uyingiz haqida yozing", controller: _descController, maxLines: 5),
            const SizedBox(height: 6),
            Text("Tafsilotlar", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _detailField("Manzil", _addressController)),
                const SizedBox(width: 12),
                Expanded(child: _detailField("Qulayliklar (vergul bilan)", _amenitiesController)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _detailField("Maydon (m²)", _areaController, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _detailField("Qavat", _floorController, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SelectableDropdownChip(
                  label: "Ta'mir",
                  value: _renovation,
                  options: _renovations,
                  onSelected: (v) => setState(() => _renovation = v ?? _renovation),
                ),
                SelectableDropdownChip(
                  label: "Narx turi",
                  value: _priceUnit,
                  options: _priceUnits,
                  onSelected: (v) => setState(() => _priceUnit = v ?? _priceUnit),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Talabalar uchun mos", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13.5)),
                Switch(value: _studentFriendly, onChanged: (v) => setState(() => _studentFriendly = v)),
              ],
            ),
            const SizedBox(height: 20),
            Text("Xonalar soni", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickNumber("Yotoq xonalar soni", _bedrooms, (v) => setState(() => _bedrooms = v)),
                    child: Text("Yotoq xonalar: $_bedrooms"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickNumber("Hammomlar soni", _bathrooms, (v) => setState(() => _bathrooms = v)),
                    child: Text("Hammomlar: $_bathrooms"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text("Kontaktlar", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  const Icon(Icons.contact_page_outlined, color: AppColors.oceanBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.fullName ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        Text(
                          (user?.phone == null || user!.phone!.isEmpty) ? "Telefon raqami kiritilmagan" : user.phone!,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    child: const Text("O'zgartirish"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "E'lon shu profil nomi va telefon raqami bilan ko'rinadi.",
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text("Narx", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            CustomTextField(
              hint: "Ijara uchun uyingizning narxini kiriting",
              controller: _priceController,
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : Text(_isEditing ? "Saqlash" : "E'lon joylashtirish"),
            ),
          ],
        ),
      ),
          );
        },
      ),
    );
  }

  Widget _imageThumb({Key? key, required Widget child, required VoidCallback onRemove}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailField(String hint, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13.5),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
