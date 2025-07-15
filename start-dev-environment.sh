docker build -t cloudi-os-builder .
docker run -it --privileged --rm -v "./:/workspace" -v /dev:/dev cloudi-os-builder

