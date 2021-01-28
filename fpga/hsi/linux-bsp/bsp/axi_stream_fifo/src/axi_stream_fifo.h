#ifndef RPADC_FIFO_0_H
#define RPADC_FIFO_0_H


#include <linux/types.h>
#include <asm/ioctl.h>



#ifdef __cplusplus
extern "C" {
#endif

#define DEVICE_NAME "$ip_name$"  /* Dev name as it appears in /proc/devices */
#define MODULE_NAME "$ip_name$"

#define $MOD_NAME$_IOCTL_BASE	'W'
#define $MOD_NAME$_RESOFFSET 			_IO($MOD_NAME$_IOCTL_BASE, 0)
#define $MOD_NAME$_RESET     			_IO($MOD_NAME$_IOCTL_BASE, 1)
#define $MOD_NAME$_CLEAR     			_IO($MOD_NAME$_IOCTL_BASE, 2)
#define $MOD_NAME$_GETSR     			_IO($MOD_NAME$_IOCTL_BASE, 3)
#define $MOD_NAME$_OVERFLOW  			_IO($MOD_NAME$_IOCTL_BASE, 4)
#define $MOD_NAME$_INT_HALF_SIZE  		_IO($MOD_NAME$_IOCTL_BASE, 5)
#define $MOD_NAME$_INT_FIRST_SAMPLE  	_IO($MOD_NAME$_IOCTL_BASE, 6)
#define $MOD_NAME$_SET_BUFSIZE  		_IO($MOD_NAME$_IOCTL_BASE, 7)
#define $MOD_NAME$_GET_BUFSIZE  		_IO($MOD_NAME$_IOCTL_BASE, 8)

enum AxiStreamFifo_Register {
    ISR   = 0x00,   ///< Interrupt Status Register (ISR)
    IER   = 0x04,   ///< Interrupt Enable Register (IER)
    TDFR  = 0x08,   ///< Transmit Data FIFO Reset (TDFR)
    TDFV  = 0x0c,   ///< Transmit Data FIFO Vacancy (TDFV)
    TDFD  = 0x10,   ///< Transmit Data FIFO 32-bit Wide Data Write Port
    TDFD4 = 0x1000, ///< Transmit Data FIFO for AXI4 Data Write Port
    TLR   = 0x14,   ///< Transmit Length Register (TLR)
    RDFR  = 0x18,   ///< Receive Data FIFO reset (RDFR)
    RDFO  = 0x1c,   ///< Receive Data FIFO Occupancy (RDFO)
    RDFD  = 0x20,   ///< Receive Data FIFO 32-bit Wide Data Read Port (RDFD)
    RDFD4 = 0x1000, ///< Receive Data FIFO for AXI4 Data Read Port (RDFD)
    RLR   = 0x24,   ///< Receive Length Register (RLR)
    SRR   = 0x28,   ///< AXI4-Stream Reset (SRR)
    TDR   = 0x2c,   ///< Transmit Destination Register (TDR)
    RDR   = 0x30,   ///< Receive Destination Register (RDR)
    /// not supported yet .. ///
    TID   = 0x34,   ///< Transmit ID Register
    TUSER = 0x38,   ///< Transmit USER Register
    RID   = 0x3c,   ///< Receive ID Register
    RUSER = 0x40    ///< Receive USER Register
};

enum AxiStreamFifo_ISREnum {
    ISR_RFPE = 1 << 19,  ///< Receive FIFO Programmable Empty
    ISR_RFPF = 1 << 20,  ///< Receive FIFO Programmable Full
    ISR_TFPE = 1 << 21,  ///< Transmit FIFO Programmable Empty
    ISR_TFPF = 1 << 22,  ///< Transmit FIFO Programmable Full
    ISR_RRC = 1 << 23,   ///< Receive Reset Complete
    ISR_TRC = 1 << 24,   ///< Transmit Reset Complete
    ISR_TSE = 1 << 25,   ///< Transmit Size Error
    ISR_RC = 1 << 26,    ///< Receive Complete
    ISR_TC = 1 << 27,    ///< Transmit Complete
    ISR_TPOE = 1 << 28,  ///< Transmit Packet Overrun Error
    ISR_RPUE = 1 << 29,  ///< Receive Packet Underrun Error
    ISR_RPORE = 1 << 30, ///< Receive Packet Overrun Read Error
    ISR_RPURE = 1 << 31, ///< Receive Packet Underrun Read Error
};


#pragma pack(1)
struct fifo_data {
    int isr;   ///< interrupt status register
    int esr;   ///< interrupt status register
    int pad[0x40];
};

struct $mod_name$ {
    struct $mod_name$ *next, *prev;
    const char *name;
    struct fifo_data fifo;
    int    fd;
};


#ifndef __KERNEL__
// api functions here //
#endif // __KERNEL__

#ifdef __cplusplus
}
#endif

#endif // RPADC_FIFO_0_H
