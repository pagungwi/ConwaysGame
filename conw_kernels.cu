#include "./kernel.h" 

#define BLOCK 4
#define TILE_WIDTH BLOCK

/*
The actual gaussian blur kernel to be implemented by 
you. Keep in mind that the kernel operates on a 
single channel.
 */


__global__ 
void global_CreateImage(uchar4*d_in, uchar4*d_out, const int rows, const int cols, uchar4 * image){

}


__global__ 
void shared_CreateImage(uchar4*d_in, uchar4*d_out, const int rows, const int cols, uchar4 * image){

}


__global__ 
void global_Conways(uchar4*d_in, uchar4*d_out, const int rows, const int cols){

}

__global__ 
void shared_Conways(uchar4*d_in, uchar4*d_out, const int rows, const int cols){

}


void par_conway(uchar4 * d_gameboard, uchar4 *d_in_img, uchar4 *d_out_img, size_t rows, size_t cols, size_t phases){
 
        // Defines number of blocks needed for data size
        dim3 gridSize((cols-1)/BLOCK+1, (rows-1)/BLOCK+1,1);
        // Defines number of threads per block
        dim3 blockSize(BLOCK, BLOCK, 1);

/*
        gaussianBlur<<<gridSize, blockSize>>>(d_red, d_rblurred, rows, cols, d_filter, filterWidth);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());

        gaussianBlur<<<gridSize, blockSize>>>(d_green, d_gblurred, rows, cols, d_filter, filterWidth);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());

        gaussianBlur<<<gridSize, blockSize>>>(d_blue, d_bblurred, rows, cols, d_filter, filterWidth);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());
*/
}




