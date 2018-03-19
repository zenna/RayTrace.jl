abstract type Scene end

"Collection of geometric objects in a scene"
struct ListScene{T <: Geometry} <: Scene
  geoms::Vector{T}
end

Base.first(scene::ListScene) = scene.geoms[1]

Base.length(scene::ListScene) = length(scene.geoms)
 
"Add `geom` to `scene`"
push!(scene::ListScene, geom::Geometry) = push!(scene.geom, geom) 