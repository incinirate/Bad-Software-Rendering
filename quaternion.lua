Quaternion = {}
do
  local Quaternion = _G.Quaternion
  local Math = _G.math
  function Quaternion.__init__(_,p1,p2,p3,p4)
    local self = {}
    
    if type(p1)=="number" then
      self.x = p1
      self.y = p2
      self.z = p3
      self.w = p4
    elseif not p2 then
      local rot = p2
      
      local trace = rot:Get(0, 0) + rot:Get(1, 1) + rot:Get(2, 2)
      
      if trace > 0 then
        local s = 0.5 / Math.sqrt(trace + 1)
        self.w = 0.25 / s
        self.x = (rot:Get(1, 2) - rot:Get(2, 1)) * s
        self.y = (rot:Get(2, 0) - rot:Get(0, 2)) * s
        self.z = (rot:Get(0, 1) - rot:Get(1, 0)) * s
      else
        if rot:Get(0, 0) > rot:Get(1, 1) and rot:Get(0, 0) > rot:Get(2, 2) then
          local s = 2 * Math.sqrt(1+rot:Get(0, 0) - rot:Get(1, 1) - rot:Get(2, 2))
          self.w = (rot:Get(1, 2) - rot:Get(2, 1)) / s
          self.x = 0.25 * s
          self.y = (rot:Get(1, 0) + rot:Get(0, 1)) / s
          self.z = (rot:Get(2, 0) + rot:Get(0, 2)) / s
        elseif rot:Get(1, 1) > rot:Get(2, 2) then
          local s = 2 * Math.sqrt(1+rot:Get(1, 1) - rot:Get(0, 0) - rot:Get(2, 2))
          self.w = (rot:Get(2, 0) - rot:Get(0, 2)) / s
          self.x = (rot:Get(1, 0) + rot:Get(0, 1)) / s
          self.y = 0.25 * s
          self.z = (rot:Get(2, 1) + rot:Get(1, 2)) / s
        else
          local s = 2 * Math.sqrt(1+rot:Get(2, 2) - rot:Get(0, 0) - rot:Get(1, 1))
          self.w = (rot:Get(0, 1) - rot:Get(1, 0)) / s
          self.x = (rot:Get(2, 0) + rot:Get(0, 2)) / s
          self.y = (rot:Get(1, 2) + rot:Get(2, 1)) / s
          self.z = 0.25 * s
        end
      end
      local leng = Math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w)
      self.x = self.x / leng
      self.y = self.y / leng
      self.z = self.z / leng
      self.w = self.w / leng
    else
      local sinHalfAngle = Math.sin(p2/2)
      local cosHalfAngle = Math.cos(p2/2)
      
      self.x = p1:GetX() * sinHalfAngle
      self.y = p1:GetY() * sinHalfAngle
      self.z = p1:GetZ() * sinHalfAngle
      self.w = cosHalfAngle
    end
    
    setmetatable(self, {__index=Quaternion})
    return self
  end
  
  setmetatable(Quaternion, {__call=Quaternion.__init__})
  
  function Quaternion:Length()
    return Math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w)
  end
  
  function Quaternion:Normalized()
    local qlen = self:Length()
    
    return Quaternion(self.x / qlen, self.y / qlen, self.z / qlen, self.w / qlen)
  end
  
  function Quaternion:Conjugate()
    return Quaternion(-self.x, -self.y, -self.z, self.w)
  end
  
  function Quaternion:Mul(r)
    if type(r) == "number" then
      return Quaternion( self.x * r, self.y * r, self.z * r, self.w * r )
    elseif r:GetName()=="Quaternion" then
      local m_x,m_y,m_z,m_w = self.x,self.y,self.z,self.w
      local w_ = m_w * r:GetW() - m_x * r:GetX() - m_y * r:GetY() - m_z * r:GetZ()
      local x_ = m_x * r:GetW() + m_w * r:GetX() + m_y * r:GetZ() - m_z * r:GetY()
      local y_ = m_y * r:GetW() + m_w * r:GetY() + m_z * r:GetX() - m_x * r:GetZ()
      local z_ = m_z * r:GetW() + m_w * r:GetZ() + m_x * r:GetY() - m_y * r:GetX()
      
      return Quaternion(x_, y_, z_, w_)
    else
      local m_x,m_y,m_z,m_w = self.x,self.y,self.z,self.w
      local w_ = -m_x * r:GetX() - m_y * r:GetY() - m_z * r:GetZ()
      local x_ =  m_w * r:GetX() + m_y * r:GetZ() - m_z * r:GetY()
      local y_ =  m_w * r:GetY() + m_z * r:GetX() - m_x * r:GetZ()
      local z_ =  m_w * r:GetZ() + m_x * r:GetY() - m_y * r:GetX()
      
      return Quaternion(x_, y_, z_, w_)
    end
  end
  
  function Quaternion:Sub(r)
    return Quaternion(self.x - r:GetX(), self.y - r:GetY(), self.z - r:GetZ(), self.w - r:GetW())
  end
  
  function Quaternion:Add(r)
    return Quaternion(self.x + r:GetX(), self.y + r:GetY(), self.z + r:GetZ(), self.w + r:GetW())
  end
  
  function Quaternion:ToRotationMatrix()
    local m_x,m_y,m_z,m_w = self.x,self.y,self.z,self.w
    
    local forward = Vector4f(2 * (m_x * m_z - m_w * m_y), 2 * (m_y * m_z + m_w * m_x), 1 - 2 * (m_x * m_x + m_y * m_y));
		local up = Vector4f(2 * (m_x * m_y + m_w * m_z), 1 - 2 * (m_x * m_x + m_z * m_z), 2 * (m_y * m_z - m_w * m_x));
		local right = Vector4f(1 - 2 * (m_y * m_y + m_z * m_z), 2 * (m_x * m_y - m_w * m_z), 2 * (m_x * m_z + m_w * m_y));
    
    return Matrix4f():InitRotation(forward, up, right)
  end
  
  function Quaternion:Dot(r)
    return self.x * r:GetX() + self.y * r:GetY() + self.z * r:GetZ() + self.w * r:GetW()
  end
  
  function Quaternion:NLerp(dest, lerpFactor, shortest)
    local correctedDest = dest
    
    if shortest and self:Dot(dest) < 0 then
      correctedDest = Quaternion(-dest:GetX(), -dest:GetY(), -dest:GetZ(), -dest:GetW())
    end
    
    return correctedDest:Sub(self):Mul(lerpFactor):Add(self):Normalized()
  end
  
  local EPSILON = 1000
  function Quaternion:SLerp(dest, lerpFactor, shortest)
    local cos = self:Dot(dest)
    local correctedDest = dest
    
    if shortest and cos < 0 then
      cos = -cos
      correctedDest = Quaternion(-dest:GetX(), -dest:GetY(), -dest:GetZ(), -dest:GetW())
    end
    
    if Math.abs(cos) >= 1 - EPSILON then
      return self:NLerp(correctedDest, lerpFactor, false)
    end
    
    local sin = Math.sqrt(1- cos * cos)
    local angle = Math.atan2(sin, cos)
    local invSin = 1/sin
    
    local srcFactor = Math.sin((1-lerpFactor) * angle) * invSin
    local destFactor = Math.sin((lerpFactor) * angle) * invSin
    
    return self:Mul(srcFactor):Add(correctedDest:Mul(destFactor))
  end
  
  function Quaternion:GetForward()
		return Vector4f(0,0,1,1):Rotate(self);
	end

	function Quaternion:GetBack()
		return Vector4f(0,0,-1,1):Rotate(self);
	end

	function Quaternion:GetUp()
		return Vector4f(0,1,0,1):Rotate(self);
	end

	function Quaternion:GetDown()
		return Vector4f(0,-1,0,1):Rotate(self);
	end

	function Quaternion:GetRight()
		return Vector4f(1,0,0,1):Rotate(self);
	end

	function Quaternion:GetLeft()
		return Vector4f(-1,0,0,1):Rotate(self);
	end
  
  function Quaternion:GetX()
    return self.x
  end
  
  function Quaternion:GetY()
    return self.y
  end
  
  function Quaternion:GetZ()
    return self.z
  end
  
  function Quaternion:GetW()
    return self.w
  end
  
  function Quaternion:equals(r)
    return (self.x == r:GetX() and self.y == r:GetY() and self.z == r:GetZ() and self.w == r:GetW())
  end
  
  function Quaternion:GetName()
    return "Quaternion"
  end
  
  function Quaternion:toString()
    return "("..self.x..","..self.y..","..self.z..","..self.w..")"
  end
end