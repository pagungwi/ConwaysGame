#include "./kernel.h" 

#define BLOCK 16
#define TILE_WIDTH (BLOCK+1)
#define RADIUS 1

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
void global_Conways(uchar4*d_in, uchar4*d_out, const int rows, const int cols, const int phases){
        int x = threadIdx.x + blockIdx.x * blockDim.x;
        int y = threadIdx.y + blockIdx.y * blockDim.y; 

        int position = y*cols+x;
      
        
        
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
        
        if(x < cols && y < rows)
        {
                // Check if neighbors alive or dead, add to alive count
                if(x % cols != 0) // Need to check if on left wall of image
                {
                        if(top_l < rows*cols && top_l > -1 && d_in[top_l].x == 0) { count++; } // top left neighbor
                        if(mid_l < rows*cols && mid_l > -1 && d_in[mid_l].x == 0) { count++; } // mid left neigbor
                        if(bot_l < rows*cols && bot_l > -1 && d_in[bot_l].x == 0) { count++; } // bottom left neighbor
                }
                if(x % cols != cols-1) // Need to check if on right wall of image
                {   
                        if(top_r < rows*cols && top_r > -1 && d_in[top_r].x == 0) { count++; } // top right neighbor
                        if(mid_r < rows*cols && mid_r > -1 && d_in[mid_r].x == 0) { count++; } // middle right neighbor
                        if(bot_r < rows*cols && bot_r > -1 && d_in[bot_r].x == 0) { count++; }// bottom right neighbor
                }
                if(top_m < rows*cols && top_m > -1 && d_in[top_m].x == 0) { count++; } // top middle neighbor
                if(bot_m < rows*cols && bot_m > -1 && d_in[bot_m].x == 0) { count++; } // bottom middle neighbor

                // Update temp board based on counts
                if(d_in[position].x == 0 && (count < 2 || count > 3)) {d_out[position] = make_uchar4(255,255,255,255);} // if alive, make dead
                else if(d_in[position].x == 0 && (count == 2 || count == 3)) {d_out[position] = make_uchar4(0,0,0,255);} // if alive, stay alive
                else if(d_in[position].x == 255 && (count == 3)) {d_out[position] = make_uchar4(0,0,0,255);} // if dead, make alive
                else {d_out[position] = make_uchar4(255,255,255,255);} // if dead, stay dead

                //d_in[position] = d_temp[position];
        }
        /*if(x < cols && y < rows)
        {
                d_out[position] = d_in[position];
        }
        */
}

__global__ 
void shared_Conways(uchar4*d_in, uchar4*d_out, const int rows, const int cols, const int phases){
        // create shared variable to load halo of pixels around block for count calculations
        __shared__ uchar4 ds_in[TILE_WIDTH][TILE_WIDTH];
        int tx = threadIdx.x;
        int ty = threadIdx.y;
        int x = tx + blockIdx.x * blockDim.x;
        int y = ty + blockIdx.y * blockDim.y;

        int position = y*cols+x;
        int count = 0;
        
        /* Load original block dims into center of shared tile*/
        if(x < cols && y < rows) {
                ds_in[ty + RADIUS][tx + RADIUS] = d_in[y*cols+x];
        } else { 
                ds_in[ty + RADIUS][tx + RADIUS] = make_uchar4(255, 255, 255, 255); // Pad with dead cells
        }

        // Left halo (tx < 1)
        if(tx == 0) {
                if(x-RADIUS >= 0 && y < rows) {
                        ds_in[ty+RADIUS][tx] = d_in[y*cols+(x-RADIUS)];
                } else {
                        ds_in[ty+RADIUS][tx] = make_uchar4(255, 255, 255, 255);
                }
        }
        // Right halo (tx = cols)
        if(tx == cols) {
                if(x+RADIUS < cols && y < rows) {
                        ds_in[ty+RADIUS][tx + 2*RADIUS] = d_in[y*cols+(x+RADIUS)];
                } else {
                        ds_in[ty+RADIUS][tx + 2*RADIUS] = make_uchar4(255, 255, 255, 255);
                }
        }
        // Top halo (ty < 1)
        if(ty == 0) {
                if(x < cols && y-RADIUS >= 0) {
                        ds_in[ty][tx+RADIUS] = d_in[(y-RADIUS)*cols+x];
                } else {
                        ds_in[ty][tx+RADIUS] = make_uchar4(255, 255, 255, 255);
                }
        }
        // Bottom halo (ty = rows)
        if(ty == rows) {
                if(x < cols && y+RADIUS < rows) {
                        ds_in[ty + 2*RADIUS][tx+RADIUS] = d_in[(y+RADIUS)*cols+x];
                } else {
                        ds_in[ty + 2*RADIUS][tx+RADIUS] = make_uchar4(255, 255, 255, 255);
                }
        }
        // Top-left corner
        if(tx == 0 && ty == 0)
        {
                if(x-RADIUS >= 0 && y-RADIUS >=0) {
                        ds_in[ty][tx] = d_in[(y-RADIUS)*cols+(x-RADIUS)]; 
                } else {
                        ds_in[ty + 2*RADIUS][tx+RADIUS] = make_uchar4(255, 255, 255, 255);
                }
        }
        // Top-right corner
        if(tx == cols && ty == 0) {
                if(x+RADIUS < cols && y-RADIUS >= 0) {
                        ds_in[ty][tx] = d_in[(y-RADIUS)*cols+(x+RADIUS)];
                } else {
                        ds_in[ty + 2*RADIUS][tx+RADIUS] = make_uchar4(255, 255, 255, 255);
                }
        }
        // Bot-left corner
        if(tx == 0 && ty == rows) {
                if(x-RADIUS >= 0 && y+RADIUS < rows) {
                        ds_in[ty][tx] = d_in[(y+RADIUS)*cols+(x-RADIUS)];
                } else {
                        ds_in[ty + 2*RADIUS][tx+RADIUS] = make_uchar4(255, 255, 255, 255);
                }
        }
        // Bot-right corner
        if(tx == cols && ty == rows) {
                if(x+RADIUS < cols && y+RADIUS < rows) {
                        ds_in[ty][tx] = d_in[(y+RADIUS)*cols+(x+RADIUS)];
                } else {
                        ds_in[ty + 2*RADIUS][tx+RADIUS] = make_uchar4(255, 255, 255, 255);
                }
        }
        __syncthreads();
        
        uchar4 nextState;
        uchar4 initialState = ds_in[ty+1][tx+1];

        if(x < cols && y < rows)
        {
                // Check if neighbors alive or dead, add to alive count
                if(x % cols != 0) // Need to check if on left wall of image
                {
                        if(y % rows != 0 && ds_in[ty][tx].x == 0) { count++; } // top left neighbor
                        if(ds_in[ty+1][tx].x == 0) { count++; } // mid left neigbor
                        if(y % rows != rows-1 && ds_in[ty+2][tx].x == 0) { count++; } // bottom left neighbor
                }
                if(x % cols != cols-1) // Need to check if on right wall of image
                {   
                        if(y % rows != 0 && ds_in[ty][tx+2].x == 0) { count++; } // top right neighbor
                        if(ds_in[ty+1][tx+2].x == 0) { count++; } // middle right neighbor
                        if(y % rows != rows-1 && ds_in[ty+2][tx+2].x == 0) { count++; }// bottom right neighbor
                }
                if(y % rows != 0 && ds_in[ty][tx+1].x == 0) { count++; } // top middle neighbor
                if(y % rows != rows-1 && ds_in[ty+2][tx+1].x == 0) { count++; } // bottom middle neighbor

                // Update temp board based on counts
                if(initialState.x == 0 && (count < 2 || count > 3)) {nextState = make_uchar4(255,255,255,255);} // if alive, make dead
                else if(initialState.x == 0 && (count == 2 || count == 3)) {nextState = make_uchar4(0,0,0,255);} // if alive, stay alive
                else if(initialState.x == 255 && (count == 3)) {nextState = make_uchar4(0,0,0,255);} // if dead, make alive
                else {nextState = make_uchar4(255,255,255,255);} // if dead, stay dead
        }
        __syncthreads();
        if(x < cols && y < rows)
        {
                d_out[position] = nextState;
        }
}


void par_conway(uchar4 *d_in_img, uchar4 *d_out_img, size_t rows, size_t cols, size_t phases){
 
        // Defines number of blocks needed for data size
        dim3 gridSize((cols-1)/BLOCK+1, (rows-1)/BLOCK+1,1);
        // Defines number of threads per block
        dim3 blockSize(BLOCK, BLOCK, 1);

        for(int p = 0; p < phases; p++) {
                global_Conways<<<gridSize, blockSize>>>(d_in_img, d_out_img, rows, cols, phases);
                //shared_Conways<<<gridSize, blockSize>>>(d_in_img, d_out_img, rows, cols, phases);
                cudaDeviceSynchronize();
                checkCudaErrors(cudaGetLastError());
                
                 // Update gmaeboard state for next phase
                uchar4* temp = d_in_img;
                d_in_img = d_out_img;
                d_out_img = temp;
        }

/*
        gaussianBlur<<<gridSize, blockSize>>>(d_green, d_gblurred, rows, cols, d_filter, filterWidth);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());

        gaussianBlur<<<gridSize, blockSize>>>(d_blue, d_bblurred, rows, cols, d_filter, filterWidth);
        cudaDeviceSynchronize();
        checkCudaErrors(cudaGetLastError());
*/
}




