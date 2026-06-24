enemyCaster = {}
enemyList = {}

local characterName = g_game.getCharacterName()
local worldName = g_game.getWorldName()

storage.enemyConfig = storage.enemyConfig or {}
storage.enemyConfig[worldName] = storage.enemyConfig[worldName] or {}
storage.enemyConfig[worldName][characterName] = storage.enemyConfig[worldName][characterName] or {}
local config = storage.enemyConfig[worldName][characterName]

if config.macroActive == nil then
    config.macroActive = true
end
config.maxDistance = config.maxDistance or 6
config.currentProfile = config.currentProfile or "Perfil 1"

config.profiles = config.profiles or {
    ["Perfil 1"] = { url = "", enemies = {} },
    ["Perfil 2"] = { url = "", enemies = {} },
    ["Perfil 3"] = { url = "", enemies = {} }
}

local function getActiveProfile()
    return config.profiles[config.currentProfile]
end

local function getSortedEnemies()
    local sorted = {}
    local profile = getActiveProfile()
    for enemyName, data in pairs(profile.enemies) do
        table.insert(sorted, { name = enemyName, data = data })
    end
    table.sort(sorted, function(a, b)
        return (a.data.index or 0) < (b.data.index or 0)
    end)
    return sorted
end

local function updateEnemyList()
    enemyList = {}
    local sorted = getSortedEnemies()
    for _, item in ipairs(sorted) do
        if item.data.enabled then
            table.insert(enemyList, item.name:lower():trim())
        end
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
    text: Enemy
    
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
  size: 550 340
  text: ENEMY BY LUIZ

  Panel
    id: mainPanel
    image-source: /images/ui/panel_flat
    anchors.fill: parent
    margin-bottom: 40

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
      anchors.bottom: urlPanel.top
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
      text: Adicionar
      anchors.left: playerNameInput.left
      anchors.top: moveUp.bottom
      margin-top: 15
      width: 140
      height: 35

    Panel
      id: urlPanel
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: 45
      
      Label
        id: urlLabel
        text: Link da Lista
        anchors.top: parent.top
        anchors.left: parent.left
        text-auto-resize: true

      TextEdit
        id: urlInput
        anchors.top: urlLabel.bottom
        anchors.left: parent.left
        anchors.right: syncButton.left
        margin-top: 3
        margin-right: 5
        height: 22

      Button
        id: syncButton
        text: Sync
        anchors.top: urlInput.top
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

local mainPanel = enemyCaster.window.mainPanel
local enemyTextList = mainPanel.enemyTextList

mainPanel.configList:addOption("Perfil 1")
mainPanel.configList:addOption("Perfil 2")
mainPanel.configList:addOption("Perfil 3")
mainPanel.configList:setCurrentOption(config.currentProfile)

mainPanel.distInput:setText(tostring(config.maxDistance))
mainPanel.urlPanel.urlInput:setText(getActiveProfile().url)

function enemyCaster.refreshList()
    local focusedChild = enemyTextList:getFocusedChild()
    local focusedNick = focusedChild and focusedChild.nickName or nil

    enemyTextList:destroyChildren()
    local sorted = getSortedEnemies()
    local profile = getActiveProfile()
    
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
            profile.enemies[enemyName].enabled = checked
            updateEnemyList()
        end
        
        itemWidget.remove.onClick = function()
            profile.enemies[enemyName] = nil
            updateEnemyList()
            enemyCaster.refreshList()
        end

        itemWidget.onClick = function()
            enemyTextList:focusChild(itemWidget)
        end

        if focusedNick == enemyName then
            enemyTextList:focusChild(itemWidget)
        end
    end
end

mainPanel.configList.onOptionChange = function(widget, option)
    config.currentProfile = option
    local profile = getActiveProfile()
    
    mainPanel.urlPanel.urlInput:setText(profile.url)
    
    updateEnemyList()
    enemyCaster.refreshList()
end

mainPanel.distUp.onClick = function()
    local current = tonumber(mainPanel.distInput:getText()) or 6
    if current < 15 then
        config.maxDistance = current + 1
        mainPanel.distInput:setText(tostring(config.maxDistance))
    end
end

mainPanel.distDown.onClick = function()
    local current = tonumber(mainPanel.distInput:getText()) or 6
    if current > 1 then
        config.maxDistance = current - 1
        mainPanel.distInput:setText(tostring(config.maxDistance))
    end
end

local function changeNickOrder(offset)
    local child = enemyTextList:getFocusedChild()
    if not child then return end
    
    local currentNick = child.nickName
    local sorted = getSortedEnemies()
    local profile = getActiveProfile()
    
    local currentIndex = nil
    for i, item in ipairs(sorted) do
        if item.name == currentNick then
            currentIndex = i
            break
        end
    end
    
    if not currentIndex then return end
    local targetIndex = currentIndex + offset
    
    if targetIndex >= 1 and targetIndex <= #sorted then
        local currentData = sorted[currentIndex].data
        local targetData = sorted[targetIndex].data
        
        local tempIndex = currentData.index
        currentData.index = targetData.index
        targetData.index = tempIndex
        
        updateEnemyList()
        enemyCaster.refreshList()
    end
end

mainPanel.moveUp.onClick = function()
    changeNickOrder(-1)
end

mainPanel.moveDown.onClick = function()
    changeNickOrder(1)
end

mainPanel.addButton.onClick = function()
    local nick = mainPanel.playerNameInput:getText():trim()
    if nick:len() > 0 then
        local profile = getActiveProfile()
        local maxIndex = 0
        for _, data in pairs(profile.enemies) do
            if data.index and data.index > maxIndex then
                maxIndex = data.index
            end
        end
        
        profile.enemies[nick] = { enabled = true, index = maxIndex + 1 }
        mainPanel.playerNameInput:setText('')
        updateEnemyList()
        enemyCaster.refreshList()
    end
end

local function fetchCloudList()
    local url = mainPanel.urlPanel.urlInput:getText():trim()
    if url:len() < 10 then return end
    
    local profile = getActiveProfile()
    profile.url = url
    
    HTTP.get(url, function(response, err)
        if err then
            g_logger.error("[Enemy Profiles] Erro ao baixar lista: " .. tostring(err))
            return
        end
        
        if response and response:len() > 0 then
            profile.enemies = {}
            
            local currentIdx = 1
            for line in response:gmatch("[^\r\n]+") do
                local name = line:trim()
                if name:len() > 0 then
                    profile.enemies[name] = { enabled = true, index = currentIdx }
                    currentIdx = currentIdx + 1
                end
            end
            
            updateEnemyList()
            enemyCaster.refreshList()
            g_logger.info("[Enemy Profiles] [" .. config.currentProfile .. "] Sincronizado! " .. (currentIdx - 1) .. " inimigos carregados.")
        end
    end)
end

mainPanel.urlPanel.syncButton.onClick = function()
    fetchCloudList()
end

ui.push.onClick = function()
    enemyCaster.window:show()
    enemyCaster.window:raise()
    enemyCaster.window:focus()
end

ui.title:setOn(config.macroActive)
ui.title.onClick = function(widget)
    config.macroActive = not config.macroActive
    widget:setOn(config.macroActive)
end

enemyCaster.window.closeButton.onClick = function()
    enemyCaster.window:hide()
end

updateEnemyList()
enemyCaster.refreshList()

local profile = getActiveProfile()
if profile.url and profile.url:len() > 10 then
    local delaySync = macro(2000, function(macroDelay)
        fetchCloudList()
        macroDelay:setOff()
    end)
end

macro(100, function()
    if not config.macroActive then return end
    if isInPz() then return end

    local pos = player:getPosition()
    local actualTarget, actualTargetHp = nil, nil
    local allowedDistance = config.maxDistance or 6
    
    for _, enemy in ipairs(enemyList) do
        for _, creature in ipairs(getSpectators(pos)) do
            local specHp = creature:getHealthPercent()
            local specName = creature:getName():lower():trim()
            
            if creature:isPlayer() and specHp and specHp > 0 then
                if specName == enemy then
                    if getDistanceBetween(pos, creature:getPosition()) <= allowedDistance then
                        if creature:canShoot() then
                            if not actualTarget or actualTargetHp > specHp then
                                actualTarget, actualTargetHp = creature, specHp
                            end
                        end
                    end
                end
            end
        end
    end
    
    if actualTarget and g_game.getAttackingCreature() ~= actualTarget then
        modules.game_interface.processMouseAction(nil, 2, pos, nil, actualTarget, actualTarget)
    end
end)
