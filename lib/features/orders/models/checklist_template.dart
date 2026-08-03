import 'dart:convert';
import 'package:isar_community/isar.dart';

part 'checklist_template.g.dart';

/// Template checklist nghiệm thu theo loại dịch vụ (máy lạnh, lau nhà, cây cảnh...).
@collection
class ChecklistTemplate {
  Id id = Isar.autoIncrement;

  /// ID record trên Odoo.
  @Index(unique: true)
  late int odooId;

  late String name; // "Kiểm tra máy lạnh 1HP"
  late String serviceType; // 'ac', 'cleaning', 'plant', 'garden', 'other'
  late bool active;
  late DateTime lastSyncAt;
  late bool isPendingSync;

  /// Items được serialize thành JSON string để tránh nested collection.
  late String itemsJson;

  @ignore
  List<ChecklistItem> get items {
    try {
      final list = jsonDecode(itemsJson) as List<dynamic>;
      return list
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  set items(List<ChecklistItem> value) {
    itemsJson = jsonEncode(value.map((e) => e.toJson()).toList());
  }
}

/// Item câu hỏi trong checklist (không phải Isar collection).
class ChecklistItem {
  final int id;
  final int sequence;
  final String questionText;
  final String answerType; // 'checkbox', 'number', 'text', 'dropdown'
  final bool required;
  final String? options; // JSON array cho dropdown

  ChecklistItem({
    required this.id,
    required this.sequence,
    required this.questionText,
    required this.answerType,
    required this.required,
    this.options,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'sequence': sequence,
        'question_text': questionText,
        'answer_type': answerType,
        'required': required,
        'options': options,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    // Safe ID parsing - Odoo có thể trả string hoặc int
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : int.tryParse(rawId.toString()) ?? 0;

    // Safe sequence parsing
    final rawSeq = json['sequence'];
    final sequence = rawSeq is int
        ? rawSeq
        : int.tryParse(rawSeq.toString()) ?? 10;

    // Normalize false to null for optional string fields
    final questionText = json['question_text'];
    final answerType = json['answer_type'];
    final options = json['options'];

    return ChecklistItem(
      id: id,
      sequence: sequence,
      questionText: questionText == false ? '' : (questionText as String?) ?? '',
      answerType: answerType == false ? 'checkbox' : (answerType as String?) ?? 'checkbox',
      required: json['required'] == true,
      options: options == false ? null : (options as String?),
    );
  }
}