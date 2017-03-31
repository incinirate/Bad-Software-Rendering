Camera = {}
do
  local Camera = _G.Camera

  local Y_AXIS = Vector4f(0,1,0)
  function Camera.__init__(_, projection)
    local self = {}
    self.projection = projection
    self.transform = Transform()
    setmetatable(self, {__index=Camera})
    return self
  end

  setmetatable(Camera, {__call=Camera.__init__})

  function Camera:GetTransform()
    return self.transform
  end

  function Camera:GetViewProjection()
    local cameraRotation = self:GetTransform():GetTransformedRot():Conjugate():ToRotationMatrix()
    local cameraPos = self:GetTransform():GetTransformedPos():Mul(-1)

    local cameraTranslation = Matrix4f():InitTranslation(cameraPos:GetX(), cameraPos:GetY(), cameraPos:GetZ())
    return self.projection:Mul(cameraRotation:Mul(cameraTranslation))
  end

  function Camera:Update(input, delta)
    -- Speed and rotation amounts are hardcoded here.
		-- In a more general system, you might want to have them as variables.
		local sensitivityX = 1.2 * delta;
		local sensitivityY = 1.2 * delta;
		local movAmt = 7.0 * delta;

    --DO NOT LEAVE IT LIKE THIS BAD CODER :D
        if input.w then
            self:Move(self:GetTransform():GetRot():GetForward(), movAmt)
        end if input.s then
            self:Move(self:GetTransform():GetRot():GetForward(), -movAmt)
        end if input.a then
            self:Move(self:GetTransform():GetRot():GetLeft(), movAmt)
        end if input.d then
            self:Move(self:GetTransform():GetRot():GetRight(), movAmt)
        end if input.right then
            self:Rotate(Y_AXIS, sensitivityX)
        end if input.left then
            self:Rotate(Y_AXIS, -sensitivityX)
        end if input.down then
            self:Rotate(self:GetTransform():GetRot():GetRight(), sensitivityY)
        end if input.up then
            self:Rotate(self:GetTransform():GetRot():GetRight(), -sensitivityY)
        end
  end

  function Camera:Move(dir, amt)
    self.transform = self:GetTransform():SetPos(self:GetTransform():GetPos():Add(dir:Mul(amt)))
  end

  function Camera:Rotate(axis, angle)
    self.transform = self:GetTransform():Rotate(Quaternion(axis,angle))
  end
end
