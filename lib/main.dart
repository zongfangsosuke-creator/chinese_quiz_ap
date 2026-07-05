import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '中国語クイズアプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '中国語への第一歩 クイズ＆文法'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> _masterLessonList = [];
  int _selectedLessonIndex = 0;
  String _activeTab = 'grammar'; // 'grammar', 'sentences', 'vocabulary'

  List<Map<String, String>> _activeQuizList = [];
  int _currentIndex = 0;
  bool _isQuizMode = false;

  final TextEditingController _controller = TextEditingController();
  String _resultMessage = '';
  String _meaningMessage = '';
  bool _isCorrect = false;
  double _speechRate = 0.9;

  Null get cross => null;

  @override
  void initState() {
    super.initState();
    _initializeAllLessons();
  }

  void _startQuiz(String type) {
    var currentLessonData = _masterLessonList[_selectedLessonIndex];
    List<dynamic> targetData = type == 'sentences'
        ? currentLessonData['sentences']
        : currentLessonData['vocabulary'];

    if (targetData.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('データがありません。')));
      return;
    }

    _activeQuizList = targetData.map((e) {
      return {
        'quiz': type == 'sentences'
            ? e['chinese'].toString()
            : e['word'].toString(),
        'pinyin': e['pinyin'].toString(),
        'answer': e['japanese'].toString(),
      };
    }).toList();

    setState(() {
      _currentIndex = 0;
      _isQuizMode = true;
      _resultMessage = '';
      _meaningMessage = '';
      _controller.clear();
    });
  }

  void _speakChinese(String text) {
    if (kIsWeb) {
      js.context.callMethod('eval', [
        '''
        var utterance = new SpeechSynthesisUtterance("$text");
        utterance.lang = "zh-CN";
        utterance.rate = $_speechRate;
        window.speechSynthesis.speak(utterance);
        ''',
      ]);
    }
  }

  String _cleanText(String text) {
    var output = text.toLowerCase();
    output = output.replaceAll(RegExp(r'[āáǎà]'), 'a');
    output = output.replaceAll(RegExp(r'[ēéěè]'), 'e');
    output = output.replaceAll(RegExp(r'[īíǐì]'), 'i');
    output = output.replaceAll(RegExp(r'[ōóǒò]'), 'o');
    output = output.replaceAll(RegExp(r'[ūúǔù]'), 'u');
    output = output.replaceAll(RegExp(r'[ǖǘǚǜü]'), 'v');
    output = output.replaceAll(RegExp(r"[ ,.?？，。！!’'…-ー]"), '');
    return output;
  }

  void _checkAnswer() {
    String input = _controller.text.trim();
    String pinyin = _activeQuizList[_currentIndex]['pinyin']!;
    String answer = _activeQuizList[_currentIndex]['answer']!;

    _speakChinese(_activeQuizList[_currentIndex]['quiz']!);

    setState(() {
      _meaningMessage = '意味: $answer';
      if (_cleanText(input) == _cleanText(pinyin)) {
        _resultMessage = '🎉 正解！\n(ピンイン: $pinyin)';
        _isCorrect = true;
      } else {
        _resultMessage = '❌ 残念！\n(正解: $pinyin)';
        _isCorrect = false;
      }
    });
  }

  void _nextQuiz() {
    setState(() {
      _controller.clear();
      _resultMessage = '';
      _meaningMessage = '';
      if (_currentIndex < _activeQuizList.length - 1) {
        _currentIndex++;
      } else {
        _isQuizMode = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('全問終了しました！')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          _isQuizMode ? '第 ${_selectedLessonIndex + 1} 講 クイズ' : widget.title,
        ),
        actions: _isQuizMode
            ? [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () => setState(() => _isQuizMode = false),
                ),
              ]
            : null,
      ),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(16.0),
          child: _isQuizMode ? _buildQuizView() : _buildMainDashboardView(),
        ),
      ),
    );
  }

  Widget _buildMainDashboardView() {
    var currentLesson = _masterLessonList[_selectedLessonIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedLessonIndex,
              isExpanded: true,
              items: _masterLessonList.map((lesson) {
                return DropdownMenuItem<int>(
                  value: _masterLessonList.indexOf(lesson),
                  child: Text(
                    '第 ${lesson['lesson']} 講: ${lesson['title']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? val) =>
                  setState(() => _selectedLessonIndex = val!),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabButton('grammar', '📖 文法紹介'),
            _buildTabButton('sentences', '💬 会話文'),
            _buildTabButton('vocabulary', '📕 単語帳'),
          ],
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(10),
            child: _buildTabContent(currentLesson),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _startQuiz('sentences'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.quiz, color: Colors.black),
                label: const Text(
                  '会話文クイズ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _startQuiz('vocabulary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.g_translate, color: Colors.black),
                label: const Text(
                  '単語クイズ',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButton(String tabKey, String label) {
    bool isSelected = _activeTab == tabKey;
    return ElevatedButton(
      onPressed: () => setState(() => _activeTab = tabKey),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.deepPurple,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.deepPurple),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildTabContent(Map<String, dynamic> currentLesson) {
    if (_activeTab == 'grammar') {
      List<dynamic> grammarList = currentLesson['grammar'] ?? [];
      if (grammarList.isEmpty) {
        return const Center(child: Text('この課の解説は会話文と単語帳を確認してください。'));
      }
      return ListView.builder(
        itemCount: grammarList.length,
        itemBuilder: (context, idx) {
          var item = grammarList[idx];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const Divider(height: 12),
                  Text(
                    item['desc'],
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (_activeTab == 'sentences') {
      List<dynamic> sentenceList = currentLesson['sentences'] ?? [];
      return ListView.builder(
        itemCount: sentenceList.length,
        itemBuilder: (context, idx) {
          var item = sentenceList[idx];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
              child: Text('${idx + 1}'),
            ),
            title: Text(
              item['chinese'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${item['pinyin']}\n${item['japanese']}'),
            trailing: IconButton(
              icon: const Icon(Icons.volume_up, size: 20),
              onPressed: () => _speakChinese(item['chinese']),
            ),
          );
        },
      );
    } else {
      List<dynamic> vocabList = currentLesson['vocabulary'] ?? [];
      return ListView.builder(
        itemCount: vocabList.length,
        itemBuilder: (context, idx) {
          var item = vocabList[idx];
          return Card(
            child: ListTile(
              title: Text(
                item['word'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              subtitle: Text('${item['pinyin']}  ➔  ${item['japanese']}'),
              trailing: IconButton(
                icon: const Icon(Icons.volume_up, size: 18),
                onPressed: () => _speakChinese(item['word']),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildQuizView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            '第 ${_currentIndex + 1} 問 / 全 ${_activeQuizList.length} 問',
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _activeQuizList[_currentIndex]['quiz']!,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('🐢 慢'),
                selected: _speechRate == 0.6,
                onSelected: (s) => setState(() => _speechRate = 0.6),
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: const Text('ふつう'),
                selected: _speechRate == 0.9,
                onSelected: (s) => setState(() => _speechRate = 0.9),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () =>
                _speakChinese(_activeQuizList[_currentIndex]['quiz']!),
            icon: const Icon(Icons.volume_up),
            label: const Text('発音を再生'),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'ピンインを入力 (例: ni hao)',
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text('答え合わせ'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _resultMessage,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isCorrect ? Colors.green : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          if (_meaningMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _meaningMessage,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (_resultMessage.isNotEmpty)
            ElevatedButton(
              onPressed: _nextQuiz,
              child: Text(
                _currentIndex == _activeQuizList.length - 1
                    ? '終了してダッシュボードへ'
                    : '次の問題へ ➡️',
              ),
            ),
        ],
      ),
    );
  }

  void _initializeAllLessons() {
    _masterLessonList.addAll([
      {
        "lesson": 1,
        "title": "中国語への第一歩 －あいさつ－",
        "grammar": [
          {
            "title": "① 基本のあいさつ「你好」",
            "desc": "最も一般的な挨拶です。相手に合わせて変化させたり時間帯による使い分けが基本となります。",
          },
          {"title": "② 疑問を表す「吗」", "desc": "文末に「吗」をつけるだけで簡単に疑問文を構築できます。"},
          {
            "title": "③ 感謝と謝罪",
            "desc": "「谢谢」には「不客气」、「对不起」には「没关系」で返すセットを覚えましょう。",
          },
        ],
        "sentences": [
          {"chinese": "你好！", "pinyin": "Nǐ hǎo!", "japanese": "こんにちは！"},
          {
            "chinese": "老师，您好！",
            "pinyin": "Lǎoshī, nín hǎo!",
            "japanese": "先生、こんにちは！",
          },
          {
            "chinese": "您身体好吗？",
            "pinyin": "Nín shēntǐ hǎo ma?",
            "japanese": "お元気ですか。",
          },
          {
            "chinese": "很好，谢谢。你呢？",
            "pinyin": "Hěn hǎo, xièxie. Nǐ ne?",
            "japanese": "元気です、ありがとう。あなたは？",
          },
          {
            "chinese": "我也很好。",
            "pinyin": "Wǒ yě hěn hǎo.",
            "japanese": "私も元気です。",
          },
          {
            "chinese": "请多关照。",
            "pinyin": "Qǐng duō guānzhào.",
            "japanese": "どうぞよろしくお願いします。",
          },
          {
            "chinese": "请多指教。",
            "pinyin": "Qǐng duō zhǐjiào.",
            "japanese": "よろしくご指導ください。",
          },
          {"chinese": "再见！", "pinyin": "Zàijiàn!", "japanese": "さようなら！"},
          {"chinese": "明天见！", "pinyin": "Míngtiān jiàn!", "japanese": "また明日！"},
          {
            "chinese": "早上好！",
            "pinyin": "Zǎoshang hǎo!",
            "japanese": "おはようございます！",
          },
          {"chinese": "晚上好！", "pinyin": "Wǎnshang hǎo!", "japanese": "こんばんは！"},
          {"chinese": "请进。", "pinyin": "Qǐng jìn.", "japanese": "どうぞお入りください。"},
          {"chinese": "请坐。", "pinyin": "Qǐng zuò.", "japanese": "どうぞお掛けください。"},
          {"chinese": "不客气。", "pinyin": "Bú kèqi.", "japanese": "どういたしまして。"},
          {
            "chinese": "对不起。",
            "pinyin": "Duìbuqǐ.",
            "japanese": "すみません／ごめんなさい。",
          },
          {
            "chinese": "没关系。",
            "pinyin": "Méi guānxi.",
            "japanese": "大丈夫です／気にしないでください。",
          },
          {
            "chinese": "请问……",
            "pinyin": "Qǐngwèn...",
            "japanese": "ちょっとお尋ねします……",
          },
          {
            "chinese": "请静一静。",
            "pinyin": "Qǐng jìng yí jìng.",
            "japanese": "静かにしてください。",
          },
        ],
        "vocabulary": [
          {"word": "好", "pinyin": "hǎo", "japanese": "良い"},
          {"word": "老师", "pinyin": "lǎoshī", "japanese": "先生"},
          {"word": "您", "pinyin": "nín", "japanese": "あなた（敬称）"},
          {"word": "高兴", "pinyin": "gāoxìng", "japanese": "うれしい"},
          {"word": "认识", "pinyin": "rènshi", "japanese": "知る／知り合う"},
          {"word": "也", "pinyin": "yě", "japanese": "〜も"},
          {
            "word": "请多关照",
            "pinyin": "qǐng duō guānzhào",
            "japanese": "どうぞよろしくお願いします",
          },
          {
            "word": "请多指教",
            "pinyin": "qǐng duō zhǐjiào",
            "japanese": "どうぞご指導ください",
          },
          {"word": "再见", "pinyin": "zàijiàn", "japanese": "さようなら"},
          {"word": "早上", "pinyin": "zǎoshang", "japanese": "朝"},
          {"word": "晚上", "pinyin": "wǎnshang", "japanese": "夜"},
          {"word": "谢谢", "pinyin": "xièxie", "japanese": "ありがとう"},
          {"word": "进", "pinyin": "jìn", "japanese": "入る"},
          {"word": "坐", "pinyin": "zuò", "japanese": "座る"},
          {"word": "不客气", "pinyin": "bú kèqi", "japanese": "どういたしまして"},
          {"word": "对不起", "pinyin": "duìbuqǐ", "japanese": "すみません／ごめんなさい"},
          {
            "word": "没关系",
            "pinyin": "méi guānxi",
            "japanese": "大丈夫です／気にしないでください",
          },
          {"word": "请问", "pinyin": "qǐngwèn", "japanese": "お尋ねします"},
          {"word": "静", "pinyin": "jìng", "japanese": "話す／静か"},
        ],
      },
      {
        "lesson": 2,
        "title": "名前・所属・専攻",
        "grammar": [
          {
            "title": "① 姓名・名前を名乗る動詞",
            "desc": "「姓」は名字のみ、「叫」はフルネームや下の名前を呼ぶときに用います。",
          },
          {
            "title": "② 判定を表す判断詞「是」",
            "desc": "「A 是 B」で「AはBである」という意味になり、英語のbe動詞に似た性質を持ちます。否定は「不是」です。",
          },
          {"title": "③ 所属や修飾の「的」", "desc": "名詞を繋いで関係性を示し、「〜の」を表現します。"},
        ],
        "sentences": [
          {"chinese": "你好！", "pinyin": "Nǐ hǎo!", "japanese": "こんにちは！"},
          {
            "chinese": "请问，您贵姓？",
            "pinyin": "Qǐngwèn, nín guìxìng?",
            "japanese": "失礼ですが、お名前を伺ってもよろしいでしょうか？",
          },
          {
            "chinese": "我姓林，叫林静。你呢？",
            "pinyin": "Wǒ xìng Lín, jiào Lín Jìng. Nǐ ne?",
            "japanese": "私は林と申します、林静といいます。あなたは？",
          },
          {
            "chinese": "我叫田中太郎。",
            "pinyin": "Wǒ jiào Tiánzhōng Tàiláng.",
            "japanese": "私は田中太郎といいます。",
          },
          {
            "chinese": "请问，你是哪个学部的学生？",
            "pinyin": "Qǐngwèn, nǐ shì nǎ ge xuébù de xuésheng?",
            "japanese": "失礼ですが、どの学部の学生ですか？",
          },
          {
            "chinese": "我是工学部的学生。",
            "pinyin": "Wǒ shì gōngxuébù de xuésheng.",
            "japanese": "私は工学部の学生です。",
          },
          {
            "chinese": "你是哪个学科の学生？",
            "pinyin": "Nǐ shì nǎ ge xuékē de xuésheng?",
            "japanese": "専攻は何ですか？",
          },
          {
            "chinese": "我是信息系统机械工学科的学生。",
            "pinyin": "Wǒ shì xìnxī xìtǒng jīxiè gōngxuékē de xuésheng.",
            "japanese": "私は情報システム機械工学科です。",
          },
          {
            "chinese": "你是先进工学部の学生吗？",
            "pinyin": "Nǐ shì xiānjìn gōngxuébù de xuésheng ma?",
            "japanese": "あなたは先進工学部の学生ですか？",
          },
          {
            "chinese": "对，我是先进工学部の学生。",
            "pinyin": "Duì, wǒ shì xiānjìn gōngxuébù de xuésheng.",
            "japanese": "はい、そうです。先進工学部です。",
          },
        ],
        "vocabulary": [
          {"word": "个", "pinyin": "gè", "japanese": "〜個／の（汎用数詞）"},
          {"word": "学部", "pinyin": "xuébù", "japanese": "学部"},
          {"word": "学生", "pinyin": "xuésheng", "japanese": "学生"},
          {"word": "工学部", "pinyin": "gōngxuébù", "japanese": "工学部"},
          {"word": "专业", "pinyin": "zhuānyè", "japanese": "専攻／専門"},
          {"word": "什么", "pinyin": "shénme", "japanese": "何"},
          {
            "word": "机械系统工学",
            "pinyin": "jīxiè xìtǒng gōngxué",
            "japanese": "機械システム工学",
          },
          {"word": "贵姓", "pinyin": "guìxìng", "japanese": "ご名字は（丁寧語）"},
          {"word": "名字", "pinyin": "míngzi", "japanese": "名前（姓名・名前）"},
          {"word": "呢", "pinyin": "ne", "japanese": "〜は？（疑問）"},
          {"word": "化学科", "pinyin": "huàxuékē", "japanese": "化学科"},
          {
            "word": "信息系统工学科",
            "pinyin": "xìnxī xìtǒng gōngxuékē",
            "japanese": "情報システム工学科",
          },
          {"word": "应用化学科", "pinyin": "yìngyòng huàxuékē", "japanese": "応用化学科"},
          {
            "word": "应用物理学科",
            "pinyin": "yìngyòng wùlǐxuékē",
            "japanese": "応用物理学科",
          },
          {
            "word": "环境资源工学科",
            "pinyin": "huánjìng zīyuán gōngxuékē",
            "japanese": "環境資源工学科",
          },
          {
            "word": "生命工学科",
            "pinyin": "shēngmìng gōngxuékē",
            "japanese": "生命工学科",
          },
          {"word": "大学", "pinyin": "dàxué", "japanese": "大学"},
        ],
      },
      {
        "lesson": 3,
        "title": "学年・年齢・家族",
        "grammar": [
          {"title": "① 年齢を表現する「岁」", "desc": "数字の後に「岁」を配置して年齢を表現します。"},
          {
            "title": "② 疑問詞「几」と「多大」",
            "desc": "10以下の数値を予想する場合は「几」、大人や全般の年齢を聞く場合は「多大」を用います。",
          },
          {"title": "③ 存在・所有の動詞「有」", "desc": "家族構成や「持っている」という存在を明示するときに多用します。"},
        ],
        "sentences": [
          {"chinese": "你好！", "pinyin": "Nǐ hǎo!", "japanese": "こんにちは！"},
          {
            "chinese": "你是几年级？",
            "pinyin": "Nǐ shì jǐ niánjí?",
            "japanese": "何年生ですか？",
          },
          {"chinese": "我一年级。", "pinyin": "Wǒ yì niánjí.", "japanese": "1年生です。"},
          {
            "chinese": "你今年多大？",
            "pinyin": "Nǐ jīnnián duō dā?",
            "japanese": "今年おいくつですか？",
          },
          {"chinese": "我十八岁。", "pinyin": "Wǒ shíbā suì.", "japanese": "18歳です。"},
          {
            "chinese": "你家有几口人？",
            "pinyin": "Nǐ jiā yǒu jǐ kǒu rén?",
            "japanese": "ご家族は何人ですか？",
          },
          {
            "chinese": "我家有四口人。爸爸、妈妈、哥哥和我。",
            "pinyin": "Wǒ jiā yǒu sì kǒu rén. Bàba, māma, gēge hé wǒ.",
            "japanese": "4人家族です。父、母、兄と私です。",
          },
        ],
        "vocabulary": [
          {"word": "几几", "pinyin": "jǐniánjí", "japanese": "何年生"},
          {"word": "年级", "pinyin": "niánjí", "japanese": "学年"},
          {"word": "今年", "pinyin": "jīnnián", "japanese": "今年"},
          {"word": "多大", "pinyin": "duō dā", "japanese": "何歳（年齢を尋ねる）"},
          {"word": "岁", "pinyin": "suì", "japanese": "歳"},
          {"word": "家", "pinyin": "jiā", "japanese": "家／家庭"},
          {"word": "有", "pinyin": "yǒu", "japanese": "ある／持っている"},
          {"word": "口", "pinyin": "kǒu", "japanese": "〜人（家族の数を数える）"},
          {"word": "人", "pinyin": "rén", "japanese": "人"},
          {"word": "和", "pinyin": "hé", "japanese": "と（並列をつなぐ）"},
          {"word": "几几", "pinyin": "jǐ suì", "japanese": "何歳（主に子どもに）"},
          {"word": "年纪", "pinyin": "niánjì", "japanese": "年齢"},
          {"word": "个", "pinyin": "gè", "japanese": "個（一般的な数詞）"},
          {"word": "他", "pinyin": "tā", "japanese": "彼（三人称・男性）"},
          {"word": "她", "pinyin": "tā", "japanese": "彼女（三人称・女性）"},
          {"word": "大一学生", "pinyin": "dàyī xuésheng", "japanese": "大学1年生"},
          {"word": "独生子", "pinyin": "dúshēngzǐ", "japanese": "一人息子"},
          {"word": "独生女", "pinyin": "dúshēngnǚ", "japanese": "一人娘"},
          {"word": "学生", "pinyin": "xuésheng", "japanese": "学生（日常的用法）"},
        ],
      },
      {
        "lesson": 4,
        "title": "建物・施設・場所",
        "grammar": [
          {
            "title": "① 存在の位置を示す動詞「在」",
            "desc": "「主語 + 在 + 場所名詞」の構文で、対象の所在地を表すことができます。",
          },
          {
            "title": "② 場所を特定する疑問詞「哪儿」",
            "desc": "「どこ」を意味し、知りたい場所の位置を尋ねる際に使用されます。",
          },
        ],
        "sentences": [
          {
            "chinese": "教室在哪儿？",
            "pinyin": "Jiàoshì zài nǎr?",
            "japanese": "教室はどこですか？",
          },
          {
            "chinese": "教室在教学楼。",
            "pinyin": "Jiàoshì zài jiàoxuélóu.",
            "japanese": "教室は講義棟にあります。",
          },
          {
            "chinese": "图书馆在哪儿？",
            "pinyin": "Túshūguǎn zài nǎr?",
            "japanese": "図書館はどこですか？",
          },
          {
            "chinese": "图书馆在管理栋旁边。",
            "pinyin": "Túshūguǎn zài guǎnlǐdòng pángbiān.",
            "japanese": "図書館は管理棟のそばにあります。",
          },
          {"chinese": "食堂呢？", "pinyin": "Shítáng ne?", "japanese": "食堂は？"},
          {
            "chinese": "食堂在体育馆前边。",
            "pinyin": "Shítáng zài tǐyùguǎn qiánbian.",
            "japanese": "食堂は体育馆の前にあります。",
          },
          {
            "chinese": "大学里有体育馆吗？",
            "pinyin": "Dàxué li yǒu tǐyùguǎn ma?",
            "japanese": "大学の中に体育館はありますか？",
          },
          {
            "chinese": "有，这里有体育馆。",
            "pinyin": "Yǒu, zhèlǐ yǒu tǐyùguǎn.",
            "japanese": "はい、あります。ここに体育館があります。",
          },
        ],
        "vocabulary": [
          {"word": "教室", "pinyin": "jiàoshì", "japanese": "教室"},
          {"word": "在", "pinyin": "zài", "japanese": "〜にある／いる（存在）"},
          {"word": "哪儿", "pinyin": "nǎr", "japanese": "どこ"},
          {"word": "教学楼", "pinyin": "jiàoxuélóu", "japanese": "講義棟"},
          {"word": "图书馆", "pinyin": "túshūguǎn", "japanese": "図書館"},
          {"word": "管理栋", "pinyin": "guǎnlǐdòng", "japanese": "管理棟"},
          {"word": "食堂", "pinyin": "shítáng", "japanese": "食堂"},
          {"word": "宿舍", "pinyin": "sùshè", "japanese": "寮／宿舎"},
          {"word": "体育馆", "pinyin": "tǐyùguǎn", "japanese": "体育館"},
          {"word": "城", "pinyin": "chéng", "japanese": "まち／その中に／そこに"},
          {"word": "博物馆", "pinyin": "bówùguǎn", "japanese": "博物館"},
          {"word": "实验室", "pinyin": "shíyànshì", "japanese": "実験室"},
          {"word": "车站", "pinyin": "chēzhàn", "japanese": "駅"},
          {"word": "网球场", "pinyin": "wǎngqiúchǎng", "japanese": "テニスコート"},
          {"word": "办公楼", "pinyin": "bàngōnglóu", "japanese": "事務棟"},
          {"word": "运动场", "pinyin": "yùndòngchǎng", "japanese": "運動場"},
          {"word": "医院", "pinyin": "yīyuàn", "japanese": "病院"},
          {"word": "商店", "pinyin": "shāngdiàn", "japanese": "売店／店"},
          {"word": "就诊中心", "pinyin": "jiùzhěn zhōngxīn", "japanese": "保健センター"},
        ],
      },
      {
        "lesson": 5,
        "title": "授業・時間・曜日",
        "grammar": [
          {
            "title": "① 曜日を表す「星期」",
            "desc": "「星期」の後に1から6の数字を付与して月曜から土曜を表現し、日曜は「星期天/星期日」と言います。",
          },
          {
            "title": "② 時刻を意味する「点」と「半」",
            "desc": "時間を指定する際は「点」、30分単位の半分を指定する際は「半」を用います。",
          },
        ],
        "sentences": [
          {
            "chinese": "今天星期几？",
            "pinyin": "Jīntiān xīngqījǐ?",
            "japanese": "今日は何曜日ですか？",
          },
          {
            "chinese": "今天星期四。",
            "pinyin": "Jīntiān xīngqīsì.",
            "japanese": "今日は木曜日です。",
          },
          {
            "chinese": "今天有课吗？",
            "pinyin": "Jīntiān yǒu kè ma?",
            "japanese": "今日、授業はありますか？",
          },
          {
            "chinese": "有，有汉语课。",
            "pinyin": "Yǒu, yǒu Hànyǔ kè.",
            "japanese": "はい、中国語の授業があります。",
          },
          {
            "chinese": "几点上课？",
            "pinyin": "Jǐ diǎn shàngkè?",
            "japanese": "何時に授業が始まりますか？",
          },
          {
            "chinese": "一点上课。",
            "pinyin": "Yì diǎn shàngkè.",
            "japanese": "1時に始まります。",
          },
          {
            "chinese": "几点下课？",
            "pinyin": "Jǐ diǎn xiàkè?",
            "japanese": "何時に授業が終わりますか？",
          },
          {
            "chinese": "两点半下课。",
            "pinyin": "Liǎng diǎn bàn xiàkè.",
            "japanese": "2時半に終わります。",
          },
        ],
        "vocabulary": [
          {"word": "今天", "pinyin": "jīntiān", "japanese": "今日"},
          {"word": "星期几", "pinyin": "xīngqījǐ", "japanese": "何曜日"},
          {"word": "星期", "pinyin": "xīngqī", "japanese": "週／曜日"},
          {"word": "汉语", "pinyin": "Hànyǔ", "japanese": "中国語"},
          {"word": "几点", "pinyin": "jǐ diǎn", "japanese": "何時"},
          {"word": "上课", "pinyin": "shàngkè", "japanese": "授業をする／授業に出る"},
          {"word": "下课", "pinyin": "xiàkè", "japanese": "授業が終わる"},
          {"word": "点", "pinyin": "diǎn", "japanese": "時（時間を表す単位）"},
          {"word": "半", "pinyin": "bàn", "japanese": "半（30分）"},
          {"word": "分", "pinyin": "fēn", "japanese": "分（時間を表す単位）"},
          {"word": "物理", "pinyin": "wùlǐ", "japanese": "物理"},
          {"word": "化学", "pinyin": "huàxué", "japanese": "化学"},
          {"word": "明天", "pinyin": "míngtiān", "japanese": "明日"},
          {"word": "日历", "pinyin": "rìlì", "japanese": "体育"},
          {"word": "数学", "pinyin": "shùxué", "japanese": "数学"},
          {"word": "英语", "pinyin": "Yīngyǔ", "japanese": "英語"},
          {"word": "实验", "pinyin": "shíyàn", "japanese": "実験"},
          {"word": "历史", "pinyin": "lìshǐ", "japanese": "歴史"},
          {"word": "生物学", "pinyin": "shēngwùxué", "japanese": "生物学"},
        ],
      },
      {
        "lesson": 6,
        "title": "学部・研究・課題",
        "grammar": [
          {
            "title": "① 習得可能性を示す助動詞「会」",
            "desc": "学習や練習を通じて習得し、「〜できる」という能力を表現します。",
          },
          {
            "title": "② 進行や状態を表す「在」",
            "desc": "動詞の前に「在」を置くことで、「〜している（研究中など）」という継続的な活動を意味します。",
          },
        ],
        "sentences": [
          {
            "chinese": "你在哪个大学？",
            "pinyin": "Nǐ zài nǎ ge dàxué?",
            "japanese": "あなたは大学で何を勉強していますか？",
          },
          {
            "chinese": "我在先进工学研究科学部。",
            "pinyin": "Wǒ zài xiānjìn gōngxué yánjiū kē xuébù.",
            "japanese": "私は先進工学研究科学部です。",
          },
          {
            "chinese": "你研究人工智能吗？",
            "pinyin": "Nǐ yánjiū réngōng zhìnéng ma?",
            "japanese": "私は人工知能を勉強しています。",
          },
          {
            "chinese": "对，我研究人工智能。",
            "pinyin": "Duì, wǒ yánjiū réngōng zhìnéng.",
            "japanese": "はい、人工知能を勉強しています。",
          },
          {
            "chinese": "你会编写程序吗？",
            "pinyin": "Nǐ huì biānxiě chéngxù ma?",
            "japanese": "プログラミングができますか？",
          },
          {
            "chinese": "对，我会编写程序。",
            "pinyin": "Duì, wǒ huì biānxiě chéngxù.",
            "japanese": "はい、プログラミングができます。",
          },
          {
            "chinese": "你在研究新材料吗？",
            "pinyin": "Nǐ zài yánjiū xīn cáiliào ma?",
            "japanese": "世界の最新材料を研究したいですか？",
          },
          {
            "chinese": "对，我在研究新材料。",
            "pinyin": "Duì, wǒ zài yánjiū xīn cáiliào.",
            "japanese": "はい、新材料を研究しています。",
          },
        ],
        "vocabulary": [
          {"word": "学", "pinyin": "xué", "japanese": "学ぶ"},
          {"word": "人工智能", "pinyin": "réngōng zhìnéng", "japanese": "人工知能"},
          {"word": "会", "pinyin": "huì", "japanese": "〜できる（学習して習得する）"},
          {"word": "编写", "pinyin": "biānxiě", "japanese": "プログラム作成"},
          {"word": "喜欢", "pinyin": "xǐhuan", "japanese": "好きだ"},
          {"word": "编程", "pinyin": "biānchéng", "japanese": "プログラミングをする"},
          {"word": "希望", "pinyin": "xīwàng", "japanese": "希望する／望む"},
          {"word": "解决", "pinyin": "jiějué", "japanese": "解決する"},
          {"word": "问题", "pinyin": "wèntí", "japanese": "問題／課題"},
          {"word": "世界最新", "pinyin": "shìjiè zuìxīn", "japanese": "世界の最新問題"},
          {"word": "具体", "pinyin": "jùtǐ", "japanese": "具体的に"},
          {"word": "研究", "pinyin": "yánjiū", "japanese": "研究する"},
          {"word": "网络", "pinyin": "wǎngluò", "japanese": "ネットワーク"},
          {"word": "线上", "pinyin": "xiànshàng", "japanese": "ネット上で／オンラインで"},
          {"word": "宇宙", "pinyin": "yǔzhòu", "japanese": "宇宙"},
          {"word": "航空", "pinyin": "hángkōng", "japanese": "航空"},
          {"word": "地球环境", "pinyin": "dìqiú huánjìng", "japanese": "地球環境"},
        ],
      },
      {
        "lesson": 7,
        "title": "実験・報告・感想",
        "grammar": [
          {
            "title": "① 完了を表す「了」",
            "desc": "動作の完了や発生を意味し、「〜した」という過去や事実を述べるときに使います。",
          },
          {
            "title": "② 正反疑問句（難不難）",
            "desc": "形容詞を肯定と否定の形で並べて並列化し、「〜ですか、そうではないですか」と尋ねる構文です。",
          },
        ],
        "sentences": [
          {
            "chinese": "今天做实验了吗？",
            "pinyin": "Jīntiān zuò shíyàn le ma?",
            "japanese": "今日の実験はしましたか？",
          },
          {"chinese": "做了。", "pinyin": "Zuò le.", "japanese": "しました。"},
          {
            "chinese": "实验难不难？",
            "pinyin": "Shíyàn nán bù nán?",
            "japanese": "実験は難しいですか？",
          },
          {
            "chinese": "我觉得很难。",
            "pinyin": "Wǒ juéde hěn nán.",
            "japanese": "とても難しいと思います。",
          },
          {
            "chinese": "实验报告写好了吗？",
            "pinyin": "Shíyàn bàogào xiě hǎo le ma?",
            "japanese": "実験レポートは書きましたか？",
          },
          {
            "chinese": "还没写好。",
            "pinyin": "Hái méi xiě hǎo.",
            "japanese": "まだ書いていません。",
          },
          {
            "chinese": "你的实验结果怎么样？",
            "pinyin": "Nǐ de shíyàn jiéguǒ zěnmeyàng?",
            "japanese": "あなたの実験の結果はどうですか？",
          },
          {
            "chinese": "结果不太好。",
            "pinyin": "Jiéguǒ bú tài hǎo.",
            "japanese": "少し難しいですが、とてもおもしろいです。",
          },
        ],
        "vocabulary": [
          {"word": "做", "pinyin": "zuò", "japanese": "する／作る"},
          {"word": "难", "pinyin": "nán", "japanese": "難しい"},
          {"word": "容易", "pinyin": "róngyì", "japanese": "易しい"},
          {"word": "报告", "pinyin": "bàogào", "japanese": "レポート／報告"},
          {"word": "写", "pinyin": "xiě", "japanese": "書く"},
          {"word": "怎么样", "pinyin": "zěnmeyàng", "japanese": "どうですか（疑問表現）"},
          {"word": "虽然", "pinyin": "suīrán", "japanese": "〜だけれども／〜とはいえ"},
          {"word": "export", "pinyin": "érqiě", "japanese": "少し／ちょっと"},
          {"word": "有趣", "pinyin": "yǒuqù", "japanese": "おもしろい／興味深い"},
          {"word": "数据", "pinyin": "shùjù", "japanese": "データ"},
          {"word": "管理", "pinyin": "guǎnlǐ", "japanese": "管理する"},
          {"word": "结果", "pinyin": "jiéguǒ", "japanese": "結果"},
          {"word": "不错", "pinyin": "búcuò", "japanese": "悪くない"},
          {"word": "作业", "pinyin": "zuòyè", "japanese": "宿題／課題"},
          {"word": "知道", "pinyin": "zhīdào", "japanese": "知っている／わかる"},
          {"word": "重要", "pinyin": "zhòngyào", "japanese": "重要だ"},
        ],
      },
      {
        "lesson": 8,
        "title": "能力・可能・許可",
        "grammar": [
          {
            "title": "① 許可を示す「可以」",
            "desc": "「〜してもよい」という客観的状況や相手への認可を求めるときに使用します。",
          },
          {"title": "② 動作の試行「一下」", "desc": "動詞の後に付け加え、「ちょっと〜してみる」と表現を柔らかくします。"},
        ],
        "sentences": [
          {
            "chinese": "你会编程吗？",
            "pinyin": "Nǐ huì biānchéng ma?",
            "japanese": "プログラミングができますか？",
          },
          {"chinese": "会。", "pinyin": "Huì.", "japanese": "できます。"},
          {
            "chinese": "你会使用这个软件吗？",
            "pinyin": "Nǐ huì shǐyòng zhège ruǎnjiàn ma?",
            "japanese": "このソフトを使うことができますか？",
          },
          {
            "chinese": "会，我会使用。",
            "pinyin": "Huì, wǒ huì shǐyòng.",
            "japanese": "はい、使えます。",
          },
          {
            "chinese": "我可以借用一下这个笔记本吗？",
            "pinyin": "Wǒ kěyǐ jièyòng yíxià zhège bǐjìběn ma?",
            "japanese": "このノートを借りてもいいですか？",
          },
          {"chinese": "可以。", "pinyin": "Kěyǐ.", "japanese": "いいですよ。"},
          {
            "chinese": "我们可以一起做这个项目吗？",
            "pinyin": "Wǒmen kěyǐ yìqǐ zuò zhège xiàngmù ma?",
            "japanese": "私たちは一緒にこのプロジェクトをしてもいいですか？",
          },
          {
            "chinese": "当然可以。",
            "pinyin": "Dāngrán kěyǐ.",
            "japanese": "もちろんいいですよ。",
          },
        ],
        "vocabulary": [
          {"word": "那", "pinyin": "nà", "japanese": "それでは"},
          {"word": "分析", "pinyin": "fēnxī", "japanese": "分析する"},
          {"word": "使用", "pinyin": "shǐyòng", "japanese": "使用する"},
          {"word": "以后", "pinyin": "yǐhòu", "japanese": "今後／これから"},
          {"word": "们", "pinyin": "men", "japanese": "〜たち（複数を表す接尾辞）"},
          {"word": "一起", "pinyin": "yìqǐ", "japanese": "一緒に"},
          {"word": "项目", "pinyin": "xiàngmù", "japanese": "プロジェクト"},
          {"word": "当然", "pinyin": "dāngrán", "japanese": "もちろん"},
          {"word": "太好了", "pinyin": "tài hǎo le", "japanese": "よかった／最高だ"},
          {"word": "说话", "pinyin": "shuōhuà", "japanese": "話す"},
          {"word": "参加", "pinyin": "cānjiā", "japanese": "参加する"},
          {"word": "课外活動", "pinyin": "kèwài huódòng", "japanese": "課外活動"},
          {"word": "用", "pinyin": "yòng", "japanese": "使う"},
          {"word": "软件", "pinyin": "ruǎnjiàn", "japanese": "ソフトウェア"},
          {"word": "设计", "pinyin": "shèjì", "japanese": "設計する／デザインする"},
          {"word": "程序", "pinyin": "chéngxù", "japanese": "プログラム"},
          {"word": "太棒了", "pinyin": "tài bàng le", "japanese": "すばらしい／最高だ"},
          {"word": "日语", "pinyin": "Rìyǔ", "japanese": "日本語"},
        ],
      },
      {
        "lesson": 9,
        "title": "手順・方法・作業",
        "grammar": [
          {"title": "① 手段や状態を聞く「怎么」", "desc": "「どのようにして〜するのか」という方法を尋ねる疑問詞です。"},
          {"title": "② 並行動作「一边〜一边…」", "desc": "2つの動作を同時に進行している状況を描写する際に用います。"},
        ],
        "sentences": [
          {
            "chinese": "今天的实验怎么做？",
            "pinyin": "Jīntiān de shíyàn zěnme zuò?",
            "japanese": "今日の実験はどうやってやりますか？",
          },
          {
            "chinese": "先准备材料，再做实验。",
            "pinyin": "Xiān zhǔnbèi cáiliào, zài zuò shíyàn.",
            "japanese": "まず材料を準備し、次に実験をします。",
          },
          {"chinese": "然后呢？", "pinyin": "Ránhòu ne?", "japanese": "それからは？"},
          {
            "chinese": "一边记录数据，一边讨论。",
            "pinyin": "Yìbiān jìlù shùjù, yìbiān tǎolùn.",
            "japanese": "実験をしながら、データを記録します。",
          },
          {
            "chinese": "然后分析実験結果。",
            "pinyin": "Ránhòu fēnxī shíyàn jiéguǒ.",
            "japanese": "それから実験結果を分析します。",
          },
          {"chinese": "最后呢？", "pinyin": "Zuìhòu ne?", "japanese": "最後は？"},
          {
            "chinese": "最后写実験報告。",
            "pinyin": "Zuìhòu xiě shíyàn bàogào.",
            "japanese": "最後に実験レポートを書きます。",
          },
        ],
        "vocabulary": [
          {"word": "怎么", "pinyin": "zěnme", "japanese": "どのように"},
          {"word": "准备", "pinyin": "zhǔnbèi", "japanese": "準備する"},
          {"word": "材料", "pinyin": "cáiliào", "japanese": "材料"},
          {"word": "记录", "pinyin": "jìlù", "japanese": "記録する"},
          {"word": "时间", "pinyin": "shíjiān", "japanese": "時／時間"},
          {"word": "安排", "pinyin": "ānpái", "japanese": "予定を立てる"},
          {"word": "打工", "pinyin": "dǎgōng", "japanese": "アルバイトをする"},
          {"word": "回家", "pinyin": "huíjiā", "japanese": "家に帰る"},
          {"word": "休息", "pinyin": "xiūxi", "japanese": "休む"},
          {"word": "听音乐", "pinyin": "tīng yīnyuè", "japanese": "音楽を聴く"},
          {"word": "看漫画", "pinyin": "kàn mànhuà", "japanese": "漫画を読む"},
          {"word": "喝咖啡", "pinyin": "hē kāfēi", "japanese": "コーヒーを飲む"},
          {"word": "看电视", "pinyin": "kàn diànshì", "japanese": "テレビを見る"},
          {"word": "吃晚饭", "pinyin": "chī wǎnfàn", "japanese": "ご飯を食べる"},
          {"word": "起床", "pinyin": "qǐchuáng", "japanese": "起床する"},
          {"word": "洗澡", "pinyin": "xǐzǎo", "japanese": "シャワーを浴びる"},
          {"word": "睡觉", "pinyin": "shuìjiào", "japanese": "寝る"},
        ],
      },
      {
        "lesson": 10,
        "title": "希望・将来・進路",
        "grammar": [
          {
            "title": "① 希望を伴う助動詞「想」",
            "desc": "「〜したい」という自身の意志や希望を動詞の前に置いて明示します。",
          },
          {
            "title": "② 職務を担う「当」",
            "desc": "「〜の役割につく」「〜になる」として将来の夢や職業を述べるときに用います。",
          },
        ],
        "sentences": [
          {
            "chinese": "将来你想做什么？",
            "pinyin": "Jiānglái nǐ xiǎng zuò shénme?",
            "japanese": "将来、何をしたいですか？",
          },
          {
            "chinese": "我想当一名科学家。",
            "pinyin": "Wǒ xiǎng dāng yì míng kēxuéjiā.",
            "japanese": "科学者なりたいです。",
          },
          {
            "chinese": "我想当一名工程师。",
            "pinyin": "Wǒ xiǎng dāng yì míng gōngchéngshī.",
            "japanese": "エンジニアになりたいです。",
          },
          {
            "chinese": "那你毕业以后想做什么？",
            "pinyin": "Nà nǐ bìyè yǐhòu xiǎng zuò shénme?",
            "japanese": "では、あなたは卒業したら何をしたいですか？",
          },
          {
            "chinese": "我想去美国留学。",
            "pinyin": "Wǒ xiǎng qù Měiguó liúxué.",
            "japanese": "アメリカに留学したいです。",
          },
          {
            "chinese": "我想先积累经验，然后自己創業。",
            "pinyin": "Wǒ xiǎng xiān jīlěi jīngyàn, ránhòu zìjǐ chuàngyè.",
            "japanese": "まず経験を積んで、その後、起業する予定です。",
          },
          {
            "chinese": "祝你们愿望成真。",
            "pinyin": "Zhù nǐmen yuànwàng chéng zhēn.",
            "japanese": "皆さんの願いがかないますように。",
          },
        ],
        "vocabulary": [
          {"word": "将来", "pinyin": "jiānglái", "japanese": "将来"},
          {"word": "当", "pinyin": "dāng", "japanese": "〜になる"},
          {"word": "名", "pinyin": "míng", "japanese": "〜名（職業を持つ人を数える数詞）"},
          {"word": "科学家", "pinyin": "kēxuéjiā", "japanese": "科学者"},
          {"word": "工程师", "pinyin": "gōngchéngshī", "japanese": "エンジニア"},
          {"word": "毕业", "pinyin": "bìyè", "japanese": "卒業する"},
          {"word": "去", "pinyin": "qù", "japanese": "行く"},
          {"word": "美国", "pinyin": "Měiguó", "japanese": "アメリカ"},
          {"word": "留学", "pinyin": "liúxué", "japanese": "留学する"},
          {"word": "积累", "pinyin": "jīlěi", "japanese": "積む／重ねる"},
          {"word": "经验", "pinyin": "jīngyàn", "japanese": "経験"},
          {"word": "创业", "pinyin": "chuàngyè", "japanese": "起業する"},
          {"word": "祝", "pinyin": "zhù", "japanese": "祈る"},
          {"word": "愿望", "pinyin": "yuànwàng", "japanese": "願い／かなう"},
          {
            "word": "心想事成",
            "pinyin": "xīn xiǎng shì chéng",
            "japanese": "思い通りになる",
          },
          {"word": "教授", "pinyin": "jiàoshòu", "japanese": "教授"},
          {"word": "研究员", "pinyin": "yánjiūyuán", "japanese": "研究員"},
        ],
      },
      {
        "lesson": 11,
        "title": "変化・成果・結果",
        "grammar": [
          {
            "title": "① 結果補語「完」と「好」",
            "desc": "動詞に接続して、動作が完全に終わる（完）、または十分に満足いく形に仕上がる（好）状態を示します。",
          },
          {"title": "② すでに行われた「已经」", "desc": "過去の出来事や変化がすでに発生していることを表す副詞です。"},
        ],
        "sentences": [
          {
            "chinese": "实验做完了吗？",
            "pinyin": "Shíyàn zuò wán le ma?",
            "japanese": "実験はやり終わりましたか？",
          },
          {"chinese": "做完了。", "pinyin": "Zuò wán le.", "japanese": "やり終わりました。"},
          {
            "chinese": "结果怎么样？",
            "pinyin": "Jiéguǒ zěnmeyàng?",
            "japanese": "結果はどうですか？",
          },
          {
            "chinese": "温度提高了，反应变快了。",
            "pinyin": "Wēndù tígāo le, fǎnyìng biàn kuài le.",
            "japanese": "温度が上がったら、反応が速くなりました。",
          },
          {
            "chinese": "报告写好了吗？",
            "pinyin": "Bàogào xiě hǎo le ma?",
            "japanese": "レポートはちゃんと書き上げましたか？",
          },
          {
            "chinese": "忙着写呢，不过数据已经分析好了。",
            "pinyin": "Máng zhe xiě ne, búguò shùjù yǐjīng fēnxī hǎo le.",
            "japanese": "まだ書き上げていませんが、データはすでに分析し終わりました。",
          },
          {
            "chinese": "那，实验算成功了吗？",
            "pinyin": "Nà, shíyàn suàn chénggōng le ma?",
            "japanese": "では、実験は成功しましたか？",
          },
          {
            "chinese": "基本上成功了，结果很不错。",
            "pinyin": "Jīběnshàng chénggōng le, jiéguǒ hěn búcuò.",
            "japanese": "おおむね成功しました。結果は悪くないです。",
          },
        ],
        "vocabulary": [
          {"word": "做完", "pinyin": "zuòwán", "japanese": "やり終える"},
          {"word": "温度", "pinyin": "wēndù", "japanese": "温度"},
          {"word": "提高", "pinyin": "tígāo", "japanese": "高める／引き上げる"},
          {"word": "反应", "pinyin": "fǎnyìng", "japanese": "反応"},
          {"word": "变", "pinyin": "biàn", "japanese": "変わる"},
          {"word": "快", "pinyin": "kuài", "japanese": "速い"},
          {"word": "写好", "pinyin": "xiěhǎo", "japanese": "書き上げる"},
          {"word": "不过", "pinyin": "búguò", "japanese": "ただし"},
          {"word": "已经", "pinyin": "yǐjīng", "japanese": "すでに"},
          {"word": "成功", "pinyin": "chénggōng", "japanese": "成功する"},
          {"word": "基本", "pinyin": "jīběn", "japanese": "だいたい／ほぼ／おおむね"},
          {"word": "看到", "pinyin": "kàndào", "japanese": "見える"},
          {"word": "完好", "pinyin": "wánhǎo", "japanese": "書き終える"},
          {"word": "下降", "pinyin": "xiàjiàng", "japanese": "下がる"},
          {"word": "慢", "pinyin": "màn", "japanese": "遅い"},
          {"word": "失败", "pinyin": "shībài", "japanese": "失敗する"},
          {"word": "上完", "pinyin": "shàngwán", "japanese": "授業／日程などを終える"},
          {"word": "水平", "pinyin": "shuǐpíng", "japanese": "レベル"},
        ],
      },
      {
        "lesson": 12,
        "title": "比較・判断・判定",
        "grammar": [
          {"title": "① 比較表現「A 比 B + 形容詞」", "desc": "「AはBより〜だ」という定番の比較文を構成します。"},
          {"title": "② 同等比較「跟〜一样」", "desc": "「〜と同じくらいである」という等価の関係を構築する表現です。"},
        ],
        "sentences": [
          {
            "chinese": "这个问题门槛难不难？",
            "pinyin": "Zhège wèntí ménkǎn nán bù nán?",
            "japanese": "この提案は、あの提案より難しいですか？",
          },
          {
            "chinese": "这个提案不比那个提案难。",
            "pinyin": "Zhège tí'àn bù bǐ nàge tí'àn nán.",
            "japanese": "この提案はあの提案ほど難しくありません。",
          },
          {
            "chinese": "你辛苦了？",
            "pinyin": "Nǐ xīnkǔ le?",
            "japanese": "（宿題は多いですか？）",
          },
          {
            "chinese": "这门的作业比化学门更难。",
            "pinyin": "Zhè mén de zuòyè bǐ huàxué mén gèng nán.",
            "japanese": "この課題のほうが化学よりさらに難しいです。",
          },
          {
            "chinese": "小组概念呢？",
            "pinyin": "Gǔlùpu kànjiàn ne?",
            "japanese": "（グループ発表は？）",
          },
          {
            "chinese": "这门课题跟那一门一样难。",
            "pinyin": "Zhè mén kètí gēn nà yì mén yíyàng nán.",
            "japanese": "この課題はあの課題と同じくらい難しいです。",
          },
          {
            "chinese": "你觉得空调重要吗？",
            "pinyin": "Nǐ juéde kōngtiáo zhòngyào ma?",
            "japanese": "（この技術が一番役に立つと思いますか？）",
          },
          {
            "chinese": "我认为这些研究里这个最实用。",
            "pinyin": "Wǒ rènwéi zhèxiē yánjiū lǐ zhège zuì shíyòng.",
            "japanese": "この研究が一番役に立つと思います。",
          },
        ],
        "vocabulary": [
          {"word": "这门课", "pinyin": "zhè mén kè", "japanese": "この授業"},
          {"word": "比", "pinyin": "bǐ", "japanese": "より（比較）"},
          {"word": "难", "pinyin": "nán", "japanese": "難しい"},
          {"word": "门", "pinyin": "mén", "japanese": "授業／教科を数える単位"},
          {"word": "没有", "pinyin": "méiyǒu", "japanese": "ほどではない（比較の否定）"},
          {"word": "更", "pinyin": "gèng", "japanese": "さらに"},
          {"word": "小组", "pinyin": "xiǎozǔ", "japanese": "グループ"},
          {"word": "发表", "pinyin": "fābiǎo", "japanese": "発表／発表する"},
          {"word": "一样", "pinyin": "yíyàng", "japanese": "同じ"},
          {"word": "最门课", "pinyin": "zuì mén kè", "japanese": "どの授業"},
          {"word": "有用", "pinyin": "yǒuyòng", "japanese": "役に立つ"},
          {"word": "对", "pinyin": "duì", "japanese": "そうだと／満足だ（肯定の返答）"},
          {"word": "几个", "pinyin": "jǐ gè", "japanese": "少し"},
          {"word": "个人", "pinyin": "gèrén", "japanese": "個人"},
          {"word": "不", "pinyin": "bù", "japanese": "いいえ（特定の文型で否定に用いる）"},
          {"word": "实用", "pinyin": "shíyòng", "japanese": "実用的だ"},
          {"word": "别", "pinyin": "bié", "japanese": "ほかの"},
        ],
      },
      {
        "lesson": 13,
        "title": "条件・仮定・証明",
        "grammar": [
          {"title": "① 仮定文「如果〜」", "desc": "「もし〜ならば」という仮定の状況を作ります。"},
          {
            "title": "② 唯一条件の限定「只有〜才…」",
            "desc": "「〜してはじめて…できる」という必須かつ唯一の制約を提示する構文です。",
          },
        ],
        "sentences": [
          {
            "chinese": "如果有留学的机会，你想去吗？",
            "pinyin": "Rúguǒ yǒu liúxué de jīhuì, nǐ xiǎng qù ma?",
            "japanese": "（もし日本留学のチャンスがあったら、申請したいですか？）",
          },
          {
            "chinese": "如果有机会，我一定去。",
            "pinyin": "Rúguǒ yǒu jīhuì, wǒ yídìng qù.",
            "japanese": "チャンスがあれば、必ず行きます。",
          },
          {
            "chinese": "要是你想去美国大学，你需要……",
            "pinyin": "Yàoshi nǐ xiǎng qù Měiguó dàxué, nǐ xūyào...",
            "japanese": "（もしアメリカの大学なら、私は心の準備をします。）",
          },
          {
            "chinese": "只要好好学习，一定能通过。",
            "pinyin": "Zhǐyào hǎohǎo xuéxí, yídìng néng tōngguò.",
            "japanese": "（アメリカの大学に行くには、試験を受けなければいけませんか？）",
          },
          {
            "chinese": "对，我想申请研究员。",
            "pinyin": "Duì, wǒ xiǎng shēnqǐng yánjiūyuán.",
            "japanese": "（はい、アメリカで研究留学を申請したいです。）",
          },
          {
            "chinese": "只有通过考试，才能申请。",
            "pinyin": "Zhǐyǒu tōngguò kǎoshì, cáinéng shēnqǐng.",
            "japanese": "（試験に合格してはじめて、申請できます。）",
          },
        ],
        "vocabulary": [
          {"word": "明年", "pinyin": "míngnián", "japanese": "来年"},
          {"word": "机会", "pinyin": "jīhuì", "japanese": "機会"},
          {"word": "申请", "pinyin": "shēnqǐng", "japanese": "申請する／応募する"},
          {"word": "条件", "pinyin": "tiáojiàn", "japanese": "条件"},
          {"word": "合适", "pinyin": "héshì", "japanese": "適当な／合う／ひったり"},
          {"word": "一定", "pinyin": "yídìng", "japanese": "きっと／必ず"},
          {"word": "努力", "pinyin": "nǔlì", "japanese": "努力する"},
          {"word": "实现", "pinyin": "shíxiàn", "japanese": "実現する"},
          {"word": "目的", "pinyin": "mùdì", "japanese": "目的"},
          {"word": "标准", "pinyin": "biāozhǔn", "japanese": "基準"},
          {"word": "只要", "pinyin": "zhǐyào", "japanese": "〜でありさえすれば"},
          {"word": "生病", "pinyin": "shēngbìng", "japanese": "病気になる"},
          {"word": "考试", "pinyin": "kǎoshì", "japanese": "試験"},
          {"word": "取得", "pinyin": "qǔdé", "japanese": "取れる"},
          {"word": "学分", "pinyin": "xuéfēn", "japanese": "単位"},
          {"word": "合格", "pinyin": "hégé", "japanese": "合格する"},
          {"word": "成绩", "pinyin": "chéngjī", "japanese": "成績"},
          {"word": "优秀", "pinyin": "yōuxiù", "japanese": "優秀だ"},
          {"word": "都", "pinyin": "dōu", "japanese": "すべて／みな（全部を包含する）"},
        ],
      },
      {
        "lesson": 14,
        "title": "総合・スピーチ・スピーキング",
        "grammar": [
          {
            "title": "① スピーチ冒頭の「大家好」",
            "desc": "聴衆全員に向けて「皆様こんにちは」と挨拶する際の定型フレーズです。",
          },
          {
            "title": "② 目的や理由を示す「为了」",
            "desc": "「〜のために」と、目指すべき方向性や理由を提示して文頭に置くことで強い動機を示します。",
          },
        ],
        "sentences": [
          {
            "chinese": "大家好！",
            "pinyin": "Dàjiā hǎo!",
            "japanese": "みなさん、こんにちは。",
          },
          {
            "chinese": "我是林静。",
            "pinyin": "Wǒ饰 Lín Jìng.",
            "japanese": "私は林静といいます。",
          },
          {
            "chinese": "我是日本人，今年十九岁。",
            "pinyin": "Wǒ shì Rìběnrén, jīnnián shíjiǔ suì.",
            "japanese": "私は日本人です。今年19歳です。",
          },
          {
            "chinese": "我家有四口人。爸爸、妈妈、姐姐和我。",
            "pinyin": "Wǒ jiā yǒu sì kǒu rén. Bàba, māma, jiějie hé wǒ.",
            "japanese": "4人家族です。父、母、姉と私です。",
          },
          {
            "chinese": "我是一名大学一年级的学生。",
            "pinyin": "Wǒ饰 yì míng dàxué yī niánjí de xuésheng.",
            "japanese": "私は大学1年生です。",
          },
          {
            "chinese": "在大学学先进工学，专业是化学。",
            "pinyin": "Zài dàxué xué xiānjìn gōngxué, zhuānyè shì huàxué.",
            "japanese": "大学では先進工学を学んでおり、専門は化学です。",
          },
          {
            "chinese": "我觉得化学很有趣，虽然有点难，但非常有意思。",
            "pinyin":
                "Wǒ juéde huàxué hěn yǒuqù, suīrán yǒudiǎn nán, dàn fēicháng yǒuyìsi.",
            "japanese": "化学は学ぶことが多くて、とてもおもしろいです。（少し難しいですが、とてもおもしろいと思います。）",
          },
          {
            "chinese": "我有中国朋友。我跟他常说汉语。",
            "pinyin": "Wǒ yǒu Zhōngguó péngyou. Wǒ gēn tā cháng shuō Hànyǔ.",
            "japanese": "私には中国人の友達がいます。（私は彼といつも中国語を話しています。）",
          },
          {
            "chinese": "我喜欢跟中国朋友交流。",
            "pinyin": "Wǒ xǐhuan gēn Zhōngguó péngyou jiāoliú.",
            "japanese": "私は中国人の友達と交流するのが好きです。",
          },
          {
            "chinese": "为了这个梦想，我要努力学好汉语。",
            "pinyin": "Wèi le zhège mèngxiǎng, wǒ yào nǔlì xuéhǎo Hànyǔ.",
            "japanese": "この夢を実現するために、中国語を一生懸命勉強しなければなりません。",
          },
          {
            "chinese": "我的发表完了。谢谢大家！",
            "pinyin": "Wǒ de fābiǎo wán le. Xièxie dàjiā!",
            "japanese": "発表は以上です。ありがとうございました！",
          },
        ],
        "vocabulary": [
          {"word": "大家", "pinyin": "dàjiā", "japanese": "みなさん"},
          {"word": "日本人", "pinyin": "Rìběnrén", "japanese": "日本人"},
          {"word": "姐姐", "pinyin": "jiějie", "japanese": "姉"},
          {"word": "护士", "pinyin": "hùshi", "japanese": "看護師"},
          {"word": "高二学生", "pinyin": "gāo'èr xuésheng", "japanese": "高校2年生"},
          {"word": "在", "pinyin": "zài", "japanese": "〜において"},
          {"word": "家人", "pinyin": "jiārén", "japanese": "家族"},
          {"word": "现在", "pinyin": "xiànzài", "japanese": "今／現在"},
          {"word": "学到", "pinyin": "xuédào", "japanese": "勉強する／学ぶ"},
          {"word": "专业课", "pinyin": "zhuānyèkè", "japanese": "専門科目"},
          {"word": "生活", "pinyin": "shēnghuó", "japanese": "生活"},
          {"word": "忙", "pinyin": "máng", "japanese": "忙しい"},
          {"word": "快乐", "pinyin": "kuàilè", "japanese": "楽しい"},
          {"word": "每周", "pinyin": "měi zhōu", "japanese": "毎週"},
          {"word": "中国朋友", "pinyin": "Zhōngguó péngyou", "japanese": "中国人の友人"},
          {"word": "常嘛", "pinyin": "chángma", "japanese": "いつも／よく"},
          {"word": "理想", "pinyin": "lǐxiǎng", "japanese": "理想"},
          {"word": "梦想", "pinyin": "mèngxiǎng", "japanese": "夢"},
          {"word": "为了", "pinyin": "wèile", "japanese": "〜のために"},
          {"word": "先进技能", "pinyin": "xiānjìn jìnéng", "japanese": "先進技術"},
          {"word": "商城", "pinyin": "shāngchéng", "japanese": "万能の表現"},
          {"word": "马路嘛", "pinyin": "mǎlùma", "japanese": "烏丸線"},
          {"word": "了解", "pinyin": "liǎojiě", "japanese": "理解する／分かる"},
          {"word": "文化", "pinyin": "wénhuà", "japanese": "文化"},
          {"word": "历史", "pinyin": "lìshǐ", "japanese": "歴史"},
          {"word": "交流", "pinyin": "jiāoliú", "japanese": "交流する"},
          {"word": "介绍", "pinyin": "jièshào", "japanese": "紹介する"},
          {"word": "自己", "pinyin": "zìjǐ", "japanese": "自分"},
          {"word": "每个", "pinyin": "měi ge", "japanese": "これ／この"},
          {"word": "每天", "pinyin": "měitiān", "japanese": "毎日"},
          {"word": "相信", "pinyin": "xiāngxìn", "japanese": "信じる"},
        ],
      },
    ]);
  }
}
