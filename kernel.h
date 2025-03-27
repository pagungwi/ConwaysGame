#include <cuda_runtime.h> 
#include <cuda.h> 
#include "utils.h"

/*
 * The launcher for your kernels. 
 * This is a single entry point and 
 * all arrays **MUST** be pre-allocated 
 * on device. you must implement all other 
 * kernels in the respective files.
 * */ 



void par_conway(uchar4* d_gameboard, uchar4 *d_in_img, uchar4 *d_out_img, size_t rows, size_t cols, size_t phases);
