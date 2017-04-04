--
-- HUD
--
-- @author  TyKonKet
-- @date 04/04/2017
HUD = {};
HUD.huds = {};
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
    self.childs = {};
    self.parent = parent;
    if self.parent ~= nil then
        table.insert(self.parent.childs, self);
    end
    table.insert(HUD.huds, self);
    return self;
end

function HUD:render()
    if self.overlay.visible and self.overlay.overlayId ~= 0 then
        local x, y = self:getRenderPosition();
        renderOverlay(self.overlay.overlayId, x, y, self.overlay.width, self.overlay.height);
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

function HUD.renderHuds()
    for _, h in pairs(HUD.huds) do
        h:render();
    end
end
