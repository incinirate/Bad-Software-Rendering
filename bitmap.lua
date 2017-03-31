Bitmap = {}
do
  local Bitmap = _G.Bitmap

  function Bitmap.loadImgNative(filename)
      local x,y = love.filesystem.newFileData(love.filesystem.read(filename))
    --   print(x)
    --   print(y)
    return Bitmap(love.image.newImageData(x))
  end

  function Bitmap.createBitmapFromFile(filename)
    local handle = fs.open(filename, "rb")
    local header = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    for i=1,54 do
      local byteVal = handle.read()
      header[i] = byteVal
      write("["..i.."]"..byteVal)
    end
    print("\nFile size = "..header[5]*65536 + header[4]*256 + header[3].."\n")
    local offset = header[12]*256+header[11]
    print("Offset to image = "..offset)
    local width = header[19]
    local height = header[23]

    local size = 3 * width * height

    local outdata = {}
    local padding = (4-((width*3)%4))%4
    for i=1,size do
      outdata[i] = handle.read()
      if i%(width*3)==0 then
        for i=1,padding do
          handle.read() --padding data we dont need or want
        end
      end
    end

    handle.close()

    for i=1, size, 3 do
      local tmp = outdata[i]
      outdata[i] = outdata[i+2]
      outdata[i+2] = tmp
    end

    local outmap = Bitmap(width, height)

    for i=1,width do
      for j=1,height do
      --write("{"..happy[i]..","..happy[i+1]..","..happy[i+2].."},")
        local poff = (j-1)*width*3 + (i-1)*3
        outmap:drawPixel(i-1,j-1,outdata[poff + 1],outdata[poff + 2],outdata[poff + 3]) --for some reason the bmps were inverted vertically?
      end
    end

    return outmap
  end

  function Bitmap.__init__(_, nWidth, nHeight, bg)
      local self
    if type(nWidth)~="number" then
        self = {width = nWidth:getWidth(),
            height = nWidth:getHeight(),
            components = nWidth,
            outcan = love.graphics.newImage(nWidth)}
    else
        self = {width = nWidth, height = nHeight,
      components = love.image.newImageData(nWidth, nHeight)}
      self.outcan = love.graphics.newImage(self.components)
    end
    setmetatable(self, {__index=Bitmap})
    return self
  end

  setmetatable(Bitmap, {__call=Bitmap.__init__})

  --takes in a byte
  function Bitmap:clear(shade)
    self.components:mapPixel(function() return shade,shade,shade,1 end, 1, 1, self.width, self.height)
  end

  function Bitmap:clearRGB(r, g, b)
      self.components:mapPixel(function() return r,g,b,1 end, 0, 0, self.width, self.height)
  end

  function Bitmap:setBG_C(bg)
    self.bg = bg
  end

  function Bitmap:setBG_RGB(r,g,b)
    self.bg = colors.fromRGB(r,g,b)
  end

  function Bitmap:drawPixel(x,y,r,g,b)
    x,y = math.floor(x),math.floor(y)
    if x > self.width or x < 0 or y < 0 or y > self.height then
     return
    end
    self.components:setPixel(x, y, r, g, b)
  end

  local floor = math.floor
  function Bitmap:copyPixel(destX,destY,srcX,srcY,src,alp)
    destX,destY = math.floor(destX),math.floor(destY)
    if destX > self.width or destX < 1 or destY < 1 or destY > self.height then
      return
    end
    local destIndex = floor(((destX-1) + (destY-1) * self.width) * 3 + 1)
    local srcIndex = floor(((srcX-1) + (srcY-1) * src.width) * 3 + 1)
    --print(self.components:getPixel(srcX-1, srcY-1))
    local xr,xg,xb
    if srcX-1 >= src.components:getWidth() or srcX-1 < 0 or srcY-1 >= src.components:getHeight() or srcY-1 < 0 then
        xr,xg,xb = 255,0,0
    else
    --print(srcX-1, srcY-1)
        xr,xg,xb = src.components:getPixel(srcX-1, srcY-1)
        xr,xg,xb = xr*alp, xg*alp, xb*alp
    end
    self.components:setPixel(destX-1, destY-1, xr, xg, xb)
    --if self.components[destIndex + 2] == nil or self.components[destIndex    ] == nil or self.components[destIndex  +1 ] == nil then
  --    self.components:setPixel(destX-1, destY-1, 255, 0, 255)
    --end
  end
end
