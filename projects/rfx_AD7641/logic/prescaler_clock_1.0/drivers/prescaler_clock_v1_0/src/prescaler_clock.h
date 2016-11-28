
#ifndef PRESCALER_CLOCK_H
#define PRESCALER_CLOCK_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"

#define PRESCALER_CLOCK_S00_AXI_SLV_REG0_OFFSET 0
#define PRESCALER_CLOCK_S00_AXI_SLV_REG1_OFFSET 4
#define PRESCALER_CLOCK_S00_AXI_SLV_REG2_OFFSET 8
#define PRESCALER_CLOCK_S00_AXI_SLV_REG3_OFFSET 12


/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a PRESCALER_CLOCK register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the PRESCALER_CLOCKdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void PRESCALER_CLOCK_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define PRESCALER_CLOCK_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a PRESCALER_CLOCK register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the PRESCALER_CLOCK device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 PRESCALER_CLOCK_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define PRESCALER_CLOCK_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the PRESCALER_CLOCK instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus PRESCALER_CLOCK_Reg_SelfTest(void * baseaddr_p);

#endif // PRESCALER_CLOCK_H
