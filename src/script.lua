--
-- Helpers
--
-- Base mod file used to test the helpers
--
-- @author  TyKonKet
-- @date 20/03/2017
Helpers = {};
Helpers.name = "Helpers";

function Helpers:print(txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9)
    local args = {txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9};
    for i, v in ipairs(args) do
        if v then
            print("[" .. self.name .. "] -> " .. tostring(v));
        end
    end
end

function Helpers:initialize(missionInfo, missionDynamicInfo, loadingScreen)
    self = Helpers;
    -- Instance of the fade effect object
    self.fadeEffect = FadeEffect:new({position = {x = 0.5, y = 0.5}, size = 0.03, shadow = true, shadowPosition = {x = 0.0025, y = 0.0035}, statesTime = {1, 2, 1}});
    -- Instance of HUDs
    self.hudBGX = 0.5;
    self.hudBGY = 0.5;
    self.hudBG = HUD:new("HUDBackground", g_baseUIFilename, hudBGX, hudBGY, 225, 125);
    self.hudBG:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_CENTER);
    self.hudBG:setUVs(g_colorBgUVs);
    self.hudBG:setColor(unpack(g_colorBg));
    self.hudBG:addCallback(Helpers.onMouseEnter, HUD.CALLBACKS_MOUSE_ENTER);
    self.hudBG:addCallback(Helpers.onMouseLeave, HUD.CALLBACKS_MOUSE_LEAVE);
    self.hudSBG = HUD:new("HUDSecondaryBackground", g_baseUIFilename, 0.5, 0.5, 151, 51, self.hudBG);
    self.hudSBG:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_CENTER);
    self.hudSBG:setUVs(g_colorBgUVs);
    self.hudSBG:setColor(0.0075, 0.0075, 0.0075, 1);
    --self.hudBox1 = HUD:new("HUDBox1", g_baseUIFilename, 0.018, 0.5, 65, 101, self.hudSBG);
    --self.hudBox1:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT);
    --self.hudBox1:setUVs(g_colorBgUVs);
    --self.hudBox1:setColor(0.75, 0.0075, 0.0075, 1);
    --self.hudBox2 = HUD:new("HUDBox2", g_baseUIFilename, 0.5, 0.5, 65, 101, self.hudSBG);
    --self.hudBox2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_CENTER);
    --self.hudBox2:setUVs(g_colorBgUVs);
    --self.hudBox2:setColor(0.0075, 0.75, 0.0075, 1);
    --self.hudBox3 = HUD:new("HUDBox3", g_baseUIFilename, 0.982, 0.5, 65, 101, self.hudSBG);
    --self.hudBox3:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_RIGHT);
    --self.hudBox3:setUVs(g_colorBgUVs);
    --self.hudBox3:setColor(0.0075, 0.75, 0.75, 1);
end
g_mpLoadingScreen.loadFunction = Utils.prependedFunction(g_mpLoadingScreen.loadFunction, Helpers.initialize);

function Helpers:load(missionInfo, missionDynamicInfo, loadingScreen)
    self = Helpers;
    g_currentMission.loadMapFinished = Utils.appendedFunction(g_currentMission.loadMapFinished, self.loadMapFinished);
    g_currentMission.onStartMission = Utils.appendedFunction(g_currentMission.onStartMission, self.afterLoad);
    g_currentMission.missionInfo.saveToXML = Utils.appendedFunction(g_currentMission.missionInfo.saveToXML, self.saveSavegame);
end
g_mpLoadingScreen.loadFunction = Utils.appendedFunction(g_mpLoadingScreen.loadFunction, Helpers.load);

function Helpers:loadMap(name)
    if self.debug then
        addConsoleCommand("AAABFUToggleDebug", "", "FUToggleDebug", self);
        addConsoleCommand("AAAPrintVehicleValue", "", "PrintVehicleValue", self);
        addConsoleCommand("AAASetFuelFillLevel", "", "SetFuelFillLevel", self);
        addConsoleCommand("gsExportStoreItems", "Exports storeItem data", "consoleCommandExportStoreItems", g_currentMission);
        addConsoleCommand("gsStartBrandSale", "Starts a brand sale", "consoleStartBrandSale", g_currentMission);
        addConsoleCommand("gsStartVehicleSale", "Starts a vehicle sale", "consoleStartVehicleSale", g_currentMission);
        addConsoleCommand("gsStartGreatDemand", "Starts a great demand", "consoleStartGreatDemand", g_currentMission);
        addConsoleCommand("gsUpdateTipCollisions", "Updates the collisions for tipping on the ground around the current camera", "consoleCommandUpdateTipCollisions", g_currentMission);
        addConsoleCommand("gsTeleport", "Teleports to given field or x/z-position", "consoleCommandTeleport", g_currentMission);
        addConsoleCommand("gsActivateCameraPath", "Activate camera path", "consoleActivateCameraPath", g_currentMission);
    end
    addConsoleCommand("AAAHelpersFadeEffect", "", "playFadeEffect", self);
    self:loadSavegame();
end

function Helpers:loadMapFinished()
    self = Helpers;
end

function Helpers:afterLoad()
    self = Helpers;
end

function Helpers:loadSavegame()
end

function Helpers:saveSavegame()
    self = Helpers;
end

function Helpers:deleteMap()
    -- Delete the HUDs and all their childs (whith the first parameter true)
    self.hudBG:delete(true);
end

function Helpers:playFadeEffect()
    -- Start/play of the fade effect object
    self.fadeEffect:play("Test fade effect!");
end

function Helpers:keyEvent(unicode, sym, modifier, isDown)
end

function Helpers:mouseEvent(posX, posY, isDown, isUp, button)
end

function Helpers:update(dt)
    -- Update of the fade effect object
    self.fadeEffect:update(dt);
    -- Update of HUDs
    --self.hudBGX = self.hudBGX + (math.random(0, 20) - 10) / 10000;
    --self.hudBGY = self.hudBGY + (math.random(0, 20) - 10) / 10000;
    if self.hudBGX > 1 then
        self.hudBGX = 0;
    end
    if self.hudBGX < 0 then
        self.hudBGX = 1;
    end
    if self.hudBGY > 1 then
        self.hudBGY = 0;
    end
    if self.hudBGY < 0 then
        self.hudBGY = 1;
    end
    self.hudBG:setPosition(self.hudBGX, self.hudBGY);
end

function Helpers:draw()
    -- Draw of the fade effect object
    self.fadeEffect:draw();
end

function Helpers:onMouseEnter(x, y)
    --self:print(string.format("onMouseEnter(x:%s, y:%s)", x, y));
    self:setColor(0.0075, 0.0075, 0.0075, 1);
end

function Helpers:onMouseLeave(x, y)
    --self:print(string.format("onMouseLeave(x:%s, y:%s)", x, y));
    self:setColor(unpack(g_colorBg));
end

addModEventListener(Helpers);
