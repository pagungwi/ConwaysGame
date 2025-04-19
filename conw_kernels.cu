#include "./kernel.h"

#define BLOCK 8
#define TILE_WIDTH (BLOCK + 2*RADIUS)
#define RADIUS 1

/* Don't need global or shared create image:
   1. Library functions already exist
   2. Parallelization would need to initialize size of file, then each thread writes a byte of data at a different location
   3. Access to the file (read/write) would have race conditions and therefore be serialized anyways 
*/

__global__ 
void global_CreateImage(uchar4*d_in, uchar4*d_out, const int rows, const int cols, uchar4 * image){}

__global__ 
void shared_CreateImage(uchar4*d_in, uchar4*d_out, const int rows, const int cols, uchar4 * image){}

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
        }
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
        // Step 1: Load the original image block into the center of ds_in
        if (y < rows && x < cols) {
                ds_in[ty + RADIUS][tx + RADIUS] = d_in[y * cols + x];
        } else {
                ds_in[ty + RADIUS][tx + RADIUS] = make_uchar4(255, 255, 255, 255);   // Zero-padding for out-of-boundary
        }

        // Left halo
        if (tx == 0) {
                int halo_x = x - RADIUS;
                if (halo_x >= 0 && y < rows) {
                ds_in[ty + RADIUS][tx] = d_in[y * cols + halo_x];
                } else {
                ds_in[ty + RADIUS][tx] = make_uchar4(255, 255, 255, 255);   // Zero-padding for out-of-boundary
                }
        }
        // Right halo
        if (tx == BLOCK - RADIUS) {
                int halo_x = x + RADIUS;
                if (halo_x < cols && y < rows) {
                ds_in[ty + RADIUS][tx + 2 * RADIUS] = d_in[y * cols + halo_x];
                } else {
                ds_in[ty + RADIUS][tx + 2 * RADIUS] = make_uchar4(255, 255, 255, 255);  // Zero-padding for out-of-boundary
                }
        }
        // Top halo
        if (ty == 0) {
                int halo_y = y - RADIUS;
                if (halo_y >= 0 && x < cols) {
                ds_in[ty][tx + RADIUS] = d_in[halo_y * cols + x];
                } else {
                ds_in[ty][tx + RADIUS] = make_uchar4(255, 255, 255, 255);   // Zero-padding for out-of-boundary
                }
        }
        // Bottom halo
        if (ty == BLOCK - RADIUS) {
                int halo_y = y + RADIUS;
                if (halo_y < rows && x < cols) {
                ds_in[ty + 2 * RADIUS][tx + RADIUS] = d_in[halo_y * cols + x];
                } else {
                ds_in[ty + 2 * RADIUS][tx + RADIUS] = make_uchar4(255, 255, 255, 255);   // Zero-padding for out-of-boundary
                }
        }
        // Top-left corner
        if (tx == 0 && ty == 0) {
                int halo_x = x - RADIUS;
                int halo_y = y - RADIUS;
                if (halo_x >= 0 && halo_y >= 0) {
                ds_in[ty][tx] = d_in[halo_y * cols + halo_x];
                } else {
                ds_in[ty][tx] = make_uchar4(255, 255, 255, 255);   // Zero-padding for out-of-boundary
                }
        }
        // Top-right corner
        if (tx == BLOCK - RADIUS && ty == 0) {
                int halo_x = x + RADIUS;
                int halo_y = y - RADIUS;
                if (halo_x < cols && halo_y >= 0) {
                ds_in[ty][tx + 2 * RADIUS] = d_in[halo_y * cols + halo_x];
                } else {
                ds_in[ty][tx + 2 * RADIUS] = make_uchar4(255, 255, 255, 255);   // Zero-padding for out-of-boundary
                }
        }
        // Bottom-left corner
        if (tx == 0 && ty == BLOCK - RADIUS) {
                int halo_x = x - RADIUS;
                int halo_y = y + RADIUS;
                if (halo_x >= 0 && halo_y < rows) {
                ds_in[ty + 2 * RADIUS][tx] = d_in[halo_y * cols + halo_x];
                } else {
                ds_in[ty + 2 * RADIUS][tx] = make_uchar4(255, 255, 255, 255);  // Zero-padding for out-of-boundary
                }
        }
        // Bottom-right corner
        if (tx == BLOCK - RADIUS && ty == BLOCK - RADIUS) {
                int halo_x = x + RADIUS;
                int halo_y = y + RADIUS;
                if (halo_x < cols && halo_y < rows) {
                ds_in[ty + 2 * RADIUS][tx + 2 * RADIUS] = d_in[halo_y * cols + halo_x];
                } else {
                ds_in[ty + 2 * RADIUS][tx + 2 * RADIUS] = make_uchar4(255, 255, 255, 255);  // Zero-padding for out-of-boundary
                }
        }
        __syncthreads();

        if(x < cols && y < rows)
        {
                int row_shared = ty + RADIUS;
                int col_shared = tx + RADIUS;
                
                if(ds_in[row_shared][col_shared-1].x == 0) { count++; } // mid left neigbor
                if(ds_in[row_shared-1][col_shared-1].x == 0) { count++; } // top left neighbor
                if(ds_in[row_shared+1][col_shared-1].x == 0) { count++; } // bottom left neighbor
                if(ds_in[row_shared][col_shared+1].x == 0) { count++; } // middle right neighbor
                if(ds_in[row_shared-1][col_shared+1].x == 0) { count++; } // top right neighbor
                if(ds_in[row_shared+1][col_shared+1].x == 0) { count++; }// bottom right neighbor
                if(ds_in[row_shared-1][col_shared].x == 0) { count++; } // top middle neighbor
                if(ds_in[row_shared+1][col_shared].x == 0) { count++; } // bottom middle neighbor

                if(ds_in[row_shared][col_shared].x == 0 && (count < 2 || count > 3)) {d_out[position] = make_uchar4(255,255,255,255);} // if alive, make dead
                else if(ds_in[row_shared][col_shared].x == 0 && (count == 2 || count == 3)) {d_out[position] = make_uchar4(0,0,0,255);} // if alive, stay alive
                else if(ds_in[row_shared][col_shared].x == 255 && (count == 3)) {d_out[position] = make_uchar4(0,0,0,255);} // if dead, make alive
                else {d_out[position] = make_uchar4(255,255,255,255);} // if dead, stay dead    
        }
}

void par_conway(uchar4 *d_in_img, uchar4 *d_out_img, size_t rows, size_t cols, size_t phases){
 
        // Defines number of blocks needed for data size
        dim3 gridSize((cols-1)/BLOCK+1, (rows-1)/BLOCK+1,1);
        // Defines number of threads per block
        dim3 blockSize(BLOCK, BLOCK, 1);

        std::chrono::time_point<std::chrono::system_clock> start, end;
        std::chrono::duration<double> elapsed_time;

        std::cout << "Parallel Kernel Execution Time:\n";

        start = std::chrono::system_clock::now();
        for(int p = 0; p < phases; p++) {
                //global_Conways<<<gridSize, blockSize>>>(d_in_img, d_out_img, rows, cols, phases);
                shared_Conways<<<gridSize, blockSize>>>(d_in_img, d_out_img, rows, cols, phases);
                cudaDeviceSynchronize();
                checkCudaErrors(cudaGetLastError());
                
                 // Update gmaeboard state for next phase
                uchar4* temp = d_in_img;
                d_in_img = d_out_img;
                d_out_img = temp;
        }
        end = std::chrono::system_clock::now();
        elapsed_time = end-start;
        std::cout << elapsed_time.count() << "s\n";
}




