#include <stdint.h>

#define SENSOR_ADDR 				0x20000000
#define RADIO_ADDR 					0x20000004
#define MILESTONE_CONDITION_ADDR 	0x20000008
#define NV_DIRTY_BIT_ADDR   		0x00010000
#define NV_PC_ADDR          		0x00010004
#define NV_REG_FILE_ADDR    		0x00010008
#define NV_CSR_ADDR         		0x00010028
#define SMOOTHING_FACTOR    		9
#define SCALE_FACTOR				10
#define Nf							2

volatile uint32_t current_sensor_reading;
volatile int ema = 0;

// Interrupt handler placed at 0x140 (aligned to 4 bytes)
void __attribute__((section(".text.fast_irq_handler_nv_write"), interrupt, aligned(4))) fast_irq_handler_nv_write(void) {
    // Save registers to non-volatile memory
    asm volatile("sw a0, 0(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a1, 4(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a2, 8(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a3, 12(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a4, 16(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a5, 20(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a6, 24(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a7, 28(%0)" : : "r"(NV_REG_FILE_ADDR));

    // Save CSRs
    uint32_t mstatus_val, mie_val;
	asm volatile("csrr %0, mie" : "=r"(mie_val));
	asm volatile("csrr %0, mstatus" : "=r"(mstatus_val));
	*((volatile uint32_t*)NV_CSR_ADDR) = mie_val;
    *((volatile uint32_t*)(NV_CSR_ADDR + 4)) = (mstatus_val & 0x80) >> 4;

    // Save PC and set dirty bit
    uint32_t mepc_val;
    asm volatile("csrr %0, mepc" : "=r"(mepc_val));
    *((volatile uint32_t*)NV_PC_ADDR) = mepc_val;
    *((volatile uint32_t*)NV_DIRTY_BIT_ADDR) = 1;
	
	//*((volatile uint32_t*)MILESTONE_CONDITION_ADDR) = 0;
}

void milestone_interrupt(uint32_t current_pc) {
    // Save registers to non-volatile memory
    asm volatile("sw a0, 0(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a1, 4(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a2, 8(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a3, 12(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a4, 16(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a5, 20(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a6, 24(%0)" : : "r"(NV_REG_FILE_ADDR));
    asm volatile("sw a7, 28(%0)" : : "r"(NV_REG_FILE_ADDR));

    // Save CSRs
    uint32_t mstatus_val, mie_val;
	asm volatile("csrr %0, mie" : "=r"(mie_val));
	asm volatile("csrr %0, mstatus" : "=r"(mstatus_val));
	*((volatile uint32_t*)NV_CSR_ADDR) = mie_val;
    *((volatile uint32_t*)(NV_CSR_ADDR + 4)) = (mstatus_val & 0x80) >> 4;

    // Save PC and set dirty bit
    *((volatile uint32_t*)NV_PC_ADDR) = current_pc;
    *((volatile uint32_t*)NV_DIRTY_BIT_ADDR) = 1;
}

int main() {
	asm volatile("csrw mie, %0" : : "r"(0x00010000));    // Use correct interrupt bit
    asm volatile("csrw mstatus, %0" : : "r"(0x8)); // Enable global interrupts (MIE)
	
    int iteration_count = 0;
	uint32_t current_pc;

    while (1) {
        current_sensor_reading = *(volatile uint32_t *)SENSOR_ADDR;
        ema = (SMOOTHING_FACTOR * current_sensor_reading) + ((SCALE_FACTOR - SMOOTHING_FACTOR) * ema);
		ema = ema / SCALE_FACTOR;
		ema = ema >> 2;

        *((volatile uint32_t *)RADIO_ADDR) = ema;

        // Delay loop
        for (volatile int i = 0; i < 100; i++) {
			/* Empty loop for delay */
		}
		
		iteration_count++;
		
		asm volatile("auipc %0, 0" : "=r"(current_pc));
		if (iteration_count == Nf){
			iteration_count = 0;
			milestone_interrupt(current_pc);
		}
    }
    return 0;
}
