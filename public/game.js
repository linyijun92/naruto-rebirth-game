// 游戏配置
const API_BASE_URL = 'https://naruto-rebirth-game.vercel.app/api';

// 游戏状态
const gameState = {
  player: null,
  token: null,
  currentScreen: 'story',
  currentChapter: 'chapter1',
  currentNode: 'node1',
  attributes: null
};

// DOM 元素
const elements = {
  // 认证界面
  authScreen: document.getElementById('auth-screen'),
  gameScreen: document.getElementById('game-screen'),
  loginForm: document.getElementById('login-form'),
  registerForm: document.getElementById('register-form'),
  authMessage: document.getElementById('auth-message'),
  tabButtons: document.querySelectorAll('.tab-btn'),

  // 游戏界面
  playerName: document.getElementById('player-name'),
  playerLevel: document.getElementById('player-level'),
  playerCurrency: document.getElementById('player-currency'),
  logoutBtn: document.getElementById('logout-btn'),
  navItems: document.querySelectorAll('.nav-item'),
  contentScreens: document.querySelectorAll('.content-screen'),

  // 剧情界面
  storyText: document.getElementById('story-text'),
  storyChoices: document.getElementById('story-choices'),

  // 属性界面
  attrChakra: document.getElementById('attr-chakra'),
  attrNinjutsu: document.getElementById('attr-ninjutsu'),
  attrTaijutsu: document.getElementById('attr-taijutsu'),
  attrIntelligence: document.getElementById('attr-intelligence'),
  attrSpeed: document.getElementById('attr-speed'),
  attrLuck: document.getElementById('attr-luck'),
  barChakra: document.getElementById('bar-chakra'),
  barNinjutsu: document.getElementById('bar-ninjutsu'),
  barTaijutsu: document.getElementById('bar-taijutsu'),
  barIntelligence: document.getElementById('bar-intelligence'),
  barSpeed: document.getElementById('bar-speed'),
  barLuck: document.getElementById('bar-luck'),

  // 任务界面
  questTabs: document.querySelectorAll('.quest-tab'),
  questList: document.getElementById('quest-list'),

  // 商店界面
  shopCurrency: document.getElementById('shop-currency'),
  shopItems: document.getElementById('shop-items'),

  // 存档界面
  createSaveBtn: document.getElementById('create-save-btn'),
  loadSaveBtn: document.getElementById('load-save-btn'),
  saveList: document.getElementById('save-list')
};

// 初始化
document.addEventListener('DOMContentLoaded', () => {
  initAuth();
  initNavigation();
  checkAuth();
});

// 认证功能
function initAuth() {
  // 标签页切换
  elements.tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      elements.tabButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      const tab = btn.dataset.tab;
      if (tab === 'login') {
        elements.loginForm.classList.add('active');
        elements.registerForm.classList.remove('active');
      } else {
        elements.registerForm.classList.add('active');
        elements.loginForm.classList.remove('active');
      }
    });
  });

  // 登录表单
  elements.loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const formData = new FormData(elements.loginForm);
    const data = Object.fromEntries(formData);
    await login(data.username, data.password);
  });

  // 注册表单
  elements.registerForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const formData = new FormData(elements.registerForm);
    const data = Object.fromEntries(formData);
    await register(data.username, data.email, data.password);
  });

  // 退出按钮
  elements.logoutBtn.addEventListener('click', logout);
}

// 检查认证状态
function checkAuth() {
  const token = localStorage.getItem('token');
  const player = localStorage.getItem('player');

  if (token && player) {
    gameState.token = token;
    gameState.player = JSON.parse(player);
    showGameScreen();
    loadPlayerData();
  } else {
    showAuthScreen();
  }
}

// 登录
async function login(username, password) {
  try {
    showMessage('登录中...', 'info');

    const response = await fetch(`${API_BASE_URL}/player/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ username, password })
    });

    const result = await response.json();

    if (result.success) {
      gameState.token = result.data.token;
      gameState.player = result.data.player;
      localStorage.setItem('token', result.data.token);
      localStorage.setItem('player', JSON.stringify(result.data.player));
      showMessage('登录成功！', 'success');
      setTimeout(() => showGameScreen(), 1000);
      loadPlayerData();
    } else {
      showMessage(result.error || '登录失败', 'error');
    }
  } catch (error) {
    console.error('Login error:', error);
    showMessage('登录失败，请稍后重试', 'error');
  }
}

// 注册
async function register(username, email, password) {
  try {
    showMessage('注册中...', 'info');

    const response = await fetch(`${API_BASE_URL}/player/register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ username, email, password })
    });

    const result = await response.json();

    if (result.success) {
      gameState.player = result.data;
      showMessage('注册成功！请登录', 'success');
      setTimeout(() => {
        elements.tabButtons[0].click();
      }, 1500);
    } else {
      showMessage(result.error || '注册失败', 'error');
    }
  } catch (error) {
    console.error('Register error:', error);
    showMessage('注册失败，请稍后重试', 'error');
  }
}

// 退出
function logout() {
  localStorage.removeItem('token');
  localStorage.removeItem('player');
  gameState.token = null;
  gameState.player = null;
  showAuthScreen();
  showMessage('已退出', 'info');
}

// 显示消息
function showMessage(message, type) {
  elements.authMessage.textContent = message;
  elements.authMessage.className = `message ${type}`;
}

// 显示认证界面
function showAuthScreen() {
  elements.authScreen.classList.remove('hidden');
  elements.gameScreen.classList.add('hidden');
}

// 显示游戏界面
function showGameScreen() {
  elements.authScreen.classList.add('hidden');
  elements.gameScreen.classList.remove('hidden');
}

// 加载玩家数据
async function loadPlayerData() {
  try {
    const playerId = gameState.player.id;
    const response = await fetch(`${API_BASE_URL}/player/${playerId}`);
    const result = await response.json();

    if (result.success) {
      gameState.player = result.data;
      localStorage.setItem('player', JSON.stringify(result.data));
      updatePlayerUI();
      loadAttributes();
    }
  } catch (error) {
    console.error('Load player error:', error);
  }
}

// 更新玩家 UI
function updatePlayerUI() {
  elements.playerName.textContent = gameState.player.username;
  elements.playerLevel.textContent = `Lv.${gameState.player.level}`;
  elements.playerCurrency.textContent = `💰 ${gameState.player.currency}`;
  elements.shopCurrency.textContent = gameState.player.currency;
}

// 加载属性
function loadAttributes() {
  if (!gameState.player.player_attributes || gameState.player.player_attributes.length === 0) {
    return;
  }

  const attrs = gameState.player.player_attributes[0];
  gameState.attributes = attrs;

  // 更新属性 UI
  updateAttributeUI('chakra', attrs.chakra);
  updateAttributeUI('ninjutsu', attrs.ninjutsu);
  updateAttributeUI('taijutsu', attrs.taijutsu);
  updateAttributeUI('intelligence', attrs.intelligence);
  updateAttributeUI('speed', attrs.speed);
  updateAttributeUI('luck', attrs.luck);
}

// 更新单个属性 UI
function updateAttributeUI(attrName, value) {
  const attrElement = elements[`attr${capitalize(attrName)}`];
  const barElement = elements[`bar${capitalize(attrName)}`];

  if (attrElement) attrElement.textContent = value;
  if (barElement) barElement.style.width = `${value}%`;
}

// 首字母大写
function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

// 导航功能
function initNavigation() {
  elements.navItems.forEach(item => {
    item.addEventListener('click', () => {
      const screen = item.dataset.screen;
      switchScreen(screen);
    });
  });
}

// 切换屏幕
function switchScreen(screen) {
  // 更新导航状态
  elements.navItems.forEach(item => {
    item.classList.remove('active');
    if (item.dataset.screen === screen) {
      item.classList.add('active');
    }
  });

  // 更新内容屏幕
  elements.contentScreens.forEach(content => {
    content.classList.remove('active');
    const contentId = `${screen}-screen`;
    if (content.id === contentId) {
      content.classList.add('active');
    }
  });

  gameState.currentScreen = screen;

  // 加载对应屏幕的数据
  loadScreenData(screen);
}

// 加载屏幕数据
function loadScreenData(screen) {
  switch (screen) {
    case 'story':
      loadStory();
      break;
    case 'quests':
      loadQuests();
      break;
    case 'shop':
      loadShop();
      break;
    case 'saves':
      loadSaves();
      break;
  }
}

// 加载剧情
function loadStory() {
  // 模拟剧情数据
  const storyData = {
    chapter1: {
      node1: {
        text: '你睁开眼睛，发现自己躺在一片陌生的草地上。四周是茂密的树林，阳光透过树叶洒下斑驳的光影。你感到一阵迷茫，这里是哪里？你的脑海中突然闪过一个念头——"重生"。',
        choices: [
          { text: '站起来，观察周围', nextNode: 'node2' },
          { text: '躺下休息', nextNode: 'node3' }
        ]
      },
      node2: {
        text: '你站起身来，环顾四周。树林郁郁葱葱，远处的山峦在云雾中若隐若现。你低头看自己，发现自己穿着简单的忍者服装。这是木叶村吗？你心中充满疑问。',
        choices: [
          { text: '朝村庄方向走去', nextNode: 'node4' },
          { text: '检查自己的忍具', nextNode: 'node5' }
        ]
      },
      node3: {
        text: '你躺下休息，但心中的不安感越来越强烈。你感觉到体内有一股查克拉在流动，这让你感到既熟悉又陌生。',
        choices: [
          { text: '尝试控制查克拉', nextNode: 'node6' },
          { text: '继续休息', nextNode: 'node7' }
        ]
      }
    }
  };

  const currentStory = storyData[gameState.currentChapter]?.[gameState.currentNode];
  if (currentStory) {
    displayStory(currentStory);
  } else {
    displayStory({
      text: '剧情继续开发中...',
      choices: [{ text: '返回', nextNode: 'node1' }]
    });
  }
}

// 显示剧情
function displayStory(story) {
  // 打字机效果
  typeWriter(story.text, elements.storyText);

  // 显示选项
  elements.storyChoices.innerHTML = '';
  story.choices.forEach(choice => {
    const button = document.createElement('button');
    button.className = 'choice-btn';
    button.textContent = choice.text;
    button.addEventListener('click', () => {
      gameState.currentNode = choice.nextNode;
      loadStory();
    });
    elements.storyChoices.appendChild(button);
  });
}

// 打字机效果
function typeWriter(text, element, index = 0) {
  if (index < text.length) {
    element.textContent += text.charAt(index);
    setTimeout(() => typeWriter(text, element, index + 1), 30);
  }
}

// 加载任务
function loadQuests() {
  // 模拟任务数据
  const quests = [
    {
      id: 1,
      title: '初次登录',
      description: '登录游戏即可完成',
      type: 'main',
      status: 'completed',
      rewards: '经验值 100'
    },
    {
      id: 2,
      title: '属性修炼',
      description: '将任意属性提升到 60',
      type: 'main',
      status: 'in_progress',
      rewards: '货币 500'
    },
    {
      id: 3,
      title: '初次购买',
      description: '在商店购买一件物品',
      type: 'side',
      status: 'available',
      rewards: '货币 100'
    },
    {
      id: 4,
      title: '每日签到',
      description: '每天登录游戏一次',
      type: 'daily',
      status: 'available',
      rewards: '货币 50'
    }
  ];

  displayQuests(quests);
}

// 显示任务
function displayQuests(quests) {
  elements.questList.innerHTML = '';

  quests.forEach(quest => {
    const card = document.createElement('div');
    card.className = 'quest-card';
    card.innerHTML = `
      <h3>${quest.title}</h3>
      <p>${quest.description}</p>
      <div class="quest-rewards">
        <span>奖励: ${quest.rewards}</span>
        <span>状态: ${getQuestStatusText(quest.status)}</span>
      </div>
    `;
    elements.questList.appendChild(card);
  });
}

// 获取任务状态文本
function getQuestStatusText(status) {
  const statusMap = {
    'available': '可接取',
    'in_progress': '进行中',
    'completed': '已完成'
  };
  return statusMap[status] || status;
}

// 任务标签页切换
elements.questTabs.forEach(tab => {
  tab.addEventListener('click', () => {
    elements.questTabs.forEach(t => t.classList.remove('active'));
    tab.classList.add('active');
    // 可以根据 tab.dataset.type 过滤任务
  });
});

// 加载商店
function loadShop() {
  // 模拟商品数据
  const items = [
    {
      id: 1,
      name: '苦无',
      price: 100,
      rarity: 'N',
      description: '基础忍者武器，提升忍术攻击力'
    },
    {
      id: 2,
      name: '手里剑',
      price: 200,
      rarity: 'R',
      description: '进阶忍者武器，大幅提升忍术攻击力'
    },
    {
      id: 3,
      name: '查克拉药水',
      price: 50,
      rarity: 'N',
      description: '恢复查克拉，提升战斗续航能力'
    },
    {
      id: 4,
      name: '血瓶',
      price: 50,
      rarity: 'N',
      description: '恢复生命值，提升生存能力'
    },
    {
      id: 5,
      name: '秘技卷轴',
      price: 500,
      rarity: 'SR',
      description: '学习高级忍术，大幅提升战斗力'
    },
    {
      id: 6,
      name: '影级武器',
      price: 2000,
      rarity: 'SSR',
      description: '传说级武器，极大提升战斗力'
    }
  ];

  displayShopItems(items);
}

// 显示商店物品
function displayShopItems(items) {
  elements.shopItems.innerHTML = '';

  items.forEach(item => {
    const card = document.createElement('div');
    card.className = 'item-card';
    card.innerHTML = `
      <div class="item-rarity rarity-${item.rarity}">${item.rarity}</div>
      <div class="item-name">${item.name}</div>
      <div class="item-price">💰 ${item.price}</div>
      <p class="item-description">${item.description}</p>
      <button class="buy-btn" ${gameState.player.currency < item.price ? 'disabled' : ''}>
        购买
      </button>
    `;

    const buyBtn = card.querySelector('.buy-btn');
    buyBtn.addEventListener('click', () => buyItem(item));

    elements.shopItems.appendChild(card);
  });
}

// 购买物品
function buyItem(item) {
  if (gameState.player.currency < item.price) {
    alert('货币不足！');
    return;
  }

  if (confirm(`确定购买 ${item.name} 吗？价格：${item.price} 货币`)) {
    gameState.player.currency -= item.price;
    updatePlayerUI();
    alert(`成功购买 ${item.name}！`);
    loadShop(); // 重新加载商店，更新按钮状态
  }
}

// 加载存档
function loadSaves() {
  // 模拟存档数据
  const saves = [
    {
      id: 1,
      name: '自动存档 1',
      time: '2026-02-14 08:30:00',
      chapter: '第一章 - 觉醒'
    }
  ];

  displaySaves(saves);
}

// 显示存档
function displaySaves(saves) {
  elements.saveList.innerHTML = '';

  if (saves.length === 0) {
    elements.saveList.innerHTML = '<p>暂无存档</p>';
    return;
  }

  saves.forEach(save => {
    const card = document.createElement('div');
    card.className = 'save-card';
    card.innerHTML = `
      <div>
        <h3>${save.name}</h3>
        <p>${save.time}</p>
        <p>${save.chapter}</p>
      </div>
      <div class="save-actions">
        <button>加载</button>
        <button>删除</button>
      </div>
    `;
    elements.saveList.appendChild(card);
  });
}

// 创建存档
elements.createSaveBtn.addEventListener('click', () => {
  const saveName = prompt('请输入存档名称：', `自动存档 ${new Date().toLocaleTimeString()}`);
  if (saveName) {
    alert(`创建存档：${saveName}`);
    loadSaves();
  }
});

// 加载存档
elements.loadSaveBtn.addEventListener('click', () => {
  alert('加载存档功能开发中...');
});

console.log('游戏已加载！');
