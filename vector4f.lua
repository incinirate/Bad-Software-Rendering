Vector4f = {}
do
  local Vector4f = _G.Vector4f

  function Vector4f.__init__(_,x,y,z,w)
    local self = {x=x,y=y,z=z,w=w or 1}
    setmetatable(self, {__index=Vector4f})
    return self
  end

  setmetatable(Vector4f, {__call=Vector4f.__init__})

  local Math = math

  function Vector4f:Length()
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w
    return Math.sqrt( x * x + y * y + z * z + w * w )
  end

  function Vector4f:Max()
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w
    return Math.max(Math.max(x, y), Math.max(z, w))
  end

  function Vector4f:Dot(r)
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w
    return x * r:GetX() + y * r:GetY() + z * r:GetZ() + w * r:GetW();
  end

  function Vector4f:Cross(r)
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w

    x_ = y * r:GetZ() - z * r:GetY();
		y_ = z * r:GetX() - x * r:GetZ();
		z_ = x * r:GetY() - y * r:GetX();

    return Vector4f(x_,y_,z_,0)
  end

  function Vector4f:Normalized()
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w

    local length = self:Length()

    return Vector4f(x / length, y / length, z / length, w / length)
  end

  function Vector4f:Rotate(axis, angle)
    if axis:GetName()=="Vector4f" then
      local sinAngle = Math.sin(-angle)
      local cosAngle = Math.cos(-angle)

      return self:Cross(axis:Mul(sinAngle)):Add(
          (self:Mul(cosAngle)):Add(
            axis:Mul(self:Dot(axis:Mul(1 - cosAngle)))))
    else
      local conjugate = axis:Conjugate()
      local w = axis:Mul(self):Mul(conjugate)
      return Vector4f(w:GetX(), w:GetY(), w:GetZ(), 1)
    end
  end

  function Vector4f:Lerp(dest, lerpFactor)
    return dest:Sub(self):Mul(lerpFactor):Add(self)
  end

  function Vector4f:Add(r)
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w

    if type(r)=="number" then
      return Vector4f(x + r, y + r, z + r, w + r)
    else
      return Vector4f(x + r:GetX(), y + r:GetY(), z + r:GetZ(), w + r:GetW())
    end
  end

  function Vector4f:Sub(r)
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w

    if type(r)=="number" then
      return Vector4f(x - r, y - r, z - r, w - r)
    else
      return Vector4f(x - r:GetX(), y - r:GetY(), z - r:GetZ(), w - r:GetW())
    end
  end

  function Vector4f:Mul(r)
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w

    if type(r)=="number" then
      return Vector4f(x * r, y * r, z * r, w * r)
    else
      return Vector4f(x * r:GetX(), y * r:GetY(), z * r:GetZ(), w * r:GetW())
    end
  end

  function Vector4f:Div(r)
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w

    if type(r)=="number" then
      return Vector4f(x / r, y / r, z / r, w / r)
    else
      return Vector4f(x / r:GetX(), y / r:GetY(), z / r:GetZ(), w / r:GetW())
    end
  end

  function Vector4f:Abs()
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w

    return Vector4f(Math.abs(x), Math.abs(y), Math.abs(z), Math.abs(w))
  end

  function Vector4f:toString()
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w

    local ct = {"(" , x , ", " , y , ", " , z , ", " , w , ")"}
    return table.concat(ct)
  end

  function Vector4f:GetName()
    return "Vector4f"
  end

  function Vector4f:GetX()
    return self.x
  end

  function Vector4f:GetY()
    return self.y
  end

  function Vector4f:GetZ()
    return self.z
  end

  function Vector4f:GetW()
    return self.w
  end

  function Vector4f:equals(r)
    return (self.x == r:GetX() and self.y == r:GetY() and self.z == r:GetZ() and self.w == r:GetW())
  end
end
