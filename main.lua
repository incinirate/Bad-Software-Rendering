local sx, sy = 600, 400;

--os.loadAPI("blittle") --I'm speshul :^P
love.filesystem.load("display.lua")()
love.filesystem.load("bitmap.lua")()
--love.filesystem.load("rgb.lua")()
love.filesystem.load("matrix4f.lua")()
love.filesystem.load("vector4f.lua")()
local Mesh = love.filesystem.load("mesh.lua")()
local Vertex = love.filesystem.load("vertex.lua")()
local renderContext = love.filesystem.load("renderContext.lua")()
love.filesystem.load("transform.lua")()
love.filesystem.load("camera.lua")()
love.filesystem.load("quaternion.lua")()
--local Stars3D = dofile("stars3d.lua")

local display = Display()

function love.load()
  love.window.setMode(sx, sy)
end

local target = renderContext(sx, sy, 0);

-- local texture2 = Bitmap(32, 32)
-- for j = 1, 32 do
--     for i = 1, 32 do
--         texture2:drawPixel(i, j,
--             ((i + j))/64 * 255,
--             ((i + j))/128 * 255,
--             ((i + j))/128 * 255)
--     end
-- end
local cubeTexture = Bitmap.loadImgNative("brkr.bmp")
local cubeMesh = Mesh("cube4.obj")
local cubeTransform = Transform(Vector4f(-3, 0, 5))

local terrainTexture = Bitmap.loadImgNative("bricks2.jpg")
local terrainMesh = Mesh("terrs.obj")
local terrainTransform = Transform(Vector4f(0, -3, 0))

local projection = Matrix4f():InitPerspective(math.pi/4,
    target.width/target.height, 1, 100)

local camera = Camera(projection)

local rotCounter = 0

local keyinput = {}

    --local previousTime = os.clock();
function love.update(delta)
      --local currentTime = os.clock();
      --local delta = (currentTime - previousTime);

      rotCounter = rotCounter + delta

      camera:Update(keyinput, delta)
      local vp = camera:GetViewProjection()

      cubeTransform = cubeTransform:Rotate(Quaternion(Vector4f(0, 1, 0), delta))

    --

      --stars:UpdateAndRender(target, delta);
      target:clearRGB(0, 0, 255);
      target:clearDepthBuffer()

      cubeMesh:drawMesh(target, vp, cubeTransform:GetTransformation(), cubeTexture)

      terrainMesh:drawMesh(target, vp, terrainTransform:GetTransformation(), terrainTexture)

      -- for j = 20, 40 do
      --     target:drawScanBuffer(j, 25 - j, 35 + j + 3 * math.sin(j + os.clock() * 3));
      -- end
      -- target:fillShape(20,40)
      -- target:drawPixel(20, 20, 255, 255, 255);

      -- target:fillTriangle(midYVert:transform(transformx), maxYVert:transform(transformx), minYVert:transform(transformx), texture)
      -- mesh:drawMesh(target, transform, texture)
      -- mesh:drawMesh(target, transform2, texture)

      display:drawImage(target, 0, 0);
      --previousTime = currentTime;
end

function love.keypressed(k)
    keyinput[k] = true
end

function love.keyreleased(k)
    keyinput[k] = false
end

function love.draw()
  love.graphics.draw(target.outcan, 0, 0)
end
