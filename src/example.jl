"Some example spheres which should create actual image"
function example_spheres()
  scene = [msphere(Point(0.0, -10004, -20), 10000.0, Vec3(0.20, 0.20, 0.20), 0.0, 0.0, Vec3(0.0, 0.0, 0.0)),
           msphere(Point(0.0, 0.0, -20), 4.0, Vec3(1.0, 0.32, 0.36), 1.0, 0.5, zeros(Vec3)),
           msphere(Point(5.0, 1.0, -15), 2.0, Vec3(0.90, 0.76, 0.46), 1.0, 0.0, zeros(Vec3)),
           msphere(Point(5.0, 0.0, -25), 3.0, Vec3(0.65, 0.77, 0.970), 1.0, 0.0, zeros(Vec3)),
           msphere(Point(-5.5,      0, -15), 3.0, Vec3(0.90, 0.90, 0.90), 1.0, 0.0, zeros(Vec3)),
           msphere(Point(0.0, 20.0, -30), 3.0, zeros(Vec3), 0.0, 0.0, Vec3(3.0, 3.0, 3.0))]
RayTrace.ListScene(scene)
end


function mixed_scene()
    scene = [msphere(Point(0.0, -10004, -20), 10000.0, Vec3(0.20, 0.20, 0.20), 0.0, 0.0, Vec3(0.0, 0.0, 0.0)),
             msphere(Point(0.0, 0.0, -20), 4.0, Vec3(1.0, 0.32, 0.36), 1.0, 0.5, zeros(Vec3)),
             msphere(Point(0.0, 0.0, -25), 2.0, Vec3(0.0, 0.32, 1.0), 1.0, 0.5, zeros(Vec3)),
             msphere(Point(0.0, 20.0, -30), 3.0, zeros(Vec3), 0.0, 0.0, Vec3(3.0, 3.0, 3.0))]
  RayTrace.ListScene(scene)
end
