import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Web環境の時だけブラウザの音声合成(SpeechSynthesis)を直接叩くためのパッケージ
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

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
  String _activeTab = 'grammar'; // 'grammar', 'sentences', 'vocabulary', 'quiz'

  // クイズ（4択用）の状態管理
  int _currentQuizIndex = 0;
  String? _selectedChoice;
  bool _isAnswered = false;
  bool _isCorrect = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _initializeAllLessons();
  }

  // index.htmlの変更が不要な、Flutter完結型の音声再生関数
  void _speak(String text) {
    if (kIsWeb) {
      try {
        // ブラウザのwindow.speechSynthesisを取得
        final synth = web.window.speechSynthesis;

        // 再生中の音声を一度クリア
        synth.cancel();

        // 発話オブジェクトを作成
        final utterance = web.SpeechSynthesisUtterance(text);
        utterance.lang = 'zh-CN'; // 中国語（大陸）に設定
        utterance.rate = 0.85; // 聞き取りやすいように少しだけゆっくり

        // 再生を実行
        synth.speak(utterance);
      } catch (e) {
        debugPrint('音声再生エラー: $e');
      }
    }
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
          {"word": "静", "pinyin": "jìng", "japanese": "静かである"},
          {"word": "你们", "pinyin": "nǐmen", "japanese": "あなたたち"},
          {"word": "同学", "pinyin": "tóngxué", "japanese": "クラスメイト/学生"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "下文の空欄に入る最も適切な文末助詞を選びなさい。\n你身体好（ ）。",
            "choices": ["吗", "呢", "不", "了"],
            "answer": "吗",
            "explanation": "文末に疑問の「吗」をつけることで、「お元気ですか」という疑問文になります。",
          },
          {
            "quiz": "「谢谢（ありがとう）」に対する正しい返答を選びなさい。",
            "choices": ["没关系", "不客气", "对不起", "再见"],
            "answer": "不客气",
            "explanation": "感謝されたときは「不客气（どういたしまして）」と返します。「没关系」は謝罪に対する返答です。",
          },
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
            "chinese": "请问，你是哪个学部の学生？",
            "pinyin": "Qǐngwèn, nǐ...哪个学部の学生？",
            "japanese": "失礼ですが、どの学部の学生ですか？",
          },
          {
            "chinese": "我是工学部の学生。",
            "pinyin": "Wǒ shì gōngxuébù de xuésheng.",
            "japanese": "私は工学部の学生です。",
          },
          {
            "chinese": "你是哪个学科の学生？",
            "pinyin": "Nǐ ... 哪个学科的学生？",
            "japanese": "専攻は何ですか？",
          },
          {
            "chinese": "我是信息系统机械工学科的学生。",
            "pinyin": "Wǒ shì xìnxī xìtǒng jīxiè gōngxuékē de xuésheng.",
            "japanese": "私は情報システム機械工学科です。",
          },
          {
            "chinese": "你是先进工学部の学生吗？",
            "pinyin": "Nǐ ... 先进工学部の学生吗？",
            "japanese": "あなたは先進工学部の学生ですか？",
          },
          {
            "chinese": "对，我是先进工学部の学生。",
            "pinyin": "Duì, wǒ...先进工学部の学生。",
            "japanese": "はい、そうです。先進工学部です。",
          },
          {
            "chinese": "张老师是大学教授。",
            "pinyin": "Zhāng lǎoshī shì dàxué jiàoshòu.",
            "japanese": "張先生は大学の教授です。",
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
          {"word": "教授", "pinyin": "jiàoshòu", "japanese": "教授"},
          {"word": "哪", "pinyin": "nǎ", "japanese": "どの、どちらの"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "「私は工学部の学生です」の正しい語順を選びなさい。",
            "choices": ["我工学部是学生。", "我是工学部の学生。", "我是学生工学部。", "工学部我是学生。"],
            "answer": "我是工学部の学生。",
            "explanation":
                "「A 是 B (AはBである)」の判定文構造になります。所属を表すときは「修飾語 + 的 + 名詞」の形にします。",
          },
          {
            "quiz": "フルネームを名乗る際に用いる正しい動詞を選びなさい。\n我（ ）田中太郎。",
            "choices": ["姓", "叫", "是", "有"],
            "answer": "叫",
            "explanation": "名字のみを言う場合は「姓」、フルネームや名前を言う場合は「叫」を使用します。",
          },
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
          {"chinese": "你是几年级？", "pinyin": "Nǐ ... 几年级？", "japanese": "何年生ですか？"},
          {"chinese": "我一年级。", "pinyin": "Wǒ ... 年级。", "japanese": "1年生です。"},
          {
            "chinese": "你今年多大？",
            "pinyin": "Nǐ jīnnián duō dà？",
            "japanese": "今年おいくつですか？",
          },
          {"chinese": "我十八岁。", "pinyin": "Wǒ shíbā suì。", "japanese": "18歳です。"},
          {
            "chinese": "你家有几口人？",
            "pinyin": "Nǐ jiā yǒu jǐ kǒu rén？",
            "japanese": "ご家族は何人ですか？",
          },
          {
            "chinese": "我家有四口人。爸爸、妈妈、哥哥和我。",
            "pinyin": "Wǒ jiā yǒu sì kǒu rén. Bàba, māma, gēge hé wǒ.",
            "japanese": "4人家族です。父、母、兄と私です。",
          },
          {
            "chinese": "你弟弟也是大学生吗？",
            "pinyin": "Nǐ dìdi yě 是大学生吗？",
            "japanese": "あなたの弟さんも大学生ですか？",
          },
        ],
        "vocabulary": [
          {"word": "几年级", "pinyin": "jǐ niánjí", "japanese": "何年生"},
          {"word": "年级", "pinyin": "niánjí", "japanese": "学年"},
          {"word": "今年", "pinyin": "jīnnián", "japanese": "今年"},
          {"word": "多大", "pinyin": "duō dà", "japanese": "何歳（年齢を尋ねる）"},
          {"word": "岁", "pinyin": "suì", "japanese": "歳"},
          {"word": "家", "pinyin": "jiā", "japanese": "家／家庭"},
          {"word": "有", "pinyin": "yǒu", "japanese": "ある／持っている"},
          {"word": "口", "pinyin": "kǒu", "japanese": "〜人（家族数を数える量詞）"},
          {"word": "人", "pinyin": "rén", "japanese": "人"},
          {"word": "和", "pinyin": "hé", "japanese": "と（並列名詞を繋ぐ語）"},
          {"word": "几岁", "pinyin": "jǐ suì", "japanese": "何歳（10歳未満の子供に）"},
          {"word": "个", "pinyin": "gè", "japanese": "個（一般的な数詞）"},
          {"word": "他", "pinyin": "tā", "japanese": "彼（三人称・男性）"},
          {"word": "她", "pinyin": "tā", "japanese": "彼女（三人称・女性）"},
          {"word": "大一学生", "pinyin": "dà yī xuésheng", "japanese": "大学1年生"},
          {"word": "独生子", "pinyin": "dúshēngzǐ", "japanese": "一人息子"},
          {"word": "独生女", "pinyin": "dúshēngnǚ", "japanese": "一人娘"},
          {"word": "爸爸", "pinyin": "bàba", "japanese": "お父さん"},
          {"word": "妈妈", "pinyin": "māma", "japanese": "お母さん"},
          {"word": "哥哥", "pinyin": "gēge", "japanese": "お兄さん"},
          {"word": "弟弟", "pinyin": "dìdi", "japanese": "弟"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "大人の年齢を尋ねる際、最も適切な疑問表現を選びなさい。\n你今年（ ）。",
            "choices": ["几岁", "多大", "几口人", "什么"],
            "answer": "多大",
            "explanation": "一般的な大人の年齢を聞く場合は「多大」を使います。「几岁」は主に10歳未満の子供に対して使われます。",
          },
          {
            "quiz": "家族の人数（口数）を聞くときの正しい表現を選びなさい。\n你家有（ ）口人？",
            "choices": ["多大", "什么", "几", "多少"],
            "answer": "几",
            "explanation": "家族の人数を尋ねる量詞「口」の前には、数を聞く疑問詞「几」を組み合わせます。",
          },
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
            "pinyin": "Jiàoxuélóu zài jiàoxuélóu.",
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
            "japanese": "食堂は体育館の前にあります。",
          },
          {
            "chinese": "大学里有体育馆吗？",
            "pinyin": "Dàxué li...体育馆吗？",
            "japanese": "大学の中に体育馆はありますか？",
          },
          {
            "chinese": "有，这里有体育馆。",
            "pinyin": "Yǒu, zhèlǐ 有体育馆。",
            "japanese": "はい、ここに体育館があります。",
          },
          {
            "chinese": "洗手间在楼梯左边。",
            "pinyin": "Xǐshǒujiān zài lóutī zuǒbian.",
            "japanese": "洗面所（トイレ）は階段の左側にあります。",
          },
        ],
        "vocabulary": [
          {"word": "教室", "pinyin": "jiàoshì", "japanese": "教室"},
          {"word": "在", "pinyin": "zài", "japanese": "〜にある／いる（存在・所在）"},
          {"word": "哪儿", "pinyin": "nǎr", "japanese": "どこ"},
          {"word": "教学楼", "pinyin": "jiàoxuélóu", "japanese": "講義棟"},
          {"word": "图书馆", "pinyin": "túshūguǎn", "japanese": "図書館"},
          {"word": "管理栋", "pinyin": "guǎnlǐdòng", "japanese": "管理棟"},
          {"word": "食堂", "pinyin": "shítáng", "japanese": "食堂"},
          {"word": "宿舍", "pinyin": "sùshè", "japanese": "寮／宿舎"},
          {"word": "体育馆", "pinyin": "tǐyùguǎn", "japanese": "体育馆"},
          {"word": "前边", "pinyin": "qiánbian", "japanese": "前側 / 前"},
          {"word": "旁边", "pinyin": "pángbiān", "japanese": "隣 / そば"},
          {"word": "实验室", "pinyin": "shíyànshì", "japanese": "実験室"},
          {"word": "车站", "pinyin": "chēzhàn", "japanese": "駅"},
          {"word": "网球场", "pinyin": "wǎngqiúchǎng", "japanese": "テニコート"},
          {"word": "办公楼", "pinyin": "bàngōnglóu", "japanese": "事務棟"},
          {"word": "洗手间", "pinyin": "xǐshǒujiān", "japanese": "洗面所/トイレ"},
          {"word": "楼梯", "pinyin": "lóutī", "japanese": "階段"},
          {"word": "左边", "pinyin": "zuǒbian", "japanese": "左側"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "「食堂はどこにありますか？」を意味する正しい中国語を選びなさい。",
            "choices": ["食堂在什么？", "食堂在哪儿？", "哪儿在食堂？", "食堂在前面吗？"],
            "answer": "食堂在哪儿？",
            "explanation": "場所の所在を尋ねる基本構文は「主語 + 在 + 哪儿？」になります。",
          },
          {
            "quiz": "「〜の隣／そば」を意味する方位詞を選びなさい。\n图书馆在管理栋（ ）。",
            "choices": ["前边", "旁", "旁边", "左"],
            "answer": "旁边",
            "explanation": "名詞の後ろにくっつけて「〜のそば、横」を表す方位詞は「旁边」が適切です。",
          },
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
            "pinyin": "Jīntiān xīngqīsì。",
            "japanese": "今日は木曜日です。",
          },
          {
            "chinese": "今天有课吗？",
            "pinyin": "Jīntiān yǒu kè ma?",
            "japanese": "今日、授業はありますか？",
          },
          {
            "chinese": "有，有汉语课。",
            "pinyin": "Yǒu, yǒu Hànyǔ kè。",
            "japanese": "はい、中国語の授業があります。",
          },
          {
            "chinese": "几点上课？",
            "pinyin": "Jǐ diǎn shàngkè?",
            "japanese": "何時に授業が始まりますか？",
          },
          {
            "chinese": "一点上课。",
            "pinyin": "Yì diǎn shàngkè。",
            "japanese": "1時に始まります。",
          },
          {
            "chinese": "几点下课？",
            "pinyin": "Jǐ diǎn xiàkè?",
            "japanese": "何時に授業が終わりますか？",
          },
          {
            "chinese": "两点半下课。",
            "pinyin": "Liǎng diǎn bàn xiàkè。",
            "japanese": "2時半に終わります。",
          },
          {
            "chinese": "星期六没有专业课。",
            "pinyin": "Xīngqīliù méiyǒu zhuānyèkè。",
            "japanese": "土曜日は専門科目の授業はありません。",
          },
        ],
        "vocabulary": [
          {"word": "今天", "pinyin": "jīntiān", "japanese": "今日"},
          {"word": "星期几", "pinyin": "xījǐ", "japanese": "何曜日"},
          {"word": "星期", "pinyin": "xīngqī", "japanese": "週／曜日"},
          {"word": "汉语", "pinyin": "Hànyǔ", "japanese": "中国語"},
          {"word": "几点", "pinyin": "jǐ diǎn", "japanese": "何時"},
          {"word": "上课", "pinyin": "shàngkè", "japanese": "授業が始まる / 授業に出る"},
          {"word": "下课", "pinyin": "xiàkè", "japanese": "授業が終わる"},
          {"word": "点", "pinyin": "diǎn", "japanese": "時（時間を表す単位）"},
          {"word": "半", "pinyin": "bàn", "japanese": "半（30分）"},
          {"word": "分", "pinyin": "fēn", "japanese": "分"},
          {"word": "物理", "pinyin": "wùlǐ", "japanese": "物理"},
          {"word": "化学", "pinyin": "huàxué", "japanese": "化学"},
          {"word": "明天", "pinyin": "míngtiān", "japanese": "明日"},
          {"word": "数学", "pinyin": "shùxué", "japanese": "数学"},
          {"word": "英語", "pinyin": "Yīngyǔ", "japanese": "英語"},
          {"word": "专业课", "pinyin": "zhuānyèkè", "japanese": "専門科目"},
          {"word": "星期天", "pinyin": "xīngqītiān", "japanese": "日曜日"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "中国語の曜日表現で、「日曜日」にあたらないものを選びなさい。",
            "choices": ["星期日", "星期天", "星期七", "礼拜天"],
            "answer": "星期七",
            "explanation":
                "月曜から土曜は星期一〜六と数字になりますが、日曜日は「星期日」か「星期天」になり、「星期七」とは表現しません。",
          },
          {
            "quiz": "「2時半」を表す自然なフレーズを選びなさい。\n两点（ ）下课。",
            "choices": ["三十分", "半", "刻", "分"],
            "answer": "半",
            "explanation": "「〜時半」は、時間の後ろにそのまま「半（bàn）」を置くのが一般的で自然です。",
          },
        ],
      },
      {
        "lesson": 6,
        "title": "学部・研究・講義",
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
            "chinese": "你在大学做什么？",
            "pinyin": "Nǐ zài dàxué zuò shénme?",
            "japanese": "あなたは大学で何をしていますか？",
          },
          {
            "chinese": "学先进工学。你呢？",
            "pinyin": "Xué xiānjìn gōngxué. Nǐ ne?",
            "japanese": "先進工学を勉強しています。あなたは？",
          },
          {
            "chinese": "我学人工智能。",
            "pinyin": "Wǒ xué réngōng zhìnéng.",
            "japanese": "私は人工知能を勉強しています。",
          },
          {
            "chinese": "为什么要学先进工学？",
            "pinyin": "Wèishénme yào xué xiānjìn gōngxué?",
            "japanese": "なぜ先進工学を勉強するのですか？",
          },
          {
            "chinese": "因为我想去美国留学。",
            "pinyin": "Yīnwèi wǒ xiǎng qù Měiguó liúxué.",
            "japanese": "アメリカに留学したいからです。",
          },
          {
            "chinese": "我也想去美国留学。",
            "pinyin": "Wǒ yě xiǎng qù Měiguó liúxué.",
            "japanese": "私もアメリカに留学したいです。",
          },
        ],
        "vocabulary": [
          {"word": "学", "pinyin": "xué", "japanese": "学ぶ"},
          {"word": "人工智能", "pinyin": "réngōng zhìnéng", "japanese": "人工知能"},
          {"word": "会", "pinyin": "huì", "japanese": "〜できる（学習して習得する能力）"},
          {
            "word": "编写程序",
            "pinyin": "biānxiě chéngxù",
            "japanese": "プログラムを記述する",
          },
          {"word": "喜欢", "pinyin": "xǐhuan", "japanese": "好きだ"},
          {"word": "编程", "pinyin": "biānchéng", "japanese": "プログラミング"},
          {"word": "希望", "pinyin": "xīwàng", "japanese": "希望する／望む"},
          {"word": "解决", "pinyin": "jiějué", "japanese": "解決する"},
          {"word": "问题", "pinyin": "wèntí", "japanese": "問題／課題"},
          {"word": "新材料", "pinyin": "xīn cáiliào", "japanese": "新材料"},
          {"word": "具体", "pinyin": "jùtǐ", "japanese": "具体的に"},
          {"word": "研究", "pinyin": "yánjiū", "japanese": "研究する"},
          {"word": "网络", "pinyin": "wǎngluò", "japanese": "ネットワーク"},
          {"word": "课题", "pinyin": "kètí", "japanese": "研究課題 / テーマ"},
          {"word": "努力", "pinyin": "nǔlì", "japanese": "努力する / 一生懸命やる"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "「プログラムを書く能力がある（～できる）」を表現する適切な助動詞を選びなさい。\n我（ ）编写程序。",
            "choices": ["会", "在", "可以", "想"],
            "answer": "会",
            "explanation": "学習して獲得した技術的な能力を表す「〜できる」には「会」を使用します。",
          },
          {
            "quiz": "「私は今、新材料を研究している最中です」という進行を表す正しい語順を選びなさい。",
            "choices": ["我研究新材料在。", "我在研究新材料。", "我新材料在研究。", "在我是研究新材料。"],
            "answer": "我在研究新材料。",
            "explanation": "動詞の前に「在」を置くことで、「今〜している最中だ」という動作の進行を表現できます。",
          },
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
            "title": "② 正反疑問文（難不難）",
            "desc": "形容詞を肯定と否定の形で並べて並列化し、「〜ですか、そうではないですか」と尋ねる構文です。",
          },
        ],
        "sentences": [
          {
            "chinese": "今天的实验做完了吗？",
            "pinyin": "Jīntzān de shíyàn zuòwán le ma?",
            "japanese": "今日の実験は終わりましたか？",
          },
          {"chinese": "做完了。", "pinyin": "Zuòwán le.", "japanese": "終わりました。"},
          {
            "chinese": "实验做完了吗？",
            "pinyin": "Shíyàn zuòwán le ma?",
            "japanese": "実験は終わりましたか？",
          },
          {
            "chinese": "还没有做完。",
            "pinyin": "Hái méiyǒu zuòwán.",
            "japanese": "まだ終わっていません。",
          },
          {
            "chinese": "实验怎么样？",
            "pinyin": "Shíyàn zěnmeyàng?",
            "japanese": "実験はどうでしたか？",
          },
          {
            "chinese": "非常难。",
            "pinyin": "Fēicháng nán.",
            "japanese": "とても難しかったです。",
          },
          {
            "chinese": "你做报告了吗？",
            "pinyin": "Nǐ zuò bàogào le ma?",
            "japanese": "レポートは書きました（提出しました）か？",
          },
          {
            "chinese": "报告也做完了。",
            "pinyin": "Bàogào yě zuòwán le.",
            "japanese": "レポートも終わりました。",
          },
        ],
        "vocabulary": [
          {"word": "做", "pinyin": "zuò", "japanese": "する／作る"},
          {"word": "难", "pinyin": "nán", "japanese": "難しい"},
          {"word": "容易", "pinyin": "róngyì", "japanese": "易しい"},
          {"word": "报告", "pinyin": "bàogào", "japanese": "レポート／報告"},
          {"word": "写", "pinyin": "xiě", "japanese": "書く"},
          {"word": "怎么样", "pinyin": "zěnmeyàng", "japanese": "どうですか（状態を尋ねる）"},
          {"word": "虽然", "pinyin": "suīrán", "japanese": "〜だけれども"},
          {"word": "但是", "pinyin": "dànshì", "japanese": "しかし / けれども"},
          {"word": "有趣", "pinyin": "yǒuqù", "japanese": "おもしろい／興味深い"},
          {"word": "数据", "pinyin": "shùjù", "japanese": "データ"},
          {"word": "结果", "pinyin": "jiéguǒ", "japanese": "結果"},
          {"word": "不错", "pinyin": "búcuò", "japanese": "悪くない、素晴らしい"},
          {"word": "作业", "pinyin": "zuòyè", "japanese": "宿題／課題"},
          {"word": "写好", "pinyin": "xiěhǎo", "japanese": "書き終える/しっかり書く"},
          {"word": "还没", "pinyin": "hái méi", "japanese": "まだ〜していない"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "「実験は難しいですか？」を聞く正反疑問文の形を選びなさい。",
            "choices": ["实验難吗不難？", "实验难不难？", "实验不难难？", "实验很难吗？"],
            "answer": "实验难不难？",
            "explanation": "形容詞を肯定＋否定（难不难）の形で並べると、文末に「吗」をつけない疑問文（正反疑問文）になります。",
          },
          {
            "quiz": "「私はレポートを書き終えました」という完了を表す「了」の正しい位置を選びなさい。",
            "choices": ["了我写完报告。", "我了写完报告。", "我写完报告了。", "我写完了报告。"],
            "answer": "我写完报告了。",
            "explanation": "文全体の事態の完了や変化の表現として、文末に「了」を置くのが最適です。",
          },
        ],
      },
      {
        "lesson": 8,
        "title": "能力・可能・許可",
        "grammar": [
          {"title": "① 能願動詞「会」", "desc": "学習や練習を通じて「（能力的に）〜できる」という意味を表します。"},
          {
            "title": "② 能願動詞「可以」",
            "desc": "条件や環境から判断して「〜できる」、または「〜してもよい（許可）」を表します。",
          },
        ],
        "sentences": [
          {
            "chinese": "你会编程吗？",
            "pinyin": "Nǐ huì biānchéng ma?",
            "japanese": "プログラミングができますか？",
          },
          {"chinese": "我会。", "pinyin": "Wǒ huì.", "japanese": "はい、できます。"},
          {
            "chinese": "你会编程吗？",
            "pinyin": "Nǐ huì biānchéng ma?",
            "japanese": "プログラミングができますか？",
          },
          {"chinese": "我不会。", "pinyin": "Wǒ bú huì.", "japanese": "いいえ、できません。"},
          {
            "chinese": "用这台电脑可以编程吗？",
            "pinyin": "Yòng zhè tái diànnǎo kěyǐ biānchéng ma?",
            "japanese": "このパソコンを使ってプログラミングしてもいいですか？",
          },
          {
            "chinese": "可以，可以用。",
            "pinyin": "Kěyǐ, kěyǐ yòng.",
            "japanese": "いいですよ、使えます。",
          },
        ],
        "vocabulary": [
          {"word": "那", "pinyin": "nà", "japanese": "それでは"},
          {"word": "分析", "pinyin": "fēnxī", "japanese": "分析する"},
          {"word": "使用", "pinyin": "shǐyòng", "japanese": "使用する"},
          {"word": "以后", "pinyin": "yǐhòu", "japanese": "今後／これから"},
          {"word": "我们", "pinyin": "wǒmen", "japanese": "私たち"},
          {"word": "一起", "pinyin": "yìqǐ", "japanese": "一緒に"},
          {"word": "项目", "pinyin": "xiangmù", "japanese": "プロジェクト"},
          {"word": "当然", "pinyin": "dāngrán", "japanese": "もちろん"},
          {"word": "太好了", "pinyin": "tài hǎo le", "japanese": "よかった／最高だ"},
          {"word": "软件", "pinyin": "ruǎnjiàn", "japanese": "ソフトウェア"},
          {"word": "借用", "pinyin": "jièyòng", "japanese": "借りて使う"},
          {"word": "一下", "pinyin": "yíxià", "japanese": "ちょっと〜してみる（動作を和らげる）"},
          {"word": "笔记本", "pinyin": "bǐjìběn", "japanese": "ノート/ノートパソコン"},
          {"word": "中文", "pinyin": "Zhōngwén", "japanese": "中国語(書き言葉・全般)"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "「このソフトを使ってもいいですか（許可を求める）」を表す正しい助動詞を選びなさい。\n我（ ）使用这个软件吗？",
            "choices": ["会", "可以", "是", "想"],
            "answer": "可以",
            "explanation": "「〜してもよい」という相手からの許可や可能性を求める場合は「可以」を用います。",
          },
          {
            "quiz": "「ちょっと見てみる」のように、動作を和らげて表現する際に入れる言葉を選びなさい。\n我看（ ）。",
            "choices": ["一下", "个", "会", "在"],
            "answer": "一下",
            "explanation": "動詞の直後に「一下（yíxià）」を置くことで、「ちょっと〜してみる」という意味になります。",
          },
        ],
      },
      {
        "lesson": 9,
        "title": "手順・方法・作業",
        "grammar": [
          {
            "title": "① 順序を表す副詞",
            "desc": "「先……，再……（まず〜して、それから〜する）」を使って、動作の順序を整然と表します。",
          },
          {
            "title": "② 同時動作の表現「一边……一边……」",
            "desc": "「〜しながら〜する」という、2つの動作が並行して行われる状態を表します。",
          },
        ],
        "sentences": [
          {
            "chinese": "这个实验怎么做？",
            "pinyin": "Zhè ge shíyàn zěnme zuò?",
            "japanese": "この実験はどうやりますか？",
          },
          {
            "chinese": "先准备材料，再做实验。",
            "pinyin": "Xiān zhǔnbèi cáiliào, zài zuò shíyàn.",
            "japanese": "まず材料を準備して、次に実験をします。",
          },
          {"chinese": "然后呢？", "pinyin": "Ránhòu ne?", "japanese": "それから？"},
          {
            "chinese": "然后记录数据，最后写报告。",
            "pinyin": "Ránhòu jìlù shùjù, zuìhòu xiě bàogào.",
            "japanese": "それからデータを記録し、最後にレポートを書きます。",
          },
          {
            "chinese": "今天的实验怎么做？",
            "pinyin": "Jīntiān de shíyàn zěnme zuò?",
            "japanese": "今日の実験はどうやりますか？",
          },
          {
            "chinese": "先洗干净，再做实验。",
            "pinyin": "Xiān xǐ gānjìng, zài zuò shíyàn.",
            "japanese": "まずきれいに洗ってから、実験をします。",
          },
        ],
        "vocabulary": [
          {"word": "怎么", "pinyin": "zěnme", "japanese": "どのように／どうやって"},
          {"word": "准备", "pinyin": "zhǔnbèi", "japanese": "準備する"},
          {"word": "材料", "pinyin": "cāiliào", "japanese": "材料"},
          {"word": "记录", "pinyin": "jìlù", "japanese": "記録する"},
          {"word": "时候", "pinyin": "shíhou", "japanese": "時／時間"},
          {"word": "安排", "pinyin": "ānpái", "japanese": "手配する／計画する"},
          {"word": "打工", "pinyin": "dǎgōng", "japanese": "アルバイトをする"},
          {"word": "回家", "pinyin": "huíjiā", "japanese": "家に帰る"},
          {"word": "休息", "pinyin": "xiūxi", "japanese": "休む"},
          {"word": "听音乐", "pinyin": "tīng yīnyuè", "japanese": "音楽を聴く"},
          {"word": "看漫画", "pinyin": "kàn mànhuà", "japanese": "漫画を読む"},
          {"word": "喝咖啡", "pinyin": "hē kāfēi", "japanese": "コーヒーを飲む"},
          {"word": "吃饭", "pinyin": "chīfàn", "japanese": "ご飯を食べる"},
          {"word": "起床", "pinyin": "qǐchuáng", "japanese": "起きる"},
          {"word": "洗澡", "pinyin": "xǐzǎo", "japanese": "お風呂に入る／シャワーを浴びる"},
          {"word": "睡觉", "pinyin": "shuìjiào", "japanese": "寝る"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "「まず材料を準備して、それから実験をする」の正しい語順表現を選びなさい。",
            "choices": [
              "先准备材料，再做实验。",
              "再准备材料，先做实验。",
              "先做实验，再准备材料。",
              "准备材料先，做实验再。",
            ],
            "answer": "先准备材料，再做实验。",
            "explanation": "「先……，再……」の組み合わせで「まず〜して、次に〜する」という作業手順を表せます。",
          },
          {
            "quiz": "「音楽を聴きながらコーヒーを飲む」という同時動作の正しい構文を選びなさい。\n我（ ）听音乐（ ）喝咖啡。",
            "choices": ["先……再……", "一边……一边……", "有的……有的……", "然后……最后……"],
            "answer": "一边……一边……",
            "explanation": "「一边 + 動作A + 一边 + 動作B」で「〜しながら〜する」という並行処理を表せます。",
          },
        ],
      },
      {
        "lesson": 10,
        "title": "希望・将来・進路",
        "grammar": [
          {"title": "① 能願動詞「想」", "desc": "「〜したい」という主観的な希望や願望を表します。否定は「不想」です。"},
          {
            "title": "② 「打算」による計画の表現",
            "desc": "「〜するつもりだ／〜する予定だ」という、具体的な予定を表します。",
          },
        ],
        "sentences": [
          {
            "chinese": "你将来想做什么？",
            "pinyin": "Nǐ jiānglái xiǎng zuò shénme?",
            "japanese": "将来は何をしたいですか？",
          },
          {
            "chinese": "我想当工程师。你呢？",
            "pinyin": "Wǒ xiǎng dāng gōngchengshī. Nǐ ne?",
            "japanese": "私はエンジニアになりたいです。あなたは？",
          },
          {
            "chinese": "我想学大数据。",
            "pinyin": "Wǒ xiǎng xué dàshùjù.",
            "japanese": "私はビッグデータを学びたいです。",
          },
          {
            "chinese": "毕业以后有什么打算？",
            "pinyin": "Bìyè yǐhòu yǒu shénme dǎsuàn?",
            "japanese": "卒業した後はどんな予定ですか？",
          },
          {
            "chinese": "我打算去美国留学。",
            "pinyin": "Wǒ dǎsuàn qù Měiguó liúxué.",
            "japanese": "アメリカに留学するつもりです。",
          },
          {
            "chinese": "祝你们成功！",
            "pinyin": "Zhù nǐmen chénggōng!",
            "japanese": "皆さんの成功を祈っています！",
          },
        ],
        "vocabulary": [
          {"word": "将来", "pinyin": "jiānglái", "japanese": "将来"},
          {"word": "当", "pinyin": "dāng", "japanese": "〜になる（職業など）"},
          {"word": "科学家", "pinyin": "kēxuéjiā", "japanese": "科学者"},
          {"word": "工程师", "pinyin": "gōngchéngshī", "japanese": "エンジニア"},
          {"word": "毕业", "pinyin": "bìyè", "japanese": "卒業する"},
          {"word": "去", "pinyin": "qù", "japanese": "行く"},
          {"word": "美国", "pinyin": "Měiguó", "japanese": "アメリカ"},
          {"word": "留学", "pinyin": "liúxué", "japanese": "留学する"},
          {"word": "希望", "pinyin": "xīwàng", "japanese": "希望する"},
          {"word": "研究", "pinyin": "yánjiū", "japanese": "研究する"},
          {"word": "制造", "pinyin": "zhìzào", "japanese": "製造する／作る"},
          {"word": "机器人", "pinyin": "jīqìrén", "japanese": "ロボット"},
          {"word": "打算", "pinyin": "dǎsuàn", "japanese": "〜するつもり／予定"},
          {"word": "住", "pinyin": "zhù", "japanese": "住む"},
          {"word": "航天员", "pinyin": "hángtiānyuán", "japanese": "宇宙飛行士"},
          {"word": "心愿", "pinyin": "xīnyuàn", "japanese": "願い／望み"},
          {"word": "教授", "pinyin": "jiàoshòu", "japanese": "教授"},
          {"word": "成功", "pinyin": "chénggōng", "japanese": "成功する"},
          {"word": "研究员", "pinyin": "yánjiūyuán", "japanese": "研究員"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "「エンジニアになりたい」という時の適切な動詞を選びなさい。\n我想（ ）工程师。",
            "choices": ["是", "叫", "当", "在"],
            "answer": "当",
            "explanation": "役割や職業に「〜になる、〜として働く」という場合は動詞「当（dāng）」を使います。",
          },
          {
            "quiz": "「私はアメリカに留学する【予定です】」と計画・予定を述べる表現を選びなさい。\n我（ ）去美国留学。",
            "choices": ["打算", "会", "可以", "在"],
            "answer": "打算",
            "explanation": "あらかじめ考えているスケジュールや予定・計画を表明するときは「打算（dǎsuàn）」を使います。",
          },
        ],
      },
      {
        "lesson": 11,
        "title": "変化・完成・結果",
        "grammar": [
          {
            "title": "① 事態の変化を表す文末の「了」",
            "desc": "文の終わりに「了」をつけることで、「新しい状況になった」「変化が生じた」ことを示します。",
          },
          {
            "title": "② 結果補語",
            "desc": "動詞の直後に別の動詞や形容詞を補語として置き、動作の結果どうなったか（例: 目的の達成「到」）を表します。",
          },
        ],
        "sentences": [
          {
            "chinese": "实验做完了吗？",
            "pinyin": "Shíyàn zuòwán le ma?",
            "japanese": "実験は終わりましたか？",
          },
          {"chinese": "做完了。", "pinyin": "Zuòwán le.", "japanese": "終わりました。"},
          {
            "chinese": "结果怎么样？",
            "pinyin": "Jiéguǒ zěnmeyàng?",
            "japanese": "結果はどうですか？",
          },
          {
            "chinese": "温度提高了，反应变快了。",
            "pinyin": "Wēndù tígāo le, fǎnyìng biàn kuài le.",
            "japanese": "温度が上がって、反応が速くなりました。",
          },
          {
            "chinese": "数据找到了吗？",
            "pinyin": "Shùjù zhǎodào le ma?",
            "japanese": "データは見つかりましたか？",
          },
          {"chinese": "找到了。", "pinyin": "Zhǎodào le.", "japanese": "見つかりました。"},
        ],
        "vocabulary": [
          {"word": "做完", "pinyin": "zuòwán", "japanese": "やり終える"},
          {"word": "温度", "pinyin": "wēndù", "japanese": "温度"},
          {"word": "提高", "pinyin": "tígāo", "japanese": "高める／引き上げる"},
          {"word": "反应", "pinyin": "fǎnyìng", "japanese": "反応"},
          {"word": "变", "pinyin": "biàn", "japanese": "変わる"},
          {"word": "快", "pinyin": "kuài", "japanese": "速い"},
          {"word": "找到", "pinyin": "zhǎodào", "japanese": "見つける／探し当てる"},
          {"word": "不过", "pinyin": "búguò", "japanese": "ただし／でも"},
          {"word": "一切", "pinyin": "yíqiè", "japanese": "すべて"},
          {"word": "成功", "pinyin": "chénggōng", "japanese": "成功する"},
          {"word": "基本", "pinyin": "jīběn", "japanese": "だいたい／基本ね"},
          {"word": "看到", "pinyin": "kàndào", "japanese": "見える"},
          {"word": "完成", "pinyin": "wánchéng", "japanese": "完成する"},
          {"word": "下降", "pinyin": "xiàjiàng", "japanese": "下がる"},
          {"word": "慢", "pinyin": "màn", "japanese": "遅い"},
          {"word": "失败", "pinyin": "shībài", "japanese": "失敗する"},
          {"word": "上拉", "pinyin": "shàngwǎn", "japanese": "回復／引き上げる"},
          {"word": "水平", "pinyin": "shuǐpíng", "japanese": "レベル"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "「データが（探した結果）見つかりました」という結果補語を含む表現を選びなさい。\n数据（ ）了。",
            "choices": ["找在", "找到", "找会", "找好"],
            "answer": "找到",
            "explanation": "探すという動作の目的が達成され、「見つかる」ことを表す結果補語は「到」です。",
          },
          {
            "quiz": "「温度が上がりました（以前より高い状態に変化した）」を意味する正しい表現を選びなさい。",
            "choices": ["温度提高在。", "温度提高了。", "提高温度在。", "温度会提高。"],
            "answer": "温度提高了。",
            "explanation": "文末の「了」は、これまでとは違った新しい状態への「変化」を指し示します。",
          },
        ],
      },
      {
        "lesson": 12,
        "title": "比較・判断・判別",
        "grammar": [
          {
            "title": "① 比較を表現する「比」",
            "desc": "「A 比 B + 形容詞」の形で「AはBより〜だ」という比較文を作ります。",
          },
          {
            "title": "② 比較の否定表現「没有」",
            "desc": "「A 没有 B + 形容詞」で「AはBほど〜ではない」という否定の比較になります。",
          },
          {
            "title": "③ 範囲を制限する副詞「最」",
            "desc": "形容詞の前に「最」を置くことで、「もっとも〜だ」という最上級の表現になります。",
          },
        ],
        "sentences": [
          {
            "chinese": "这台电脑比那台好吗？",
            "pinyin": "Zhè tái diànnǎo bǐ nà tái hǎo ma?",
            "japanese": "このパソコンはあのパソコンより良いですか？",
          },
          {
            "chinese": "对，这台比那台更好一点儿。",
            "pinyin": "Duì, zhè tái bǐ nà tái gèng hǎo yìdiǎnr.",
            "japanese": "はい、このほうが少し性能が良いです。",
          },
          {
            "chinese": "这台电脑贵不贵？",
            "pinyin": "Zhè tái diànnǎo guì bú guì?",
            "japanese": "このパソコンは高いですか？",
          },
          {
            "chinese": "不贵，这台没有那台贵。",
            "pinyin": "Bú guì, zhè tái méiyǒu nà tái guì.",
            "japanese": "高くないです、これはあれほど高くありません。",
          },
          {
            "chinese": "哪台电脑最好用？",
            "pinyin": "Nǎ tái diànnǎo zuì hǎoyòng?",
            "japanese": "どのパソコンが一番使いやすいですか？",
          },
          {
            "chinese": "这台新电脑最好用。",
            "pinyin": "Zhè tái xīn diànnǎo zuì hǎoyòng.",
            "japanese": "この新しいパソコンが一番使いやすいです。",
          },
        ],
        "vocabulary": [
          {"word": "这台电脑", "pinyin": "zhè tái diànnǎo", "japanese": "このパソコン"},
          {"word": "比", "pinyin": "bǐ", "japanese": "より（比較）"},
          {"word": "更", "pinyin": "gèng", "japanese": "さらに"},
          {"word": "门", "pinyin": "mén", "japanese": "授業／教科を数える単位"},
          {"word": "没有", "pinyin": "méiyou", "japanese": "ほどではない（比較の否定）"},
          {"word": "小组", "pinyin": "xiǎozǔ", "japanese": "グループ"},
          {"word": "发展", "pinyin": "fāzhǎn", "japanese": "発表／発表する"},
          {"word": "一模一样", "pinyin": "yìmú yíyàng", "japanese": "同じ"},
          {"word": "最", "pinyin": "zuì", "japanese": "もっとも"},
          {"word": "难度", "pinyin": "nándù", "japanese": "難度"},
          {"word": "好用", "pinyin": "hǎoyòng", "japanese": "使いやすい"},
          {"word": "对", "pinyin": "duì", "japanese": "正しい／その通り"},
          {"word": "有数", "pinyin": "yǒushù", "japanese": "目途が立っている / 把握している"},
          {"word": "一个", "pinyin": "yígè", "japanese": "1つ"},
          {"word": "个人", "pinyin": "gèrén", "japanese": "個人"},
          {"word": "不", "pinyin": "bù", "japanese": "いいえ"},
          {"word": "实用", "pinyin": "shíyòng", "japanese": "実用的"},
          {"word": "别", "pinyin": "bié", "japanese": "ほかの"},
        ],
        "grammar_quizzes": [
          {
            "quiz": "「このパソコンはあのパソコンよりも良い」という比較文の正しい構造を選びなさい。",
            "choices": ["这台电脑比那台好。", "这台电脑那台比好。", "比这台电脑那台好。", "这台电脑好比那台。"],
            "answer": "这台电脑比那台好。",
            "explanation": "比較を表す際は「A 比 B + 形容詞」という基本語順に当てはめて文章を作ります。",
          },
          {
            "quiz": "「このパソコンはあのパソコンほど高くない」という否定の比較表現を選びなさい。\n这台电脑（ ）那台贵。",
            "choices": ["不比", "没有", "不是", "不"],
            "answer": "没有",
            "explanation": "「A 没有 B + 形容詞」の構文で、「AはBほど〜ではない」という否定比較になります。",
          },
        ],
      },
      {
        "lesson": 13,
        "title": "条件・仮定・証明",
        "grammar": [
          {
            "title": "① 仮定を表現する「如果……就……」",
            "desc": "「もし〜ならば、そのときは〜する」という条件と結果を繋ぐ仮定文を構築します。",
          },
          {
            "title": "② 「只要……就……」による必要条件",
            "desc": "「〜しさえすれば、すぐに〜になる」という、十分な条件を提示する表現です。",
          },
        ],
        "sentences": [
          {
            "chinese": "如果实验成功了，你会做什么？",
            "pinyin": "Rúguǒ shíyàn chénggōng le, nǐ huì zuò shénme?",
            "japanese": "もし実験が成功したら、あなたは何をしますか？",
          },
          {
            "chinese": "如果成功了，我一定请客。",
            "pinyin": "Rúguǒ ... 一定请客。",
            "japanese": "もし成功したら、必ずおごりますよ。",
          },
          {
            "chinese": "如果失败了呢？",
            "pinyin": "Rúguǒ shībài le ne?",
            "japanese": "もし失敗したら？",
          },
          {
            "chinese": "如果失败了，就重新再做。",
            "pinyin": "Rúguǒ shībài le, jiù chóngxīn zài zuò.",
            "japanese": "もし失敗したら、もう一度やり直します。",
          },
          {
            "chinese": "只要努力，就一定能成功吗？",
            "pinyin": "Zhǐyào nǔlì, jiù yídìng néng chénggōng ma?",
            "japanese": "努力しさえすれば、必ず成功できますか？",
          },
          {
            "chinese": "对，只要努力，就一定能成功.",
            "pinyin": "Duì, zhǐyào nǔlì, jiù yídìng néng chénggōng.",
            "japanese": "はい、努力さえすれば必ず成功できます。",
          },
        ],
        "vocabulary": [
          {"word": "如果", "pinyin": "rúguǒ", "japanese": "もし〜なら"},
          {"word": "成功", "pinyin": "chenggōng", "japanese": "成功する"},
          {"word": "一定", "pinyin": "yídìng", "japanese": "必ず"},
          {"word": "请客", "pinyin": "qǐngkè", "japanese": "おごる／ごちそうする"},
          {"word": "就", "pinyin": "jiù", "japanese": "すぐに／そのとき"},
          {"word": "重新", "pinyin": "chóngxīn", "japanese": "改めて／もう一度"},
          {"word": "只要", "pinyin": "zhǐyào", "japanese": "〜でありさえすれば"},
          {"word": "努力", "pinyin": "nǔlì", "japanese": "努力する"},
          {"word": "能", "pinyin": "néng", "japanese": "〜できる"},
          {"word": "条件", "pinyin": "tiáojiàn", "japanese": "条件"},
          {"word": "合格", "pinyin": "hégé", "japanese": "合格する"},
          {"word": "通过", "pinyin": "tōngguò", "japanese": "パスする／合格する"},
          {"word": "重做", "pinyin": "chóngzuò", "japanese": "やり直す"},
          {"word": "修正", "pinyin": "xiūzhèng", "japanese": "修正する"},
          {"word": "数据", "pinyin": "shùjù", "japanese": "データ"},
          {
            "word": "只要……就……",
            "pinyin": "zhǐyào... jiù...",
            "japanese": "条件・必要規定",
          },
          {
            "word": "如果……就……",
            "pinyin": "rúguǒ... jiù...",
            "japanese": "条件・仮定規定",
          },
          {
            "word": "只有……才……",
            "pinyin": "zhǐyǒu... cái...",
            "japanese": "条件・結果限定",
          },
        ],
        "grammar_quizzes": [
          {
            "quiz":
                "「【もし】実験が失敗したら、【そのときは】やり直す」という仮定文の正しいセットを選びなさい。\n（ ）失败了，（ ）重新再做。",
            "choices": ["只要……就……", "如果……就……", "虽然……但是……", "因为……所以……"],
            "answer": "如果……就……",
            "explanation": "「如果……，就……」で「もし〜なら、〜する」という仮定を表す構文を形成します。",
          },
          {
            "quiz": "「努力【さえすれば】、必ず成功できる」という表現を選びなさい。\n（ ）努力，就一定能成功。",
            "choices": ["如果", "只要", "因为", "虽然"],
            "answer": "只要",
            "explanation": "「只要……，就……」で「〜しさえすれば、必ず〜となる」という条件規定を表せます。",
          },
        ],
      },
      {
        "lesson": 14,
        "title": "総合学習",
        "grammar": [
          {
            "title": "① 長文の読解と要約",
            "desc": "これまでに学んだ文法（是、在、有、了、想、比など）を総合して、自己紹介や大学生活を包括的に表現します。",
          },
          {
            "title": "② 将来への展望のまとめ",
            "desc": "目的、予定、能力を論理的に繋げて、自分の言葉でスピーチや作文を行う総仕上げを行います。",
          },
        ],
        "sentences": [
          {
            "chinese": "大家好！",
            "pinyin": "Dàjiā hǎo!",
            "japanese": "みなさん、こんにちは！",
          },
          {
            "chinese": "我来自我介绍一下。",
            "pinyin": "Wǒ lái zìwǒ jièshào yíxià.",
            "japanese": "自己紹介をさせていただきます。",
          },
          {
            "chinese": "我叫田中太郎，是先进工学部の学生。",
            "pinyin":
                "Wǒ jiào Tiánzhōng Tàiláng, shì xiānjìn gōngxuébù de xuésheng.",
            "japanese": "私は田中太郎といいます。先進工学部の学生です。",
          },
          {
            "chinese": "我的专业は人工智能。",
            "pinyin": "Wǒ de zhuānyè shì réngōng zhìnéng.",
            "japanese": "専門は人工知能です。",
          },
          {
            "chinese": "我觉得先进工学非常重要。",
            "pinyin": "Wǒ juéde xiānjìn gōngxué fēicháng zhòngyào.",
            "japanese": "先進工学は非常に重要だと思います。",
          },
          {
            "chinese": "为了实现我的梦想，我想去美国留学。",
            "pinyin":
                "Wèile shíxiàn wǒ de mèngxiǎng, wǒ xiǎng qù Měiguó liúxué.",
            "japanese": "夢を実現するために、アメリカへ留学したいと考えています。",
          },
          {
            "chinese": "谢谢大家！",
            "pinyin": "Xièxie dàjiā!",
            "japanese": "ありがとうございました！",
          },
        ],
        "vocabulary": [
          {"word": "大家", "pinyin": "dàjiā", "japanese": "みなさん"},
          {"word": "自我是", "pinyin": "zìwǒshì", "japanese": "自己紹介／〜である"},
          {"word": "紹介", "pinyin": "jièshào", "japanese": "紹介する"},
          {"word": "护士", "pinyin": "hùshi", "japanese": "看護師"},
          {"word": "专业课", "pinyin": "zhuānyèkè", "japanese": "専門科目"},
          {"word": "生活", "pinyin": "shēnghuó", "japanese": "生活"},
          {"word": "忙", "pinyin": "máng", "japanese": "忙しい"},
          {"word": "快乐", "pinyin": "kuàlè", "japanese": "楽しい"},
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
          {"word": "相信", "pinyin": "xiāngxìn", "japanese": "信じる"},
        ],
        "grammar_quizzes": [
          {
            "quiz":
                "「【私の夢を実現するために】、アメリカへ留学したい」という目的規定を表す前置詞を選びなさい。\n（ ）实现我的梦想，我想去美国留学。",
            "choices": ["因为", "为了", "虽然", "关于"],
            "answer": "为了",
            "explanation": "「为了 + 目的」で、「〜のために、〜を目指して」という行為の目的・動機を提示できます。",
          },
          {
            "quiz": "「自己紹介を【ちょっとさせていただきます】」と言うときの、自然なフレーズを選びなさい。",
            "choices": ["我来自我介绍在。", "我来自我介绍一下。", "我自我介绍会。", "一下我自我介绍。"],
            "answer": "我来自我介绍一下。",
            "explanation":
                "自分が進んで何かをする意向を示す「我来〜」に、動作を和らげる「一下」を組み合わせることで、「ちょっと自己紹介をさせていただきます」という自然な表現になります。",
          },
        ],
      },
    ]);
  }

  void _resetQuiz() {
    setState(() {
      _currentQuizIndex = 0;
      _selectedChoice = null;
      _isAnswered = false;
      _isCorrect = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var currentLesson = _masterLessonList[_selectedLessonIndex];
    List<dynamic> grammarList = currentLesson['grammar'] ?? [];
    List<dynamic> sentencesList = currentLesson['sentences'] ?? [];
    List<dynamic> vocabularyList = currentLesson['vocabulary'] ?? [];
    List<dynamic> quizList = currentLesson['grammar_quizzes'] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: _masterLessonList.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(_masterLessonList[index]['title']),
              selected: _selectedLessonIndex == index,
              onTap: () {
                setState(() {
                  _selectedLessonIndex = index;
                  _activeTab = 'grammar';
                  _resetQuiz();
                });
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            width: double.infinity,
            child: Text(
              '第${_selectedLessonIndex + 1}講: ${currentLesson['title']}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton('grammar', '文法解説'),
              _buildTabButton('sentences', '日常会話'),
              _buildTabButton('vocabulary', '重要単語'),
              _buildTabButton('quiz', '4択クイズ'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: IndexedStack(
              index: _activeTab == 'grammar'
                  ? 0
                  : _activeTab == 'sentences'
                  ? 1
                  : _activeTab == 'vocabulary'
                  ? 2
                  : 3,
              children: [
                _buildGrammarTab(grammarList),
                _buildSentencesTab(sentencesList),
                _buildVocabularyTab(vocabularyList),
                _buildQuizTab(quizList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabName, String label) {
    bool isActive = _activeTab == tabName;
    return TextButton(
      onPressed: () {
        setState(() {
          _activeTab = tabName;
          if (tabName == 'quiz') _resetQuiz();
        });
      },
      style: TextButton.styleFrom(
        foregroundColor: isActive ? Colors.deepPurple : Colors.grey,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildGrammarTab(List<dynamic> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(
              list[index]['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(list[index]['desc'] ?? ''),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSentencesTab(List<dynamic> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final chineseText = list[index]['chinese'] ?? '';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: InkWell(
            onTap: () => _speak(chineseText), // タップで中国語音声を再生
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chineseText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.volume_up,
                        color: Colors.deepPurple,
                        size: 20,
                      ), // 音声アイコン
                    ],
                  ),
                  Text(
                    list[index]['pinyin'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Divider(height: 12),
                  Text(
                    list[index]['japanese'] ?? '',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVocabularyTab(List<dynamic> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final wordText = list[index]['word'] ?? '';
        return ListTile(
          onTap: () => _speak(wordText), // タップで中国語音声を再生
          title: Row(
            children: [
              Text(
                wordText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.volume_up, color: Colors.grey, size: 16),
            ],
          ),
          subtitle: Text(list[index]['pinyin'] ?? ''),
          trailing: Text(
            list[index]['japanese'] ?? '',
            style: const TextStyle(fontSize: 16),
          ),
        );
      },
    );
  }

  Widget _buildQuizTab(List<dynamic> quizzes) {
    if (quizzes.isEmpty) {
      return const Center(child: Text("この講にはクイズがありません。"));
    }

    if (_currentQuizIndex >= quizzes.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              "クイズ完了！",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "スコア: $_score / ${quizzes.length}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _resetQuiz,
              child: const Text("もう一度挑戦する"),
            ),
          ],
        ),
      );
    }

    var quizData = quizzes[_currentQuizIndex];
    List<String> choices = List<String>.from(quizData['choices']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "問題 ${_currentQuizIndex + 1} / ${quizzes.length}",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            quizData['quiz'] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...choices.map((choice) {
            bool isSelected = _selectedChoice == choice;
            Color? btnColor = Colors.white;
            if (_isAnswered) {
              if (choice == quizData['answer']) {
                btnColor = Colors.green.shade100;
              } else if (isSelected) {
                btnColor = Colors.red.shade100;
              }
            } else if (isSelected) {
              btnColor = Colors.deepPurple.shade50;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: btnColor,
                    side: BorderSide(
                      color: isSelected
                          ? Colors.deepPurple
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isAnswered
                      ? null
                      : () {
                          setState(() {
                            _selectedChoice = choice;
                          });
                        },
                  child: Text(
                    choice,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          if (!_isAnswered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedChoice == null
                    ? null
                    : () {
                        setState(() {
                          _isAnswered = true;
                          _isCorrect = _selectedChoice == quizData['answer'];
                          if (_isCorrect) _score++;
                        });
                      },
                child: const Text("回答を確定する"),
              ),
            ),
          if (_isAnswered) ...[
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: _isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle : Icons.cancel,
                        color: _isCorrect ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCorrect ? "正解！" : "不正解...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "解説:\n${quizData['explanation'] ?? ''}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentQuizIndex++;
                    _selectedChoice = null;
                    _isAnswered = false;
                  });
                },
                child: Text(
                  _currentQuizIndex + 1 >= quizzes.length ? "結果を見る" : "次の問題へ",
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
