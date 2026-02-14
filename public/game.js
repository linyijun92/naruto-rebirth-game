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
  const attributePoints = gameState.player.attribute_points || 0;

  // 更新属性 UI，添加提升按钮
  updateAttributeUI('chakra', attrs.chakra, attributePoints);
  updateAttributeUI('ninjutsu', attrs.ninjutsu, attributePoints);
  updateAttributeUI('taijutsu', attrs.taijutsu, attributePoints);
  updateAttributeUI('intelligence', attrs.intelligence, attributePoints);
  updateAttributeUI('speed', attrs.speed, attributePoints);
  updateAttributeUI('luck', attrs.luck, attributePoints);
}

// 更新单个属性 UI
function updateAttributeUI(attrName, value, availablePoints = 0) {
  const attrElement = elements[`attr${capitalize(attrName)}`];
  const barElement = elements[`bar${capitalize(attrName)}`];
  const container = attrElement ? attrElement.parentElement : null;

  if (attrElement) attrElement.textContent = value;
  if (barElement) barElement.style.width = `${value}%`;

  // 添加提升按钮
  if (container) {
    // 移除旧的提升按钮
    const oldUpgradeBtn = container.querySelector('.upgrade-btn');
    if (oldUpgradeBtn) {
      oldUpgradeBtn.remove();
    }

    // 添加新的提升按钮
    const upgradeBtn = document.createElement('button');
    upgradeBtn.className = 'upgrade-btn';
    upgradeBtn.textContent = `提升 (1点)`;

    // 计算是否可以提升
    const canUpgrade = value < 100 && availablePoints > 0;
    if (!canUpgrade) {
      upgradeBtn.classList.add('disabled');
      if (value >= 100) {
        upgradeBtn.textContent = '已满级';
      } else if (availablePoints <= 0) {
        upgradeBtn.textContent = '属性点不足';
      }
    }

    upgradeBtn.addEventListener('click', () => {
      upgradeAttribute(attrName, availablePoints);
    });

    container.appendChild(upgradeBtn);
  }
}

// 升级属性
async function upgradeAttribute(attrName, availablePoints) {
  try {
    const response = await fetch(`${API_BASE_URL}/player/upgrade`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${gameState.token}`
      },
      body: JSON.stringify({
        attribute: attrName,
        amount: 1
      })
    });

    const result = await response.json();

    if (result.success) {
      // 更新玩家数据
      const upgrade = result.data.upgrade;
      gameState.player = result.data.player;
      gameState.player.attribute_points = upgrade.newAttributePoints;

      // 更新属性
      const attrIndex = ['chakra', 'ninjutsu', 'taijutsu', 'intelligence', 'speed', 'luck'].indexOf(attrName);
      if (attrIndex !== -1) {
        gameState.player.player_attributes[0][attrName] += upgrade.increase;
      }

      // 持久化
      localStorage.setItem('player', JSON.stringify(gameState.player));

      // 更新 UI
      updatePlayerUI();
      loadAttributes();

      alert(`${capitalize(attrName)} 升级成功！从 ${upgrade.oldValue} 提升到 ${upgrade.newValue}`);
    } else {
      alert(`属性升级失败：${result.message || '未知错误'}`);
    }
  } catch (error) {
    console.error('Upgrade attribute error:', error);
    alert(`属性升级失败：${error.message || '网络错误，请稍后重试'}`);
  }
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
async function loadStory() {
  try {
    // 尝试从 API 获取剧情数据（API 尚未实现，使用备用数据）
    const response = await fetch(`${API_BASE_URL}/story/${gameState.currentChapter}`);
    const result = await response.json();

    if (result.code !== 501 && result.data) {
      // TODO: 当 API 实现后，解析返回的剧情数据
      console.log('Story API not yet implemented, using fallback data');
      loadStoryFallback();
    } else {
      loadStoryFallback();
    }
  } catch (error) {
    console.error('Load story error:', error);
    console.warn('Using fallback story data due to API error');
    loadStoryFallback();
  }
}

// 加载剧情（备用数据）
function loadStoryFallback() {
  // 模拟剧情数据（API 实现前使用）
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
async function loadQuests() {
  try {
    // 尝试从 API 获取任务数据（API 尚未实现，使用备用数据）
    const response = await fetch(`${API_BASE_URL}/quests`, {
      headers: {
        'Authorization': `Bearer ${gameState.token}`
      }
    });
    const result = await response.json();

    if (result.code !== 501 && result.data) {
      // TODO: 当 API 实现后，解析返回的任务数据
      console.log('Quests API not yet implemented, using fallback data');
      loadQuestsFallback();
    } else {
      loadQuestsFallback();
    }
  } catch (error) {
    console.error('Load quests error:', error);
    console.warn('Using fallback quests data due to API error');
    loadQuestsFallback();
  }
}

// 加载任务（备用数据）
function loadQuestsFallback() {
  // 模拟任务数据（API 实现前使用）
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

  if (!quests || quests.length === 0) {
    elements.questList.innerHTML = '<p>暂无任务</p>';
    return;
  }

  quests.forEach(quest => {
    const card = document.createElement('div');
    card.className = 'quest-card';

    // 根据任务状态显示不同按钮
    let actionButton = '';
    if (quest.status === 'in_progress') {
      actionButton = `<button class="quest-btn complete-btn" data-quest-id="${quest.id}">完成任务</button>`;
    } else if (quest.status === 'completed' && !quest.claimed) {
      actionButton = `<button class="quest-btn claim-btn" data-quest-id="${quest.id}">领取奖励</button>`;
    } else if (quest.status === 'completed' && quest.claimed) {
      actionButton = `<button class="quest-btn" disabled>已领取</button>`;
    }

    card.innerHTML = `
      <h3>${quest.title}</h3>
      <p>${quest.description}</p>
      <div class="quest-rewards">
        <span>奖励: ${quest.rewards}</span>
        <span>状态: ${getQuestStatusText(quest.status)}</span>
      </div>
      ${actionButton}
    `;

    elements.questList.appendChild(card);

    // 绑定按钮事件
    const completeBtn = card.querySelector('.complete-btn');
    const claimBtn = card.querySelector('.claim-btn');

    if (completeBtn) {
      completeBtn.addEventListener('click', () => completeQuest(quest.id));
    }

    if (claimBtn) {
      claimBtn.addEventListener('click', () => claimQuestReward(quest.id));
    }
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

// 完成任务
async function completeQuest(questId) {
  try {
    const response = await fetch(`${API_BASE_URL}/quest/${questId}/complete`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${gameState.token}`
      }
    });

    const result = await response.json();

    if (result.success) {
      // 更新玩家数据
      const rewards = result.data.rewards;
      gameState.player = result.data.player;
      gameState.player.currency = rewards.currency;
      gameState.player.experience = rewards.experience;

      // 更新属性
      if (rewards.attributeIncrease) {
        gameState.player.player_attributes[0][rewards.attribute] += rewards.amount;
      }

      // 持久化
      localStorage.setItem('player', JSON.stringify(gameState.player));

      // 更新 UI
      updatePlayerUI();
      loadAttributes();

      // 重新加载任务
      loadQuests();

      alert(`任务完成！获得：${rewards.description || '无'}`);
    } else {
      alert(`任务完成失败：${result.message || '未知错误'}`);
    }
  } catch (error) {
    console.error('Complete quest error:', error);
    alert(`任务完成失败：${error.message || '网络错误，请稍后重试'}`);
  }
}

// 领取奖励
async function claimQuestReward(questId) {
  try {
    const response = await fetch(`${API_BASE_URL}/quest/${questId}/claim`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${gameState.token}`
      }
    });

    const result = await response.json();

    if (result.success) {
      // 更新玩家数据
      const rewards = result.data.rewards;
      gameState.player = result.data.player;
      gameState.player.currency = rewards.currency;

      // 持久化
      localStorage.setItem('player', JSON.stringify(gameState.player));

      // 更新 UI
      updatePlayerUI();

      // 重新加载任务
      loadQuests();

      alert(`奖励领取成功！获得：${rewards.description || '无'}`);
    } else {
      alert(`奖励领取失败：${result.message || '未知错误'}`);
    }
  } catch (error) {
    console.error('Claim reward error:', error);
    alert(`奖励领取失败：${error.message || '网络错误，请稍后重试'}`);
  }
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
async function loadShop() {
  try {
    const response = await fetch(`${API_BASE_URL}/shop/items`, {
      headers: {
        'Authorization': `Bearer ${gameState.token}`
      }
    });

    const result = await response.json();

    if (result.success && result.data && result.data.items) {
      displayShopItems(result.data.items);
    } else {
      console.warn('Failed to load shop items from API, using fallback data');
      loadShopFallback();
    }
  } catch (error) {
    console.error('Load shop error:', error);
    console.warn('Using fallback shop data due to API error');
    loadShopFallback();
  }
}

// 加载商店（备用数据）
function loadShopFallback() {
  // 模拟商品数据（仅当 API 失败时使用）
  const items = [
    {
      itemId: 1,
      name: '苦无',
      price: 100,
      rarity: 'N',
      description: '基础忍者武器，提升忍术攻击力'
    },
    {
      itemId: 2,
      name: '手里剑',
      price: 200,
      rarity: 'R',
      description: '进阶忍者武器，大幅提升忍术攻击力'
    },
    {
      itemId: 3,
      name: '查克拉药水',
      price: 50,
      rarity: 'N',
      description: '恢复查克拉，提升战斗续航能力'
    },
    {
      itemId: 4,
      name: '血瓶',
      price: 50,
      rarity: 'N',
      description: '恢复生命值，提升生存能力'
    },
    {
      itemId: 5,
      name: '秘技卷轴',
      price: 500,
      rarity: 'SR',
      description: '学习高级忍术，大幅提升战斗力'
    },
    {
      itemId: 6,
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

  if (!items || items.length === 0) {
    elements.shopItems.innerHTML = '<p>暂无商品</p>';
    return;
  }

  items.forEach(item => {
    const card = document.createElement('div');
    card.className = 'item-card';
    card.innerHTML = `
      <div class="item-rarity rarity-${item.rarity}">${item.rarity}</div>
      <div class="item-name">${item.name}</div>
      <div class="item-price">💰 ${item.price}</div>
      <p class="item-description">${item.description || item.effect || ''}</p>
      <button class="buy-btn" data-item-id="${item.itemId || item.id}" ${gameState.player.currency < item.price ? 'disabled' : ''}>
        购买
      </button>
    `;

    const buyBtn = card.querySelector('.buy-btn');
    buyBtn.addEventListener('click', () => buyItem(item));

    elements.shopItems.appendChild(card);
  });
}

// 购买物品
async function buyItem(item) {
  if (gameState.player.currency < item.price) {
    alert('货币不足！');
    return;
  }

  if (confirm(`确定购买 ${item.name} 吗？价格：${item.price} 货币`)) {
    try {
      const itemId = item.itemId || item.id;
      const response = await fetch(`${API_BASE_URL}/shop/purchase`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${gameState.token}`
        },
        body: JSON.stringify({
          itemId: itemId,
          quantity: 1
        })
      });

      const result = await response.json();

      if (result.success) {
        // 更新本地玩家数据
        gameState.player.currency = result.data.gold;
        localStorage.setItem('player', JSON.stringify(gameState.player));
        updatePlayerUI();
        alert(`成功购买 ${item.name}！`);
        loadShop(); // 重新加载商店，更新按钮状态
      } else {
        alert(`购买失败：${result.message || '未知错误'}`);
      }
    } catch (error) {
      console.error('Purchase error:', error);
      alert('购买失败，请稍后重试');
    }
  }
}

// 加载存档
async function loadSaves() {
  try {
    const response = await fetch(`${API_BASE_URL}/saves`, {
      headers: {
        'Authorization': `Bearer ${gameState.token}`
      }
    });

    const result = await response.json();

    if (result.code === 200 && result.data && result.data.saves) {
      displaySaves(result.data.saves);
    } else {
      console.warn('Failed to load saves from API, using fallback data');
      displaySaves([]);
    }
  } catch (error) {
    console.error('Load saves error:', error);
    console.warn('No saves loaded due to API error');
    displaySaves([]);
  }
}

// 显示存档
function displaySaves(saves) {
  elements.saveList.innerHTML = '';

  if (!saves || saves.length === 0) {
    elements.saveList.innerHTML = '<p>暂无存档</p>';
    return;
  }

  saves.forEach(save => {
    const card = document.createElement('div');
    card.className = 'save-card';

    // 格式化时间
    const updatedAt = save.updatedAt ? new Date(save.updatedAt).toLocaleString() : '未知时间';
    const chapterName = save.currentChapter || '未知章节';
    const playerLevel = save.playerLevel || 1;

    card.innerHTML = `
      <div>
        <h3>${save.saveName || '未命名存档'}</h3>
        <p>时间：${updatedAt}</p>
        <p>章节：${chapterName}</p>
        <p>等级：Lv.${playerLevel}</p>
      </div>
      <div class="save-actions">
        <button class="load-save-btn" data-save-id="${save.saveId}">加载</button>
        <button class="delete-save-btn" data-save-id="${save.saveId}">删除</button>
      </div>
    `;

    // 加载按钮事件
    const loadBtn = card.querySelector('.load-save-btn');
    loadBtn.addEventListener('click', () => loadSave(save));

    // 删除按钮事件
    const deleteBtn = card.querySelector('.delete-save-btn');
    deleteBtn.addEventListener('click', () => deleteSave(save.saveId));

    elements.saveList.appendChild(card);
  });
}

// 创建存档
async function createSave(saveName) {
  try {
    const saveData = {
      saveName: saveName || `自动存档 ${new Date().toLocaleString()}`,
      playerLevel: gameState.player.level,
      attributes: gameState.attributes,
      currentChapter: gameState.currentChapter,
      playTime: 0 // TODO: 添加实际的游玩时间跟踪
    };

    const response = await fetch(`${API_BASE_URL}/saves`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${gameState.token}`
      },
      body: JSON.stringify(saveData)
    });

    const result = await response.json();

    if (result.code === 201) {
      alert(`存档创建成功：${saveName}`);
      loadSaves();
    } else {
      alert(`存档创建失败：${result.message || '未知错误'}`);
    }
  } catch (error) {
    console.error('Create save error:', error);
    alert('存档创建失败，请稍后重试');
  }
}

// 加载存档
async function loadSave(save) {
  try {
    // 1. 确认加载
    if (!confirm(`确定加载存档 "${save.saveName}" 吗？当前进度将被覆盖。`)) {
      return;
    }

    // 2. 调用加载存档 API
    const response = await fetch(`${API_BASE_URL}/saves/${save.saveId}/load`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${gameState.token}`
      }
    });

    const result = await response.json();

    // 3. 检查结果
    if (result.success) {
      // 4. 更新玩家数据
      const saveData = result.data.saveData;
      gameState.player = saveData.playerData;
      gameState.currentChapter = saveData.currentChapter;
      gameState.currentNode = saveData.currentNode;
      gameState.attributes = saveData.attributes;

      // 5. 持久化到 localStorage
      localStorage.setItem('player', JSON.stringify(gameState.player));
      localStorage.setItem('currentChapter', gameState.currentChapter);
      localStorage.setItem('currentNode', gameState.currentNode);
      if (gameState.attributes) {
        localStorage.setItem('attributes', JSON.stringify(gameState.attributes));
      }

      // 6. 更新所有 UI
      updatePlayerUI();
      loadAttributes();
      loadStory();
      loadQuests();

      // 7. 显示成功提示
      alert(`存档 "${save.saveName}" 加载成功！`);
    } else {
      alert(`加载存档失败：${result.message || '未知错误'}`);
    }
  } catch (error) {
    console.error('Load save error:', error);
    alert(`加载存档失败：${error.message || '网络错误，请稍后重试'}`);
  }
}

// 删除存档
async function deleteSave(saveId) {
  if (confirm('确定删除该存档吗？此操作不可恢复。')) {
    try {
      const response = await fetch(`${API_BASE_URL}/saves/${saveId}`, {
        method: 'DELETE',
        headers: {
          'Authorization': `Bearer ${gameState.token}`
        }
      });

      const result = await response.json();

      if (result.code === 200) {
        alert('存档删除成功');
        loadSaves();
      } else {
        alert(`存档删除失败：${result.message || '未知错误'}`);
      }
    } catch (error) {
      console.error('Delete save error:', error);
      alert('存档删除失败，请稍后重试');
    }
  }
}

// 创建存档按钮事件
elements.createSaveBtn.addEventListener('click', () => {
  const saveName = prompt('请输入存档名称：', `自动存档 ${new Date().toLocaleTimeString()}`);
  if (saveName) {
    createSave(saveName);
  }
});

// 加载存档按钮事件（预留）
elements.loadSaveBtn.addEventListener('click', () => {
  alert('请从存档列表中选择要加载的存档');
});

console.log('游戏已加载！');
