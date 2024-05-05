#include "headers.h"
#include <math.h>
#include "xscugic.h"
#include "sleep.h"

extern XAxiDma AxiDma_mul;

int call_fpga(u64 * bufin, u64 * bufout)
{
	int Status;
	//send batch data to the multiply_window
	//Beaware the data width
	Status = XAxiDma_SimpleTransfer(&AxiDma_mul, (UINTPTR)bufout,
				MAX_PKT_LEN*8, XAXIDMA_DEVICE_TO_DMA);

	if (Status != XST_SUCCESS) {
			return XST_FAILURE;
	}

	//transfer data from here to multiply_window module
	Status = XAxiDma_SimpleTransfer(&AxiDma_mul, (UINTPTR)bufin,
				MAX_PKT_LEN*8, XAXIDMA_DMA_TO_DEVICE);

	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	while ((XAxiDma_Busy(&AxiDma_mul,XAXIDMA_DEVICE_TO_DMA))||(XAxiDma_Busy(&AxiDma_mul,XAXIDMA_DMA_TO_DEVICE)))
	{
		/*wait*/
	}
}
