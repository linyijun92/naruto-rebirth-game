# 主线剧情文档

## 文档信息
- 版本：v1.0
- 创建日期：2026-02-13
- 负责人：剧情策划
- 状态：草稿

---

## 剧情数据结构说明

本文档使用JSON格式存储主线剧情数据，每个剧情节点包含：
- `id`: 唯一标识
- `chapter`: 所属章节
- `text`: 剧情文本
- `choices`: 玩家选项
- `next_nodes`: 下一个节点ID映射
- `conditions`: 触发条件（可选）
- `effects`: 选项效果（可选）

---

## 主线剧情数据

```json
{
  "main_story": {
    "prologue": {
      "id": "prologue_001",
      "chapter": "序章",
      "title": "觉醒",
      "text": "你在一片混沌中苏醒。头痛欲裂，记忆如同碎片般涌入脑海。\n\n你意识到自己重生到了一个陌生的世界——忍者世界。\n\n这里是火之国，木叶隐村的所在地。你的身份是一个普通的村民之子，父母在战争前夕去世，留给你一座简陋的小屋和微薄的遗产。\n\n窗外的蝉鸣声此起彼伏，阳光透过纸窗洒在榻榻米上。你坐起身，感受到体内流动着一股陌生的能量——查克拉。\n\n这究竟是什么力量？你要如何在这个危险的忍界生存下去？",
      "background_music": "bgm_morning",
      "background_image": "img_room_morning",
      "characters": [],
      "choices": [
        {
          "id": "choice_001",
          "text": "起身查看周围环境",
          "next_node": "prologue_002",
          "effects": {
            "attributes": {
              "intelligence": 1
            }
          }
        },
        {
          "id": "choice_002",
          "text": "尝试感知体内的查克拉",
          "next_node": "prologue_003",
          "effects": {
            "attributes": {
              "chakra": 1
            }
          }
        },
        {
          "id": "choice_003",
          "text": "直接出门探索村子",
          "next_node": "prologue_004",
          "effects": {
            "attributes": {
              "speed": 1
            }
          }
        }
      ]
    },

    "prologue_002": {
      "id": "prologue_002",
      "chapter": "序章",
      "title": "初识",
      "text": "你环顾四周，这是一间典型的和式房间。墙上挂着一把看起来有些年头的木剑，角落里有一个旧木箱。\n\n你走到木箱前，打开一看，里面有几件换洗的衣服、一些硬币，还有一本破旧的书。书的封面上写着《忍者基础理论》。\n\n原来，这个身体的原主人曾经梦想成为忍者，甚至自学了一些基础知识。可惜，他还没来得及参加忍者学校的入学考试，就染上了疾病，在不久前去世了。\n\n你感受到一种责任——继承他的梦想，还是过自己的生活？",
      "background_music": "bgm_mystery",
      "background_image": "img_room_detail",
      "choices": [
        {
          "id": "choice_004",
          "text": "阅读《忍者基础理论》",
          "next_node": "prologue_005",
          "effects": {
            "attributes": {
              "intelligence": 2,
              "ninjutsu": 1
            },
            "unlock": ["knowledge_basic_ninjutsu"]
          }
        },
        {
          "id": "choice_005",
          "text": "拿起木剑试试身手",
          "next_node": "prologue_006",
          "effects": {
            "attributes": {
              "taijutsu": 2
            },
            "unlock": ["item_wooden_sword"]
          }
        },
        {
          "id": "choice_006",
          "text": "收起钱，出门去",
          "next_node": "prologue_004",
          "effects": {
            "money": 100
          }
        }
      ]
    },

    "prologue_003": {
      "id": "prologue_003",
      "chapter": "序章",
      "title": "查克拉的觉醒",
      "text": "你闭上眼睛，尝试感知体内的查克拉。起初什么都没有，但随着你集中精神，一股温暖的能量开始在体内流动。\n\n它从你的腹部——也就是被称为'丹田'的地方——扩散到全身。你能感觉到这股能量的存在，它就像一条沉睡的河流，等待着被唤醒。\n\n根据书中的理论，查克拉是精神和身体能量的结合。普通人也可以通过训练掌握，但天赋和血统决定了你未来的极限。\n\n你是第一次感受到查克拉的存在，这让你对这个身体有了更深的了解。",
      "background_music": "bgm_mystery",
      "background_image": "img_meditation",
      "choices": [
        {
          "id": "choice_007",
          "text": "尝试提炼查克拉",
          "next_node": "prologue_007",
          "effects": {
            "attributes": {
              "chakra": 2
            }
          }
        },
        {
          "id": "choice_008",
          "text": "继续感知查克拉的流动",
          "next_node": "prologue_008",
          "effects": {
            "attributes": {
              "chakra": 1,
              "intelligence": 1
            }
          }
        },
        {
          "id": "choice_009",
          "text": "起身出门，试试能否运用查克拉",
          "next_node": "prologue_004",
          "effects": {
            "attributes": {
              "chakra": 1,
              "speed": 1
            }
          }
        }
      ]
    },

    "prologue_004": {
      "id": "prologue_004",
      "chapter": "序章",
      "title": "木叶村",
      "text": "你推开门，阳光刺得你眯起了眼睛。眼前是木叶村——一个隐藏在森林中的忍者村落。\n\n木制的建筑错落有致，街道两旁是各种店铺。虽然现在是和平时期，但你仍能在一些地方感受到村子的警惕性。\n\n不远处，火影岩高耸入云，四位火影的雕像俯瞰着整个村子。那是一种威严的象征，也是村子的精神支柱。\n\n街道上来来往往的人中，既有身穿马甲的忍者，也有普通的村民。你感受到一种复杂的氛围——表面的和平下，隐藏着危机和挑战。",
      "background_music": "bgm_konoha_village",
      "background_image": "img_konoha_street",
      "choices": [
        {
          "id": "choice_010",
          "text": "前往忍者学校看看",
          "next_node": "chapter1_001",
          "effects": {
            "unlock": ["location_ninja_school"]
          }
        },
        {
          "id": "choice_011",
          "text": "去忍者任务委托处",
          "next_node": "chapter1_002",
          "effects": {
            "unlock": ["location_mission_board"]
          }
        },
        {
          "id": "choice_012",
          "text": "在街道上闲逛，观察村子",
          "next_node": "chapter1_003",
          "effects": {
            "attributes": {
              "intelligence": 1
            },
            "unlock": ["knowledge_village_layout"]
          }
        }
      ]
    },

    "prologue_005": {
      "id": "prologue_005",
      "chapter": "序章",
      "title": "忍者基础",
      "text": "你翻开《忍者基础理论》，开始认真阅读。\n\n书中详细介绍了查克拉的提炼、忍术的基础分类、忍者的等级制度等内容。虽然书已经很旧了，但内容依然有用。\n\n你了解到：\n\n查克拉 = 身体能量 + 精神能量\n忍术等级：E级、D级、C级、B级、A级、S级\n忍者等级：下忍、中忍、上忍、特别上忍、影级\n\n这本书还记录了一些基础的体术动作和查克拉提炼的方法。你感觉自己对这个世界有了初步的认识。",
      "background_music": "bgm_reading",
      "background_image": "img_book_reading",
      "choices": [
        {
          "id": "choice_013",
          "text": "尝试书中的查克拉提炼方法",
          "next_node": "prologue_007",
          "effects": {
            "attributes": {
              "chakra": 2
            },
            "unlock": ["skill_chakra_refinement"]
          }
        },
        {
          "id": "choice_014",
          "text": "练习书中的基础体术",
          "next_node": "prologue_006",
          "effects": {
            "attributes": {
              "taijutsu": 2
            }
          }
        },
        {
          "id": "choice_015",
          "text": "读完书，出门看看",
          "next_node": "prologue_004"
        }
      ]
    },

    "prologue_006": {
      "id": "prologue_006",
      "chapter": "序章",
      "title": "体术练习",
      "text": "你拿起木剑，开始在房间内挥舞。起初动作生硬，但很快你找到了感觉。\n\n身体的记忆开始苏醒——这个身体曾经无数次练习过这些动作。虽然现在还很生疏，但至少基础还在。\n\n你尝试了几种基础剑术：劈、刺、扫、挑。每一个动作都让你感受到手臂和腰部的发力方式。\n\n半个小时后，你已经微微出汗，但精神却很振奋。至少，你有自保的能力了。",
      "background_music": "bgm_training",
      "background_image": "img_training_room",
      "choices": [
        {
          "id": "choice_016",
          "text": "继续练习",
          "next_node": "prologue_009",
          "effects": {
            "attributes": {
              "taijutsu": 1,
              "chakra": -1
            },
            "money": -2
          }
        },
        {
          "id": "choice_017",
          "text": "出门看看村子",
          "next_node": "prologue_004",
          "effects": {
            "attributes": {
              "speed": 1
            }
          }
        },
        {
          "id": "choice_018",
          "text": "休息一下",
          "next_node": "prologue_010",
          "effects": {
            "attributes": {
              "chakra": 1
            }
          }
        }
      ]
    },

    "prologue_007": {
      "id": "prologue_007",
      "chapter": "序章",
      "title": "查克拉提炼",
      "text": "你按照书中的方法开始提炼查克拉。\n\n首先，放松全身，让精神集中。然后，从身体和精神两方面同时汲取能量，让它们在丹田处融合。\n\n起初什么也没有发生，但你没有放弃。一遍又一遍，你感受着体内的变化。\n\n终于，你感觉到一股暖流在丹田处形成，然后缓缓扩散到全身。这就是你的查克拉！\n\n虽然还很微弱，但这是第一步。你成功提炼出了自己的查克拉！",
      "background_music": "bgm_mystery",
      "background_image": "img_chakra_awakening",
      "choices": [
        {
          "id": "choice_019",
          "text": "尝试运用查克拉",
          "next_node": "prologue_011",
          "effects": {
            "attributes": {
              "chakra": 1
            }
          }
        },
        {
          "id": "choice_020",
          "text": "继续提炼查克拉",
          "next_node": "prologue_007",
          "effects": {
            "attributes": {
              "chakra": 2,
              "chakra": -1
            }
          }
        },
        {
          "id": "choice_021",
          "text": "出门，去测试查克拉",
          "next_node": "prologue_004",
          "effects": {
            "attributes": {
              "speed": 1
            }
          }
        }
      ]
    },

    "prologue_008": {
      "id": "prologue_008",
      "chapter": "序章",
      "title": "查克拉感知",
      "text": "你专注于感知查克拉的流动，试图理解它的本质。\n\n经过一段时间的探索，你发现自己的查克拉似乎有某种特性——它比常人的更加纯净，更加温和。\n\n这可能意味着你的天赋不错，也可能只是你的错觉。无论如何，你都需要更多的练习来确认。\n\n你的感知能力在慢慢提高，你能感受到周围环境中微弱的查克拉流动——那是忍者们留下的痕迹。",
      "background_music": "bgm_meditation",
      "background_image": "img_meditation",
      "choices": [
        {
          "id": "choice_022",
          "text": "尝试提炼查克拉",
          "next_node": "prologue_007",
          "effects": {
            "attributes": {
              "chakra": 2,
              "intelligence": 1
            }
          }
        },
        {
          "id": "choice_023",
          "text": "出门去感知更多的查克拉",
          "next_node": "prologue_004",
          "effects": {
            "attributes": {
              "intelligence": 1,
              "chakra": 1
            },
            "unlock": ["skill_chakra_sense"]
          }
        }
      ]
    },

    "prologue_009": {
      "id": "prologue_009",
      "chapter": "序章",
      "title": "体术精进",
      "text": "你继续挥舞着木剑，动作越来越流畅。\n\n身体的记忆在恢复，你的体术水平也在稳步提升。虽然距离真正的强者还很远，但至少你不再是手无缚鸡之力的弱者了。\n\n你感受到体力的消耗，也感受到自己的成长。这就是变强的感觉——虽然缓慢，但确实存在。\n\n你现在可以选择继续修炼，或者出门去探索这个村子。",
      "background_music": "bgm_training",
      "background_image": "img_training",
      "choices": [
        {
          "id": "choice_024",
          "text": "再练一会儿",
          "next_node": "prologue_006",
          "effects": {
            "attributes": {
              "taijutsu": 1,
              "chakra": -2
            }
          }
        },
        {
          "id": "choice_025",
          "text": "出门探索村子",
          "next_node": "prologue_004",
          "effects": {
            "attributes": {
              "speed": 1
            }
          }
        },
        {
          "id": "choice_026",
          "text": "休息一下，恢复体力",
          "next_node": "prologue_010",
          "effects": {
            "attributes": {
              "chakra": 3
            }
          }
        }
      ]
    },

    "prologue_010": {
      "id": "prologue_010",
      "chapter": "序章",
      "title": "休息",
      "text": "你在榻榻米上躺下，让身体得到充分的休息。\n\n窗外，蝉鸣声依旧，但你的内心已经不同了。你不再是那个迷茫的新生者，你有了目标，有了方向。\n\n你在思考接下来的计划——成为忍者？学习忍术？还是过普通人的生活？\n\n这个选择将决定你未来的道路。无论如何，你都需要休息，为明天的冒险做好准备。",
      "background_music": "bgm_rest",
      "background_image": "img_room_rest",
      "choices": [
        {
          "id": "choice_027",
          "text": "思考成为忍者的道路",
          "next_node": "prologue_012",
          "effects": {
            "attributes": {
              "intelligence": 1
            }
          }
        },
        {
          "id": "choice_028",
          "text": "直接出门探索",
          "next_node": "prologue_004"
        },
        {
          "id": "choice_029",
          "text": "继续睡觉",
          "next_node": "chapter1_wakeup",
          "effects": {
            "attributes": {
              "chakra": 5
            }
          }
        }
      ]
    },

    "prologue_011": {
      "id": "prologue_011",
      "chapter": "序章",
      "title": "查克拉运用",
      "text": "你尝试运用刚才提炼出的查克拉。\n\n起初什么也没有发生，但随着你的尝试，查克拉开始听从你的指令。你将查克拉集中到手掌，感受到一股微弱的力量。\n\n虽然还很弱小，但这证明了你确实能够控制查克拉。这是一个重要的里程碑。\n\n你可以继续练习查克拉控制，或者出门去寻找更多的学习机会。",
      "background_music": "bgm_practice",
      "background_image": "img_chakra_control",
      "choices": [
        {
          "id": "choice_030",
          "text": "练习查克拉附着在物体上",
          "next_node": "prologue_013",
          "effects": {
            "attributes": {
              "chakra": 1,
              "ninjutsu": 1
            },
            "unlock": ["skill_tree_climbing"]
          }
        },
        {
          "id": "choice_031",
          "text": "出门去测试查克拉",
          "next_node": "prologue_004",
          "effects": {
            "attributes": {
              "speed": 1
            }
          }
        }
      ]
    },

    "prologue_012": {
      "id": "prologue_012",
      "chapter": "序章",
      "title": "忍者之路",
      "text": "你躺在榻榻米上，思考着成为忍者的可能性。\n\n成为忍者意味着危险、牺牲和战争，但也意味着力量、荣耀和改变世界的可能。\n\n你知道这条路不会平坦，但你内心深处渴望着成长和变强。或许，这真的是你在这个世界的宿命。\n\n现在，你需要做出选择——是踏上这条充满荆棘的忍者之路，还是选择平凡的生活？",
      "background_music": "bgm_decision",
      "background_image": "img_thinking",
      "choices": [
        {
          "id": "choice_032",
          "text": "决定成为忍者",
          "next_node": "chapter1_001",
          "effects": {
            "unlock": ["path_ninja"],
            "attributes": {
              "intelligence": 1
            }
          }
        },
        {
          "id": "choice_033",
          "text": "先不决定，出门看看",
          "next_node": "prologue_004"
        },
        {
          "id": "choice_034",
          "text": "过平凡的生活",
          "next_node": "ending_villager",
          "effects": {
            "unlock": ["path_villager"]
          }
        }
      ]
    },

    "prologue_013": {
      "id": "prologue_013",
      "chapter": "序章",
      "title": "查克拉附着",
      "text": "你尝试将查克拉附着在木剑上。\n\n起初，查克拉像水一样从剑上滑落。但随着你不断尝试，查克拉开始附着在剑的表面，让木剑发出微弱的光芒。\n\n这是查克拉控制的第一步——将查克拉附着在物体上。这是许多高级忍术的基础。\n\n你的木剑现在变得稍微坚硬了一些，虽然只是微不足道的提升，但这是成长的证明。",
      "background_music": "bgm_practice",
      "background_image": "img_sword_with_chakra",
      "choices": [
        {
          "id": "choice_035",
          "text": "尝试用查克拉爬树",
          "next_node": "prologue_014",
          "effects": {
            "attributes": {
              "chakra": 1,
              "taijutsu": 1
            },
            "unlock": ["skill_tree_climbing"]
          }
        },
        {
          "id": "choice_036",
          "text": "出门测试查克拉附着",
          "next_node": "prologue_004",
          "effects": {
            "attributes": {
              "speed": 1
            }
          }
        }
      ]
    },

    "prologue_014": {
      "id": "prologue_014",
      "chapter": "序章",
      "title": "爬树练习",
      "text": "你走到后院，找了一棵树，开始练习用查克拉爬树。\n\n这是忍者学校的经典训练项目——通过将查克拉附着在脚底，克服重力爬上树干。\n\n第一次，你摔倒了。第二次，你爬了几步又滑了下来。但第三次、第四次……你开始掌握技巧。\n\n终于，你成功爬到了树梢！这种成就感让你兴奋不已。你用查克拉控制了重力！",
      "background_music": "bgm_training",
      "background_image": "img_tree_climbing",
      "choices": [
        {
          "id": "choice_037",
          "text": "从树上跳下来，练习落地",
          "next_node": "prologue_015",
          "effects": {
            "attributes": {
              "taijutsu": 1,
              "chakra": -1
            }
          }
        },
        {
          "id": "choice_038",
          "text": "继续练习爬树",
          "next_node": "prologue_014",
          "effects": {
            "attributes": {
              "chakra": 1,
              "taijutsu": 1,
              "chakra": -1
            }
          }
        },
        {
          "id": "choice_039",
          "text": "出门探索村子",
          "next_node": "prologue_004",
          "effects": {
            "attributes": {
              "speed": 1
            }
          }
        }
      ]
    },

    "prologue_015": {
      "id": "prologue_015",
      "chapter": "序章",
      "title": "落地技巧",
      "text": "你从树梢跳下，在空中调整身体姿态。落地时，你用查克拉缓冲冲击，平稳地站在了地上。\n\n这是忍者最重要的技能之一——灵活的身手和精准的查克拉控制。\n\n你的身体在慢慢适应这种高强度的运动，你的查克拉控制也在稳步提升。这让你更加期待明天的到来。\n\n序章即将结束，真正的冒险即将开始。你准备好迎接挑战了吗？",
      "background_music": "bgm_epic",
      "background_image": "img_landing",
      "choices": [
        {
          "id": "choice_040",
          "text": "结束序章，开始第一章",
          "next_node": "chapter1_wakeup",
          "effects": {
            "unlock": ["chapter1"],
            "achievements": ["survived_prologue"]
          }
        }
      ]
    },

    "chapter1_wakeup": {
      "id": "chapter1_wakeup",
      "chapter": "第一章",
      "title": "木叶的清晨",
      "text": "新的一天开始了。阳光透过窗户照进房间，你从梦中醒来。\n\n经过昨天的修炼，你的身体发生了微妙的变化——你的体力和查克拉都比昨天更强了。\n\n你坐起身，伸展身体。今天的计划是什么？是继续修炼，还是出门去探索这个村子？\n\n无论如何，你的忍者之路才刚刚开始。",
      "background_music": "bgm_morning",
      "background_image": "img_wakeup_morning",
      "choices": [
        {
          "id": "choice_041",
          "text": "前往忍者学校",
          "next_node": "chapter1_001",
          "effects": {
            "unlock": ["location_ninja_school"]
          }
        },
        {
          "id": "choice_042",
          "text": "去任务委托处看看",
          "next_node": "chapter1_002",
          "effects": {
            "unlock": ["location_mission_board"]
          }
        },
        {
          "id": "choice_043",
          "text": "继续在房间里修炼",
          "next_node": "chapter1_training",
          "effects": {
            "attributes": {
              "chakra": 2
            }
          }
        }
      ]
    },

    "chapter1_001": {
      "id": "chapter1_001",
      "chapter": "第一章",
      "title": "忍者学校",
      "text": "你来到木叶忍者学校。这是培养下忍的地方，许多未来的强者都曾在这里学习。\n\n现在正是课间休息时间，操场上到处是年轻的学生。他们穿着统一的训练服，脸上洋溢着青春的笑容。\n\n你看到伊鲁卡老师正在和几个学生交谈。他是忍者学校的老师，也是许多学生的启蒙者。\n\n你要如何接近这里？",
      "background_music": "bgm_school",
      "background_image": "img_ninja_school",
      "characters": ["iruka"],
      "choices": [
        {
          "id": "choice_044",
          "text": "直接上前和伊鲁卡老师搭话",
          "next_node": "chapter1_001_iruka",
          "effects": {
            "relationships": {
              "iruka": 1
            },
            "unlock": ["character_iruka"]
          }
        },
        {
          "id": "choice_045",
          "text": "在一旁观察，了解学校的情况",
          "next_node": "chapter1_001_observe",
          "effects": {
            "attributes": {
              "intelligence": 1
            }
          }
        },
        {
          "id": "choice_046",
          "text": "离开，去其他地方",
          "next_node": "chapter1_003"
        }
      ]
    },

    "chapter1_001_iruka": {
      "id": "chapter1_001_iruka",
      "chapter": "第一章",
      "title": "遇见伊鲁卡",
      "text": "你走到伊鲁卡老师面前，礼貌地打招呼。\n\n"你好，我是新来的村民，想了解一下忍者学校的情况。"你说道。\n\n伊鲁卡老师转过头，看着你。他的眼神很温和，带着一丝关心。\n\n"啊，你好！你是想报名参加忍者学校吗？"伊鲁卡问道，"如果是的话，你可以到那边登记。不过，入学考试有些难度，需要做好充分的准备。"\n\n他给你详细介绍了忍者学校的课程、考试时间和注意事项。你感觉他对学生真的很关心。",
      "background_music": "bgm_dialogue",
      "background_image": "img_iruka",
      "characters": ["iruka"],
      "choices": [
        {
          "id": "choice_047",
          "text": "询问如何准备入学考试",
          "next_node": "chapter1_001_preparation",
          "effects": {
            "relationships": {
              "iruka": 2
            },
            "unlock": ["knowledge_exam_preparation"]
          }
        },
        {
          "id": "choice_048",
          "text": "感谢伊鲁卡老师，离开",
          "next_node": "chapter1_003",
          "effects": {
            "relationships": {
              "iruka": 1
            }
          }
        },
        {
          "id": "choice_049",
          "text": "询问是否有额外的学习机会",
          "next_node": "chapter1_001_tutoring",
          "effects": {
            "relationships": {
              "iruka": 3
            },
            "unlock": ["quest_private_lesson"]
          }
        }
      ]
    },

    "chapter1_002": {
      "id": "chapter1_002",
      "chapter": "第一章",
      "title": "任务委托处",
      "text": "你来到忍者任务委托处。这里是发布任务的地方，从简单的D级任务到危险的S级任务，都可以在这里找到。\n\n现在有几个忍者正在登记处领取任务，墙上贴满了各种委托单。\n\n你看到D级任务大多是些日常杂活——帮邻居找猫、帮店铺搬货物、修整房屋等。而高级任务则涉及战斗和危险。\n\n作为普通人，你只能接一些简单的任务来赚钱。",
      "background_music": "bgm_office",
      "background_image": "img_mission_board",
      "choices": [
        {
          "id": "choice_050",
          "text": "查看可接的D级任务",
          "next_node": "chapter1_002_drank",
          "effects": {
            "unlock": ["mission_list_d_rank"]
          }
        },
        {
          "id": "choice_051",
          "text": "向负责人询问任务情况",
          "next_node": "chapter1_002_info",
          "effects": {
            "unlock": ["knowledge_mission_system"]
          }
        },
        {
          "id": "choice_052",
          "text": "离开，去其他地方",
          "next_node": "chapter1_003"
        }
      ]
    },

    "chapter1_003": {
      "id": "chapter1_003",
      "chapter": "第一章",
      "title": "木叶街道",
      "text": "你在木叶的街道上漫步。\n\n木叶的建筑风格统一，大多是木质结构，透露着古朴的气息。街道两旁是各种店铺——忍具店、拉面馆、花店、书店……\n\n你感受到村子的活力和秩序。虽然这是一个军事化的忍者村落，但居民们的生活依然丰富多彩。\n\n远处，火影岩上四位火影的雕像俯瞰着整个村子。那是村子的象征，也是力量的象征。\n\n你想先去哪里？",
      "background_music": "bgm_konoha_village",
      "background_image": "img_konoha_street",
      "choices": [
        {
          "id": "choice_053",
          "text": "去一乐拉面馆",
          "next_node": "chapter1_ramen",
          "effects": {
            "unlock": ["location_ichiraku_ramen"]
          }
        },
        {
          "id": "choice_054",
          "text": "去忍具店看看",
          "next_node": "chapter1_ninja_tool",
          "effects": {
            "unlock": ["location_ninja_tool_shop"]
          }
        },
        {
          "id": "choice_055",
          "text": "返回忍者学校",
          "next_node": "chapter1_001"
        }
      ]
    },

    "chapter1_training": {
      "id": "chapter1_training",
      "chapter": "第一章",
      "title": "日常修炼",
      "text": "你决定继续在房间里修炼。\n\n经过昨天的训练，你已经掌握了基础的查克拉提炼和体术动作。今天，你计划进行更深入的练习。\n\n你选择什么修炼内容？",
      "background_music": "bgm_training",
      "background_image": "img_training",
      "choices": [
        {
          "id": "choice_056",
          "text": "提炼查克拉",
          "next_node": "chapter1_training_chakra",
          "effects": {
            "attributes": {
              "chakra": 2
            }
          }
        },
        {
          "id": "choice_057",
          "text": "体术训练",
          "next_node": "chapter1_training_taijutsu",
          "effects": {
            "attributes": {
              "taijutsu": 2
            }
          }
        },
        {
          "id": "choice_058",
          "text": "出门去忍者学校",
          "next_node": "chapter1_001"
        }
      ]
    },

    "ending_villager": {
      "id": "ending_villager",
      "chapter": "结局",
      "title": "普通村民",
      "text": "你选择了过平凡的生活。\n\n你不再追求力量，不再渴望成为忍者。你在木叶村找到一个普通的工作，过着平静而安稳的日子。\n\n偶尔，你会看到忍者们从你身边走过，去执行任务。你会感叹他们的伟大，也会庆幸自己的选择。\n\n这就是你的一生——平凡，但真实。\n\n\n【结局达成：普通村民】\n\n这是一个平凡的结局，也许不够精彩，但你选择了自己的道路。\n\n你可以在重生后选择不同的人生。",
      "background_music": "bgm_ending",
      "background_image": "img_ending_villager",
      "choices": [
        {
          "id": "choice_059",
          "text": "重新开始",
          "next_node": "rebirth_start",
          "effects": {
            "unlock": ["ending_villager"],
            "achievements": ["ending_1_villager"]
          }
        }
      ]
    }
  }
}
```

---

## 剧情节点索引

### 序章（Prologue）

| 节点ID | 标题 | 类型 |
|--------|------|------|
| prologue_001 | 觉醒 | 开始节点 |
| prologue_002 | 初识 | 探索节点 |
| prologue_003 | 查克拉的觉醒 | 查克拉节点 |
| prologue_004 | 木叶村 | 探索节点 |
| prologue_005 | 忍者基础 | 学习节点 |
| prologue_006 | 体术练习 | 训练节点 |
| prologue_007 | 查克拉提炼 | 查克拉节点 |
| prologue_008 | 查克拉感知 | 查克拉节点 |
| prologue_009 | 体术精进 | 训练节点 |
| prologue_010 | 休息 | 休息节点 |
| prologue_011 | 查克拉运用 | 技能节点 |
| prologue_012 | 忍者之路 | 关键决策 |
| prologue_013 | 查克拉附着 | 技能节点 |
| prologue_014 | 爬树练习 | 技能节点 |
| prologue_015 | 落地技巧 | 技能节点 |

### 第一章（Chapter 1）

| 节点ID | 标题 | 类型 |
|--------|------|------|
| chapter1_wakeup | 木叶的清晨 | 开始节点 |
| chapter1_001 | 忍者学校 | 地点节点 |
| chapter1_001_iruka | 遇见伊鲁卡 | 羁绊节点 |
| chapter1_001_preparation | 入学考试准备 | 学习节点 |
| chapter1_001_tutoring | 私人课程 | 任务节点 |
| chapter1_002 | 任务委托处 | 地点节点 |
| chapter1_002_drank | D级任务列表 | 任务节点 |
| chapter1_002_info | 任务系统介绍 | 信息节点 |
| chapter1_003 | 木叶街道 | 探索节点 |
| chapter1_ramen | 一乐拉面馆 | 地点节点 |
| chapter1_ninja_tool | 忍具店 | 地点节点 |
| chapter1_training | 日常修炼 | 训练节点 |
| chapter1_training_chakra | 查克拉训练 | 训练节点 |
| chapter1_training_taijutsu | 体术训练 | 训练节点 |

### 结局（Endings）

| 节点ID | 标题 | 类型 |
|--------|------|------|
| ending_villager | 普通村民 | 普通结局 |
| rebirth_start | 重新开始 | 重生节点 |

---

## 剧情创作规范

### 节点创建标准

每个剧情节点必须包含：
1. **唯一ID**：格式为 `chapter_node_number`
2. **章节归属**：明确所属章节
3. **标题**：简洁概括节点内容
4. **剧情文本**：200-500字，描述当前情境
5. **背景音乐**：建议BGM（可选）
6. **背景图片**：建议场景图（可选）
7. **出场角色**：列表格式（可选）
8. **选项**：至少2个，最多5个
9. **效果**：属性变化、解锁内容等

### 选择分支原则

1. **意义明确**：每个选项都应有明确的目的和后果
2. **条件限制**：高级选项可以设置属性或关系要求
3. **多样性**：提供不同类型的选项（战斗、探索、学习等）
4. **反馈及时**：选择后立即显示效果

### 属性影响规则

- **属性增长**：每次选择最多+3点
- **属性消耗**：体力消耗-1到-5
- **关系变化**：+1到+5点
- **解锁内容**：技能、地点、角色等

---

**文档结束**

*此文档包含主线剧情的核心数据，后续将根据开发进度持续更新。*
