
;-----------------------------------------------------------------------------------------------------
; Special thanks to Rainbow and Mattrizzle for general infos about the game. Hacker Bogaa getting things broken..
;------------------------------------------------------------------------------------------------

hirom

; ------------------- features ---------------------------------------------------	
	!practiceEnable = 1
	!debugFeaturesVisability = 1		; disable this so the loading is closer to the vanilla game. When set it will keep alphabet in VRAM and not free the slot!
	!improvedDebuggScreen = 1 			; it is more aimed to give infos about speedruning
	
	!expandSRAM = 0

; ------------------- defines ---------------------------------------------------	
	!jumpTableAddress = $1c 
	!jumpTableE0 = $e0 
	!practiceModeVanilla = $7f8000 
	!practiceFrameStop = $7f8002 
	!scrapRam = $7f8004 
	!EntitySpawner = $7f8008 
	!EntitySpawner01 = $7f800A  
	!FramesDecimal = $7f800c
	!framCounterMirror = $7f800e	
	!MenuDrawOAMStart = $7f8010 
	!MenuIndex = $7f8012 
	!saveFlag = $7f8014
	!loadFlag = $7f8016
	!levelIDFailsave	= $7f8018
	!ok2LoadSaveState = $7f801a


	; PPU backupDefines they use different location depending on setting 0x800 0x1000 0x2000
	!BG1_tilemap = $D000			;
	!BG2_tilemap = $E000			;
	!BG3_tilemap = $F000			;
	!BG1_tilemap_backup = $7fD000
	!BG2_tilemap_backup = $7fE000
	!BG3_tilemap_backup = $7fF000
	;	!checkpointSwitchFlag = $7f8014			; unused 
	
	!DMA_CH1_Set = $4310
	!DMA_CH1_Bbus = $4311			; set to 18
	!DMA_CH1_AbusBank = $4314		; !DMA_CH5_AbusHi = $4313
	!DMA_CH1_AbusLo = $4312			
	!DMA_CH1_DAtaSizeLo = $4315		; !DMA_CH1_DataSizeHi = $4316
	
	!DMA_CH5_Set = $4350
	!DMA_CH5_Bbus = $4351			
	!DMA_CH5_AbusBank = $4354		
	!DMA_CH5_AbusLo = $4352			
    !DMA_CH5_DAtaSizeLo = $4355		


	!VRAM_Bus = $2118 				; lower 8 bit  	
	!VRAM_AddressLo = $2116			; !VRAM_AddressHi = $2117
	
	!DMA_Set_Enable_CHX = $420B  
	!HDMA_Set_Enable_CHX = $420C
; 3e levelType??
; e0-ee free zero page memory??
; $7ef9fc checkpoint table level entrance table 
; $7e7000 overwritable table used in loading?? 
incsrc code/labels.asm 

if !expandSRAM == 1
org $C0ffd8	
		db $03		; SRAM 2000 byte  ;007FD8

org $C0E9C0			; disable DRM protection 
		nop
		nop
org $C0E9D4
		nop
		nop 
endif 



org $FC35CA			; free Space overwrite German  org $FAE0A0
pushPC 

if !practiceEnable == 1 
incsrc code/practice.asm
endif 

pullPC
warnPC $FC5838		; check that we do not use too much space 


