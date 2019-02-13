abstract type Scene end

"Collection of geometric objects in a scene"
struct ListScene{T} <: Scene
  geoms::Vector{T} # zt: This should be an abstract vector, to support static, is it even necessary?
end

Base.getindex(scene::ListScene, i) = scene.geoms[i]
Base.first(scene::ListScene) = scene.geoms[1]
Base.size(scene::ListScene) = size(scene.geoms)
Base.length(scene::ListScene) = length(scene.geoms)
 
"Add `geom` to `scene`"
Base.push!(scene::ListScene, geom::Geometry) = push!(scene.geom, geom) 