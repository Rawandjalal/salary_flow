import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class AiService {
  /// Calls the Gemini API to get a chat response
  static Future<String> getGeminiChatResponse({
    required String apiKey,
    required String userMessage,
    required List<Map<String, String>> chatHistory,
    required List<Transaction> transactions,
    required String activeScope,
  }) async {
    if (apiKey.isEmpty) {
      return _getLocalFallbackChat(userMessage, activeScope);
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    // Formulate transaction summary for context
    final txSummary = transactions.map((t) {
      return '${t.date.toIso8601String().split('T')[0]}: ${t.scope.toUpperCase()} - ${t.isIncome ? 'INCOME' : 'EXPENSE'} - ${t.category} - ${t.amount} ${t.currency} (${t.title})';
    }).join('\n');

    final systemInstruction = 
      'You are a professional financial advisor and business analyst for the application SalaryFlow. '
      'The user is managing their budgets in USD and IQD. '
      'Current active view scope: $activeScope. '
      'Here is the user\'s transaction ledger data for context:\n$txSummary\n\n'
      'CRITICAL: Answer in Kurdish (Soranî dialect written in Arabic script) in a friendly, professional tone. '
      'If the user asks a question in English or Arabic, you can write the analysis in Kurdish but keep key terms understandable. '
      'Give highly practical money-saving advice, business optimization steps, and budget insights.';

    // Construct request body with history
    final List<Map<String, dynamic>> contents = [];

    // Map history to Gemini format (role must be 'user' or 'model')
    for (final msg in chatHistory) {
      contents.add({
        'role': msg['sender'] == 'user' ? 'user' : 'model',
        'parts': [{'text': msg['text']}]
      });
    }

    // Add current user message
    contents.add({
      'role': 'user',
      'parts': [{'text': userMessage}]
    });

    final body = {
      'contents': contents,
      'systemInstruction': {
        'parts': [{'text': systemInstruction}]
      },
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 800,
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        return text;
      } else {
        final errData = jsonDecode(response.body);
        final errMsg = errData['error']['message'] ?? 'Unknown API error';
        return 'تکایە ببوورە، هەڵەیەک ڕوویدا لە پەیوەندیکردن بە سێرڤەر: $errMsg';
      }
    } catch (e) {
      return 'تکایە ببوورە، ناتوانم وەڵامت بدەمەوە لەبەر نەبوونی هێڵی ئینتەرنێت یان کێشەی سیستەم: $e';
    }
  }

  /// Returns a free, unlimited image generation URL from Pollinations.ai
  static String getPollinationsImageUrl(String prompt, String style) {
    final fullPrompt = '$prompt, high resolution, digital art, $style';
    final encoded = Uri.encodeComponent(fullPrompt);
    // Seed and nologo flags to ensure clean outputs
    final seed = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'https://image.pollinations.ai/prompt/$encoded?width=768&height=768&nologo=true&seed=$seed';
  }

  /// Generates a podcast/debate script in Kurdish between 2 or 3 characters using Gemini
  static Future<List<Map<String, String>>> generateKurdishDebateScript({
    required String apiKey,
    required String topic,
    required List<String> speakers,
    required List<Transaction> transactions,
  }) async {
    if (apiKey.isEmpty) {
      return _getLocalFallbackDebate(topic, speakers);
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final txSummary = transactions.take(15).map((t) {
      return '${t.category}: ${t.amount} ${t.currency} (${t.title})';
    }).join(', ');

    final prompt = 
      'Write a scripted podcast dialogue in Kurdish (Soranî dialect) about the topic: "$topic".\n'
      'The speakers are: ${speakers.join(', ')}.\n'
      'Some transactions context to debate: $txSummary.\n'
      'Make it a lively debate! Let them disagree on budget management, shop pricing, or savings. '
      'Format the output strictly in JSON so I can parse it in my app. Do not write markdown blocks other than JSON. '
      'The JSON must be a list of dialogue entries with keys "speaker" and "text". '
      'Example structure:\n'
      '[\n'
      '  {"speaker": "${speakers[0]}", "text": "ڕای ئێوە چییە لەسەر ئەمە؟"},\n'
      '  {"speaker": "${speakers[1]}", "text": "من پێم وایە پێویستە زیاتر ئاگاداری خەرجییەکان بین..."}\n'
      ']';

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ],
          'generationConfig': {
            'temperature': 0.85,
            'responseMimeType': 'application/json',
          }
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jsonText = data['candidates'][0]['content']['parts'][0]['text'] as String;
        final decodedList = jsonDecode(jsonText) as List;
        return decodedList.map((item) {
          return {
            'speaker': item['speaker'].toString(),
            'text': item['text'].toString(),
          };
        }).toList();
      }
    } catch (e) {
      // Fallback on timeout or parse error
    }

    return _getLocalFallbackDebate(topic, speakers);
  }

  // ----------------------------------------------------
  // LOCAL MOCK FALLBACKS (Demo mode / Offline mode)
  // ----------------------------------------------------

  static String _getLocalFallbackChat(String message, String scope) {
    final msg = message.toLowerCase();
    if (msg.contains('سەلام') || msg.contains('سلاو') || msg.contains('hello') || msg.contains('hi')) {
      return 'سڵاو! بەخێربێیت بۆ چاتی ژیری سەلاريفلۆو. من یاریدەدەری دارایی تۆم. دەتوانی پرسیارم لێ بکەیت دەربارەی خەرجییەکانت، چۆنیەتی پاشەکەوتکردن، یان پلانی بازرگانی نوێ. (تێبینی: بۆ وەڵامی تەواوی ڕاستەوخۆ، کلیلەکەت لە بەشی سەرەوە دابنێ!)';
    } else if (msg.contains('قەرز') || msg.contains('debt')) {
      return 'بەڕێوبەرایەتی قەرزەکان زۆر گرنگە. لە سەلاريفلۆو، کاتێک خەرجییەک بە شێوازی "قەرز" تۆمار دەکەیت، گرنگە ناوی کەسەکە دیاری بکەیت تاوەکو لەبیرت نەچێت کەی بۆی بگەڕێنیتەوە. هەوڵبدە هەمیشە ٢٠٪ی داهاتت دابنێیت بۆ پاککردنەوەی قەرزەکان.';
    } else if (msg.contains('پاشەکەوت') || msg.contains('save') || msg.contains('savings')) {
      return 'بۆ پاشەکەوتکردنی کاریگەر لە کوردستان، من پێشنیاری ڕێسای 50/30/20 دەکەم:\n'
             '- ٥٠٪ بۆ پێداویستییە سەرەکییەکان (خۆراک، کرێ، پسوولە)\n'
             '- ٥٠٪ بۆ خەرجی کەسی و خۆشی (یاخود ٣٠٪)\n'
             '- ٢٠٪ بۆ پاشەکەوت یان وەبەرهێنان لە زێڕ و دراوی جێگیر.';
    } else if (msg.contains('بیزنس') || msg.contains('business') || msg.contains('دوکان')) {
      return 'لە بەڕێوەبردنی دوکان یان بزنس لە کوردستاندا، پێویستە هەمیشە سندوقی داهاتی بزنسەکە بە تەواوی جیا بکەیتەوە لە خەرجی ماڵەوە. تۆمارکردنی ڕۆژانەی داهات (EOD) یارمەتیت دەدات بۆ زانینی تەندروستی بازرگانییەکەت لە هەر مانگێکدا.';
    } else {
      return 'سوپاس بۆ پرسیارەکەت. من شیکاری دەکەم بۆ بەشەکانی: $scope. '
             'تەواوی داتای دارایی و خەرجی تۆ پارێزراوە. بۆ ئەوەی ڕاوێژی تەواوت پێبدەم، تکایە کلیلێکی Gemini API لە سندوقی سەرەوەدا دابنێ تاوەکو بە تەواوی ئۆنلاین پرۆسێس بکرێت.';
    }
  }

  static List<Map<String, String>> _getLocalFallbackDebate(String topic, List<String> speakers) {
    final s1 = speakers.isNotEmpty ? speakers[0] : 'دانا';
    final s2 = speakers.length > 1 ? speakers[1] : 'ئەڤین';
    final s3 = speakers.length > 2 ? speakers[2] : 'زانا';

    if (topic.contains('Analyze') || topic.contains('شیکردنەوە') || topic.contains('Transactions')) {
      return [
        {'speaker': s1, 'text': 'سڵاو هاوڕێیان، وەرن با سەیری ڕاپۆرتی مامەڵەکانی ئەم دواییەی بەکارهێنەر بکەین.'},
        {'speaker': s2, 'text': 'بەڵێ، دانا. من دەبینم خەرجی سەر پۆلی وەک خزمەتگوزاری و خواردن دەرەوە زۆر بەرز بووەتەوە ئەم هەفتەیە.'},
        {'speaker': s3, 'text': 'وەک خاوەن کارێک، پێم وایە ئەمە ئاساییە. هەندێک جار خەرجی ڕۆژانەی کار وا دەخوازێت، بەڵام گرنگە داهاتی ڕۆژانەش بەهەمان شێوە زیاد بکات!'},
        {'speaker': s1, 'text': 'دروستە زانا، بەڵام بەکارهێنەر پێویستە زیاتر ئاگاداری ڕێژەی خەرجکردنی ڕۆژانە بێت تا کاتی مانەوەی بودجەکەی درێژتر بێت.'},
        {'speaker': s2, 'text': 'من پێشنیار دەکەم بودجەی ڕۆژانەی دەستی بۆ کەسی کەم بکرێتەوە بۆ ئەوەی پاشەکەوت بەهێزتر بێت.'},
      ];
    }

    return [
      {'speaker': s1, 'text': 'بەخێربێن بۆ گفتوگۆی ژیری سەلاريفلۆو. بابەتەکەمان دەربارەی: $topic.'},
      {'speaker': s2, 'text': 'ڕای من وایە کە هەمیشە کۆنترۆڵکردنی خەرجییە بچووکەکان بنەمای سەرکەوتنی داراییە.'},
      {'speaker': s3, 'text': 'من هاوڕام بەشەنێکی، بەڵام بێگومان دەبێت بیر لە زیادکردنی سەرچاوەی داهاتیش بکەینەوە، نەک تەنها کەمکردنەوەی خەرجی!'},
      {'speaker': s1, 'text': 'هەردووکیان گرنگن. بۆیە لێرە لە سەلاريفلۆو گرنگی بە جیاکردنەوەی جزدانی کەسی و کار دەدەین.'},
      {'speaker': s2, 'text': 'تەواو وایە. هیواخوازم بەکارهێنەر سوود لەم شیکاریانە وەربگرێت بۆ ڕێکخستنی کارەکانی.'},
    ];
  }
}
