/*
 * code sizes:
 *
 *				   Code   Data   Used    Size   Use%
 * BREATH:			50    300    350     512  68.4%
 * HBEAT1:			50    284    334     512  65.2%
 * HBEAT2:			50    302    352     512  68.8%
 * SINE:			50     66    116     512  22.7%
 *
 */ 


 .include "tn4def.inc"
#define BREATH	1
#define HBEAT1	2
#define HBEAT2	3
#define SINE	9

#define MODE SINE
 

.equ    LED = 0				; LED connected to PB0

#if MODE == BREATH
.equ  DELAYTIME = 17
#elif MODE == HBEAT1
; if you use the HEARTBEAT patterns the delay should be 2-4ms
.equ	DELAYTIME = 2
#elif MODE == HBEAT2
.equ	DELAYTIME = 2
#elif MODE == SINE
.equ DELAYTIME = 33
#else
.equ DELAYTIME = 20
#endif


.cseg 

.org 0x0000
	rjmp	RESET

.def	temp   		= R16	; general purpose temp
.def	delaycnt1  	= R17   ; counter for 1ms delay loop
.def	delayms  	= R28	; keeps track of how many ms left in delay

RESET:
	sbi		DDRB, LED		; LED output
	sbi		PORTB, LED    	; LED off

	; set up fast PWM output timer WGM[3:0] = 0101
	; COM0A1 = 1, COM0A0 = 0 or 1
	ldi		temp, 0xC1		;  Fast PWM (PB2 output)
	out		TCCR0A, temp
	ldi		temp, 0x81      ; fastest clock
	out		TCCR0B, temp

	; we dont use the top of the counter since its only 8 bit
	ldi		temp, 0
	out		OCR0AH, temp


LOOPSTART:
   	ldi ZH, high(PATTERN*2) + 0x40   ; This is start of Code in Tiny4 (0x4000)
   	ldi ZL, low (PATTERN*2) 		; init Z-pointer to storage bytes 
LOOP:
	ld		temp, Z+			; load next led brightness
	cpi		temp, 0			; last entry?
	brne	NORELOAD
	; if temp == 0, means we reached the end, so reload the table index
    rjmp    LOOPSTART

NORELOAD:

	out		OCR0AL, temp	; Shove the brightness into the PWM driver

	; delay!
	ldi		delayms, DELAYTIME			; delay ~17 ms
DELAY:
	ldi		delaycnt1, 0xFF
	DELAY1MS:   ; this loop takes about 1ms (with 1 MHz clock)
		dec		delaycnt1      ; 1 clock
		cpi		delaycnt1, 0   ; 1 clock
		brne	DELAY1MS       ; 2 clocks (on avg)
	dec		delayms
	cpi		delayms, 0
	brne	DELAY

	rjmp	LOOP


PATTERN:
#if MODE == BREATH
;PULSETAB
.db 255, 255, 255, 255, 255, 255, 255, 255, 252, 247, 235, 235, 230, 225, 218, 213, 208, 206, 199, 189, 187, 182, 182, 177, 175, 168, 165, 163, 158, 148, 146, 144, 144, 141, 139, 136, 134, 127, 122, 120, 117, 115, 112, 112, 110, 110, 108, 103, 96, 96, 93, 91, 88, 88, 88, 88, 84, 79, 76, 74, 74, 72, 72, 72, 72, 69, 69, 62, 60, 60, 57, 57, 57, 55, 55, 55, 55, 48, 48, 45, 45, 43, 43, 40, 40, 40, 40, 36, 36, 36, 33, 33, 31, 31, 31, 28, 28, 26, 26, 26, 26, 24, 24, 21, 21, 21, 21, 20, 19, 19, 16, 16, 16, 16, 14, 14, 14, 16, 12, 12, 12, 12, 12, 9, 9, 9, 9, 9, 9, 7, 7, 7, 7, 7, 7, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 7, 7, 7, 7, 7, 7, 9, 9, 9, 12, 12, 12, 14, 14, 16, 16, 16, 16, 21, 21, 21, 21, 24, 24, 26, 28, 28, 28, 31, 36, 33, 36, 36, 40, 40, 43, 43, 45, 48, 52, 55, 55, 55, 57, 62, 62, 64, 67, 72, 74, 79, 81, 86, 86, 86, 88, 93, 96, 98, 100, 112, 115, 117, 124, 127, 129, 129, 136, 141, 144, 148, 160, 165, 170, 175, 184, 189, 194, 199, 208, 213, 220, 237, 244, 252, 255, 255, 255, 255, 255, 255, 255, 0
#elif MODE == HBEAT1
;HEARTBEAT1:
.db 114, 114, 117, 117, 119, 122, 124, 124, 112, 103, 100, 100, 95, 87, 75, 62, 56, 65, 88, 118, 149, 174, 188, 190, 187, 192, 198, 200, 197, 190, 180, 168, 155, 140, 126, 111, 96, 82, 67, 53, 39, 26, 15, 7, 3, 3, 1, 0, 2, 8, 17, 28, 40, 55, 72, 90, 108, 126, 145, 162, 178, 191, 203, 211, 217, 220, 221, 221, 219, 215, 211, 205, 200, 194, 189, 183, 176, 168, 161, 153, 144, 136, 127, 118, 110, 101, 92, 84, 76, 68, 61, 54, 49, 44, 40, 37, 35, 34, 35, 36, 39, 43, 47, 52, 58, 63, 70, 76, 82, 88, 94, 100, 105, 111, 116, 120, 125, 128, 132, 135, 138, 141, 144, 146, 148, 150, 152, 154, 155, 156, 156, 157, 157, 157, 156, 155, 154, 153, 151, 149, 147, 145, 142, 139, 136, 133, 130, 127, 123, 120, 117, 114, 111, 108, 105, 103, 101, 99, 97, 96, 95, 94, 93, 93, 92, 92, 92, 93, 93, 93, 94, 95, 95, 96, 97, 98, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 119, 120, 121, 121, 122, 122, 122, 123, 123, 123, 123, 124, 124, 124, 124, 124, 123, 123, 123, 123, 123, 122, 122, 122, 121, 121, 120, 120, 119, 119, 118, 118, 117, 117, 116, 116, 116, 115, 115, 115, 114, 114, 114, 113, 113, 113, 113, 112, 112, 112, 112, 112, 112, 112, 111, 111, 111, 111, 111, 111, 111, 112, 111, 112, 112, 112, 112, 112, 112, 112, 112, 112, 113, 113, 113, 113, 113, 113, 113, 113, 113, 114, 114, 114, 114, 114, 0
#elif MODE == HBEAT2
;HEARTBEAT2:
.db 120, 120, 119, 119, 117, 116, 115, 115, 98, 101, 122, 138, 143, 144, 150, 161, 176, 190, 193, 176, 145, 109, 74, 46, 28, 23, 17, 9, 7, 11, 19, 31, 44, 62, 80, 100, 123, 144, 162, 179, 193, 206, 215, 225, 237, 244, 246, 244, 247, 248, 245, 236, 224, 211, 196, 178, 158, 138, 118, 99, 80, 62, 47, 33, 21, 12, 5, 1, 1, 1, 4, 8, 14, 20, 27, 34, 40, 47, 54, 62, 70, 80, 89, 99, 110, 120, 130, 140, 150, 160, 169, 177, 186, 193, 199, 204, 208, 209, 210, 210, 209, 206, 203, 198, 193, 187, 181, 174, 166, 159, 151, 144, 137, 130, 124, 118, 113, 108, 104, 100, 97, 94, 91, 89, 87, 84, 83, 81, 80, 79, 78, 77, 77, 77, 77, 77, 78, 79, 80, 82, 84, 86, 89, 91, 94, 97, 101, 104, 107, 111, 114, 118, 121, 124, 127, 130, 132, 135, 137, 139, 140, 142, 143, 143, 144, 144, 145, 145, 144, 144, 144, 143, 143, 142, 141, 140, 139, 138, 137, 136, 135, 134, 133, 132, 130, 129, 128, 127, 126, 125, 124, 122, 121, 120, 119, 118, 117, 116, 116, 115, 114, 113, 113, 112, 111, 111, 111, 110, 110, 110, 110, 110, 110, 110, 111, 111, 111, 111, 112, 112, 112, 113, 113, 114, 114, 115, 115, 116, 116, 116, 117, 118, 118, 119, 119, 120, 120, 120, 121, 121, 122, 122, 122, 123, 123, 123, 123, 123, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 123, 123, 123, 123, 123, 123, 122, 122, 122, 122, 122, 122, 121, 121, 121, 121, 121, 121, 121, 121, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 119, 120, 0
#elif MODE == SINE
.db 1, 1, 2, 5, 9, 15, 21, 29, 37, 46, 56, 67, 79, 90, 103, 115, 128, 140, 152, 165, 176, 188, 199, 209, 218, 226, 234, 240, 246, 250, 253, 255, 255, 255, 253, 250, 246, 240, 234, 226, 218, 209, 199, 188, 176, 165, 152, 140, 127, 115, 103, 90, 79, 67, 56, 46, 37, 29, 21, 15, 9, 5, 2, 1, 0
#endif
