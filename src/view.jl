import Colors

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
