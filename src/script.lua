--
-- Helpers
--
-- Base mod file used to test the helpers
--
-- @author  TyKonKet
-- @date 20/03/2017

Helpers = {};
Helpers.name = "Helpers";
Helpers.debug = true;

function Helpers:print(txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9)
    if self.debug then
        local args = {txt1, txt2, txt3, txt4, txt5, txt6, txt7, txt8, txt9};
        for i, v in ipairs(args) do
            if v then
                print("[" .. self.name .. "] -> " .. tostring(v));
            end
        end
    end
end

function Helpers:initialize(missionInfo, missionDynamicInfo, loadingScreen)
    self = Helpers;
    self:print("initialize()");
end
g_mpLoadingScreen.loadFunction = Utils.prependedFunction(g_mpLoadingScreen.loadFunction, Helpers.initialize);

function Helpers:load(missionInfo, missionDynamicInfo, loadingScreen)
    self = Helpers;
    self:print("load()");
    g_currentMission.loadMapFinished = Utils.appendedFunction(g_currentMission.loadMapFinished, self.loadMapFinished);
    g_currentMission.onStartMission = Utils.appendedFunction(g_currentMission.onStartMission, self.afterLoad);
    g_currentMission.missionInfo.saveToXML = Utils.appendedFunction(g_currentMission.missionInfo.saveToXML, self.saveSavegame);
end
g_mpLoadingScreen.loadFunction = Utils.appendedFunction(g_mpLoadingScreen.loadFunction, Helpers.load);

function Helpers:loadMap(name)
    self:print(("loadMap(name:%s)"):format(name));
    if self.debug then
        addConsoleCommand("AAAHelpersTestCommand", "", "TestCommand", self);
    end
    self:loadSavegame();
end

function Helpers:loadMapFinished()
    self = Helpers;
    self:print("loadMapFinished()");
end

function Helpers:afterLoad()
    self = Helpers;
    self:print("afterLoad");
end

function Helpers:loadSavegame()
    self:print("loadSavegame()");
end

function Helpers:saveSavegame()
    self = Helpers;
    self:print("saveSavegame()");
end

function Helpers:deleteMap()
    self:print("deleteMap()");
end

function Helpers:TestCommand()
    return "This is a test command";
end

function Helpers:keyEvent(unicode, sym, modifier, isDown)
end

function Helpers:mouseEvent(posX, posY, isDown, isUp, button)
end

function Helpers:update(dt)
end

function Helpers:draw()
end

addModEventListener(Helpers)