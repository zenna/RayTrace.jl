abstract type Scene end

"Collection of geometric objects in a scene"
struct ListScene{T <: Geometry} <: Scene
  geoms::Vector{T}
end

"Add `geom` to `scene`"
push!(scene::ListScene, geom::Geom) = push!(scene.geom, geom)