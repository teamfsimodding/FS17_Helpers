--
-- HUD
--
-- @author  TyKonKet
-- @date 04/04/2017
HUD = {};
HUD.CALLBACKS_MOUSE_ENTER = 1;
HUD.CALLBACKS_MOUSE_LEAVE = 2;
HUD.CALLBACKS_MOUSE_DOWN = 3;
HUD.CALLBACKS_MOUSE_UP = 4;
HUD.CALLBACKS_MOUSE_CLICK = 5;
HUD.MOUSEBUTTONS_LEFT = 1;
HUD.MOUSEBUTTONS_WHEEL = 2;
HUD.MOUSEBUTTONS_RIGHT = 3;
HUD.MOUSEBUTTONS_WHEEL_UP = 4;
HUD.MOUSEBUTTONS_WHEEL_DOWN = 5;
local HUD_mt = Class(HUD);

function HUD:print(...)
    if Helpers ~= nil then
        local args = {...};
        for i, v in ipairs(args) do
            if v then
                if #args > 1 then
                    print(string.format("[%s](%s) -> %s", self.name, i, v));
                else
                    print(string.format("[%s] -> %s", self.name, v));
                end
            end
        end
    end
end

function HUD:new(name, overlayFilename, x, y, width, height, parent)
    if HUD_mt == nil then
        HUD_mt = Class(HUD);
    end
    local self = {};
    setmetatable(self, HUD_mt);
    self.name = name
    self.uiScale = g_gameSettings:getValue("uiScale");
    self.width, self.height = getNormalizedScreenValues(width * self.uiScale, height * self.uiScale);
    self.overlay = Overlay:new(self.name, overlayFilename, x, y, self.width, self.height);
    self.callbacks = {};
    self.leaveRaised = true;
    self.wasUp = true;
    self.childs = {};
    self.parent = parent;
    if self.parent ~= nil then
        table.insert(self.parent.childs, self);
    end
    HUDManager:addHUD(self);
    return self;
end

function HUD:mouseEvent(posX, posY, isDown, isUp, button)
        local x, y = self:getRenderPosition();
        local w, h = self:getRenderDimension();
        if posX >= x and posX <= x + w and posY >= y and posY <= y + h then
            if not self.enterRaised then
                self.leaveRaised = false;
                self.enterRaised = true;
                self:callCallback(HUD.CALLBACKS_MOUSE_ENTER, posX, posY);
            end
            if isDown then
                self.clickRaised = false;
                self.wasDown = true;
                self.wasUp = false;
            end
            if isUp then
                if not self.clickRaised then
                    self.clickRaised = true
                    self:callCallback(HUD.CALLBACKS_MOUSE_CLICK, posX, posY, button);
                end
                self.wasDown = false;
                self.wasUp = true;
            end
            if self.wasUp then
                self:callCallback(HUD.CALLBACKS_MOUSE_UP, posX, posY, button);
            end
            if self.wasDown then
                self:callCallback(HUD.CALLBACKS_MOUSE_DOWN, posX, posY, button);
            end
        else
            if not self.leaveRaised then
                self.leaveRaised = true;
                self.enterRaised = false;
                self:callCallback(HUD.CALLBACKS_MOUSE_LEAVE, posX, posY);
            end
        end
end

function HUD:addCallback(cb, type)
    if self.callbacks[type] == nil then
        self.callbacks[type] = {};
    end
    table.insert(self.callbacks[type], cb);
end

function HUD:callCallback(type, ...)
    if self.callbacks[type] ~= nil then
        for _, c in pairs(self.callbacks[type]) do
            if c ~= nil then
                c(self, ...);
            end
        end
    end
end

function HUD:draw()
    self:render();
end

function HUD:render()
    if self.overlay.visible and self.overlay.overlayId ~= 0 then
        local x, y = self:getRenderPosition();
        local w, h = self:getRenderDimension();
        renderOverlay(self.overlay.overlayId, x, y, w, h);
    end
end

function HUD:delete(applyToChilds)
    self.overlay:delete();
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:delete(applyToChilds);
        end
    else
        for _, c in pairs(self.childs) do
            c.parent = nil;
        end
    end
end

function HUD:setColor(r, g, b, a)
    self.overlay:setColor(r, g, b, a);
end

function HUD:setUVs(uvs)
    self.overlay:setUVs(uvs);
end

function HUD:setPosition(x, y)
    self.overlay:setPosition(x, y);
end

function HUD:getRenderPosition()
    if self.overlay.x == nil or self.overlay.y == nil then
        return nil, nil;
    end
    local x = self.overlay.x + self.overlay.offsetX;
    local y = self.overlay.y + self.overlay.offsetY;
    if self.parent ~= nil then
        x = self.overlay.x * self.parent.overlay.width + self.overlay.offsetX;
        y = self.overlay.y * self.parent.overlay.height + self.overlay.offsetY;
        local xP, yP = self.parent:getRenderPosition();
        x = x + xP;
        y = y + yP;
    end
    return x, y;
end

function HUD:setDimension(width, height)
    self.overlay:setDimension(width, height);
end

function HUD:getRenderDimension()
    return self.overlay.width, self.overlay.height;
end

function HUD:resetDimensions(applyToChilds)
    self.overlay:resetDimensions();
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:resetDimensions(applyToChilds);
        end
    end
end

function HUD:setInvertX(invertX, applyToChilds)
    self.overlay:setInvertX(invertX);
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:setInvertX(invertX, applyToChilds);
        end
    end
end

function HUD:setRotation(rotation, centerX, centerY, applyToChilds)
    self.overlay:setRotation(rotation, centerX, centerY);
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:setRotation(rotation, centerX, centerY, applyToChilds);
        end
    end
end

function HUD:setAlignment(vertical, horizontal)
    self.overlay:setAlignment(vertical, horizontal);
end

function HUD:setIsVisible(visible, applyToChilds)
    self.overlay:setIsVisible(visible);
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:setIsVisible(visible, applyToChilds);
        end
    end
end

function HUD:setImage(overlayFilename)
    self.overlay:setImage(overlayFilename)
end

--
-- HUDManager
--
-- @author  TyKonKet
-- @date 04/04/2017
HUDManager = {};
HUDManager.huds = {};

function HUDManager:loadMap(name)
end

function HUDManager:deleteMap()
end

function HUDManager:keyEvent(unicode, sym, modifier, isDown)
    if self.missionIsStarted then
        for _, h in pairs(self.huds) do
            if h.keyEvent ~= nil then
                h:keyEvent(unicode, sym, modifier, isDown);
            end
        end
    end
end

function HUDManager:mouseEvent(posX, posY, isDown, isUp, button)
    if self.missionIsStarted then
        for _, h in pairs(self.huds) do
            if h.mouseEvent ~= nil then
                h:mouseEvent(posX, posY, isDown, isUp, button);
            end
        end
    end
end

function HUDManager:update(dt)
    if not self.missionIsStarted then
        self.missionIsStarted = true;
    end
    InputBinding.setShowMouseCursor(true);
    for _, h in pairs(self.huds) do
        if h.update ~= nil then
            h:update(dt);
        end
    end
end

function HUDManager:draw()
    if self.missionIsStarted then
        for _, h in pairs(self.huds) do
            if h.draw ~= nil then
                h:draw();
            end
        end
    end
end

function HUDManager:addHUD(hud)
    table.insert(self.huds, hud);
end

addModEventListener(HUDManager);
