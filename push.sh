#docker-compose push
docker push stevenrbrandt/phylanx.devenv:working
ssh -p 8000 rostam singularity build images/phylanx-devenv.simg docker://stevenrbrandt/phylanx.devenv:working
