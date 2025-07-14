docker build -t cloudi-os-builder .
docker run -it --privileged --rm -v "output:/output" -v /dev:/dev cloudi-os-builder
