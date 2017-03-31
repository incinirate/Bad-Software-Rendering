local objLoader = love.filesystem.load("obj_loader.lua")()
local Vertex = love.filesystem.load("vertex.lua")()

local Mesh = {}
do
    function Mesh.__init__(_, filename)
        local t = {}

        local model = objLoader.load(filename)

        local verts = {}
        local snorm = {}
        for i = 1, #model.v do
            local v = model.v[i]
            local vt = model.vt[i] or {}
            local vn = model.vn[i] or {}
            vt.u = vt.u or 0.5; vn.x = vn.x or 0;
            vt.v = vt.v or 0.5; vn.y = vn.y or 1;
                                vn.z = vn.z or 0;
            verts[i] = Vertex(Vector4f(v.x, v.y, v.z, 1), Vector4f(vt.u, vt.v, 0, 0), Vector4f(vn.x, vn.y, vn.z, 0))
            snorm[i] = Vector4f(vn.x, vn.y, vn.z, 0)
        end

        t.vertices = verts
        t.indices = model.f
        t.snorm = snorm

        setmetatable(t, {__index=Mesh})
        return t
    end

    setmetatable(Mesh, {__call=Mesh.__init__})

    function Mesh:drawMesh(context, projection, transform, texture)
        local mvp = projection:Mul(transform)

        --self.vertices[self.indices[i][1].v]
        for i=1, #self.indices do
            local face = self.indices[i]
            local v1 = self.vertices[face[1].v]
            local v1n = self.snorm[face[1].vn] if not v1n then v1n = v1.normal end
            local v2 = self.vertices[face[2].v]
            local v2n = self.snorm[face[2].vn] if not v2n then v2n = v2.normal end
            local v3 = self.vertices[face[3].v]
            local v3n = self.snorm[face[3].vn] if not v3n then v3n = v3.normal end

            context:drawTriangle(
                Vertex(v1.pos, v1.texCoords, v1n):transform(mvp, transform),
                Vertex(v2.pos, v2.texCoords, v2n):transform(mvp, transform),
                Vertex(v3.pos, v3.texCoords, v3n):transform(mvp, transform),
                texture)
        end
    end
end
return Mesh
