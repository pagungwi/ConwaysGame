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

void createRandomInitialState(uchar4 * gameboard, int rows, int cols)
{
    int i = 0;
    int j = 0;
    int objNum; // Start in top left corner of gameboard
    int * temp;
    // Use modulus and rand numbers to move and place randomized objects (0-13)
    srand(time(0));
    for(i = 0; i < rows; i++) {
        int max_i = 0; // minimum object size
        for(j=0; j < cols; j++) {
            objNum = (rand() % 13) + 1;
            temp = placeObject(gameboard, objNum, rows, cols, i, j);
            j += temp[1]+2;
            if(temp[0] > max_i) {max_i = temp[0];}
        } 
        i += max_i + 2;
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
void serialConways(uchar4 *in, uchar4 *out, const int rows, const int cols){
    
    // Use gaussian_blur_filter function and Lecture3.1 Parallelism Slides to build out for-loops

}

/*
Kernel that creates visible image for effectively viewing Conway's game (make single value in array map to 5x5 block of pixels)
*/
void serialCreateImage(uchar4 *in, const int rows, const int cols, std::string name)
{
    // CV_8UC1 = 8-bit unsigned single channel
    cv::Mat output(rows, cols, CV_8UC4, (void*)in); // generate image
    bool suc = cv::imwrite(name.c_str(), output);
    if(!suc){
        std::cerr << "Couldn't write GPU image!\n";
        exit(1);
    }
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

    const size_t  numPixels = game_rows*game_cols;

    uchar4 * gameboard;
    gameboard = (uchar4 *)malloc(numPixels*sizeof(uchar4));
    uchar4 def = make_uchar4(255, 255, 255, 255);
    memset(gameboard, 255, numPixels*sizeof(uchar4));
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
    createRandomInitialState(gameboard, game_rows, game_cols);

    
    /* Print array could be useful for ensuring Conway's game looks correct */
    /*
    std::cout << "Gaussian Filter Array: \n";
    printArray<float>(gameboard5, numPixels); // printUtility. 
    std::cout << "\n";
    */
    uchar4 *h_in_board, *h_o_board; // pointers to the actual image input and output pointers  
    uchar4 *d_in_board, *d_o_board;
    uchar4 *r_in_board, *r_o_board; // reference serial output image

    cv::Mat i_img, o_img; 

    // Names of parallel files
    std::string infile = "parallel_initial.bmp"; 
    std::string outfile = "parallel_final.bmp";

    // Names of serial files
    std::string i_reference = "serial_initial.bmp";
    std::string o_reference = "serial_final.bmp";

    i_img.create(game_rows, game_cols, CV_8UC1);
    h_in_board = i_img.ptr<uchar4>(0); // pointer to output image
    r_in_board = i_img.ptr<uchar4>(0); // pointer to reference serial output image
    serialCreateImage(gameboard, game_rows, game_cols, i_reference);

    checkCudaErrors(cudaMalloc((void**)&h_in_board, sizeof(uchar4)*numPixels));
    checkCudaErrors(cudaMalloc((void**)&h_o_board, sizeof(uchar4)*numPixels));
    // allocate the memories for the device pointers  
    checkCudaErrors(cudaMalloc((void**)&d_in_board, sizeof(uchar4)*numPixels));
    checkCudaErrors(cudaMalloc((void**)&d_o_board, sizeof(uchar4)*numPixels));

    // copy the image and filter over to GPU here 
    checkCudaErrors(cudaMemcpy(d_in_board, h_in_board, sizeof(uchar4)*numPixels, cudaMemcpyHostToDevice));

    // kernel launch code 
    par_conway(gameboard, d_in_board, d_o_board, game_rows, game_cols, game_phases); // Select what gameBoard version we want to test
    cudaDeviceSynchronize();
    checkCudaErrors(cudaGetLastError());

    // memcpy the output image to the host side.
    checkCudaErrors(cudaMemcpy(h_o_board, d_o_board, numPixels*sizeof(uchar4), cudaMemcpyDeviceToHost));

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
    cudaFree(d_in_board);
    cudaFree(d_o_board);
    free(gameboard);
    // free gameboards?

    return 0;
}



