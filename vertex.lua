local Vertex = {}
do
    function Vertex.__init__(_, v, c, n)
        local t = {pos = v, texCoords = c, normal = n}

        setmetatable(t, {__index=Vertex})
        return t
    end

    function Vertex:transform(transform, normalTransform)
        return Vertex(transform:Transform(self.pos), self.texCoords, normalTransform:Transform(self.normal))
    end

    function Vertex:perspectiveDivide()
        return Vertex(Vector4f(self.pos.x / self.pos.w, self.pos.y / self.pos.w,
                      self.pos.z / self.pos.w, self.pos.w), self.texCoords, self.normal)
    end

    function Vertex:IsInsideViewFrustum()
        return
			math.abs(self.pos.x) <= math.abs(self.pos.w) and
			math.abs(self.pos.y) <= math.abs(self.pos.w) and
            math.abs(self.pos.z) <= math.abs(self.pos.w)
    end

    function Vertex:triangleAreaTimesTwo(b, c)
        local x1 = b.pos.x - self.pos.x
        local y1 = b.pos.y - self.pos.y

        local x2 = c.pos.x - self.pos.x
        local y2 = c.pos.y - self.pos.y

        return (x1 * y2 - x2 * y1)
    end

    function Vertex:Lerp(other, lerpAmt)
        return Vertex(
            self.pos:Lerp(other.pos, lerpAmt),
            self.texCoords:Lerp(other.texCoords, lerpAmt),
            self.normal:Lerp(other.normal, lerpAmt)
        )
    end

    function Vertex:Get(index)
        if index == 1 then
            return self.pos.x
        elseif index == 2 then
            return self.pos.y
        elseif index == 3 then
            return self.pos.z
        elseif index == 4 then
            return self.pos.w
        end
    end

    setmetatable(Vertex, {__call=Vertex.__init__})
end
return Vertex
