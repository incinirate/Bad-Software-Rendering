local Stars3D = {}
do
    local f = math.floor

    function Stars3D.__init__(_, numStars, spread, speed)
        local t = {m_spread=spread, m_speed=speed, m_starX={}, m_starY={}, m_starZ={}}
        setmetatable(t, {__index=Stars3D})

        for i=1,numStars do
            t:InitStar(i)
        end

        return t
    end

    setmetatable(Stars3D, {__call=Stars3D.__init__})

    function Stars3D:UpdateAndRender(target, delta)
        target:clear(0)

        local halfWidth = target.width/2
        local halfHeight = target.height/2
        for i=1, #self.m_starX do
            self.m_starZ[i] = self.m_starZ[i] - delta * self.m_speed

            if self.m_starZ[i] <= 0 then
                self:InitStar(i)
            end

            local x = f((self.m_starX[i]/self.m_starZ[i]) * halfWidth + halfWidth)
            local y = f((self.m_starY[i]/self.m_starZ[i]) * halfHeight + halfHeight)

            if x < 0 or x >= target.width or y < 0 or y >= target.height then
                self:InitStar(i)
            else
                target:drawPixel(x, y, 255, 255, 255)
            end
        end
    end

    function Stars3D:InitStar(i)
        self.m_starX[i] = math.random(-1000, 1000)/1000 * self.m_spread
        self.m_starY[i] = math.random(-1000, 1000)/1000 * self.m_spread
        self.m_starZ[i] = math.random(1, 1000)/1000 * self.m_spread
    end
end
return Stars3D
