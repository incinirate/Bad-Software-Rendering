Transform = {}
do
  local Transform = _G.Transform
  function Transform.__init__(_,pos,rot,scale)
    local self = {}
    self.pos = pos or Vector4f(0,0,0,0)
    self.rot = rot or Quaternion(0,0,0,1)
    self.scale = scale or Vector4f(1,1,1,1)
    
    setmetatable(self, {__index=Transform})
    return self
  end
  
  setmetatable(Transform, {__call=Transform.__init__})
  
  function Transform:SetPos(pos)
    return Transform(pos, self.rot, self.scale)
  end
  
  function Transform:Rotate(rotation)
    return Transform(self.pos, rotation:Mul(self.rot):Normalized(), self.scale)
  end
  
  function Transform:Scale(scaleAmt)
    return Transform(self.pos, self.rot, scaleAmt)
  end
  
  function Transform:GetLookAtRotation(point, up)
    return Quaternion(Matrix4f():InitRotation(point:Sub(self.pos):Normalized(), up))
  end
  
  function Transform:LookAt(point, up)
    return self:Rotate(self:GetLookAtRotation(point, up))
  end
  
  function Transform:GetTransformation()
    local translationMatrix = Matrix4f():InitTranslation(self.pos:GetX(), self.pos:GetY(), self.pos:GetZ())
    --print(self.rot.ToRotationMatrix)
    local rotationMatrix = self.rot:ToRotationMatrix()
    local scaleMatrix = Matrix4f():InitScale(self.scale:GetX(), self.scale:GetY(), self.scale:GetZ())
    
    return translationMatrix:Mul(rotationMatrix:Mul(scaleMatrix))
  end
  
  function Transform:GetTransformedPos()
    return self.pos
  end
  
  function Transform:GetTransformedRot()
    return self.rot
  end
  
  function Transform:GetPos()
    return self.pos
  end
  
  function Transform:GetRot()
    return self.rot
  end
  
  function Transform:GetScale()
    return self.scale
  end
end