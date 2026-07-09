#include "ti_msp_dl_config.h"

/* 2 Hz blink: 100ms on, 400ms off (24MHz CPU clock, 1 cycle = 1/24 us) */
#define DELAY_ON  (2400000)   /* 100ms */
#define DELAY_OFF (9600000)   /* 400ms */

int main(void)
{
    SYSCFG_DL_init();

    /* LED off (active-low: pin high = off) */
    DL_GPIO_setPins(GPIO_LEDS_PORT, GPIO_LEDS_USER_LED_1_PIN);

    while (1) {
        /* LED on */
        DL_GPIO_clearPins(GPIO_LEDS_PORT, GPIO_LEDS_USER_LED_1_PIN);
        delay_cycles(DELAY_ON);
        /* LED off */
        DL_GPIO_setPins(GPIO_LEDS_PORT, GPIO_LEDS_USER_LED_1_PIN);
        delay_cycles(DELAY_OFF);
    }
}
