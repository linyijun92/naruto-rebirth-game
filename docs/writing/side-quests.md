# 支线任务文档

## 文档信息
- 版本：v1.0
- 创建日期：2026-02-13
- 负责人：剧情策划
- 状态：草稿

---

## 支线任务数据结构

```json
{
  "quest_id": "唯一ID",
  "name": "任务名称",
  "type": "任务类型",
  "rank": "任务等级",
  "chapter": "所属章节",
  "location": "任务地点",
  "giver": "发布者NPC",
  "description": "任务描述",
  "requirements": {
    "min_level": 1,
    "required_skills": [],
    "required_relationships": {},
    "required_attributes": {}
  },
  "objectives": [
    {
      "id": "obj_001",
      "description": "目标描述",
      "target": "目标对象",
      "count": 1
    }
  ],
  "rewards": {
    "experience": 100,
    "money": 500,
    "attributes": {},
    "items": [],
    "unlock": [],
    "relationships": {}
  },
  "steps": [
    {
      "step_id": "step_001",
      "description": "步骤描述",
      "dialogue": "对话文本",
      "conditions": {},
      "rewards": {}
    }
  ],
  "completion_condition": "完成条件",
  "failure_condition": "失败条件",
  "repeatable": false,
  "cooldown": 0
}
```

---

## 支线任务数据库

```json
{
  "side_quests": {
    "sq001_lost_cat": {
      "quest_id": "sq001_lost_cat",
      "name": "丢失的猫咪",
      "type": "fetch",
      "rank": "D",
      "chapter": "chapter1",
      "location": "konoha_village",
      "giver": "old_lady",
      "description": "一位老奶奶的宠物猫不见了，她非常担心，请求你帮忙寻找。",
      "requirements": {
        "min_level": 1,
        "required_skills": [],
        "required_relationships": {},
        "required_attributes": {}
      },
      "objectives": [
        {
          "id": "obj_001",
          "description": "在木叶村中找到丢失的猫",
          "target": "cat",
          "count": 1
        },
        {
          "id": "obj_002",
          "description": "将猫带回给老奶奶",
          "target": "old_lady",
          "count": 1
        }
      ],
      "rewards": {
        "experience": 50,
        "money": 100,
        "attributes": {
          "intelligence": 1,
          "speed": 1
        },
        "items": [],
        "unlock": ["relationship_old_lady"],
        "relationships": {
          "old_lady": 2
        }
      },
      "steps": [
        {
          "step_id": "step_001",
          "description": "接取任务",
          "dialogue": {
            "speaker": "老奶奶",
            "text": "年轻人，拜托你了！我的猫咪'咪咪'不见了。它是一只白色的波斯猫，戴着红色的项圈。如果你能帮我找到它，我会感激不尽的！"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_002",
          "description": "寻找猫咪",
          "dialogue": {
            "speaker": "system",
            "text": "你在村子里四处寻找。猫咪可能藏在这些地方：\n- 花园的灌木丛中\n- 屋顶上\n- 面馆的后面\n- 公园的长椅下"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_003",
          "description": "找到猫咪",
          "dialogue": {
            "speaker": "system",
            "text": "你在一乐拉面馆后面的巷子里找到了咪咪！它正蜷缩在纸箱里，看起来很饿。"
          },
          "conditions": {
            "attributes": {
              "intelligence": 1
            }
          },
          "rewards": {}
        },
        {
          "step_id": "step_004",
          "description": "返回老奶奶家",
          "dialogue": {
            "speaker": "老奶奶",
            "text": "咪咪！你回来了！太感谢你了年轻人！这些钱你收下吧，这是我的一点心意。"
          },
          "conditions": {},
          "rewards": {
            "experience": 50,
            "money": 100
          }
        }
      ],
      "completion_condition": "objective_obj_002_completed",
      "failure_condition": "time_limit_exceeded",
      "repeatable": true,
      "cooldown": 24
    },

    "sq002_ramen_delivery": {
      "quest_id": "sq002_ramen_delivery",
      "name": "拉面配送",
      "type": "delivery",
      "rank": "D",
      "chapter": "chapter1",
      "location": "konoha_village",
      "giver": "teuchi",
      "description": "一乐拉面馆的老板手打人手不足，需要你帮忙配送拉面。",
      "requirements": {
        "min_level": 1,
        "required_skills": [],
        "required_relationships": {
          "teuchi": 0
        },
        "required_attributes": {
          "speed": 5
        }
      },
      "objectives": [
        {
          "id": "obj_001",
          "description": "领取需要配送的拉面",
          "target": "teuchi",
          "count": 1
        },
        {
          "id": "obj_002",
          "description": "将拉面送到指定地点",
          "target": "delivery_location",
          "count": 3
        },
        {
          "id": "obj_003",
          "description": "返回店铺汇报",
          "target": "teuchi",
          "count": 1
        }
      ],
      "rewards": {
        "experience": 100,
        "money": 200,
        "attributes": {
          "speed": 2
        },
        "items": ["item_ramen_coupon"],
        "unlock": ["relationship_teuchi"],
        "relationships": {
          "teuchi": 3
        }
      },
      "steps": [
        {
          "step_id": "step_001",
          "description": "接取任务",
          "dialogue": {
            "speaker": "手打",
            "text": "喂，年轻人！看你体力不错，能帮个忙吗？今天店里太忙了，需要帮忙送几碗拉面。报酬优厚哦！"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_002",
          "description": "领取拉面",
          "dialogue": {
            "speaker": "手打",
            "text": "好，这里有三个订单，地址都写在上面了。记住要快，拉面要趁热吃才好吃！"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_003",
          "description": "配送拉面（1/3）",
          "dialogue": {
            "speaker": "customer",
            "text": "啊，一乐的拉面！谢谢！"
          },
          "conditions": {},
          "rewards": {
            "money": 50
          }
        },
        {
          "step_id": "step_004",
          "description": "配送拉面（2/3）",
          "dialogue": {
            "speaker": "customer",
            "text": "太好了！正是我想吃的！"
          },
          "conditions": {},
          "rewards": {
            "money": 50
          }
        },
        {
          "step_id": "step_005",
          "description": "配送拉面（3/3）",
          "dialogue": {
            "speaker": "customer",
            "text": "谢谢你年轻人！下次再来！"
          },
          "conditions": {},
          "rewards": {
            "money": 50
          }
        },
        {
          "step_id": "step_006",
          "description": "返回店铺",
          "dialogue": {
            "speaker": "手打",
            "text": "干得漂亮！这是你的报酬，还有一张拉面优惠券，下次来可以免费吃一碗！"
          },
          "conditions": {},
          "rewards": {
            "experience": 100,
            "money": 50,
            "items": ["item_ramen_coupon"]
          }
        }
      ],
      "completion_condition": "objective_obj_003_completed",
      "failure_condition": "ramen_cold",
      "repeatable": true,
      "cooldown": 12
    },

    "sq003_private_lesson": {
      "quest_id": "sq003_private_lesson",
      "name": "私人课程",
      "type": "learning",
      "rank": "C",
      "chapter": "chapter1",
      "location": "ninja_school",
      "giver": "iruka",
      "description": "伊鲁卡老师同意给你提供私人课程，帮助你准备忍者学校的入学考试。",
      "requirements": {
        "min_level": 2,
        "required_skills": [],
        "required_relationships": {
          "iruka": 3
        },
        "required_attributes": {
          "intelligence": 10
        }
      },
      "objectives": [
        {
          "id": "obj_001",
          "description": "参加第一次课程",
          "target": "iruka",
          "count": 1
        },
        {
          "id": "obj_002",
          "description": "完成基础体术训练",
          "target": "training_ground",
          "count": 1
        },
        {
          "id": "obj_003",
          "description": "通过基础理论测试",
          "target": "iruka",
          "count": 1
        },
        {
          "id": "obj_004",
          "description": "参加最终考核",
          "target": "iruka",
          "count": 1
        }
      ],
      "rewards": {
        "experience": 500,
        "money": 0,
        "attributes": {
          "taijutsu": 5,
          "ninjutsu": 3,
          "intelligence": 3
        },
        "items": ["item_textbook_basic"],
        "unlock": ["skill_basic_ninjutsu", "skill_basic_taijutsu"],
        "relationships": {
          "iruka": 5
        }
      },
      "steps": [
        {
          "step_id": "step_001",
          "description": "开始课程",
          "dialogue": {
            "speaker": "伊鲁卡",
            "text": "好，既然你这么努力，我就教你一些基础知识。首先是查克拉的提炼和控制，这是所有忍术的基础。"
          },
          "conditions": {},
          "rewards": {
            "attributes": {
              "ninjutsu": 1,
              "chakra": 2
            }
          }
        },
        {
          "step_id": "step_002",
          "description": "体术训练",
          "dialogue": {
            "speaker": "伊鲁卡",
            "text": "接下来是体术。即使你不会忍术，强健的体魄也能让你在战斗中占据优势。来，跟我一起练习基本动作！"
          },
          "conditions": {},
          "rewards": {
            "attributes": {
              "taijutsu": 2,
              "chakra": -2
            }
          }
        },
        {
          "step_id": "step_003",
          "description": "理论测试",
          "dialogue": {
            "speaker": "伊鲁卡",
            "text": "现在测试一下你的理论学习成果。忍者的等级有哪些？查克拉的基本原理是什么？"
          },
          "conditions": {
            "attributes": {
              "intelligence": 15
            }
          },
          "rewards": {
            "items": ["item_textbook_basic"]
          }
        },
        {
          "step_id": "step_004",
          "description": "最终考核",
          "dialogue": {
            "speaker": "伊鲁卡",
            "text": "很好，你的进步很大。现在进行最终考核——与我对战一分钟！只要能坚持住，就算你通过！"
          },
          "conditions": {
            "attributes": {
              "taijutsu": 8,
              "speed": 6
            }
          },
          "rewards": {
            "experience": 500,
            "attributes": {
              "taijutsu": 3,
              "speed": 1
            }
          }
        },
        {
          "step_id": "step_005",
          "description": "课程完成",
          "dialogue": {
            "speaker": "伊鲁卡",
            "text": "你通过了！你的进步让我很惊讶，你有成为优秀忍者的潜质。继续保持，我相信你一定能在入学考试中取得好成绩！"
          },
          "conditions": {},
          "rewards": {
            "unlock": ["skill_basic_ninjutsu", "skill_basic_taijutsu"]
          }
        }
      ],
      "completion_condition": "objective_obj_004_completed",
      "failure_condition": "failed_final_exam",
      "repeatable": false,
      "cooldown": 0
    },

    "sq004_missing_ninja": {
      "quest_id": "sq004_missing_ninja",
      "name": "失踪的忍者",
      "type": "investigation",
      "rank": "C",
      "chapter": "chapter2",
      "location": "konoha_forest",
      "giver": "kotetsu",
      "description": "一名中忍在执行任务时失踪了，需要有人去调查。",
      "requirements": {
        "min_level": 5,
        "required_skills": ["skill_tracking", "skill_survival"],
        "required_relationships": {},
        "required_attributes": {
          "intelligence": 15,
          "taijutsu": 10
        }
      },
      "objectives": [
        {
          "id": "obj_001",
          "description": "前往失踪忍者最后出现的位置",
          "target": "forest_area",
          "count": 1
        },
        {
          "id": "obj_002",
          "description": "调查线索",
          "target": "clues",
          "count": 3
        },
        {
          "id": "obj_003",
          "description": "找到失踪忍者",
          "target": "missing_ninja",
          "count": 1
        },
        {
          "id": "obj_004",
          "description": "安全返回木叶",
          "target": "konoha_gate",
          "count": 1
        }
      ],
      "rewards": {
        "experience": 800,
        "money": 500,
        "attributes": {
          "intelligence": 3,
          "taijutsu": 2
        },
        "items": ["item_map_forest"],
        "unlock": ["knowledge_missing_ninja_truth"],
        "relationships": {
          "kotetsu": 5,
          "missing_ninja": 10
        }
      },
      "steps": [
        {
          "step_id": "step_001",
          "description": "接取任务",
          "dialogue": {
            "speaker": "出云",
            "text": "拜托了！我的同事在执行D级任务时失踪了。虽然只是简单的调查任务，但他已经三天没有回来了。你能帮帮忙吗？"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_002",
          "description": "前往森林",
          "dialogue": {
            "speaker": "system",
            "text": "你进入木叶附近的森林，开始搜寻失踪忍者的踪迹。森林中有很多危险的生物，你需要小心。"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_003",
          "description": "发现线索1",
          "dialogue": {
            "speaker": "system",
            "text": "你发现了一个破碎的忍具袋，上面有木叶的标志。这应该是失踪忍者的物品！"
          },
          "conditions": {},
          "rewards": {
            "attributes": {
              "intelligence": 1
            }
          }
        },
        {
          "step_id": "step_004",
          "description": "发现线索2",
          "dialogue": {
            "speaker": "system",
            "text": "地上有打斗的痕迹，还有干涸的血迹。看来失踪忍者遇到了敌人！"
          },
          "conditions": {},
          "rewards": {
            "attributes": {
              "intelligence": 1
            }
          }
        },
        {
          "step_id": "step_005",
          "description": "发现线索3",
          "dialogue": {
            "speaker": "system",
            "text": "你追踪足迹来到一个隐蔽的山洞前。洞口有查克拉的残留，这一定是失踪忍者被带进去的地方！"
          },
          "conditions": {},
          "rewards": {
            "items": ["item_map_forest"]
          }
        },
        {
          "step_id": "step_006",
          "description": "进入山洞",
          "dialogue": {
            "speaker": "system",
            "text": "山洞中昏暗而潮湿，你小心翼翼地前进。前方传来微弱的声音，是失踪忍者！但他似乎受了伤。"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_007",
          "description": "救出忍者",
          "dialogue": {
            "speaker": "missing_ninja",
            "text": "谢谢你……我遇到了叛忍的袭击，受了重伤……如果不是你，我可能就……"
          },
          "conditions": {},
          "rewards": {
            "attributes": {
              "taijutsu": 1
            },
            "relationships": {
              "missing_ninja": 10
            }
          }
        },
        {
          "step_id": "step_008",
          "description": "返回木叶",
          "dialogue": {
            "speaker": "出云",
            "text": "太好了！谢谢你救了他！这份报酬是你应得的，以后有需要再找我！"
          },
          "conditions": {},
          "rewards": {
            "experience": 800,
            "money": 500
          }
        }
      ],
      "completion_condition": "objective_obj_004_completed",
      "failure_condition": "player_death",
      "repeatable": false,
      "cooldown": 0
    },

    "sq005_mission_revenge": {
      "quest_id": "sq005_mission_revenge",
      "name": "复仇的委托",
      "type": "assassination",
      "rank": "B",
      "chapter": "chapter3",
      "location": "fire_country_border",
      "giver": "mysterious_man",
      "description": "一个神秘的人委托你去刺杀一个叛忍，他说这个叛忍摧毁了他的村庄。",
      "requirements": {
        "min_level": 10,
        "required_skills": ["skill_stealth", "skill_assassination"],
        "required_relationships": {},
        "required_attributes": {
          "taijutsu": 25,
          "ninjutsu": 20,
          "speed": 20
        }
      },
      "objectives": [
        {
          "id": "obj_001",
          "description": "调查叛忍的行踪",
          "target": "border_towns",
          "count": 1
        },
        {
          "id": "obj_002",
          "description": "潜入叛忍的据点",
          "target": "rogue_hideout",
          "count": 1
        },
        {
          "id": "obj_003",
          "description": "击败叛忍",
          "target": "rogue_ninja",
          "count": 1
        },
        {
          "id": "obj_004",
          "description": "返回委托人处",
          "target": "mysterious_man",
          "count": 1
        }
      ],
      "rewards": {
        "experience": 1500,
        "money": 2000,
        "attributes": {
          "taijutsu": 5,
          "ninjutsu": 5,
          "speed": 3
        },
        "items": ["item_poisson_dagger"],
        "unlock": ["relationship_mysterious_man", "knowledge_rogue_organization"],
        "relationships": {
          "mysterious_man": 10
        }
      },
      "steps": [
        {
          "step_id": "step_001",
          "description": "接取任务",
          "dialogue": {
            "speaker": "神秘人",
            "text": "我需要你去杀一个人。他是一个叛忍，曾经摧毁了我的村庄。我付给你很多钱，只要你完成这个任务。"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_002",
          "description": "调查情报",
          "dialogue": {
            "speaker": "informant",
            "text": "你说的是'赤月'吧？他最近在边境地区活动，据说在组织一个小团体。我可以告诉你他的据点在哪里，但你得付钱。"
          },
          "conditions": {
            "money": 500
          },
          "rewards": {
            "money": -500,
            "unlock": ["location_rogue_hideout"]
          }
        },
        {
          "step_id": "step_003",
          "description": "潜入据点",
          "dialogue": {
            "speaker": "system",
            "text": "你按照情报来到叛忍的据点。这里是一个废弃的村庄，有几名叛忍在巡逻。你需要潜行接近目标。"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_004",
          "description": "遭遇战",
          "dialogue": {
            "speaker": "rogue_ninja_guard",
            "text": "你是谁？！这里是禁地！"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_005",
          "description": "击败守卫",
          "dialogue": {
            "speaker": "system",
            "text": "你解决了守卫，继续深入据点。"
          },
          "conditions": {
            "attributes": {
              "taijutsu": 15,
              "ninjutsu": 12
            }
          },
          "rewards": {
            "experience": 300
          }
        },
        {
          "step_id": "step_006",
          "description": "面对叛忍首领",
          "dialogue": {
            "speaker": "赤月",
            "text": "哼，有人花钱来杀我吗？真是有趣。让我看看你的本事！"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_007",
          "description": "击败赤月",
          "dialogue": {
            "speaker": "赤月",
            "text": "不错……你很强……咳咳……"
          },
          "conditions": {
            "attributes": {
              "taijutsu": 25,
              "ninjutsu": 20,
              "speed": 18
            }
          },
          "rewards": {
            "experience": 1000,
            "attributes": {
              "taijutsu": 3,
              "ninjutsu": 3
            }
          }
        },
        {
          "step_id": "step_008",
          "description": "任务完成",
          "dialogue": {
            "speaker": "神秘人",
            "text": "干得好！这是答应你的报酬。对了，你对我的服务感兴趣吗？以后有这种任务可以再联系我。"
          },
          "conditions": {},
          "rewards": {
            "experience": 500,
            "money": 2000,
            "items": ["item_poisson_dagger"]
          }
        }
      ],
      "completion_condition": "objective_obj_004_completed",
      "failure_condition": "player_death",
      "repeatable": false,
      "cooldown": 0
    },

    "sq006_hidden_technique": {
      "quest_id": "sq006_hidden_technique",
      "name": "传承的秘术",
      "type": "learning",
      "rank": "A",
      "chapter": "chapter4",
      "location": "ancient_temple",
      "giver": "old_master",
      "description": "一位隐居的老忍者传授给你一门失传已久的秘术。",
      "requirements": {
        "min_level": 20,
        "required_skills": [],
        "required_relationships": {
          "old_master": 10
        },
        "required_attributes": {
          "ninjutsu": 40,
          "intelligence": 30,
          "chakra": 50
        }
      },
      "objectives": [
        {
          "id": "obj_001",
          "description": "寻找隐居的老忍者",
          "target": "hidden_valley",
          "count": 1
        },
        {
          "id": "obj_002",
          "description": "通过老忍者的测试",
          "target": "test_of_will",
          "count": 1
        },
        {
          "id": "obj_003",
          "description": "学习秘术",
          "target": "hidden_technique",
          "count": 1
        },
        {
          "id": "obj_004",
          "description": "掌握秘术",
          "target": "mastery_test",
          "count": 1
        }
      ],
      "rewards": {
        "experience": 3000,
        "money": 0,
        "attributes": {
          "ninjutsu": 10,
          "intelligence": 5,
          "chakra": 5
        },
        "items": [],
        "unlock": ["hidden_technance_fire_dragon"],
        "relationships": {
          "old_master": 15
        }
      },
      "steps": [
        {
          "step_id": "step_001",
          "description": "寻找老忍者",
          "dialogue": {
            "speaker": "老忍者",
            "text": "年轻人，你来到这里……是为了我的秘术吗？"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_002",
          "description": "通过测试",
          "dialogue": {
            "speaker": "老忍者",
            "text": "要学习我的秘术，你需要通过三个测试：勇气、智慧和决心。你准备好了吗？"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_003",
          "description": "勇气测试",
          "dialogue": {
            "speaker": "老忍者",
            "text": "勇气测试：在漆黑的洞穴中独自前行一小时，不使用任何忍术。"
          },
          "conditions": {
            "attributes": {
              "intelligence": 25
            }
          },
          "rewards": {
            "attributes": {
              "intelligence": 2
            }
          }
        },
        {
          "step_id": "step_004",
          "description": "智慧测试",
          "dialogue": {
            "speaker": "老忍者",
            "text": "智慧测试：解开这个古老的谜题。'无形无影，却无处不在；无声无息，却能撼动天地。这是什么？'"
          },
          "conditions": {
            "attributes": {
              "intelligence": 30
            }
          },
          "rewards": {
            "attributes": {
              "intelligence": 3
            }
          }
        },
        {
          "step_id": "step_005",
          "description": "决心测试",
          "dialogue": {
            "speaker": "老忍者",
            "text": "决心测试：在瀑布下冥想三天三夜，不断用查克拉冲击自己的极限。"
          },
          "conditions": {
            "attributes": {
              "chakra": 45
            }
          },
          "rewards": {
            "attributes": {
              "chakra": 5
            }
          }
        },
        {
          "step_id": "step_006",
          "description": "开始学习秘术",
          "dialogue": {
            "speaker": "老忍者",
            "text": "你通过了所有测试。现在，我将传授给你'火龙之术'——这是千手柱间曾经使用过的秘术。"
          },
          "conditions": {},
          "rewards": {
            "unlock": ["hidden_technance_fire_dragon"]
          }
        },
        {
          "step_id": "step_007",
          "description": "掌握秘术",
          "dialogue": {
            "speaker": "老忍者",
            "text": "很好，你已经掌握了这门秘术的基础。记住，力量需要用来保护，而不是毁灭。"
          },
          "conditions": {
            "attributes": {
              "ninjutsu": 50,
              "chakra": 55
            }
          },
          "rewards": {
            "experience": 3000,
            "attributes": {
              "ninjutsu": 5
            }
          }
        }
      ],
      "completion_condition": "objective_obj_004_completed",
      "failure_condition": "failed_any_test",
      "repeatable": false,
      "cooldown": 0
    },

    "sq007_rescue_hostage": {
      "quest_id": "sq007_rescue_hostage",
      "name": "人质营救",
      "type": "rescue",
      "rank": "B",
      "chapter": "chapter3",
      "location": "enemy_territory",
      "giver": "kakashi",
      "description": "木叶的一名重要官员被敌国绑架，需要你潜入敌境进行营救。",
      "requirements": {
        "min_level": 15,
        "required_skills": ["skill_stealth", "skill_genjutsu"],
        "required_relationships": {
          "kakashi": 5
        },
        "required_attributes": {
          "taijutsu": 30,
          "genjutsu": 15,
          "speed": 25
        }
      },
      "objectives": [
        {
          "id": "obj_001",
          "description": "潜入敌国边境",
          "target": "enemy_border",
          "count": 1
        },
        {
          "id": "obj_002",
          "description": "收集情报",
          "target": "enemy_base",
          "count": 1
        },
        {
          "id": "obj_003",
          "description": "解救人质",
          "target": "hostage",
          "count": 1
        },
        {
          "id": "obj_004",
          "description": "安全返回木叶",
          "target": "konoha_gate",
          "count": 1
        }
      ],
      "rewards": {
        "experience": 2000,
        "money": 1500,
        "attributes": {
          "genjutsu": 5,
          "speed": 3
        },
        "items": ["item_anbu_mask"],
        "unlock": ["relationship_kakashi"],
        "relationships": {
          "kakashi": 8,
          "hostage": 15
        }
      },
      "steps": [
        {
          "step_id": "step_001",
          "description": "接取任务",
          "dialogue": {
            "speaker": "卡卡西",
            "text": "有个紧急任务。我们的官员被敌国绑架了，情报显示他就在边境的一座堡垒里。你能去救他吗？"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_002",
          "description": "潜入敌境",
          "dialogue": {
            "speaker": "system",
            "text": "你通过隐秘的路径潜入敌国。这里戒备森严，任何失误都可能导致任务失败。"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_003",
          "description": "收集情报",
          "dialogue": {
            "speaker": "system",
            "text": "你发现人质被关押在堡垒的地下层，有三名精英忍者看守。你需要制定营救计划。"
          },
          "conditions": {},
          "rewards": {
            "attributes": {
              "intelligence": 2
            }
          }
        },
        {
          "step_id": "step_004",
          "description": "使用幻术潜行",
          "dialogue": {
            "speaker": "system",
            "text": "你使用幻术迷惑守卫，悄悄接近人质所在地。"
          },
          "conditions": {
            "attributes": {
              "genjutsu": 15
            }
          },
          "rewards": {}
        },
        {
          "step_id": "step_005",
          "description": "解救人质",
          "dialogue": {
            "speaker": "官员",
            "text": "你是木叶的忍者吗？快带我离开这里！"
          },
          "conditions": {},
          "rewards": {
            "attributes": {
              "speed": 2
            }
          }
        },
        {
          "step_id": "step_006",
          "description": "遭遇敌人",
          "dialogue": {
            "speaker": "enemy_ninja",
            "text": "有人闯进来了！抓住他们！"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_007",
          "description": "战斗逃脱",
          "dialogue": {
            "speaker": "system",
            "text": "你护送人质与追兵战斗，同时寻找撤离路线。"
          },
          "conditions": {
            "attributes": {
              "taijutsu": 25,
              "speed": 20
            }
          },
          "rewards": {
            "experience": 1000
          }
        },
        {
          "step_id": "step_008",
          "description": "返回木叶",
          "dialogue": {
            "speaker": "卡卡西",
            "text": "干得漂亮！人质安全了。这次任务很危险，但你的表现让我刮目相看。"
          },
          "conditions": {},
          "rewards": {
            "experience": 1000,
            "money": 1500,
            "items": ["item_anbu_mask"]
          }
        }
      ],
      "completion_condition": "objective_obj_004_completed",
      "failure_condition": "hostage_killed_or_player_death",
      "repeatable": false,
      "cooldown": 0
    },

    "sq008_forbidden_scroll": {
      "quest_id": "sq008_forbidden_scroll",
      "name": "禁忌之书",
      "type": "special",
      "rank": "S",
      "chapter": "chapter5",
      "location": "hidden_library",
      "giver": "hiruzen",
      "description": "三代火影委托你保护并研究一本记录着禁忌忍术的古卷轴。",
      "requirements": {
        "min_level": 30,
        "required_skills": [],
        "required_relationships": {
          "hiruzen": 15
        },
        "required_attributes": {
          "ninjutsu": 50,
          "intelligence": 40,
          "chakra": 60
        }
      },
      "objectives": [
        {
          "id": "obj_001",
          "description": "从三代火影处接受任务",
          "target": "hiruzen",
          "count": 1
        },
        {
          "id": "obj_002",
          "description": "保护卷轴不被夺走",
          "target": "protection_mission",
          "count": 1
        },
        {
          "id": "obj_003",
          "description": "研究卷轴内容",
          "target": "scroll_study",
          "count": 1
        },
        {
          "id": "obj_004",
          "description": "向火影汇报研究结果",
          "target": "hiruzen",
          "count": 1
        }
      ],
      "rewards": {
        "experience": 5000,
        "money": 0,
        "attributes": {
          "ninjutsu": 15,
          "intelligence": 10,
          "chakra": 10
        },
        "items": [],
        "unlock": ["forbidden_technance_shadow_clones", "relationship_hiruzen"],
        "relationships": {
          "hiruzen": 20
        }
      },
      "steps": [
        {
          "step_id": "step_001",
          "description": "接受任务",
          "dialogue": {
            "speaker": "三代火影",
            "text": "年轻人，我有一件重要的事情交给你。这是木叶的禁忌之书，记录着一些危险的忍术。我需要你保护它，同时研究其中的内容。"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_002",
          "description": "保护卷轴",
          "dialogue": {
            "speaker": "system",
            "text": "你带着卷轴回到了自己的房间，但你感觉到有人在监视你。看来有人想要得到这本卷轴。"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_003",
          "description": "遭遇袭击",
          "dialogue": {
            "speaker": "unknown_attacker",
            "text": "把卷轴交出来！"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_004",
          "description": "击退袭击者",
          "dialogue": {
            "speaker": "system",
            "text": "你成功击退了袭击者，但他们似乎还有同伙。你需要更加小心。"
          },
          "conditions": {
            "attributes": {
              "taijutsu": 40,
              "ninjutsu": 45
            }
          },
          "rewards": {
            "experience": 1000
          }
        },
        {
          "step_id": "step_005",
          "description": "研究卷轴",
          "dialogue": {
            "speaker": "system",
            "text": "你开始研究禁忌之书。里面记录了许多危险的忍术，包括多重影分身之术、尸鬼封尽等。"
          },
          "conditions": {
            "attributes": {
              "intelligence": 45
            }
          },
          "rewards": {
            "attributes": {
              "ninjutsu": 10
            }
          }
        },
        {
          "step_id": "step_006",
          "description": "掌握部分忍术",
          "dialogue": {
            "speaker": "system",
            "text": "经过反复研究，你学会了多重影分身之术的精髓。"
          },
          "conditions": {
            "attributes": {
              "chakra": 55
            }
          },
          "rewards": {
            "unlock": ["forbidden_technance_shadow_clones"]
          }
        },
        {
          "step_id": "step_007",
          "description": "最终袭击",
          "dialogue": {
            "speaker": "boss_attacker",
            "text": "看来你很了解这本卷轴。那就让我试试你的实力！"
          },
          "conditions": {},
          "rewards": {}
        },
        {
          "step_id": "step_008",
          "description": "击败首领",
          "dialogue": {
            "speaker": "system",
            "text": "你使用了新学会的多重影分身之术，成功击败了袭击者的首领。"
          },
          "conditions": {
            "attributes": {
              "ninjutsu": 50,
              "chakra": 60
            }
          },
          "rewards": {
            "experience": 3000,
            "attributes": {
              "ninjutsu": 5
            }
          }
        },
        {
          "step_id": "step_009",
          "description": "汇报结果",
          "dialogue": {
            "speaker": "三代火影",
            "text": "你完成了任务！而且你还掌握了多重影分身之术……这是鸣人那孩子的成名忍术啊。你让我很惊讶。"
          },
          "conditions": {},
          "rewards": {
            "experience": 2000,
            "relationships": {
              "hiruzen": 5
            }
          }
        }
      ],
      "completion_condition": "objective_obj_004_completed",
      "failure_condition": "scroll_stolen",
      "repeatable": false,
      "cooldown": 0
    }
  }
}
```

---

## 任务类型说明

### 任务类型分类

| 类型 | 英文 | 说明 | 典型任务 |
|------|------|------|----------|
| 运送 | delivery | 将物品从A地送到B地 | 拉面配送 |
| 寻找 | fetch | 寻找并找回物品或人 | 丢失的猫咪 |
| 讨伐 | extermination | 击败指定的敌人 | 击败山贼 |
| 调查 | investigation | 调查某个地点或事件 | 失踪的忍者 |
| 护送 | escort | 保护目标安全到达目的地 | 护送商人 |
| 刺杀 | assassination | 刺杀指定目标 | 复仇的委托 |
| 解谜 | puzzle | 解决谜题或智力挑战 | 古代遗迹的谜题 |
| 营救 | rescue | 救出被囚禁的人质 | 人质营救 |
| 学习 | learning | 学习新的技能或知识 | 私人课程 |
| 特殊 | special | 特殊类型的任务 | 禁忌之书 |

### 任务等级说明

| 等级 | 描述 | 难度 | 奖励 | 目标玩家 |
|------|------|------|------|----------|
| D | 简单任务 | ★☆☆☆☆ | 低 | 新手玩家（1-5级） |
| C | 普通任务 | ★★☆☆☆ | 中 | 初级玩家（5-15级） |
| B | 困难任务 | ★★★☆☆ | 高 | 中级玩家（15-30级） |
| A | 极难任务 | ★★★★☆ | 很高 | 高级玩家（30-50级） |
| S | 传说任务 | ★★★★★ | 极高 | 顶尖玩家（50级以上） |

---

## 支线任务设计规范

### 任务命名规范

- 格式：`sq[编号]_[英文名]`
- 示例：`sq001_lost_cat`、`sq005_mission_revenge`
- 编号范围：001-999

### 任务奖励设计原则

1. **经验值**：
   - D级：50-150
   - C级：200-500
   - B级：800-2000
   - A级：3000-5000
   - S级：5000-10000

2. **金钱**：
   - D级：50-300
   - C级：500-1000
   - B级：1500-3000
   - A级：3000-5000
   - S级：10000+

3. **属性**：
   - D级：+1-2
   - C级：+3-5
   - B级：+5-10
   - A级：+10-15
   - S级：+15-20

4. **物品**：
   - 普通物品：D-C级任务
   - 稀有物品：B级任务
   - 史诗物品：A-S级任务

### 任务条件设计

1. **最低等级**：确保玩家有一定能力
2. **技能要求**：高级任务需要特定技能
3. **关系要求**：某些任务需要与特定NPC有足够高的关系
4. **属性要求**：确保玩家有足够的属性完成挑战

### 任务流程设计

1. **接取任务**：清晰的对话和目标
2. **执行任务**：多样化的挑战（战斗、解谜、潜行等）
3. **完成任务**：奖励和后续内容
4. **失败惩罚**：适当的失败后果

---

## 支线任务列表索引

### D级任务

| 任务ID | 任务名称 | 类型 | 章节 | 奖励 |
|--------|----------|------|------|------|
| sq001 | 丢失的猫咪 | 寻找 | 第一章 | 100金币 + 关系提升 |
| sq002 | 拉面配送 | 运送 | 第一章 | 200金币 + 拉面优惠券 |

### C级任务

| 任务ID | 任务名称 | 类型 | 章节 | 奖励 |
|--------|----------|------|------|------|
| sq003 | 私人课程 | 学习 | 第一章 | 500经验 + 基础技能 |
| sq004 | 失踪的忍者 | 调查 | 第二章 | 800经验 + 500金币 |

### B级任务

| 任务ID | 任务名称 | 类型 | 章节 | 奖励 |
|--------|----------|------|------|------|
| sq005 | 复仇的委托 | 刺杀 | 第三章 | 1500经验 + 2000金币 |
| sq007 | 人质营救 | 营救 | 第三章 | 2000经验 + 1500金币 |

### A级任务

| 任务ID | 任务名称 | 类型 | 章节 | 奖励 |
|--------|----------|------|------|------|
| sq006 | 传承的秘术 | 学习 | 第四章 | 3000经验 + 秘术 |

### S级任务

| 任务ID | 任务名称 | 类型 | 章节 | 奖励 |
|--------|----------|------|------|------|
| sq008 | 禁忌之书 | 特殊 | 第五章 | 5000经验 + 禁忌忍术 |

---

**文档结束**

*此文档包含所有支线任务的数据，后续将根据开发进度持续更新和扩展。*
