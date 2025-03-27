/* Different Defined Objects */

/* Starting with unsigned char for black/white, could change to uchar4 for colors */

/* Stills */
unsigned char block[2][2] = {{0, 0}, {0, 0}} ; // (2x2)
unsigned char bee_hive[3][4] = {{255, 0, 0, 255}, {0,255,255, 0}, {255, 0, 0, 255}}; // (3x4)
unsigned char loaf[4][4] = {{255, 0, 0, 255}, {0, 255, 255, 0}, {255, 0, 255, 0}, {255, 255, 0, 255}}; // (4x4)
unsigned char boat[3][3] = {{0,0,255}, {0, 255, 0}, {255, 0, 255}}; // (3x3)
unsigned char tub[3][3] = {{255, 0, 255}, {0, 255, 0}, {255, 0, 255}}; // (3x3)

/* Oscillators */
unsigned char beacon[4][4] = {{0,0,255,255}, {0, 255, 255, 255}, {255, 255, 255, 0}, {255,255,0,0}}; // (4x4) - period 2
unsigned char penta[16][9] = {
                                {255, 255, 255, 255, 255, 255, 255, 255, 255},
                                {255, 255, 255, 0, 0, 0, 255, 255, 255},
                                {255, 255, 255, 255, 255, 255, 255, 255, 255},
                                {255, 255, 0, 255, 255, 255, 0, 255, 255},
                                {255, 255, 0, 255, 255, 255, 0, 255, 255},
                                {255, 255, 255, 255, 255, 255, 255, 255, 255},
                                {255, 255, 255, 0, 0, 0, 255, 255, 255},
                                {255, 255, 255, 255, 255, 255, 255, 255, 255},
                                {255, 255, 255, 255, 255, 255, 255, 255, 255},
                                {255, 255, 255, 0, 0, 0, 255, 255, 255},
                                {255, 255, 255, 255, 255, 255, 255, 255, 255},
                                {255, 255, 0, 255, 255, 255, 0, 255, 255},
                                {255, 255, 0, 255, 255, 255, 0, 255, 255},
                                {255, 255, 255, 255, 255, 255, 255, 255, 255},
                                {255, 255, 255, 0, 0, 0, 255, 255, 255},
                                {255, 255, 255, 255, 255, 255, 255, 255, 255}
}; // (16x9) - period 15
unsigned char pulsar[15][15] = {
                                {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255},
                                {255, 255, 255, 0, 0, 0, 255, 255, 255, 0, 0, 0, 255, 255, 255},
                                {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255},
                                {255, 0, 255, 255, 255, 255, 0, 255, 0, 255, 255, 255, 255, 0, 255},
                                {255, 0, 255, 255, 255, 255, 0, 255, 0, 255, 255, 255, 255, 0, 255},
                                {255, 0, 255, 255, 255, 255, 0, 255, 0, 255, 255, 255, 255, 0, 255},
                                {255, 255, 255, 0, 0, 0, 255, 255, 255, 0, 0, 0, 255, 255, 255},
                                {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255},
                                {255, 255, 255, 0, 0, 0, 255, 255, 255, 0, 0, 0, 255, 255, 255},
                                {255, 0, 255, 255, 255, 255, 0, 255, 0, 255, 255, 255, 255, 0, 255},
                                {255, 0, 255, 255, 255, 255, 0, 255, 0, 255, 255, 255, 255, 0, 255},
                                {255, 0, 255, 255, 255, 255, 0, 255, 0, 255, 255, 255, 255, 0, 255},
                                {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255},
                                {255, 255, 255, 0, 0, 0, 255, 255, 255, 0, 0, 0, 255, 255, 255},
                                {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255}
}; // (15x15) - period 3

/* Spaceships */
unsigned char r_glider[3][3] = {{255,255,0},{0,255,0},{255,0,0}}; // moves down and right (3x3)
unsigned char l_glider[3][3] = {{0,255,0}, {0,0,255}, {255,0,255}}; // moves down and left (3x3)
unsigned char lw_ship[4][5] = {{255,0,0,0,0},{0,255,255,255,0},{255,255,255,255,0},{0,255,255,0,255}}; // moves left to right (4x5)
unsigned char mw_ship[5][6] = {{255,0,0,0,0,0},{0,255,255,255,255,0},{255,255,255,255,255,0},{0,255,255,255,0,255},{255,255,0,255,255,255}}; // moves left to right (5x6)
unsigned char r_hw_ship[5][7] = {{255,0,0,0,0,0,0}, {0,255,255,255,255,255,0}, {255,255,255,255,255,255,0},{0,255,255,255,255,0,255},{255,255,0,0,255,255,255}}; // moves left to right (5x7)
unsigned char l_hw_ship[5][7] = {{255,255,255,0,0,255,255}, {255,0,255,255,255,255,0}, {0,255,255,255,255,255,255}, {0,255,255,255,255,255,0}, {0,0,0,0,0,0,255}}; // moves right to left (5x7)

/* Takes 2D input array (image), object selected, rows and cols of array, placement x and y locations in array */
int * placeObject(uchar4 * input, int object, int rows, int cols, int x, int y)
{
    int i, j;
    switch(object) {
        case 1: // block
            for(i = 0; i < 2; i++) {
                for(j= 0; j < 2; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(block[i][j], block[i][j], block[i][j], 255);
                    }
                }
            }
            break;
        case 2: // bee hive
            for(i = 0; i < 3; i++) {
                for(j= 0; j < 4; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(bee_hive[i][j], bee_hive[i][j], bee_hive[i][j], 255);
                    }
                }
            }
            break;
        case 3: // loaf
            for(i = 0; i < 4; i++) {
                for(j= 0; j < 4; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(loaf[i][j], loaf[i][j], loaf[i][j], 255);
                    }
                }
            }
            break;
        case 4: // boat
            for(i = 0; i < 3; i++) {
                for(j= 0; j < 3; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(boat[i][j], boat[i][j], boat[i][j], 255);
                    }
                }
            }
            break;
        case 5: // tub
            for(i = 0; i < 3; i++) {
                for(j= 0; j < 3; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(tub[i][j], tub[i][j], tub[i][j], 255);
                    }
                }
            }
            break;
        case 6: // beacon
            for(i = 0; i < 4; i++) {
                for(j= 0; j < 4; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(beacon[i][j], beacon[i][j], beacon[i][j], 255);
                    }
                }
            }
            break;
        case 7: // penta
            for(i = 0; i < 16; i++) {
                for(j= 0; j < 9; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(penta[i][j], penta[i][j], penta[i][j], 255);
                    }
                }
            }
            break;
        case 8: // pulsar
            for(i = 0; i < 15; i++) {
                for(j= 0; j < 15; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(pulsar[i][j], pulsar[i][j], pulsar[i][j], 255);
                    }
                }
            }
            break;
        case 9: // right glider
            for(i = 0; i < 3; i++) {
                for(j= 0; j < 3; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(r_glider[i][j], r_glider[i][j], r_glider[i][j], 255);
                    }
                }
            }
            break;
        case 10: // left glider
            for(i = 0; i < 3; i++) {
                for(j= 0; j < 3; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(l_glider[i][j], l_glider[i][j], l_glider[i][j], 255);
                    }
                }
            }
            break;
        case 11: // lw_ship
            for(i = 0; i < 4; i++) {
                for(j= 0; j < 5; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(lw_ship[i][j], lw_ship[i][j], lw_ship[i][j], 255);
                    }
                }
            }
            break;
        case 12: // mw_ship
            for(i = 0; i < 5; i++) {
                for(j= 0; j < 6; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(mw_ship[i][j], mw_ship[i][j], mw_ship[i][j], 255);
                    }
                }
            }
            break;
        case 13: // left hw_ship
            for(i = 0; i < 5; i++) {
                for(j= 0; j < 7; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(l_hw_ship[i][j], l_hw_ship[i][j], l_hw_ship[i][j], 255);
                    }
                }
            }
        default: // right hw_ship
            for(i = 0; i < 5; i++) {
                for(j= 0; j < 7; j++) {
                    if(i+y < rows && j+x < cols) {
                        input[(i+y)*cols+(j+x)] = make_uchar4(r_hw_ship[i][j], r_hw_ship[i][j], r_hw_ship[i][j], 255);
                    }
                }
            }
            break;
    }
    int * temp = (int *)malloc(2*sizeof(int));
    temp[0] = i;
    temp[1] = j;
    return temp;
}
