import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/bill_entity.dart';
import 'package:uuid/uuid.dart';

class AIService {
  static Future<BillEntity> analyzeBill(String imagePath) async {
    final apiKey = dotenv.get('GEMINI_API_KEY', fallback: '');
    
    if (apiKey.isEmpty || apiKey == 'your_api_key_here') {
      throw Exception('Gemini API Key is not set! Please add your key to the .env file.');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    final imageBytes = await File(imagePath).readAsBytes();
    
    final prompt = [
      Content.multi([
        TextPart('''
          Analyze this image and determine if it is a shopping receipt or bill. 
          If it is NOT a bill or receipt, return exactly: {"error": "not_a_bill"}.
          
          If it is a bill, extract the following information and return it in a strictly valid JSON format:
          {
            "shopName": "Name of the store",
            "date": "ISO8601 date string",
            "totalAmount": 123.45,
            "category": "Suggested category (e.g., Food, Shopping, Groceries, Travel, Entertainment)",
            "notes": "Brief summary",
            "items": [
              {
                "itemName": "Name of item",
                "quantity": 1,
                "price": 10.0,
                "total": 10.0
              }
            ]
          }
          
          Ensure the totalAmount and item totals are numbers, not strings.
          Extract as many items as clearly readable.
        '''),
        DataPart('image/jpeg', imageBytes),
      ]),
    ];

    try {
      final response = await model.generateContent(prompt);
      final text = response.text;
      
      if (text == null) throw Exception('Empty response from AI');
      
      // Clean the response text (remove markdown code blocks if any)
      final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);
      
      if (data.containsKey('error') && data['error'] == 'not_a_bill') {
        throw Exception('This image does not appear to be a valid bill or receipt.');
      }

      return BillEntity(
        id: const Uuid().v4(),
        shopName: data['shopName'] ?? 'Unknown Shop',
        date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
        totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
        category: data['category'] ?? 'General',
        imagePath: imagePath,
        items: (data['items'] as List? ?? []).map((item) {
          return BillItemEntity(
            id: const Uuid().v4(),
            itemName: item['itemName'] ?? 'Unknown Item',
            quantity: item['quantity'] ?? 1,
            price: (item['price'] ?? 0.0).toDouble(),
            total: (item['total'] ?? 0.0).toDouble(),
          );
        }).toList(),
        notes: data['notes'],
      );
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Failed to parse AI response. The image might be too blurry or not a receipt.');
      }
      rethrow;
    }
  }
}
