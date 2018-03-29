using RayTrace
import RayTrace: Sphere, Vec3
using Colors
using ImageView

"Some example spheres which should create actual image"
function example_spheres()
  RayTrace.ListScene(
   [Sphere(Vec3([0.0, -10004, -20]), 10000.0, Vec3([0.20, 0.20, 0.20]), 0.0, 0.0, Vec3([0.0, 0.0, 0.0])),
   Sphere(Vec3([0.0,      0, -20]),     4.0, Vec3([1.00, 0.32, 0.36]), 1.0, 0.5, Vec3([0.0, 0.0, 0.0])),
   Sphere(Vec3([5.0,     -1, -15]),     2.0, Vec3([0.90, 0.76, 0.46]), 1.0, 0.0, Vec3([0.0, 0.0, 0.0])),
   Sphere(Vec3([5.0,      0, -25]),     3.0, Vec3([0.65, 0.77, 0.97]), 1.0, 0.0, Vec3([0.0, 0.0, 0.0])),
   Sphere(Vec3([-5.5,      0, -15]),    3.0, Vec3([0.90, 0.90, 0.90]), 1.0, 0.0, Vec3([0.0, 0.0, 0.0])),
   # light (emission > 0)
   Sphere(Vec3([0.0,     20.0, -30]),  3.0, Vec3([0.00, 0.00, 0.00]), 0.0, 0.0, Vec3([3.0, 3.0, 3.0]))])
end

"Render an example scene and display it"
function render_example_spheres()
  scene = example_spheres()
  RayTrace.render(scene)
end

"Create an rgb image from a 3D matrix (w, h, c)"
function rgbimg(img)
  w = size(img)[1]
  h = size(img)[2]
  clrimg = Array{Colors.RGB}(w, h)
  for i = 1:w
    for j = 1:h
      clrimg[i,j] = Colors.RGB(img[i,j,:]...)
    end
  end
  clrimg
end


function show_img()
  img_ = render_example_spheres()
  img = rgbimg(img_)
  ImageView.imshow(img)
end