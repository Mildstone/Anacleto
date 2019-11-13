
#ifndef AXI_MMIO2_H
#define AXI_MMIO2_H

#include <linux/types.h>
#include <asm/ioctl.h>


#define DEVICE_NAME "$ip_name$"  /* Dev name as it appears in /proc/devices */
#define MODULE_NAME "$ip_name$"

#define $IP_NAME$_IOCTL_BASE	'W'
#define $IP_NAME$_RESET        _IO($IP_NAME$_IOCTL_BASE, 0)

// #pragma pack(1)
// struct $ip_name$_device {
//     const char *name;
//     struct $ip_name$ priv;
//     int    fd;
// };

#ifndef __KERNEL__

// hybrid header api functions here //

#endif // __KERNEL__
#endif // AXI_MMIO2_H

