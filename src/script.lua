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
end

function Helpers:draw()
    -- Draw of the fade effect object
    self.fadeEffect:draw();
end

addModEventListener(Helpers)
