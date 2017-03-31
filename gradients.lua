local Gradients = {}
do
    function Gradients.__init__(_, minYVert, midYVert, maxYVert)
        local t = {texCoordX = {}, texCoordY = {}, oneOverZ = {}, depth = {}, lightAmt = {}}

        t.oneOverZ[1] = 1 / minYVert.pos.w
        t.oneOverZ[2] = 1 / midYVert.pos.w
        t.oneOverZ[3] = 1 / maxYVert.pos.w

        t.texCoordX[1] = minYVert.texCoords.x * t.oneOverZ[1]
        t.texCoordX[2] = midYVert.texCoords.x * t.oneOverZ[2]
        t.texCoordX[3] = maxYVert.texCoords.x * t.oneOverZ[3]

        t.texCoordY[1] = minYVert.texCoords.y * t.oneOverZ[1]
        t.texCoordY[2] = midYVert.texCoords.y * t.oneOverZ[2]
        t.texCoordY[3] = maxYVert.texCoords.y * t.oneOverZ[3]

        t.depth[1] = minYVert.pos.z
        t.depth[2] = midYVert.pos.z
        t.depth[3] = maxYVert.pos.z

        local lightDir = Vector4f(0, 0, 1)
        t.lightAmt[1] = Gradients.saturate(minYVert.normal:Dot(lightDir)) * 0.8 + 0.2
        t.lightAmt[2] = Gradients.saturate(midYVert.normal:Dot(lightDir)) * 0.8 + 0.2
        t.lightAmt[3] = Gradients.saturate(maxYVert.normal:Dot(lightDir)) * 0.8 + 0.2

        local oneOverdX = 1 /
            (((midYVert.pos.x - maxYVert.pos.x) *
            (minYVert.pos.y - maxYVert.pos.y)) -
            ((minYVert.pos.x - maxYVert.pos.x) *
            (midYVert.pos.y - maxYVert.pos.y)))

        local oneOverdY = -oneOverdX

        -- local dColor = (((t.color[2]:Sub(t.color[3])):Mul(
        --     (minYVert.pos.y - maxYVert.pos.y))):Sub(
        --     ((t.color[1]:Sub(t.color[3])):Mul(
        --     (midYVert.pos.y - maxYVert.pos.y)))))

        t.texCoordXXStep = Gradients.calcXStep(t.texCoordX, minYVert, midYVert, maxYVert, oneOverdX)
        t.texCoordXYStep = Gradients.calcYStep(t.texCoordX, minYVert, midYVert, maxYVert, oneOverdY)

        t.texCoordYXStep = Gradients.calcXStep(t.texCoordY, minYVert, midYVert, maxYVert, oneOverdX)
        t.texCoordYYStep = Gradients.calcYStep(t.texCoordY, minYVert, midYVert, maxYVert, oneOverdY)

        t.oneOverZXStep = Gradients.calcXStep(t.oneOverZ, minYVert, midYVert, maxYVert, oneOverdX)
        t.oneOverZYStep = Gradients.calcYStep(t.oneOverZ, minYVert, midYVert, maxYVert, oneOverdY)

        t.depthXStep = Gradients.calcXStep(t.depth, minYVert, midYVert, maxYVert, oneOverdX)
        t.depthYStep = Gradients.calcYStep(t.depth, minYVert, midYVert, maxYVert, oneOverdY)

        t.lightAmtXStep = Gradients.calcXStep(t.lightAmt, minYVert, midYVert, maxYVert, oneOverdX)
        t.lightAmtYStep = Gradients.calcYStep(t.lightAmt, minYVert, midYVert, maxYVert, oneOverdY)

        setmetatable(t, {__index=Gradients})
        return t
    end

    function Gradients.saturate(val)
        if val < 0 then
            return 0
        end
        if val > 1 then
            return 1
        end
        return val
    end

    function Gradients.calcXStep(values, minYVert, midYVert, maxYVert, oneOverdX)
        return
            (((values[2] - values[3]) *
            (minYVert.pos.y - maxYVert.pos.y)) -
            ((values[1] - values[3]) *
            (midYVert.pos.y - maxYVert.pos.y))) * oneOverdX
    end

    function Gradients.calcYStep(values, minYVert, midYVert, maxYVert, oneOverdY)
        return
            (((values[2] - values[3]) *
            (minYVert.pos.x - maxYVert.pos.x)) -
            ((values[1] - values[3]) *
            (midYVert.pos.x - maxYVert.pos.x))) * oneOverdY
    end

    setmetatable(Gradients, {__call=Gradients.__init__})
end
return Gradients
