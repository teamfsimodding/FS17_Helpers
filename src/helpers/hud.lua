--
-- HUD
--
-- @author  TyKonKet
-- @date 04/04/2017
HUD = {};
local HUD_mt = Class(HUD);

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

HUD.ALIGNS_VERTICAL_BOTTOM = 1;
HUD.ALIGNS_VERTICAL_MIDDLE = 2;
HUD.ALIGNS_VERTICAL_TOP = 3;

HUD.ALIGNS_HORIZONTAL_LEFT = 4;
HUD.ALIGNS_HORIZONTAL_CENTER = 5;
HUD.ALIGNS_HORIZONTAL_RIGHT = 6;

HUD.DEFAULT_UVS = {0, 0, 0, 1, 1, 0, 1, 1};

function HUD:print(text, ...)
    if Helpers ~= nil then
        local start = string.format("[%s(%s)] -> ", self.name, getDate("%H:%M:%S"));
        local ptext = string.format(text, ...);
        print(string.format("%s%s", start, ptext));
    --local args = {...};
    --for i, v in ipairs(args) do
    --    if v then
    --        if #args > 1 then
    --            print(string.format("[%s](%s) -> %s", self.name, i, v));
    --        else
    --            print(string.format("%s", self.name, v));
    --        end
    --    end
    --end
    end
end

function HUD:new(name, overlayFilename, x, y, width, height, parent)
    if HUD_mt == nil then
        HUD_mt = Class(HUD);
    end
    local self = {};
    self.name = name
    self.uiScale = g_gameSettings:getValue("uiScale");
    self.width, self.height = getNormalizedScreenValues(width * self.uiScale, height * self.uiScale);
    self.defaultWidth = self.width;
    self.defaultHeight = self.height;
    self.x = x;
    self.y = y;
    self.alignmentVertical = HUD.ALIGNS_VERTICAL_BOTTOM;
    self.alignmentHorizontal = HUD.ALIGNS_HORIZONTAL_LEFT;
    self.offsetX = 0;
    self.offsetY = 0;
    self.invertX = false;
    self.rotation = 0;
    self.rotationCenterX = 0;
    self.rotationCenterY = 0;
    self.r = 1.0;
    self.g = 1.0;
    self.b = 1.0;
    self.a = 1.0;
    self.visible = true;
    self.filename = overlayFilename;
    self.uvs = HUD.DEFAULT_UVS;
    self.overlayId = 0;
    if self.filename ~= nil then
        self.overlayId = createImageOverlay(self.filename);
    end
    self.callbacks = {};
    self.leaveRaised = true;
    self.wasUp = true;
    self.childs = {};
    self.parent = parent;
    if self.parent ~= nil then
        table.insert(self.parent.childs, self);
    end
    setmetatable(self, HUD_mt);
    HUDManager:addHUD(self);
    return self;
end

function HUD:delete(applyToChilds)
    if self.overlayId ~= 0 then
        delete(self.overlayId);
    end
    for _, c in pairs(self.childs) do
        if applyToChilds then
            c:delete(applyToChilds);
        else
            c.parent = nil;
        end
    end
end

function HUD:setColor(r, g, b, a, applyToChilds)
    self.r = Utils.getNoNil(r, self.r);
    self.g = Utils.getNoNil(g, self.g);
    self.b = Utils.getNoNil(b, self.b);
    self.a = Utils.getNoNil(a, self.a);
    if self.overlayId ~= 0 then
        setOverlayColor(self.overlayId, self.r, self.g, self.b, self.a);
    end
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:setColor(r, g, b, a, applyToChilds);
        end
    end
end

function HUD:setUVs(uvs)
    if self.overlayId ~= 0 then
        if type(uvs) == "number" then
            printCallstack();
        end
        self.uvs = uvs;
        setOverlayUVs(self.overlayId, unpack(uvs));
    end
end

function HUD:setPosition(x, y)
    self.x = Utils.getNoNil(x, self.x);
    self.y = Utils.getNoNil(y, self.y);
end

function HUD:getRenderPosition()
    local x = self.x + self.offsetX;
    local y = self.y + self.offsetY;
    if self.parent ~= nil then
        local xP, yP = self.parent:getRenderPosition();
        x = self.x * self.parent.width + self.offsetX + xP;
        y = self.y * self.parent.height + self.offsetY + yP;
    end
    return x, y;
end

function HUD:setDimension(width, height)
    self.width = Utils.getNoNil(width, self.width);
    self.height = Utils.getNoNil(height, self.height);
    self:setAlignment(self.alignmentVertical, self.alignmentHorizontal)
end

function HUD:getRenderDimension()
    return self.width, self.height;
end

function HUD:resetDimensions(applyToChilds)
    self:setDimension(self.defaultWidth, self.defaultHeight);
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:resetDimensions(applyToChilds);
        end
    end
end

function HUD:setInvertX(invertX, applyToChilds)
    if self.invertX ~= invertX then
        self.invertX = invertX;
        if self.overlayId ~= 0 then
            if invertX then
                setOverlayUVs(self.overlayId, unpack(self.uvs));
            else
                setOverlayUVs(self.overlayId, self.uvs[5], self.uvs[6], self.uvs[7], self.uvs[8], self.uvs[1], self.uvs[2], self.uvs[3], self.uvs[4]);
            end
        end
    end
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:setInvertX(invertX, applyToChilds);
        end
    end
end

function HUD:setRotation(rotation, centerX, centerY, applyToChilds)
    if self.rotation ~= rotation or self.rotationCenterX ~= centerX or self.rotationCenterY ~= centerY then
        self.rotation = rotation;
        self.rotationCenterX = centerX;
        self.rotationCenterY = centerY;
        if self.overlayId ~= 0 then
            setOverlayRotation(self.overlayId, rotation, centerX, centerY);
        end
    end
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:setRotation(rotation, centerX, centerY, applyToChilds);
        end
    end
end

function HUD:render()
    if self.visible and self.overlayId ~= 0 then
        local x, y = self:getRenderPosition();
        local w, h = self:getRenderDimension();
        if x ~= nil and y ~= nil then
            renderOverlay(self.overlayId, x, y, w, h);
        end
    end
end

function HUD:setAlignment(vertical, horizontal)
    if vertical == HUD.ALIGNS_VERTICAL_TOP then
        self.offsetY = -self.height;
    elseif vertical == HUD.ALIGNS_VERTICAL_MIDDLE then
        self.offsetY = -self.height * 0.5;
    else
        self.offsetY = 0;
    end
    self.alignmentVertical = Utils.getNoNil(vertical, HUD.ALIGNS_VERTICAL_BOTTOM);
    
    if horizontal == HUD.ALIGNS_HORIZONTAL_RIGHT then
        self.offsetX = -self.width;
    elseif horizontal == HUD.ALIGNS_HORIZONTAL_CENTER then
        self.offsetX = -self.width * 0.5;
    else
        self.offsetX = 0;
    end
    self.alignmentHorizontal = Utils.getNoNil(horizontal, HUD.ALIGNS_HORIZONTAL_LEFT);
end

function HUD:setIsVisible(visible, applyToChilds)
    self.visible = visible;
    if applyToChilds then
        for _, c in pairs(self.childs) do
            c:setIsVisible(visible, applyToChilds);
        end
    end
end

function HUD:setImage(overlayFilename)
    if self.filename ~= overlayFilename then
        if self.overlayId ~= 0 then
            delete(self.overlayId);
        end
        self.filename = overlayFilename;
        self.overlayId = createImageOverlay(overlayFilename);
    end
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
