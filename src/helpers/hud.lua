--
-- HUD
--
-- @author  TyKonKet
-- @date 04/04/2017
HUD = {};
HUD.CALLBACKS_MOUSE_ENTER = 1;
HUD.CALLBACKS_MOUSE_LEAVE = 2;
HUD.CALLBACKS_MOUSE_DOWN = 3;
HUD.CALLBACKS_MOUSE_CLICK = 5;
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
    self.callbacks.mouseEnter = {};
    self.callbacks.mouseLeave = {};
    self.leaveRised = true;
    self.callbacks.mouseDown = {};
    self.callbacks.mouseUp = {};
    self.callbacks.mouseClick = {};
    self.childs = {};
    self.parent = parent;
    if self.parent ~= nil then
        table.insert(self.parent.childs, self);
    end
    HUDManager:addHUD(self);
    return self;
end

function HUD:mouseEvent(posX, posY, isDown, isUp, button)
    if self.parent == nil then
        local x, y = self:getRenderPosition();
        local w, h = self:getRenderDimension();
        if posX >= x and posX <= x + w and posY >= y and posY <= y + h then
            --self:print(string.format("posX:%s, posY:%s, isDown:%s, isUp:%s, button:%s", posX, posY, isDown, isUp, button));
            if not self.enterRised then
                self.leaveRised = false;
                self.enterRised = true;
                self:callCallback(HUD.CALLBACKS_MOUSE_ENTER, posX, posY);
            end
        else
            if not self.leaveRised then
                self.leaveRised = true;
                self.enterRised = false;
                self:callCallback(HUD.CALLBACKS_MOUSE_LEAVE, posX, posY);
            end
        end
    end
end

function HUD:addCallback(cb, type)
    if type == HUD.CALLBACKS_MOUSE_ENTER then
        table.insert(self.callbacks.mouseEnter, cb);
        return true;
    end
    if type == HUD.CALLBACKS_MOUSE_LEAVE then
        table.insert(self.callbacks.mouseLeave, cb);
        return true;
    end
    if type == HUD.CALLBACKS_MOUSE_DOWN then
        table.insert(self.callbacks.mouseDown, cb);
        return true;
    end
    if type == HUD.CALLBACKS_MOUSE_UP then
        table.insert(self.callbacks.mouseUp, cb);
        return true;
    end
    if type == HUD.CALLBACKS_MOUSE_CLICK then
        table.insert(self.callbacks.mouseClick, cb);
        return true;
    end
    return false;
end

function HUD:callCallback(type, ...)
    local callbacks = nil;
    if type == HUD.CALLBACKS_MOUSE_ENTER then
        callbacks = self.callbacks.mouseEnter, cb;
    end
    if type == HUD.CALLBACKS_MOUSE_LEAVE then
        callbacks = self.callbacks.mouseLeave, cb;
    end
    if type == HUD.CALLBACKS_MOUSE_DOWN then
        callbacks = self.callbacks.mouseDown, cb;
    end
    if type == HUD.CALLBACKS_MOUSE_UP then
        callbacks = self.callbacks.mouseUP, cb;
    end
    if type == HUD.CALLBACKS_MOUSE_CLICK then
        callbacks = self.callbacks.mouseClick, cb;
    end
    if callbacks ~= nil then
        for _, c in pairs(callbacks) do
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
