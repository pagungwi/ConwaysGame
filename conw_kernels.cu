#include "./kernel.h" 

#define BLOCK 8
#define TILE_WIDTH BLOCK

/* Don't need global or shared create image:
   1. Library functions already exist
   2. Parallelization would need to initialize size of file, then each thread writes a byte of data at a different location
   3. Access to the file (read/write) would have race conditions and therefore be serialized anyways 
*/

__global__ 
void global_CreateImage(uchar4*d_in, uchar4*d_out, const int rows, const int cols, uchar4 * image){

}


__global__ 
void shared_CreateImage(uchar4*d_in, uchar4*d_out, const int rows, const int cols, uchar4 * image){

}


__global__ 
void global_Conways(uchar4*d_in, uchar4*d_out, uchar4*d_temp, const int rows, const int cols, const int phases){
        int x = threadIdx.x + blockIdx.x * blockDim.x;
        int y = threadIdx.y + blockIdx.y * blockDim.y; 

        int position = y*cols+x;
      
        for(int p = 0; p < phases; p++) {
                
                int count = 0;
                
                // Neighbor positions
                int top_l = position - 1 - cols;
                int top_m = position - cols;
                int top_r = position + 1 - cols;
                int mid_l = position - 1;
                int mid_r = position + 1;
                int bot_l = position - 1 + cols;
                int bot_m = position + cols;
                int bot_r = position + cols + 1;
                
                if(position < rows*cols && position > -1)
                {
                        // Check if neighbors alive or dead, add to alive count
                        if(x % cols != 0) // Need to check if on left wall of image
                        {
                                if(top_l < rows*cols && top_l > -1 && d_in[top_l].x == 0) { count++; } // top left neighbor
                                if(mid_l < rows*cols && mid_l > -1 && d_in[mid_l].x == 0) { count++; } // mid left neigbor
                                if(bot_l < rows*cols && bot_l > -1 && d_in[bot_l].x == 0) { count++; } // bottom left neighbor
                        }
                        if(x % (cols-1) != 0) // Need to check if on right wall of image
                        {   
                                if(top_r < rows*cols && top_r > -1 && d_in[top_r].x == 0) { count++; } // top right neighbor
                                if(mid_r < rows*cols && mid_r > -1 && d_in[mid_r].x == 0) { count++; } // middle right neighbor
                                if(bot_r < rows*cols && bot_r > -1 && d_in[bot_r].x == 0) { count++; }// bottom right neighbor
                        }
                        if(top_m < rows*cols && top_m > -1 && d_in[top_m].x == 0) { count++; } // top middle neighbor
                        if(bot_m < rows*cols && bot_m > -1 && d_in[bot_m].x == 0) { count++; } // bottom middle neighbor

                        // Update temp board based on counts
                        if(d_in[position].x == 0 && (count < 2 || count > 3)) {d_temp[position] = make_uchar4(255,255,255,255);} // if alive, make dead
                        else if(d_in[position].x == 0 && (count == 2 || count == 3)) {d_temp[position] = make_uchar4(0,0,0,255);} // if alive, stay alive
                        else if(d_in[position].x == 255 && (count == 3)) {d_temp[position] = make_uchar4(0,0,0,255);} // if dead, make alive
                        else {d_temp[position] = make_uchar4(255,255,255,255);} // if dead, stay dead
                        d_in[position] = d_temp[position];
                }
                __syncthreads();
        }
        if(position < rows*cols && position > -1)
        {
                d_out[position] = d_in[position];
        }
}

__global__ 
void shared_Conways(uchar4*d_in, uchar4*d_out, const int rows, const int cols){

}


void par_conway(uchar4 *d_in_img, uchar4 *d_out_img, uchar4 *d_temp, size_t rows, size_t cols, size_t phases){
 
        // Defines number of blocks needed for data size
        dim3 gridSize((cols-1)/BLOCK+1, (rows-1)/BLOCK+1,1);
        // Defines number of threads per block
        dim3 blockSize(BLOCK, BLOCK, 1);


        global_Conways<<<gridSize, blockSize>>>(d_in_img, d_out_img, d_temp, rows, cols, phases);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());

/*
        gaussianBlur<<<gridSize, blockSize>>>(d_green, d_gblurred, rows, cols, d_filter, filterWidth);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());

        gaussianBlur<<<gridSize, blockSize>>>(d_blue, d_bblurred, rows, cols, d_filter, filterWidth);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());
*/
}




