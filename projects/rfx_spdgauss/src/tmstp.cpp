
// #include <stdio.h>
// #include <math.h>



// float test_f () {
//     static float f=M_PI;
//     return sin(f+1E-3);
// }

// void tmstp(int *si, int *so)
// {
// #pragma HLS INTERFACE s_axilite port=si bundle=BUS_A
// #pragma HLS INTERFACE s_axilite port=so register bundle=BUS_A
// #pragma HLS INTERFACE s_axistream    
// // #pragma HLS INTERFACE s_axilite port=return bundle=BUS_A
//     *so = 2 * *si;
// }
  


// HLS example of vector add using AXI streams for data, and AXI lite for control interface

#include <iostream>
#include <hls_stream.h>
#include <ap_axi_sdata.h>

#include <ap_int.h>

// using namespace std;

typedef ap_axis <32,1,1,1> AXI_T;
typedef hls::stream<AXI_T> STREAM_T;

void tmstp(STREAM_T &A, STREAM_T &B, STREAM_T &C, int LEN){
#pragma HLS INTERFACE axis port=A
#pragma HLS INTERFACE axis port=B
#pragma HLS INTERFACE axis port=C
#pragma HLS INTERFACE s_axilite port=LEN bundle=ctrl
// #pragma HLS INTERFACE s_axilite port=return bundle=ctrl // this creates the interrupt port also

    AXI_T tmpA, tmpB, tmpC;
    ap_uint<32> array[255];
    ap_uint<8>  array_pos;

    for(int i=0; i<LEN; i++){

        A >> tmpA;
        B >> tmpB;
        tmpC.data = tmpA.data + tmpB.data;

        if(i == LEN-1) {
			tmpC.last = 1;
		} else {
			tmpC.last = 0;
		}

		tmpC.strb = 0xf;	
		tmpC.keep = 0xf;	
		C << tmpC;
    }

}