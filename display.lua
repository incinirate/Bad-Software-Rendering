Display = {}
do
  local Display = _G.Display
  local math = _G.math

  function Display.__init__()
    local self={}--canvas=0}

    --self.canvas = Canvas.create()
    --self.blwin = blittle.createWindow()
    self.imgdata = love.image.newImageData(600,600)

    setmetatable(self, {__index=Display})
    return self
  end

  setmetatable(Display, {__call=Display.__init__})

  function Display:drawLine(x1,y1,x2,y2,bg,fg) --Basically copied from paintutils
    bg = bg or colors.black
    fg = fg or colors.white

    x1,y1 = math.floor(x1),math.floor(y1)
    x2,y2 = math.floor(x2),math.floor(y2)

    if x1==x2 and y1==y2 then
      self.canvas:setPixel(x1,y1,true,bg,fg)
    end

    local minX = x1 > x2 and x2 or x1
    local minY,maxX,maxY
    if minX == x1 then
      minY = y1
      maxX = x2
      maxY = y2
    else
      minY = y2
      maxX = x1
      maxY = y1
    end

    local xDiff = x2 - x1
    local yDiff = y2 - y1

    if xDiff > ( yDiff < 0 and -yDiff or yDiff ) then --optimization bruh
      local y = minY
      local dy = yDiff / xDiff
      for x=minX,maxX do
        self.canvas:setPixel(x, math.floor( y + 0.5), true,bg,fg )
        y = y + dy
      end
    else
      local x = minX
      local dx = xDiff / yDiff
      if maxY >= minY then
        for y=minY,maxY do
          self.canvas:setPixel( math.floor( x + 0.5 ), y, true,bg,fg )
          x = x + dx
        end
      else
        for y=minY,maxY,-1 do
          self.canvas:setPixel( math.floor( x + 0.5 ), y, true,bg,fg )
          x = x - dx
        end
      end
    end
  end

  function Display:setSize(w,h)
    --self.canvas:setSize(w,h)
  end

  --TODO: Add scaling for drawImage?

  --MAJOR TODO: REWORK FOR USE WITH TERM.BLIT
  -- OR SOME OPTIMIZATION, TOO SLOW
  function Display:drawImage(bitmap, x, y)
    local compo = bitmap.components
    local bwid = bitmap.width
    --local canv = self.canvas
    local blwin = self.blwin
    local bg = bitmap.bg
    local offy = -3
    bitmap.outcan:refresh()
    --love.graphics.draw(bitmap.outcan, 0, 0)
    --love.graphics.present()
  end

  function Display:flush()
    --Deprecated
    --self.canvas:draw()
  end
end

--local canvas = Canvas.create()
--canvas:setPixel(1,1,true)
--canvas:setPixel(3,3,true)
--canvas:setPixel(3,2,true, colors.red, colors.green)
--canvas:draw()
--os.pullEvent("char")
