NVCC=nvcc 

OPENCV_INCLUDEPATH="$(HOME)/software/spackages/linux-rocky8-skylake_avx512/gcc-12.3.0/opencv-4.8.0-miqey2j5nnm57c5mlgd4rhgdwcsu3yku/include/opencv4"
OPENCV_LIBPATH=$(HOME)/software/spackages/linux-rocky8-skylake_avx512/gcc-12.3.0/opencv-4.8.0-miqey2j5nnm57c5mlgd4rhgdwcsu3yku/lib64

OPENCV_LIBS= -lopencv_core -lopencv_imgproc -lopencv_imgcodecs
OPENCV_CFLAGS=`pkg-config --cflags opencv4`
OPENCV_CFLAGS=-I$(OPENCV_INCLUDEPATH)

CUDA_INCLUDEPATH=$(CUDA_HOME)/targets/x86_64-linux/include

NVCC_OPTS=-g -G -allow-unsupported-compiler 
GCC_OPTS=-std=c++11 -g -Wall 
CUDA_LD_FLAGS=-L /usr/local/cuda/lib64 -lcuda -lcudart

final: main.o conw.o
	$(NVCC) -o conway main.o conw_kernels.o $(CUDA_LD_FLAGS) $(CUDA_LIB) $(OPENCV_CFLAGS) -L $(OPENCV_LIBPATH) $(OPENCV_LIBS) 

main.o:main.cpp kernel.h utils.h 
	g++ -c $(GCC_OPTS) -I $(CUDA_INCLUDEPATH) $(OPENCV_CFLAGS) $(OPENCV_INCLUDE) main.cpp

conw.o: conw_kernels.cu kernel.h  utils.h
	$(NVCC) -c conw_kernels.cu $(NVCC_OPTS)

clean:
	rm *.o conway
