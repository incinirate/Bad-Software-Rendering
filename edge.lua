local Edge = {}
do
    local ceil = math.ceil
    function Edge.__init__(_, gradients, minYVert, maxYVert, minYVertIndex)
        local yDist = maxYVert.pos.y - minYVert.pos.y
        local xDist = maxYVert.pos.x - minYVert.pos.x


        local t = {
            yStart = ceil(minYVert.pos.y),
            yEnd = ceil(maxYVert.pos.y),
            xStep = xDist / yDist
        }

        local yPrestep = t.yStart - minYVert.pos.y
        t.x = minYVert.pos.x + yPrestep * t.xStep
        local xPrestep = t.x - minYVert.pos.x

        t.texCoordX = gradients.texCoordX[minYVertIndex] +
            gradients.texCoordXXStep * xPrestep +
            gradients.texCoordXYStep * yPrestep
        t.texCoordXStep = gradients.texCoordXYStep + gradients.texCoordXXStep * t.xStep

        t.texCoordY = gradients.texCoordY[minYVertIndex] +
            gradients.texCoordYXStep * xPrestep +
            gradients.texCoordYYStep * yPrestep
        t.texCoordYStep = gradients.texCoordYYStep + gradients.texCoordYXStep * t.xStep

        t.oneOverZ = gradients.oneOverZ[minYVertIndex] +
            gradients.oneOverZXStep * xPrestep +
            gradients.oneOverZYStep * yPrestep
        t.oneOverZStep = gradients.oneOverZYStep + gradients.oneOverZXStep * t.xStep

        t.depth = gradients.depth[minYVertIndex] +
            gradients.depthXStep * xPrestep +
            gradients.depthYStep * yPrestep
        t.depthStep = gradients.depthYStep + gradients.depthXStep * t.xStep

        t.lightAmt = gradients.lightAmt[minYVertIndex] +
            gradients.lightAmtXStep * xPrestep +
            gradients.lightAmtYStep * yPrestep
        t.lightAmtStep = gradients.lightAmtYStep + gradients.lightAmtXStep * t.xStep

        setmetatable(t, {__index=Edge})
        return t
    end

    function Edge:step()
        self.x = self.x + self.xStep
        self.texCoordX = self.texCoordX + self.texCoordXStep
        self.texCoordY = self.texCoordY + self.texCoordYStep
        self.oneOverZ = self.oneOverZ + self.oneOverZStep
        self.depth = self.depth + self.depthStep
        self.lightAmt = self.lightAmt + self.lightAmtStep
    end

    setmetatable(Edge, {__call=Edge.__init__})
end
return Edge
