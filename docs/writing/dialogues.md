# 对话库文档

## 文档信息
- 版本：v1.0
- 创建日期：2026-02-13
- 负责人：剧情策划
- 状态：草稿

---

## 对话数据结构

```json
{
  "dialogue_id": "唯一ID",
  "speaker": "说话者",
  "text": "对话文本",
  "emotion": "情感状态",
  "bgm": "背景音乐",
  "sound_effect": "音效",
  "animation": "动画效果",
  "choices": ["选项列表"],
  "next_dialogue": "下一个对话ID",
  "conditions": {
    "attributes": {},
    "relationships": {},
    "flags": []
  },
  "effects": {
    "attributes": {},
    "relationships": {},
    "flags": [],
    "unlock": []
  }
}
```

---

## 核心角色对话

### 伊鲁卡（Iruka）

```json
{
  "character": "iruka",
  "name": "伊鲁卡",
  "title": "忍者学校教师",
  "personality": "温柔、负责、关怀学生",
  "dialogues": {
    "first_meeting": {
      "dialogue_id": "iruka_first_meeting",
      "speaker": "iruka",
      "text": "你好！我是伊鲁卡，是这所忍者学校的老师。你是新来的学生吗？",
      "emotion": "friendly",
      "bgm": "bgm_school",
      "choices": [
        "我想报名参加入学考试",
        "我只是来了解一下",
        "我需要学习忍术"
      ]
    },
    "enrollment": {
      "dialogue_id": "iruka_enrollment",
      "speaker": "iruka",
      "text": "欢迎加入！忍者学校会教你成为优秀忍者所需的一切知识。不过，入学考试有些难度，你需要好好准备。",
      "emotion": "encouraging",
      "bgm": "bgm_school",
      "choices": [
        "我需要做什么准备？",
        "我有信心能通过",
        "有没有额外的学习机会？"
      ]
    },
    "exam_preparation": {
      "dialogue_id": "iruka_exam_preparation",
      "speaker": "iruka",
      "text": "入学考试包括三个部分：查克拉控制、体术测试和理论考试。你需要掌握基础的查克拉提炼，能够完成基本的体术动作，还要了解忍者的基本知识。",
      "emotion": "serious",
      "bgm": "bgm_school",
      "choices": [
        "我会好好准备的",
        "能不能给我一些练习建议？",
        "理论考试考什么内容？"
      ]
    },
    "private_lesson_offer": {
      "dialogue_id": "iruka_private_lesson_offer",
      "speaker": "iruka",
      "text": "我看你学习很认真，愿意花额外的时间来准备。如果你愿意，我可以给你一些私人课程，帮助你更好地准备考试。",
      "emotion": "kind",
      "bgm": "bgm_school",
      "choices": [
        "我非常愿意！",
        "我需要考虑一下",
        "这要多少钱？"
      ]
    },
    "praise": {
      "dialogue_id": "iruka_praise",
      "speaker": "iruka",
      "text": "你的进步很快！继续保持这样的努力，我相信你一定能成为优秀的忍者。",
      "emotion": "proud",
      "bgm": "bgm_school",
      "choices": [
        "谢谢老师！",
        "我会更加努力的",
        "还有什么需要改进的吗？"
      ]
    },
    "encouragement": {
      "dialogue_id": "iruka_encouragement",
      "speaker": "iruka",
      "text": "失败了也没关系，重要的是从失败中学习。忍者就是要不断面对挫折，然后站起来继续前进。你可以的！",
      "emotion": "supportive",
      "bgm": "bgm_school",
      "choices": [
        "谢谢老师的鼓励",
        "我会继续努力",
        "我再试一次"
      ]
    },
    "farewell": {
      "dialogue_id": "iruka_farewell",
      "speaker": "iruka",
      "text": "好了，今天的学习就到这里吧。回去好好休息，明天继续努力！",
      "emotion": "friendly",
      "bgm": "bgm_school",
      "choices": [
        "再见老师",
        "谢谢老师",
        "明天见"
      ]
    }
  }
}
```

### 卡卡西（Kakashi）

```json
{
  "character": "kakashi",
  "name": "旗木卡卡西",
  "title": "暗部精英/第七班导师",
  "personality": "冷静、腹黑、神秘",
  "dialogues": {
    "first_meeting": {
      "dialogue_id": "kakashi_first_meeting",
      "speaker": "kakashi",
      "text": "哦？你是新人？让我看看……嗯，看起来还不错。",
      "emotion": "indifferent",
      "bgm": "bgm_mysterious",
      "choices": [
        "请多多指教",
        "您是谁？",
        "我需要提升实力"
      ]
    },
    "team_7_mention": {
      "dialogue_id": "kakashi_team_7_mention",
      "speaker": "kakashi",
      "text": "你是说鸣人他们吗？那三个小家伙确实很让人头疼，但也很有潜力。他们让我想起了年轻时的自己。",
      "emotion": "nostalgic",
      "bgm": "bgm_sentimental",
      "choices": [
        "他们真的很厉害吗？",
        "您是怎么成为他们的老师的？",
        "我想变得像他们一样强"
      ]
    },
    "advice": {
      "dialogue_id": "kakashi_advice",
      "speaker": "kakashi",
      "text": "在忍界生存，力量是必要的，但更重要的是什么力量应该用来做什么。记住，保护同伴比任何忍术都重要。",
      "emotion": "serious",
      "bgm": "bgm_wisdom",
      "choices": [
        "我记住了",
        "您的同伴是谁？",
        "能教我一些技巧吗？"
      ]
    },
    "training": {
      "dialogue_id": "kakashi_training",
      "speaker": "kakashi",
      "text": "你想跟我学？好吧，但我的训练很严格。如果你坚持不下来，随时可以退出。",
      "emotion": "strict",
      "bgm": "bgm_training",
      "choices": [
        "我准备好接受挑战",
        "我能行吗？",
        "从什么开始？"
      ]
    },
    "chidori_mention": {
      "dialogue_id": "kakashi_chidori_mention",
      "speaker": "kakashi",
      "text": "千鸟吗？那是我开发的忍术，用来配合写轮眼使用。不过，现在的你还没有掌握它的资格。继续努力吧。",
      "emotion": "serious",
      "bgm": "bgm_mysterious",
      "choices": [
        "我想学习千鸟",
        "写轮眼是什么？",
        "我需要达到什么水平？"
      ]
    },
    "raikiri_stories": {
      "dialogue_id": "kakashi_raikiri_stories",
      "speaker": "kakashi",
      "text": "雷切啊……那是我的成名技。我曾经用它切过闪电，所以叫雷切。不过，这个忍术的诞生……付出了很大的代价。",
      "emotion": "melancholic",
      "bgm": "bgm_sentimental",
      "choices": [
        "什么样的代价？",
        "我明白了",
        "对不起提起这个"
      ]
    },
    "friendship": {
      "dialogue_id": "kakashi_friendship",
      "speaker": "kakashi",
      "text": "朋友……我失去过很多朋友。所以现在我更加珍惜身边的人。你也一样，要珍惜你的同伴。",
      "emotion": "deep",
      "bgm": "bgm_sentimental",
      "choices": [
        "我会的",
        "失去朋友一定很痛苦",
        "您能告诉我更多吗？"
      ]
    },
    "hokage_path": {
      "dialogue_id": "kakashi_hokage_path",
      "speaker": "kakashi",
      "text": "成为火影吗？那是一条充满荆棘的道路。你需要承受整个村子的重量，做出艰难的选择。你真的准备好了吗？",
      "emotion": "serious",
      "bgm": "bgm_epic",
      "choices": [
        "我已经做好了准备",
        "我会考虑清楚",
        "火影是怎样的存在？"
      ]
    }
  }
}
```

### 鸣人（Naruto）

```json
{
  "character": "naruto",
  "name": "漩涡鸣人",
  "title": "预言之子",
  "personality": "热血、直率、永不放弃",
  "dialogues": {
    "first_meeting": {
      "dialogue_id": "naruto_first_meeting",
      "speaker": "naruto",
      "text": "哟！我是漩涡鸣人，是要成为火影的男人！你是谁啊？",
      "emotion": "energetic",
      "bgm": "bgm_energetic",
      "choices": [
        "我是新来的",
        "很高兴认识你",
        "火影是个什么样的职业？"
      ]
    },
    "ramen": {
      "dialogue_id": "naruto_ramen",
      "speaker": "naruto",
      "text": "一乐拉面是世界上最好吃的拉面！你要不要试试？手打大叔的手艺可是全村最好的！",
      "emotion": "excited",
      "bgm": "bgm_ramen",
      "choices": [
        "好啊，请你一碗",
        "我也很喜欢拉面",
        "你经常来这里吗？"
      ]
    },
    "determination": {
      "dialogue_id": "naruto_determination",
      "speaker": "naruto",
      "text": "不管别人怎么说，我都不会放弃的！我要让大家认可我，我要成为火影，保护大家！",
      "emotion": "passionate",
      "bgm": "bgm_determined",
      "choices": [
        "我相信你能做到",
        "我也想成为像你一样的人",
        "是什么让你这么坚持？"
      ]
    },
    "sasuke": {
      "dialogue_id": "naruto_sasuke",
      "speaker": "naruto",
      "text": "佐助……他是我最好的朋友，也是我最大的对手。我们约定过，只有击败对方才能实现各自的理想。",
      "emotion": "conflicted",
      "bgm": "bgm_sentimental",
      "choices": [
        "你们的关系很特别",
        "你会赢过他吗？",
        "理想是什么？"
      ]
    },
    "kyuubi": {
      "dialogue_id": "naruto_kyuubi",
      "speaker": "naruto",
      "text": "九尾……它是我的力量，也是我的诅咒。但我会控制它，用它来保护我想保护的人！",
      "emotion": "determined",
      "bgm": "bgm_mysterious",
      "choices": [
        "那一定很难",
        "你需要帮助吗？",
        "九尾是什么？"
      ]
    },
    "friendship_offer": {
      "dialogue_id": "naruto_friendship_offer",
      "speaker": "naruto",
      "text": "你看起来是个不错的人！我们做朋友吧！有困难的话，我会帮你的！",
      "emotion": "friendly",
      "bgm": "bgm_friendship",
      "choices": [
        "我很乐意做你的朋友",
        "谢谢你的好意",
        "我们互相帮助"
      ]
    },
    "encouragement": {
      "dialogue_id": "naruto_encouragement",
      "speaker": "naruto",
      "text": "别放弃啊！忍者就是遇到困难也要继续前进的人！如果你放弃了，那就不是真正的忍者了！",
      "emotion": "enthusiastic",
      "bgm": "bgm_energetic",
      "choices": [
        "你说得对",
        "我不会放弃的",
        "谢谢你鸣人"
      ]
    }
  }
}
```

### 佐助（Sasuke）

```json
{
  "character": "sasuke",
  "name": "宇智波佐助",
  "title": "复仇者",
  "personality": "冷傲、执着、聪明",
  "dialogues": {
    "first_meeting": {
      "dialogue_id": "sasuke_first_meeting",
      "speaker": "sasuke",
      "text": "……你找我有事吗？我正忙。",
      "emotion": "cold",
      "bgm": "bgm_cool",
      "choices": [
        "我想认识你",
        "你在做什么？",
        "抱歉打扰了"
      ]
    },
    "uchiha": {
      "dialogue_id": "sasuke_uchiha",
      "speaker": "sasuke",
      "text": "宇智波一族……那是一个已经不复存在的家族。如果你只是想打听八卦，那就别浪费时间了。",
      "emotion": "cold",
      "bgm": "bgm_dark",
      "choices": [
        "我不是想打听八卦",
        "发生了什么？",
        "对不起，我不该问"
      ]
    },
    "revenge": {
      "dialogue_id": "sasuke_revenge",
      "speaker": "sasuke",
      "text": "复仇……那是我的道路。我要杀死那个男人，为宇智波一族报仇。其他任何事情都不能阻挡我。",
      "emotion": "determined",
      "bgm": "bgm_dark",
      "choices": [
        "复仇真的是正确的吗？",
        "我能帮你吗？",
        "那个男人是谁？"
      ]
    },
    "naruto": {
      "dialogue_id": "sasuke_naruto",
      "speaker": "sasuke",
      "text": "鸣人……那家伙是个傻瓜。但是，只有他才能跟我匹敌。他是……我唯一的朋友。",
      "emotion": "complex",
      "bgm": "bgm_sentimental",
      "choices": [
        "你们的关系很复杂",
        "朋友和对手吗？",
        "你很重视他"
      ]
    },
    "power": {
      "dialogue_id": "sasuke_power",
      "speaker": "sasuke",
      "text": "力量……我需要更多的力量。只有足够的力量，才能杀死那个男人。只要能达成目的，我不在乎使用什么手段。",
      "emotion": "obsessed",
      "bgm": "bgm_dark",
      "choices": [
        "力量不是一切",
        "你已经很强了",
        "为什么要这么执着？"
      ]
    },
    "sharigan": {
      "dialogue_id": "sasuke_sharigan",
      "speaker": "sasuke",
      "text": "写轮眼……宇智波一族的血继限界。它可以看穿忍术，复制忍术，甚至控制九尾。但这双眼睛……是用鲜血换来的。",
      "emotion": "melancholic",
      "bgm": "bgm_mysterious",
      "choices": [
        "这很痛苦吗？",
        "写轮眼有多强？",
        "你能控制它吗？"
      ]
    },
    "friendship": {
      "dialogue_id": "sasuke_friendship",
      "speaker": "sasuke",
      "text": "朋友……我曾经有过。但现在，复仇的道路不允许我拥有朋友。你不要靠近我，对你没有好处。",
      "emotion": "cold",
      "bgm": "bgm_dark",
      "choices": [
        "我愿意冒险",
        "你需要朋友",
        "我明白了"
      ]
    }
  }
}
```

### 小樱（Sakura）

```json
{
  "character": "sakura",
  "name": "春野樱",
  "title": "医疗忍者",
  "personality": "坚强、聪明、温柔",
  "dialogues": {
    "first_meeting": {
      "dialogue_id": "sakura_first_meeting",
      "speaker": "sakura",
      "text": "你好！我是春野樱。你找我有事吗？",
      "emotion": "friendly",
      "bgm": "bgm_light",
      "choices": [
        "我想认识你",
        "听说你是医疗忍者？",
        "你看起来很厉害"
      ]
    },
    "medical_ninja": {
      "dialogue_id": "sakura_medical_ninja",
      "speaker": "sakura",
      "text": "是的，我跟随纲手大人学习了医疗忍术。医疗忍者不仅能治疗伤员，还能在战斗中发挥作用。",
      "emotion": "proud",
      "bgm": "bgm_wisdom",
      "choices": [
        "那一定很难",
        "纲手大人是谁？",
        "我能学习医疗忍术吗？"
      ]
    },
    "training": {
      "dialogue_id": "sakura_training",
      "speaker": "sakura",
      "text": "训练医疗忍术需要大量的练习。你需要了解人体结构，掌握查克拉控制，还要有精准的判断力。",
      "emotion": "serious",
      "bgm": "bgm_training",
      "choices": [
        "我能做到吗？",
        "能教我一些基础知识吗？",
        "需要准备什么？"
      ]
    },
    "team_7": {
      "dialogue_id": "sakura_team_7",
      "speaker": "sakura",
      "text": "鸣人、佐助……他们是我的队友，也是我很重要的人。虽然我们经历了很多困难，但我们是永远的朋友。",
      "emotion": "nostalgic",
      "bgm": "bgm_sentimental",
      "choices": [
        "你们的关系真好",
        "你也很重视他们",
        "你们经历了什么？"
      ]
    },
    "tsunade": {
      "dialogue_id": "sakura_tsunade",
      "speaker": "sakura",
      "text": "纲手大人是我的老师，也是我学习的榜样。她教会我医疗忍术，也教会我如何成为坚强的人。",
      "emotion": "respectful",
      "bgm": "bgm_wisdom",
      "choices": [
        "她一定很厉害",
        "你能成为像她一样的人",
        "她教会了你什么？"
      ]
    },
    "strength": {
      "dialogue_id": "sakura_strength",
      "speaker": "sakura",
      "text": "以前我总觉得自己很弱，只会依赖别人。但现在不同了，我有了保护大家的力量！",
      "emotion": "confident",
      "bgm": "bgm_epic",
      "choices": [
        "你变强了",
        "是什么样的力量？",
        "你是怎么做到的？"
      ]
    },
    "support": {
      "dialogue_id": "sakura_support",
      "speaker": "sakura",
      "text": "如果你需要帮助，随时可以来找我。无论是医疗问题还是其他事情，我都会尽力帮你。",
      "emotion": "kind",
      "bgm": "bgm_friendship",
      "choices": [
        "谢谢你小樱",
        "我会记住的",
        "有什么我能帮你的吗？"
      ]
    }
  }
}
```

---

## NPC对话

### 手打（Teuchi - 一乐拉面店老板）

```json
{
  "character": "teuchi",
  "name": "手打",
  "title": "一乐拉面店老板",
  "personality": "热情、善良、厨艺高超",
  "dialogues": {
    "greeting": {
      "dialogue_id": "teuchi_greeting",
      "speaker": "teuchi",
      "text": "欢迎光临一乐！今天想吃点什么？我们有特制豚骨拉面、味噌拉面，还有很多其他口味！",
      "emotion": "enthusiastic",
      "bgm": "bgm_ramen",
      "choices": [
        "来一碗豚骨拉面",
        "你推荐什么？",
        "鸣人经常来吗？"
      ]
    },
    "naruto_mention": {
      "dialogue_id": "teuchi_naruto_mention",
      "speaker": "teuchi",
      "text": "鸣人那孩子啊，经常来我这里吃饭。他是个好孩子，虽然大家都不怎么理解他，但我知道他的心是善良的。",
      "emotion": "kind",
      "bgm": "bgm_sentimental",
      "choices": [
        "你也关心他",
        "他为什么不受欢迎？",
        "你是个好人"
      ]
    },
    "ramen_passion": {
      "dialogue_id": "teuchi_ramen_passion",
      "speaker": "teuchi",
      "text": "做拉面是我的生命！每一碗拉面都倾注了我的心血。看着客人满足的表情，就是我最大的幸福。",
      "emotion": "passionate",
      "bgm": "bgm_warm",
      "choices": [
        "你的拉面真的很好吃",
        "做拉面需要什么？",
        "我也能学习做拉面吗？"
      ]
    },
    "delivery": {
      "dialogue_id": "teuchi_delivery",
      "speaker": "teuchi",
      "text": "有时候店里忙不过来，会有人帮忙送拉面。你要是有空的话，也可以帮忙，报酬优厚哦！",
      "emotion": "businesslike",
      "bgm": "bgm_light",
      "choices": [
        "我愿意帮忙",
        "报酬是多少？",
        "需要注意什么？"
      ]
    }
  }
}
```

### 菖蒲（Ayame - 手打的女儿）

```json
{
  "character": "ayame",
  "name": "菖蒲",
  "title": "一乐拉面店店员",
  "personality": "温柔、细心、可爱",
  "dialogues": {
    "greeting": {
      "dialogue_id": "ayame_greeting",
      "speaker": "ayame",
      "text": "欢迎光临！今天想吃点什么？",
      "emotion": "gentle",
      "bgm": "bgm_ramen",
      "choices": [
        "来一碗豚骨拉面",
        "有什么推荐？",
        "你工作辛苦了"
      ]
    },
    "naruto": {
      "dialogue_id": "ayame_naruto",
      "speaker": "ayame",
      "text": "鸣人那孩子总是那么有精神，看到他开心地吃拉面，我也觉得很幸福。",
      "emotion": "warm",
      "bgm": "bgm_sentimental",
      "choices": [
        "你也喜欢他",
        "他经常来吗？",
        "你们关系很好"
      ]
    },
    "help": {
      "dialogue_id": "ayame_help",
      "speaker": "ayame",
      "text": "如果你需要帮助，随时可以来找我。虽然我只是一个普通的店员，但我会尽力帮你。",
      "emotion": "kind",
      "bgm": "bgm_friendship",
      "choices": [
        "谢谢你菖蒲",
        "你人真好",
        "有什么我能帮忙的吗？"
      ]
    }
  }
}
```

### 井野（Ino）

```json
{
  "character": "ino",
  "name": "山中井野",
  "title": "山中一族继承人",
  "personality": "自信、时髦、善良",
  "dialogues": {
    "greeting": {
      "dialogue_id": "ino_greeting",
      "speaker": "ino",
      "text": "哟！你是新来的？我是山中井野，欢迎来到木叶！",
      "emotion": "confident",
      "bgm": "bgm_fashion",
      "choices": [
        "很高兴认识你",
        "你很漂亮",
        "山中一族是做什么的？"
      ]
    },
    "flower_shop": {
      "dialogue_id": "ino_flower_shop",
      "speaker": "ino",
      "text": "我家经营花店，如果你喜欢花的话，随时可以来光顾。每种花都有自己的花语哦。",
      "emotion": "enthusiastic",
      "bgm": "bgm_flower",
      "choices": [
        "我喜欢花",
        "能推荐一些花吗？",
        "花语是什么？"
      ]
    },
    "sasuke": {
      "dialogue_id": "ino_sasuke",
      "speaker": "ino",
      "text": "佐助……哼，那个冷傲的家伙。虽然我以前喜欢他，但现在……我已经放下了。重要的是，我找到了更好的自己。",
      "emotion": "mixed",
      "bgm": "bgm_sentimental",
      "choices": [
        "你成长了",
        "那是什么感觉？",
        "佐助知道吗？"
      ]
    },
    "friendship": {
      "dialogue_id": "ino_friendship",
      "speaker": "ino",
      "text": "朋友之间就是要互相支持啊。虽然我和小樱以前是情敌，但现在是最好的朋友了。",
      "emotion": "warm",
      "bgm": "bgm_friendship",
      "choices": [
        "你们的故事很励志",
        "你是怎么做到的？",
        "我和小樱也能成为朋友吗？"
      ]
    }
  }
}
```

---

## 情感状态定义

### 情感状态列表

| 情感ID | 英文 | 说明 | 适用角色 |
|--------|------|------|----------|
| friendly | 友好 | 温和、亲切的态度 | 通用 |
| cold | 冷淡 | 不热情、疏远的态度 | 佐助、部分NPC |
| encouraging | 鼓励 | 给予支持和信心 | 伊鲁卡、鸣人 |
| serious | 严肃 | 认真、不苟言笑 | 卡卡西、三代火影 |
| enthusiastic | 热情 | 充满活力、兴奋 | 鸣人、井野 |
| kind | 善良 | 温柔、关心他人 | 小樱、菖蒲 |
| passionate | 充满激情 | 强烈的情感表达 | 鸣人、手打 |
 nostalgic | 怀旧 | 回忆过去 | 卡卡西、井野 |
| melancholic | 忧郁 | 忧伤、伤感 | 佐助、卡卡西 |
| confident | 自信 | 有信心、坚定 | 小樱、井野 |
| supportive | 支持 | 支持、鼓励 | 鸣人、伊鲁卡 |
| respectful | 尊敬 | 表示尊敬 | 小樱 |
| indifferent | 漠不关心 | 无所谓的态度 | 卡卡西（初次见面） |
| strict | 严厉 | 严格、严肃 | 卡卡西（训练时） |
| complex | 复杂 | 情感复杂 | 佐助、井野 |
| warm | 温暖 | 温暖、亲切 | 菖蒲、手打 |
| businesslike | 商业化 | 公事公办 | 手打（工作时） |
| deep | 深沉 | 情感深沉 | 卡卡西 |
| obsessed | 执着 | 固执、偏执 | 佐助（复仇时） |
| proud | 自豪 | 为自己感到骄傲 | 小樱、伊鲁卡 |
| excited | 兴奋 | 兴奋、激动 | 鸣人、井野 |
| gentle | 温柔 | 轻柔、温和 | 菖蒲、小樱 |
| fashion | 时尚 | 时髦、潮流 | 井野 |

---

## 背景音乐定义

### BGM列表

| BGM ID | 名称 | 场景 | 情感基调 |
|--------|------|------|----------|
| bgm_morning | 清晨之曲 | 早晨醒来 | 温暖、希望 |
| bgm_school | 忍者学校 | 学习、训练 | 积极向上 |
| bgm_ramen | 一乐拉面 | 拉面馆 | 温馨、愉快 |
| bgm_training | 训练 | 修炼、锻炼 | 激励、专注 |
| bgm_battle | 战斗 | 战斗场景 | 紧张、激烈 |
| bgm_sentimental | 感伤 | 情感场景 | 悲伤、怀念 |
| bgm_epic | 史诗 | 高潮场景 | 壮丽、震撼 |
| bgm_mystery | 神秘 | 谜题、探索 | 悬疑、神秘 |
| bgm_dark | 黑暗 | 暗黑场景 | 阴郁、压抑 |
| bgm_wisdom | 智慧 | 传授、指导 | 庄重、深刻 |
| bgm_friendship | 友谊 | 友情场景 | 温暖、感动 |
| bgm_determined | 坚定 | 决心场景 | 坚定、不屈 |
| bgm_energetic | 活力 | 活力场景 | 充满活力 |
| bgm_light | 轻快 | 轻松场景 | 轻松、愉快 |
| bgm_warm | 温暖 | 温暖场景 | 温暖、亲切 |
| bgm_decision | 决策 | 选择场景 | 严肃、重要 |
| bgm_ending | 结局 | 结局场景 | 回味、总结 |
| bgm_rest | 休息 | 休息场景 | 平静、放松 |
| bgm_reading | 阅读 | 阅读场景 | 安静、专注 |
| bgm_practice | 练习 | 练习场景 | 认真、专注 |
| bgm_office | 办公室 | 办公场所 | 正式、商务 |
| bgm_dialogue | 对话 | 对话场景 | 中性、交流 |
| bgm_cool | 酷炫 | 酷炫场景 | 冷酷、帅气 |
| bgm_meditation | 冥想 | 冥想场景 | 宁静、禅意 |
| bgm_flower | 花店 | 花店场景 | 清新、美好 |

---

## 对话使用规范

### 对话触发条件

1. **关系等级触发**：
   - 关系0-5：基础对话
   - 关系6-15：中级对话
   - 关系16-25：高级对话
   - 关系26+：特殊对话

2. **剧情进度触发**：
   - 根据章节解锁特定对话
   - 关键事件后触发情感对话

3. **属性触发**：
   - 特定属性值触发对话
   - 高属性可解锁深层对话

### 对话效果

1. **关系提升**：
   - 普通对话：+1点
   - 好感对话：+2-3点
   - 特殊对话：+4-5点

2. **属性提升**：
   - 智力类对话：+1-2点
   - 查克拉类对话：+1-2点
   - 体术类对话：+1-2点

3. **解锁内容**：
   - 技能、物品、地点、剧情分支等

---

**文档结束**

*此文档包含所有角色的对话数据，后续将根据开发进度持续更新和扩展。*
