for v in /hpx /blaze /blaze_tensor /pybind11 ~/phylanx
do
  echo -n "VERSION: $v "
  cd $v
  git log -1 --format=%cd
done
