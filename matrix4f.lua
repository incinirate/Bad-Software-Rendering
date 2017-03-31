Matrix4f = {}
do
  local Matrix4f = _G.Matrix4f

  function Matrix4f.__init__()
    local self = {}
    self.m = {[0]={0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}
    setmetatable(self, {__index=Matrix4f})
    return self
  end

  setmetatable(Matrix4f,{__call=Matrix4f.__init__})

  function Matrix4f:InitIdentity()
    local m = self.m

    m[0][0] = 1;	m[0][1] = 0;	m[0][2] = 0;	m[0][3] = 0;
		m[1][0] = 0;	m[1][1] = 1;	m[1][2] = 0;	m[1][3] = 0;
		m[2][0] = 0;	m[2][1] = 0;	m[2][2] = 1;	m[2][3] = 0;
		m[3][0] = 0;	m[3][1] = 0;	m[3][2] = 0;	m[3][3] = 1;

    return self
  end

  function Matrix4f:InitScreenSpaceTransform(halfWidth, halfHeight)
    local m = self.m

    m[0][0] = halfWidth;	m[0][1] = 0;	m[0][2] = 0;	m[0][3] = halfWidth - 0.5;
		m[1][0] = 0;	m[1][1] = -halfHeight;	m[1][2] = 0;	m[1][3] = halfHeight - 0.5;
		m[2][0] = 0;	m[2][1] = 0;	m[2][2] = 1;	m[2][3] = 0;
		m[3][0] = 0;	m[3][1] = 0;	m[3][2] = 0;	m[3][3] = 1;

    return self
  end

  function Matrix4f:InitTranslation(x,y,z)
    local m = self.m
    m[0][0] = 1;	m[0][1] = 0;	m[0][2] = 0;	m[0][3] = x;
		m[1][0] = 0;	m[1][1] = 1;	m[1][2] = 0;	m[1][3] = y;
		m[2][0] = 0;	m[2][1] = 0;	m[2][2] = 1;	m[2][3] = z;
		m[3][0] = 0;	m[3][1] = 0;	m[3][2] = 0;	m[3][3] = 1;

    return self
  end

  function Matrix4f:InitRotation(x,y,z,angle)

    if type(x) == "number" then
      if angle then
        local m = self.m
        local sin = math.sin(angle)
        local cos = math.cos(angle)

        m[0][0] = cos+x*x*(1-cos); m[0][1] = x*y*(1-cos)-z*sin; m[0][2] = x*z*(1-cos)+y*sin; m[0][3] = 0;
        m[1][0] = y*x*(1-cos)+z*sin; m[1][1] = cos+y*y*(1-cos);	m[1][2] = y*z*(1-cos)-x*sin; m[1][3] = 0;
        m[2][0] = z*x*(1-cos)-y*sin; m[2][1] = z*y*(1-cos)+x*sin; m[2][2] = cos+z*z*(1-cos); m[2][3] = 0;
        m[3][0] = 0;	m[3][1] = 0;	m[3][2] = 0;	m[3][3] = 1;

        return self
      else
        local rx = Matrix4f()
        local ry = Matrix4f()
        local rz = Matrix4f()

        local math = math

        rz.m[0][0] = math.cos(z);rz.m[0][1] = -math.sin(z);rz.m[0][2] = 0;				rz.m[0][3] = 0;
        rz.m[1][0] = math.sin(z);rz.m[1][1] = math.cos(z);rz.m[1][2] = 0;					rz.m[1][3] = 0;
        rz.m[2][0] = 0;					rz.m[2][1] = 0;					rz.m[2][2] = 1;					rz.m[2][3] = 0;
        rz.m[3][0] = 0;					rz.m[3][1] = 0;					rz.m[3][2] = 0;					rz.m[3][3] = 1;

        rx.m[0][0] = 1;					rx.m[0][1] = 0;					rx.m[0][2] = 0;					rx.m[0][3] = 0;
        rx.m[1][0] = 0;					rx.m[1][1] = math.cos(x);rx.m[1][2] = -math.sin(x);rx.m[1][3] = 0;
        rx.m[2][0] = 0;					rx.m[2][1] = math.sin(x);rx.m[2][2] = math.cos(x);rx.m[2][3] = 0;
        rx.m[3][0] = 0;					rx.m[3][1] = 0;					rx.m[3][2] = 0;					rx.m[3][3] = 1;

        ry.m[0][0] = math.cos(y);ry.m[0][1] = 0;					ry.m[0][2] = -math.sin(y);ry.m[0][3] = 0;
        ry.m[1][0] = 0;					ry.m[1][1] = 1;					ry.m[1][2] = 0;					ry.m[1][3] = 0;
        ry.m[2][0] = math.sin(y);ry.m[2][1] = 0;					ry.m[2][2] = math.cos(y);ry.m[2][3] = 0;
        ry.m[3][0] = 0;					ry.m[3][1] = 0;					ry.m[3][2] = 0;					ry.m[3][3] = 1;

        self.m = rz:Mul(ry:Mul(rx)):GetM();

        return self
      end
    else
      local forward = x
      local up = y
      local right = z
      if right then
        local m = self.m

        local f = forward
        local r = right
        local u = up

        m[0][0] = r:GetX();	m[0][1] = r:GetY();	m[0][2] = r:GetZ();	m[0][3] = 0;
        m[1][0] = u:GetX();	m[1][1] = u:GetY();	m[1][2] = u:GetZ();	m[1][3] = 0;
        m[2][0] = f:GetX();	m[2][1] = f:GetY();	m[2][2] = f:GetZ();	m[2][3] = 0;
        m[3][0] = 0;		m[3][1] = 0;		m[3][2] = 0;		m[3][3] = 1;

        return self
      else
        local f = forward:Normalized()

        local r = up:Normalized()
        r = r:Cross(f)

        local u = f:Cross(r)

        return self:InitRotation(f, u, r)
      end
    end
  end

  function Matrix4f:InitScale(x,y,z)
    local m = self.m

    m[0][0] = x;	m[0][1] = 0;	m[0][2] = 0;	m[0][3] = 0;
		m[1][0] = 0;	m[1][1] = y;	m[1][2] = 0;	m[1][3] = 0;
		m[2][0] = 0;	m[2][1] = 0;	m[2][2] = z;	m[2][3] = 0;
		m[3][0] = 0;	m[3][1] = 0;	m[3][2] = 0;	m[3][3] = 1;

    return self
  end

  function Matrix4f:InitPerspective(fov, aspectRatio, zNear, zFar)
    local tanHalfFOV = math.tan(fov/2)
    local zRange = zNear - zFar

    local m = self.m

    m[0][0] = 1.0 / (tanHalfFOV * aspectRatio);	m[0][1] = 0;					m[0][2] = 0;	m[0][3] = 0;
		m[1][0] = 0;						m[1][1] = 1.0 / tanHalfFOV;	m[1][2] = 0;	m[1][3] = 0;
		m[2][0] = 0;						m[2][1] = 0;					m[2][2] = (-zNear -zFar)/zRange;	m[2][3] = 2 * zFar * zNear / zRange;
		m[3][0] = 0;						m[3][1] = 0;					m[3][2] = 1;	m[3][3] = 0;

    return self
  end

  function Matrix4f:InitOrthographic(left, right, bottom, top, near, far)
    local width = right - left
    local height = top - bottom
    local depth = far - near

    local m = self.m

    m[0][0] = 2/width;m[0][1] = 0;	m[0][2] = 0;	m[0][3] = -(right + left)/width;
		m[1][0] = 0;	m[1][1] = 2/height;m[1][2] = 0;	m[1][3] = -(top + bottom)/height;
		m[2][0] = 0;	m[2][1] = 0;	m[2][2] = -2/depth;m[2][3] = -(far + near)/depth;
		m[3][0] = 0;	m[3][1] = 0;	m[3][2] = 0;	m[3][3] = 1;

    return self
  end

  function Matrix4f:Transform(r)
    local m = self.m
    --print(r:GetZ())
    return Vector4f(m[0][0] * r:GetX() + m[0][1] * r:GetY() + m[0][2] * r:GetZ() + m[0][3] * r:GetW(),
		                    m[1][0] * r:GetX() + m[1][1] * r:GetY() + m[1][2] * r:GetZ() + m[1][3] * r:GetW(),
		                    m[2][0] * r:GetX() + m[2][1] * r:GetY() + m[2][2] * r:GetZ() + m[2][3] * r:GetW(),
							m[3][0] * r:GetX() + m[3][1] * r:GetY() + m[3][2] * r:GetZ() + m[3][3] * r:GetW());
  end

  function Matrix4f:Mul(r)
    local res = Matrix4f()
    local m = self.m

    for i=0,3 do
      for j=0,3 do
        res:Set(i, j, m[i][0] * r:Get(0, j) +
						m[i][1] * r:Get(1, j) +
						m[i][2] * r:Get(2, j) +
						m[i][3] * r:Get(3, j));
      end
    end

    return res
  end

  function Matrix4f:GetM()
    local res = {[0]={0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}
    local m = self.m

    for i=0,3 do
      for j=0,3 do
        res[i][j] = m[i][j]
      end
    end

    return res
  end

  function Matrix4f:Get(x,y)
    return self.m[x][y]
  end

  function Matrix4f:SetM(m)
    self.m = m
  end

  function Matrix4f:Set(x,y,value)
    self.m[x][y]=value
  end
end
