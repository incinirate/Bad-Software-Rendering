local Edge = love.filesystem.load("edge.lua")()
local Gradients = love.filesystem.load("gradients.lua")()

local renderContext = {}
do
    local f = math.floor
    local ceil = math.ceil
    function renderContext.__init__(_, nWidth, nHeight, bg)
        local super = Bitmap(nWidth, nHeight, bg)
        local t = {}
        t.zBuffer = {}

        setmetatable(t, {__index=function(t,k) if renderContext[k] then return renderContext[k] elseif super[k] then return super[k] end end})
        return t
    end

    setmetatable(renderContext, {__call=renderContext.__init__, __index=Bitmap})

    function renderContext:clearDepthBuffer()
        for i = 0, self.width * self.height do
            self.zBuffer[i] = math.huge
        end
    end

    function renderContext:drawTriangle(v1, v2, v3, texture)
        if(v1:IsInsideViewFrustum() and v2:IsInsideViewFrustum() and v3:IsInsideViewFrustum()) then
			self:fillTriangle(v1, v2, v3, texture);
			return;
        end

        local vertices = {v1, v2, v3}
        local auxillaryList = {}

        if self:clipPolygonAxis(vertices, auxillaryList, 1) and
            self:clipPolygonAxis(vertices, auxillaryList, 2) and
            self:clipPolygonAxis(vertices, auxillaryList, 3) then
                local initialVertex = vertices[1]
                for i=2, #vertices - 1 do
                    self:fillTriangle(initialVertex, vertices[i], vertices[i + 1], texture)
                end
        end
    end

    function renderContext:clipPolygonComponent(vertices, componentIndex, componentFactor, result)
        local previousVertex = vertices[#vertices]
        local previousComponent = previousVertex:Get(componentIndex) * componentFactor
        local previousInside = previousComponent <= previousVertex.pos.w

        for i=1, #vertices do
            local currentVertex = vertices[i]
            local currentComponent = currentVertex:Get(componentIndex) * componentFactor
            local currentInside = currentComponent <= currentVertex.pos.w

            if (currentInside and not previousInside) or (not currentInside and previousInside) then
                local lerpAmt = (previousVertex.pos.w - previousComponent) /
                    ((previousVertex.pos.w - previousComponent) -
                    (currentVertex.pos.w - currentComponent))
                result[#result + 1] = previousVertex:Lerp(currentVertex, lerpAmt)
            end

            if (currentInside) then
                result[#result + 1] = currentVertex
            end

            previousVertex = currentVertex
            previousComponent = currentComponent
            previousInside = currentInside
        end
    end

    function renderContext:clipPolygonAxis(vertices, auxillaryList, componentIndex)
        self:clipPolygonComponent(vertices, componentIndex, 1, auxillaryList)
        for i=1, #vertices do
            vertices[i] = nil
        end

        if #auxillaryList == 0 then
            return
        end

        self:clipPolygonComponent(auxillaryList, componentIndex, -1, vertices)
        for i=1, #auxillaryList do
            auxillaryList[i] = nil
        end

        return #vertices ~= 0
    end

    function renderContext:fillTriangle(v1, v2, v3, texture)
        local screenSpaceTransform = Matrix4f():InitScreenSpaceTransform(self.width/2, self.height/2)
        local identity = Matrix4f():InitIdentity()
        local minYVert = v1:transform(screenSpaceTransform, identity):perspectiveDivide()
        local midYVert = v2:transform(screenSpaceTransform, identity):perspectiveDivide()
        local maxYVert = v3:transform(screenSpaceTransform, identity):perspectiveDivide()

        if (minYVert:triangleAreaTimesTwo(maxYVert, midYVert) >= 0) then
            return
        end

        if maxYVert.pos.y < midYVert.pos.y then
            local temp = maxYVert
            maxYVert = midYVert
            midYVert = temp
        end

        if midYVert.pos.y < minYVert.pos.y then
            local temp = midYVert
            midYVert = minYVert
            minYVert = temp
        end

        if maxYVert.pos.y < midYVert.pos.y then
            local temp = maxYVert
            maxYVert = midYVert
            midYVert = temp
        end

        local area = minYVert:triangleAreaTimesTwo(maxYVert, midYVert)

        self:scanTriangle(minYVert, midYVert, maxYVert, area >= 0, texture)
    end

    function renderContext:scanEdges(gradients, a, b, handedness, texture)
        local left
        local right

        if handedness then
            left = b
            right = a
        else
            left = a
            right = b
        end

        local yStart = f(b.yStart)
        local yEnd = f(b.yEnd)

        for j = yStart, yEnd - 1 do
            self:drawScanLine(gradients, left, right, j, texture)
            left:step()
            right:step()
        end
    end

    function renderContext:scanTriangle(minYVert, midYVert, maxYVert, handedness, texture)
        local gradients      = Gradients(minYVert, midYVert, maxYVert)
        local topToBottom    = Edge(gradients, minYVert, maxYVert, 1)
        local topToMiddle    = Edge(gradients, minYVert, midYVert, 1)
        local middleToBottom = Edge(gradients, midYVert, maxYVert, 2)

        self:scanEdges(gradients, topToBottom, topToMiddle, handedness, texture)
        self:scanEdges(gradients, topToBottom, middleToBottom, handedness, texture)
    end

    function renderContext:drawScanLine(gradients, left, right, j, texture)
        local xMin = ceil(left.x);
        local xMax = ceil(right.x);
        local xPrestep = xMin - left.x;

        -- local xDist = right.x - left.x
        -- local texCoordXXStep = (right.texCoordX - left.texCoordX)/xDist
        -- local texCoordYXStep = (right.texCoordY - left.texCoordY)/xDist
        -- local oneOverZXStep = (right.oneOverZ - left.oneOverZ)/xDist
        -- local depthXStep = (right.depth - left.depth)/xDist
        -- local lightAmtXStep = (right.lightAmt - left.lightAmt)/xDist
        local texCoordXXStep = gradients.texCoordXXStep
        local texCoordYXStep = gradients.texCoordYXStep
        local oneOverZXStep = gradients.oneOverZXStep
        local depthXStep = gradients.depthXStep
        local lightAmtXStep = gradients.lightAmtXStep

        local texCoordX = left.texCoordX + texCoordXXStep * xPrestep
        local texCoordY = left.texCoordY + texCoordYXStep * xPrestep
        local oneOverZ = left.oneOverZ + oneOverZXStep * xPrestep
        local depth = left.depth + depthXStep * xPrestep
        local lightAmt = left.lightAmt + lightAmtXStep * xPrestep

        -- local minColor = left.color:Add(gradients.colorXStep:Mul(xPrestep));
        -- local maxColor = right.color:Add(gradients.colorXStep:Mul(xPrestep));

        local lerpAmt = 0;
        local lerpStep = 1/(xMax - xMin);

        for i = xMin, xMax - 1 do

            local index = i + j * self.width
            if self.zBuffer[index] > depth then
                self.zBuffer[index] = depth
                -- local color = minColor:Lerp(maxColor, lerpAmt);
                -- local r = f(color.x * 255 + 0.5)
                -- local g = f(color.y * 255 + 0.5)
                -- local b = f(color.z * 255 + 0.5)

                -- self:drawPixel(i, j, r, g, b);
                local z = 1/oneOverZ
                local srcX = f((texCoordX * z) * (texture.width - 1) + 1)
                local srcY = f(((texCoordY * z) * (texture.height - 1)) + 1)
                --print(srcY)
                --read()

                local light = f(lightAmt * 255)
                --print(light)
                --self:drawPixel(i, j, light, light, light)
                self:copyPixel(i, j, srcX, srcY, texture, lightAmt)
            end
            texCoordX = texCoordX + texCoordXXStep
            texCoordY = texCoordY + texCoordYXStep
            oneOverZ = oneOverZ + oneOverZXStep
            depth = depth + depthXStep
            lightAmt = lightAmt + lightAmtXStep
            -- lerpAmt = lerpAmt + lerpStep
        end
    end
end

return renderContext
