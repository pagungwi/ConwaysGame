#include <iostream>
#include <cstdio>
#include <cuda.h>
#include <cuda_runtime.h> 
#include <cassert>
#include <cstdio> 
#include <string> 
#include <opencv2/opencv.hpp> 
#include <cmath> 
#include <iomanip>
#include <chrono>
#include <stdlib.h>

#include "utils.h"
#include "kernel.h"
#include "objects.h"

/* 
 * Compute if the two images are correctly 
 * computed. The reference image can 
 * either be produced by a software or by 
 * your own serial implementation.
 * */
void checkApproxResults(unsigned char *ref, unsigned char *gpu, size_t numElems){

    for(size_t i = 0; i < numElems; i++){
        if(ref[i] - gpu[i] > 1e-5){
            std::cerr << "Error at position " << i << "\n"; 

            std::cerr << "Reference:: " << std::setprecision(17) << +ref[i] <<"\n";
            std::cerr << "GPU:: " << +gpu[i] << "\n";

            exit(1);
        }
    }
}



void checkResult(const std::string &reference_file, const std::string &output_file, float eps){
    cv::Mat ref_img, out_img; 

    ref_img = cv::imread(reference_file, -1);
    out_img = cv::imread(output_file, -1);


    unsigned char *refPtr = ref_img.ptr<unsigned char>(0);
    unsigned char *oPtr = out_img.ptr<unsigned char>(0);

    checkApproxResults(refPtr, oPtr, ref_img.rows*ref_img.cols*ref_img.channels());
    std::cout << "PASSED!\n";


}

// Serial implementations of kernel functions

/*
  Handy constructors provided by the 
  cuda library i.e. 
  make_int2(x, y) -> creates a vector of type int2 having x,y components 
  make_uchar4(x,y,z,255) -> creates a vector of uchar4 type x,y,z components 
  the last argument being the transperency value. 
 */

void createRandomInitialState(unsigned char * gameboard, int rows, int cols)
{
    int i, j;
    gameboard = (unsigned char *)malloc(rows*cols*sizeof(unsigned char));
    int objNum; // Start in top left corner of gameboard
    int * temp;
    // Use modulus and rand numbers to move and place randomized objects (0-13)
    for(i = 0; i < rows; i++) {
        for(j = 0; j < cols; j++) {
            srand(time(0));
            objNum = (rand() % 13) + 1;
            temp = placeObject(gameboard, objNum, rows, cols, i, j);
            i = temp[0];
            j = temp[1];
        } 
    }
}

/*
void createInitialState(unsigned char * gameboard, int rows, int cols)
{
    gameboard = (unsigned char *)malloc(rows*cols*sizeof(unsigned char));
}
*/

/*
Kernel for running Conway's Game of Life Serially for x phases/iterations
 */
void serialConways(unsigned char *in, unsigned char *out, const int rows, const int cols){
    
    // Use gaussian_blur_filter function and Lecture3.1 Parallelism Slides to build out for-loops

}

/*
Kernel that creates visible image for effectively viewing Conway's game (make single value in array map to 5x5 block of pixels)
*/
uchar4 * serialCreateImage(unsigned char *in, unsigned char *out, const int rows, const int cols)
{
    return NULL;
}

int main(int argc, char const *argv[]) {

    int game_rows, game_cols, game_phases;

    switch(argc){
        case 1:
            game_rows = 256;
            game_cols = 256;
            game_phases = 10;
            break; 
        case 3:
            game_rows = atoi(argv[1]);
            game_cols = atoi(argv[2]);
            game_phases = 10;
            break;
        case 4:
            game_rows = atoi(argv[1]);
            game_cols = atoi(argv[2]);
            game_phases = atoi(argv[3]);
            break;
        default: 
                std::cerr << "Usage ./conway <# rows> <# cols> <# of phases> \n";
                exit(1);
    }

    // Switch to uchar4 down the line?

    /* Create fixed initial states using pre-defined sizes:
        512 x 512
        2048 x 2048
        512 x 4096
        8192 x 1024
    */
    unsigned char * gameboard1;
    unsigned char * gameboard2;
    unsigned char * gameboard3;
    unsigned char * gameboard4; unsigned char * gameboard5;
    /*
    createInitialState(gameboard1, 512, 512);
    createInitialState(gameboard2, 2048, 2048);
    createInitialState(gameboard3, 512, 4096);
    createInitialState(gameboard4, 8192, 1024);
    */
    /* Create randomized initial states using user-input sizes:
        512 x 512
        2048 x 2048
        512 x 4096
        8192 x 1024
    */
    createRandomInitialState(gameboard5, game_rows, game_cols);

    const size_t  numPixels = game_rows*game_cols;
    /* Print array could be useful for ensuring Conway's game looks correct */
    /*
    std::cout << "Gaussian Filter Array: \n";
    printArray<float>(gameboard5, numPixels); // printUtility. 
    std::cout << "\n";
    */
    uchar4 *h_in_img, *h_o_img; // pointers to the actual image input and output pointers  
    uchar4 *d_in_img, *d_o_img;
    uchar4 *r_o_img; // reference serial output image

    cv::Mat imrgba, o_img; 
/*
    std::string infile; 
    std::string outfile; 
    std::string reference;

    // preprocess 
    cv::Mat img = cv::imread(infile.c_str(), cv::IMREAD_COLOR); 
    if(img.empty()){
        std::cerr << "Image file couldn't be read, exiting\n"; 
        exit(1);
    }

    cv::cvtColor(img, imrgba, cv::COLOR_BGR2RGBA);

    o_img.create(img.rows, img.cols, CV_8UC4); //oimg changed to o_img

    h_in_img = imrgba.ptr<uchar4>(0); // pointer to input image
    h_o_img = o_img.ptr<uchar4>(0); // pointer to output image
    r_o_img = o_img.ptr<uchar4>(0); // pointer to reference serial output image
*/

    // allocate the memories for the device pointers  
    checkCudaErrors(cudaMalloc((void**)&d_in_img, sizeof(uchar4)*numPixels));
    checkCudaErrors(cudaMalloc((void**)&d_o_img, sizeof(uchar4)*numPixels));

    // copy the image and filter over to GPU here 
    checkCudaErrors(cudaMemcpy(d_in_img, h_in_img, sizeof(uchar4)*numPixels, cudaMemcpyHostToDevice));

    // kernel launch code 
    par_conway(gameboard5, d_in_img, d_o_img, game_rows, game_cols, game_phases); // Select what gameBoard version we want to test
    cudaDeviceSynchronize();
    checkCudaErrors(cudaGetLastError());

    // memcpy the output image to the host side.
    checkCudaErrors(cudaMemcpy(h_o_img, d_o_img, numPixels*sizeof(uchar4), cudaMemcpyDeviceToHost));

    // perform serial memory allocation and function calls, final output should be stored in *r_o_img
    //  ** there are many ways to perform timing in c++ such as std::chrono **

    std::chrono::time_point<std::chrono::system_clock> start, end;
    std::chrono::duration<double> elapsed_time;

    std::cout << "Serial Kernel Execution Times:\n";

/*
    start = std::chrono::system_clock::now();
    serialGaussianBlur(h_red, h_red_blurred, img.rows, img.cols, h_filter, fWidth);
    end = std::chrono::system_clock::now();
    elapsed_time = end-start;
    std::cout << "GaussianBlur: " << elapsed_time.count() << "s\n";

    // create the image with the output data 
    cv::Mat output(img.rows, img.cols, CV_8UC4, (void*)h_o_img); // generate GPU output image.
    bool suc = cv::imwrite(outfile.c_str(), output);
    if(!suc){
        std::cerr << "Couldn't write GPU image!\n";
        exit(1);
    }
    cv::Mat output_s(img.rows, img.cols, CV_8UC4, (void*)r_o_img); // generate serial output image
    suc = cv::imwrite(reference.c_str(), output_s);
    if(!suc){
        std::cerr << "Couldn't write serial image!\n";
        exit(1);
    }
    
    // check if the caclulation was correct to a degree of tolerance

    checkResult(reference, outfile, 1e-5);
*/
    // free any necessary memory.
    cudaFree(d_in_img);
    cudaFree(d_o_img);

    // free gameboards?

    return 0;
}



