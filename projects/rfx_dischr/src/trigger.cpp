/**
 ** This file is part of the anacleto project.
 ** Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, either version 3 of the License, or
 ** (at your option) any later version.
 **
 ** This program is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ** GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/


#include "ap_axi_sdata.h"

#include "ap_int.h"
typedef ap_uint<1> bit;

//
// D --> size of bus
// U --> user
// TI -> id
// TD -> dest
//
// template<int D,int U,int TI,int TD>
// struct ap_axis{
//    ap_int<D>        data;
//    ap_uint<(D+7)/8> keep;
//    ap_uint<(D+7)/8> strb;
//    ap_uint<U>       user;
//    ap_uint<1>       last;
//    ap_uint<TI>      id;
//    ap_uint<TD>      dest;
// };




void trigger(ap_axis<32,2,5,6> &A, ap_axis<32,2,5,6> &B,
             int *th, volatile bit &led, volatile bit &led2){
#pragma HLS INTERFACE axis      port=A
#pragma HLS INTERFACE axis      port=B
#pragma HLS INTERFACE ap_none   port=led register
#pragma HLS INTERFACE ap_none   port=led2 register
#pragma HLS INTERFACE s_axilite port=return bundle=C
#pragma HLS INTERFACE s_axilite port=th     bundle=C

    static int duty = 70E6;
    static int count = 0;

    led = *th & 1;
    //    if(count++ > duty) {
    //        if (  count > duty/2 ) led2 = 1;
    //        else led2 = 0;
    //        count = 0;
    //    }

    led2 = 1;

    if( A.data.to_int() > *th ) {
        B.data = A.data;
    }
    else {
        B.data = 0;
    }
    B.keep = A.keep;
    B.strb = A.strb;
    B.user = A.user;
    B.last = A.last;
    B.id   = A.id;
    B.dest = A.dest;
}

