enemyCaster = {}
enemyList = {}
teamList = {}

local characterName = g_game.getCharacterName()
local worldName = g_game.getWorldName()

storage.enemyConfig = storage.enemyConfig or {}
storage.enemyConfig[worldName] = storage.enemyConfig[worldName] or {}
storage.enemyConfig[worldName][characterName] = storage.enemyConfig[worldName][characterName] or {}
local config = storage.enemyConfig[worldName][characterName]

if config.macroActive == nil then config.macroActive = true end
if config.teamMacroActive == nil then config.teamMacroActive = false end
config.maxDistance = config.maxDistance or 6
config.currentMode = config.currentMode or "Enemy Priority"


config.enemies = config.enemies or {}
config.team = config.team or {}


local INIMIGOS_BASE = {
    "S A S K H E", "B L A S P H E M O U S", "N E A Rmx", "Demon Blessed",
    "B O C H I T A", "A n G eL JeS", "D R A K A R", "HALL DEMON",
    "S E P H I R O T H", "C R I S T I A N", "J O S S E", "G aa P",
    "And Do SuMiDaO", "D a N", "H A Y A M I", "T u v i s i c a"
}

local TEAM_BASE = {
    "S U P E R A", "A DROGA DA VIDA", "A DROGA DO AMOR", "A K A S H I SEIJURO",
    "Cheon Yeo Woon", "K A M i", "Last Dance", "I B O L I N I",
    "P A K U R O", "S e r i a l K i l l e r"
}

local function verificarBases()
    for i, v in ipairs(INIMIGOS_BASE) do
        if config.enemies[v] == nil then config.enemies[v] = { enabled = true, index = i } end
    end
    for i, v in ipairs(TEAM_BASE) do
        if config.team[v] == nil then config.team[v] = { enabled = true, index = i } end
    end
end
verificarBases()

local function getActiveTable()
    return config.currentMode == "Enemy Priority" and config.enemies or config.team
end

local function getActiveBase()
    return config.currentMode == "Enemy Priority" and INIMIGOS_BASE or TEAM_BASE
end

function getSortedList()
    local sorted = {}
    local t = getActiveTable()
    for name, data in pairs(t) do
        table.insert(sorted, { name = name, data = data })
    end
    table.sort(sorted, function(a, b) return (a.data.index or 0) < (b.data.index or 0) end)
    return sorted
end

local function updateInternalLists()
    enemyList = {}
    teamList = {}
    
    local sortedEnemies = {}
    for name, data in pairs(config.enemies) do table.insert(sortedEnemies, {name=name, data=data}) end
    table.sort(sortedEnemies, function(a,b) return (a.data.index or 0) < (b.data.index or 0) end)
    for _, item in ipairs(sortedEnemies) do
        if item.data.enabled then table.insert(enemyList, item.name:lower():trim()) end
    end

    local sortedTeam = {}
    for name, data in pairs(config.team) do table.insert(sortedTeam, {name=name, data=data}) end
    table.sort(sortedTeam, function(a,b) return (a.data.index or 0) < (b.data.index or 0) end)
    for _, item in ipairs(sortedTeam) do
        if item.data.enabled then table.insert(teamList, item.name:lower():trim()) end
    end
end

local corText = '#FFFFFF'
local ui = setupUI([[
Panel
  height: 19
  BotSwitch
    id: title
    anchors.top: parent.top
    anchors.left: parent.left
    text-align: center
    width: 130
    text: enemyfinal
    $on:
      color: ]] .. corText .. [[
    $!on:
      color: white
  Button
    id: push
    anchors.top: prev.top
    anchors.left: prev.right
    anchors.right: parent.right
    margin-left: 3
    height: 17
    text: Setup
]], mainTab)

enemyCaster.window = setupUI([[
MainWindow
  id: enemyWindow
  size: 550 350
  text: ENEMY byLUIZ

  Panel
    id: mainPanel
    image-source: /images/ui/panel_flat
    anchors.fill: parent
    margin-bottom: 35

    ComboBox
      id: configList
      anchors.top: parent.top
      anchors.left: parent.left
      margin-top: 5
      text-offset: 3 0
      width: 140

    TextList
      id: enemyTextList
      anchors.left: parent.left
      anchors.top: configList.bottom
      anchors.bottom: codePanel.top
      width: 250
      background-color: #00000044
      margin-top: 5
      margin-bottom: 5
      margin-left: 0
      vertical-scrollbar: enemyListScroll
      text-list-toggle: false

    VerticalScrollBar
      id: enemyListScroll
      anchors.top: enemyTextList.top
      anchors.bottom: enemyTextList.bottom
      anchors.right: enemyTextList.right
      step: 10
      pixels-scroll: true

    Label
      id: playerNameLabel
      text: Nick do Jogador
      anchors.left: enemyTextList.right
      anchors.top: parent.top
      margin-left: 20
      margin-top: 15
      text-auto-resize: true
    
    TextEdit
      id: playerNameInput
      anchors.left: playerNameLabel.left
      anchors.top: playerNameLabel.bottom
      anchors.right: parent.right
      margin-top: 5
      margin-right: 15
      height: 30

    Button
      id: moveUp
      text: ^
      tooltip: Mover para cima
      anchors.left: enemyTextList.right
      anchors.top: playerNameInput.bottom
      margin-top: 15
      margin-left: 20
      size: 20 20

    Button
      id: moveDown
      text: v
      tooltip: Mover para baixo
      anchors.left: moveUp.right
      anchors.top: moveUp.top
      margin-left: 5
      size: 20 20

    Label
      id: distLabel
      text: Distancia Max:
      anchors.left: moveDown.right
      anchors.verticalCenter: moveDown.verticalCenter
      margin-left: 25
      text-auto-resize: true

    TextEdit
      id: distInput
      anchors.left: distLabel.right
      anchors.verticalCenter: distLabel.verticalCenter
      margin-left: 5
      width: 35
      height: 20
      text-align: center
      focusable: false

    Button
      id: distUp
      text: ^
      anchors.left: distInput.right
      anchors.top: distInput.top
      margin-left: 2
      size: 15 10

    Button
      id: distDown
      text: v
      anchors.left: distUp.left
      anchors.top: distUp.bottom
      size: 15 10

    Button
      id: addButton
      text: Adicionar Base
      anchors.left: playerNameInput.left
      anchors.top: moveUp.bottom
      margin-top: 15
      width: 140
      height: 35

    Panel
      id: codePanel
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: 45
      
      Label
        id: codeLabel
        text: Codigo da Chave Atual:
        anchors.top: parent.top
        anchors.left: parent.left
        text-auto-resize: true

      TextEdit
        id: codeInput
        anchors.top: codeLabel.bottom
        anchors.left: parent.left
        anchors.right: applyButton.left
        margin-top: 3
        margin-right: 5
        height: 22

      Button
        id: applyButton
        text: Aplicar
        anchors.top: codeInput.top
        anchors.right: generateButton.left
        margin-right: 5
        width: 60
        height: 22

      Button
        id: generateButton
        text: Gerar
        anchors.top: codeInput.top
        anchors.right: parent.right
        width: 60
        height: 22

  Button
    id: closeButton
    text: Close
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    width: 85
    height: 25
]], g_ui.getRootWidget())

enemyCaster.window:hide()

local mainPanel = enemyCaster.window:getChildById('mainPanel')
local enemyTextList = mainPanel:getChildById('enemyTextList')
local codePanel = mainPanel:getChildById('codePanel')
local comboMode = mainPanel:getChildById('configList')

comboMode:addOption("Enemy Priority")
comboMode:addOption("Team Priority")
comboMode:setCurrentOption(config.currentMode)

mainPanel:getChildById('distInput'):setText(tostring(config.maxDistance))

function enemyCaster.refreshList()
    local focusedChild = enemyTextList:getFocusedChild()
    local focusedNick = focusedChild and focusedChild.nickName or nil

    enemyTextList:destroyChildren()
    local sorted = getSortedList()
    
    for _, item in ipairs(sorted) do
        local enemyName = item.name
        local data = item.data

        local itemWidget = setupUI([[
UIWidget
  height: 22
  margin-top: 2
  anchors.left: parent.left
  anchors.right: parent.right
  focusable: true
  $focus:
    background-color: #00000055
  CheckBox
    id: enabled
    width: 15
    height: 15
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    margin-left: 5
  Label
    id: nickLabel
    anchors.left: enabled.right
    anchors.right: remove.left
    anchors.verticalCenter: parent.verticalCenter
    margin-left: 5
    text-auto-resize: true
  Button
    id: remove
    text: X
    width: 16
    height: 16
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    margin-right: 18
]], enemyTextList)
        
        itemWidget.nickName = enemyName
        itemWidget.nickLabel:setText(enemyName)
        itemWidget.enabled:setChecked(data.enabled)
        
        itemWidget.enabled.onCheckChange = function(cb, checked)
            local t = getActiveTable()
            if t[enemyName] then t[enemyName].enabled = checked end
            updateInternalLists()
        end
        
        itemWidget.remove.onClick = function()
            local t = getActiveTable()
            t[enemyName] = nil
            updateInternalLists()
            enemyCaster.refreshList()
        end

        itemWidget.onClick = function() enemyTextList:focusChild(itemWidget) end
        if focusedNick == enemyName then enemyTextList:focusChild(itemWidget) end
    end
end

comboMode.onOptionChange = function(widget, option)
    config.currentMode = option
    codePanel:getChildById('codeInput'):setText("")
    enemyCaster.refreshList()
end

local function gerarNumeroOrdem()
    local sorted = getSortedList()
    local base = getActiveBase()
    local orderStr = ""
    for _, item in ipairs(sorted) do
        for baseIdx, baseName in ipairs(base) do
            if item.name == baseName then
                orderStr = orderStr .. string.format("%02d", baseIdx)
                break
            end
        end
    end
    codePanel:getChildById('codeInput'):setText(orderStr)
end

local function aplicarNumeroOrdem(codigo)
    codigo = codigo:trim()
    if codigo:len() == 0 or (codigo:len() % 2 ~= 0) then 
        g_logger.error("[Ordem] Chave inválida ou incorreta para este modo!")
        return 
    end
    
    local base = getActiveBase()
    
    if config.currentMode == "Enemy Priority" then config.enemies = {} else config.team = {} end
    local t = getActiveTable()
    
    local currentIdx = 1
    for i = 1, codigo:len(), 2 do
        local baseIdx = tonumber(codigo:sub(i, i+1))
        if baseIdx and base[baseIdx] then
            local name = base[baseIdx]
            t[name] = { enabled = true, index = currentIdx }
            currentIdx = currentIdx + 1
        end
    end
    
    updateInternalLists()
    enemyCaster.refreshList()
    g_logger.info("[Ordem] Nova lista de prioridade aplicada via chave!")
end

codePanel:getChildById('generateButton').onClick = function() gerarNumeroOrdem() end
codePanel:getChildById('applyButton').onClick = function()
    local codigo = codePanel:getChildById('codeInput'):getText()
    aplicarNumeroOrdem(codigo)
end

-- MOVIMENTAÇÃO DE PRIORIDADE
local function changeNickOrder(offset)
    local child = enemyTextList:getFocusedChild()
    if not child then return end
    
    local currentNick = child.nickName
    local sorted = getSortedList()
    
    local currentIndex = nil
    for i, item in ipairs(sorted) do
        if item.name == currentNick then currentIndex = i; break end
    end
    if not currentIndex then return end
    
    local targetIndex = currentIndex + offset
    if targetIndex >= 1 and targetIndex <= #sorted then
        local currentData = sorted[currentIndex].data
        local targetData = sorted[targetIndex].data
        
        local tempIndex = currentData.index
        currentData.index = targetData.index
        targetData.index = tempIndex
        
        updateInternalLists()
        enemyCaster.refreshList()
    end
end

mainPanel:getChildById('moveUp').onClick = function() changeNickOrder(-1) end
mainPanel:getChildById('moveDown').onClick = function() changeNickOrder(1) end

mainPanel:getChildById('addButton').onClick = function()
    local nick = mainPanel:getChildById('playerNameInput'):getText():trim()
    if nick:len() > 0 then
        local base = getActiveBase()
        local t = getActiveTable()
        
        local encontrado = false
        for _, v in ipairs(base) do
            if v:lower() == nick:lower() then encontrado = true; nick = v; break end
        end
        if not encontrado then table.insert(base, nick) end

        local maxIndex = 0
        for _, data in pairs(t) do
            if data.index and data.index > maxIndex then maxIndex = data.index end
        end
        
        t[nick] = { enabled = true, index = maxIndex + 1 }
        mainPanel:getChildById('playerNameInput'):setText('')
        updateInternalLists()
        enemyCaster.refreshList()
    end
end

mainPanel:getChildById('distUp').onClick = function()
    local current = tonumber(mainPanel:getChildById('distInput'):getText()) or 6
    if current < 15 then
        config.maxDistance = current + 1
        mainPanel:getChildById('distInput'):setText(tostring(config.maxDistance))
    end
end

mainPanel:getChildById('distDown').onClick = function()
    local current = tonumber(mainPanel:getChildById('distInput'):getText()) or 6
    if current > 1 then
        config.maxDistance = current - 1
        mainPanel:getChildById('distInput'):setText(tostring(config.maxDistance))
    end
end

ui.push.onClick = function()
    enemyCaster.window:show(); enemyCaster.window:raise(); enemyCaster.window:focus()
end

ui.title:setOn(config.macroActive)
ui.title.onClick = function(widget)
    config.macroActive = not config.macroActive
    widget:setOn(config.macroActive)
end

local closeBtn = enemyCaster.window:getChildById('closeButton')
if closeBtn then closeBtn.onClick = function() enemyCaster.window:hide() end end

updateInternalLists()
enemyCaster.refreshList()

macro(100, function()
    if not config.macroActive then return end
    if isInPz() then return end

    local pos = player:getPosition()
    if not pos then return end
    
    local myName = player:getName():lower():trim() 
    local allowedDistance = config.maxDistance or 6
    local listaAlvo = config.currentMode == "Enemy Priority" and enemyList or teamList
    
    -- Se a lista de alvos estiver vazia, não há o que processar
    if #listaAlvo == 0 then return end

    -- 1. Coleta os espectadores da tela uma ÚNICA vez
    local spectators = getSpectators(pos)
    if not spectators then return end

    -- Map para busca rápida dos espectadores visíveis por nome formatado
    local visiblePlayers = {}
    for _, creature in ipairs(spectators) do
        if creature:isPlayer() and creature:getHealthPercent() > 0 then
            local specName = creature:getName():lower():trim()
            if specName ~= myName then
                visiblePlayers[specName] = creature
            end
        end
    end

    local actualTarget, actualTargetHp = nil, nil

    -- 2. Varre a lista de alvos na ordem de prioridade correta
    for _, targetName in ipairs(listaAlvo) do
        local creature = visiblePlayers[targetName]
        
        if creature then
            -- Verifica distância e se é possível atacar (canShoot)
            if getDistanceBetween(pos, creature:getPosition()) <= allowedDistance then
                if creature:canShoot() then
                    local specHp = creature:getHealthPercent()
                    
                    -- Prioriza o jogador que tiver menos vida (mantendo a lógica original)
                    if not actualTarget or actualTargetHp > specHp then
                        actualTarget, actualTargetHp = creature, specHp
                    end
                end
            end
        end
    end
    
    -- 3. Ataca o alvo encontrado se já não estiver atacando ele
    if actualTarget and g_game.getAttackingCreature() ~= actualTarget then
        modules.game_interface.processMouseAction(nil, 2, pos, nil, actualTarget, actualTarget)
    end
end)
