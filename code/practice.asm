
; -----------------------------------------------------------------------------
; -------------------------------------------- hijacks ------------------------

if !debugFeaturesVisability == 1
org $FDF350						; leave text in VRAM 
        CPY.W #$000C			; #$0008                         ;FDF350|C00800  |      ;  
endif 


org $C0FE81				; freeSpace 	
	newNMIRoutine:		
		lda #newGameLoop		
		sta rGameModePointer	
		jmp.w (rGameModePointer)
		rti 

	newGameLoop:
		cli						; clear interrupts in this loop 
		lda #$1ff
		tcs 
		
		lda #newNMIRoutine
		sta rGameModePointer
		
		LDA #$80				; set data bank
		PHA     
		PLB     
		
;		lda #$0000				; chlear used channels 
;		sta $420B
		
		lda.l !saveFlag		
		beq +	
		jsl dmaSaveRoutineL
	+	lda.l !loadFlag		
		beq +		
		jsl dmaLoadRoutineL
	+

	-	wai
		bra -
;	-	
;		bra -
		
 
org $C080F2                      		 
		jsl saveFunctionEndFrame
		nop 


org $C09AFF
		jsl whilePauseHijack
		nop

org $C0F97A
		jsl easierMusicMenuInSaveSelect
		nop
		nop 
		
org $C0BC73			; init hijack 
		jml gameGetFullSaveFileAtInit
		nop 

org $F88340
;        STA.W $0579                          ;F88340|8D7905  |B50579;  force pause 
		nop
		nop
		nop 

org $c09b4f
		nop									; always exit with start select 
		nop 

org $C0E6BE
		JSL.L newLevelSelectRoutine          ;C0E6BE|22B08C81|818CB0;  hijack map screen


org $C0A1B1
        JSL.L practiceMain 					; CODE_B8B529                    ;C0A1B1|2229B5B8|B8B529;  		
	
org $B8F200									; free space in bank f8 probably!!	
	drawText2_OAM_Long:
		JSR.W $9C63				; textWriteRoutine  CODE_F89C63    
		rtl 
	drawText2_OAM_Long2:
		jsr $9CA4
		rtl
	
	menuText:
		db "MENU",$FF	
	livesText:
		db "LIVES",$FF 
	atText:
		db "@",$FF		
	emptyText:
		db "ERROR",$FF
	animalText:
		db "ANIMAL",$FF	
	bonusesText:
		db "BONUS",$FF 
	saveText:
		db "SAVE",$FF 
	loadText:
		db "LOAD",$FF 
		
; --------------------------------------------------------------------------------
pullPC		; -----------------------	; freeSpace  ------------------------------- 

	whilePauseHijack:							; bank fc 		
		phd
		php
		phy
		phx
		pha

		jsr drawTextWhilePause		
		jsr curserPos
		jsr menuAction
;		jsr saveFunctionEndFrame			

		pla
		plx
		ply
		plp
		pld

		DEC.B rFrameCounter00                ;C09AFF|C628    |000028;  hijack Fix 
        DEC.W $1E33                          ;C09B01|CE331E  |801E33;  
		rtl 

	
	drawTextWhilePause:
;		LDA.W #$0200                     ; make space in OAM table 
;       STA.B rOAMIndex                      
;		ldx #$01fe
;		lda #$0000
;	-	sta $200,x 
;		dex
;		dex
;		bpl -

		lda.l !MenuDrawOAMStart		; get the same oam offset for pause menu. Else it overflows since it is not cleard while pause.
		bne +		
		lda.w rOAMIndex 
		sta.l !MenuDrawOAMStart
	+	tay 		

		lda #$0000					; set starting possition to draw menu text 
		sta !scrapRam
		
	-	CPY.W #$03B8               ; slot about to overflow  
        BPL +

		lda.l !scrapRam		
		tax 
		lda.l menuRoutineTextTableYoffset,x 
		sta $004e
		lda.l menuRoutineTextTable,x 
		cmp #$ffff
		beq +
		pha 
		
		txa							; set next text pointer
		inc a
		inc a
		sta.l !scrapRam
		
		plx  
		jsl drawText2_OAM_Long
		bra -
	menuRoutineTextTable:	
		dw menuText,livesText,bonusesText,animalText,saveText,loadText,$FFFF
	menuRoutineTextTableYoffset:
		dw $0030,$0050,$0060,$0070,$0080,$0090
		
	+	CPY.W #$03B8               ; slot about to overflow  
        BPL +
		lda rPlayer_CurrentLifeCount		; add number infos 
		LDX.W #$50a0               ; xy dest    
        JSL.L $B89E78              ; draw 2 OAM     		
		
		CPY.W #$03B8               ; slot about to overflow  
        BPL +
		lda.l !EntitySpawner		; 
		LDX.W #$60a0               ; xy dest    
        JSL.L $B89E78              ; draw 2 OAM    
		
		CPY.W #$03B8               ; slot about to overflow  
        BPL +
		lda.l !EntitySpawner01		; 
		LDX.W #$70a0               ; xy dest    
        JSL.L $B89E78              ; draw 2 OAM    
		
		
	+	lda.l !MenuDrawOAMStart		; fix this in possition while pause. It can OVERFLOW!! 
		sta rOAMIndex 
		rts 
		
	curserPos:
		lda !MenuIndex
		and #$00f0
		clc 
		adc #$0050 					; yPos start
		sta $4e
		lda #$0050					; xPos 
		sta $4c 
		LDX.W #atText 
		jsl drawText2_OAM_Long2
		
		lda rPressedButtonsP1				; check down button 
		bit #$0400
		beq +
		lda.l !MenuIndex
		clc
		adc #$0011
		sta.l !MenuIndex
		
	+	lda rPressedButtonsP1				; check up button 
		bit #$0800
		beq +
		
		lda.l !MenuIndex
		sec
		sbc #$0011
		sta.l !MenuIndex		
		
	+	lda.l !MenuIndex					; set bounderies 
		bpl +
		lda #$0000
		sta.l !MenuIndex
	+	cmp #$0044							; max menues
		bmi +
		lda #$0044
		sta.l !MenuIndex
	+	rts 
	

	menuAction:
		lda !MenuIndex
		and #$000f
		asl 
		tax 
		lda.l menuActionRoutines,x 
		sta $02
		jmp.w ($02) 
		
	menuActionRoutines:
		dw menuAction00,menuAction01,menuAction02,menuAction03,menuAction04,menuAction05,menuAction06
	
	menuAction00:
		lda rPressedButtonsP1				
		bit #$0100
		beq +
		sed
		lda rPlayer_CurrentLifeCount
		clc 
		adc #$0001
		and #$00ff
		sta rPlayer_CurrentLifeCount
		cld

	+	lda rPressedButtonsP1				
		bit #$0200
		beq +
		sed
		lda rPlayer_CurrentLifeCount
		sec
		sbc #$0001
		and #$00ff
		sta rPlayer_CurrentLifeCount
		cld 
	+	lda rPressedButtonsP1				
		bit #$8000
		beq +
		jsr resetLevel
	+	rts 
	
	menuAction01:
		lda rPressedButtonsP1				
		bit #$0100
		beq +
		lda.l !EntitySpawner
		clc 
		adc #$0001
		sta.l !EntitySpawner

	+	lda rPressedButtonsP1				
		bit #$0200
		beq +
		lda.l !EntitySpawner
		sec
		sbc #$0001
		sta.l !EntitySpawner

	+	lda rPressedButtonsP1				
		bit #$8000
		beq +
	
		lda.l !EntitySpawner
		jsr spawnEntity_bonuses 	
	+	rts 
	menuAction02:
		lda rPressedButtonsP1				
		bit #$0100
		beq +
		lda.l !EntitySpawner01
		clc 
		adc #$0001
		sta.l !EntitySpawner01

	+	lda rPressedButtonsP1				
		bit #$0200
		beq +
		lda.l !EntitySpawner01
		sec
		sbc #$0001
		sta.l !EntitySpawner01

	+	lda rPressedButtonsP1				
		bit #$8000
		beq +
	
		lda.l !EntitySpawner01
		jsr spawnEntity_00 	
	+	rts 
		
		
	menuAction03:
		lda rPressedButtonsP1				
		bit #$8000
		beq +
		lda #$0001
		sta.l !saveFlag			
		sta.l !ok2LoadSaveState	
		lda rEntranceID
		sta.l !levelIDFailsave
		
	+	rts 

	menuAction04:
		lda rPressedButtonsP1				
		bit #$8000
		beq +
	
		lda.l !ok2LoadSaveState			; make sure Ram will not get overwritten with nothing 
		beq +
		
		lda #$0001							; stay in menue on load 
		sta.l !ok2LoadSaveState			; flag to quit pasue after 
		lda #$0001
		sta.l !loadFlag
		
	+	rts 
	menuAction05:
	menuAction06:
		rts  
		
	
	dmaSaveRoutineL:
		jsr.w dmaSaveRoutine
		rtl 
	dmaLoadRoutineL:
		jsr.w dmaLoadRoutine
		rtl 
	
;------ reset Jijack 2 execute save function form there -------------------------------------------------------
	saveFunctionEndFrame:                                                    						
		LDA.W #$80AB                        ; jijack fix 
        STA.B rGameModePointer              
		phd 								; backup data bank too 
		
		lda.l !saveFlag
		beq +

		lda #newNMIRoutine	
		STA.B rGameModePointer 
		
	+	lda.l !loadFlag		
		beq +
		
		lda #newNMIRoutine	
		STA.B rGameModePointer 
		
	+	pld 	
		rtl  

	dmaSaveRoutine:          				
		asl
		tax
		lda.l saveStateRoutines,x 
		sta !jumpTableE0 
		JMP.W (!jumpTableE0) 
		
	saveStateRoutines:
		dw $0000,bufferFrameSave,savePaletteAnim,saveFrame00,saveFrame01,saveFrame02,saveFrame03,saveFrame04_DMA,saveFrame05_DMA,saveFrame06_DMA,saveFrameFF 
	
	
	savePaletteAnim:
		lda.l $00102b 
		cmp #$0036				; water level check?? 
		beq +
		cmp #$002b
		beq +
		LDX.W #$0000   			; src							
		LDY.W #$e000   			; des 
		LDA #$15fe   			; size 
		MVN $7F,$7F  			; bank des src	
		
	+	jsr incSaveFlag		
		rts 
		
	saveFrame00:
		LDX.W #$0002   		; src								; methode without DMA is slow enough not to finish 1c00 bytes 
		LDY.W #$8100   		; des $7f8100
		LDA #$00FD   			; size 
		MVN $7F,$7E  			; bank des src	

		LDX.W #$0200   		; src								; methode without DMA is slow enough not to finish 1c00 bytes 
		LDY.W #$8200   		; des $7f8100
		LDA #$01ff   			; size 
		MVN $7F,$7E  			; bank des src	

		lda.l rJungleWeatherEffects		; will break colors when palette animations go on 
		bne +	

		sep #$20	
		ldx #$0000			; backup palettes 
		lda #$00
		sta.l $802121
	-	lda.l $80213b
		sta.l $7ffe00,x 
		inx
		cpx #$00200
		bmi - 
		
	+	rep #$30 

		jsr incSaveFlag		
		rts 

	saveFrame01:
		LDX.W #$0400   		; src
		LDY.W #$8400   		; des  $7f8200  $7f9E00				; next
		LDA #$08FF  			; size 
		MVN $7F,$7E  			; bank des src	
				
		jsr incSaveFlag		
		rts 

	saveFrame02:
		LDX.W #$0D00   		; src
		LDY.W #$8d00   		; des  $7f8200  $7f9E00				; next
		LDA #$08FF   			; size 
		MVN $7F,$7E  			; bank des src	
				
		jsr incSaveFlag		
		rts 

	saveFrame03:
		LDX.W #$1600   		; src
		LDY.W #$9600   		; des  $7f8200  $7f9E00				; next
		LDA #$09FF   			; size 
		MVN $7F,$7E  			; bank des src	
				
		jsr incSaveFlag		
		rts 

	saveFrame04_DMA:				
		sep #$20					; set A to 8 bit										
		rep #$10					; set x y to 16 bit 	 
		
		LDX.W #$5800     			; VRAM Target  
        STX.W !VRAM_AddressLo    	  
		LDA #$39        			; $2118 is the destination, so 39??
		STA !DMA_CH5_Bbus       

		LDX #$a000					; Source Offset 7fa000 - 7fffff 
		STX !DMA_CH5_AbusLo 	
		LDA #$7f  					; Source bank
		STA !DMA_CH5_AbusBank   	; Set Source address upper 8-bits
		LDX #$0fff					; # of bytes to copy (16k)
		STX !DMA_CH5_DAtaSizeLo 	      	   
 
		LDA #$81       			; Set DMA increment or decrement 
		STA !DMA_CH5_Set      	; using write mode 1 (meaning write a word to $2118/$2119)		
		LDA #%00100000        	; The registers we've been setting are for channel 0
		STA !DMA_Set_Enable_CHX
		
		rep #$30
		
		jsr incSaveFlag
		rts 		
	
	saveFrame05_DMA:				;  															;	7f8000 - 7fffff free
		sep #$20					; set A to 8 bit											;	7e3000 - 7e6fff ??? free			
		rep #$10					; set x y to 16 bit 										;	7ef9fc - 7fe1fb levelGFX decompression 																									;	7ef9fb
 
		LDX.W #$6800     			; VRAM Target  
        STX.W !VRAM_AddressLo    	  
		LDA #$39        			; $2118 is the destination, so 39??
		STA !DMA_CH5_Bbus       

		LDX #$b002					; Source Offset 
		STX !DMA_CH5_AbusLo 	
		LDA #$7f  					; Source bank
		STA !DMA_CH5_AbusBank   	; Set Source address upper 8-bits
		LDX #$1fff					; # of bytes to copy (16k)
		STX !DMA_CH5_DAtaSizeLo 	      	   
 
		LDA #$81       			; Set DMA increment or decrement 
		STA !DMA_CH5_Set      	; using write mode 1 (meaning write a word to $2118/$2119)		
		LDA #%00100000        	; The registers we've been setting are for channel 0
		STA !DMA_Set_Enable_CHX
		
		rep #$30
		jsr incSaveFlag
		rts 

	saveFrame06_DMA:				; backup 0000-2000 
		sep #$20					; set A to 8 bit												
		rep #$10					; set x y to 16 bit 	 
		
		LDX.W #$7800     			; VRAM Target   0000-1fff
        STX.W !VRAM_AddressLo    	  
		LDA #$39        			; $2118 is the destination, so 39??
		STA !DMA_CH5_Bbus       

		LDX #$d004					; Source Offset 7fb000 - 7fffff
		STX !DMA_CH5_AbusLo 	
		LDA #$7f  					; Source bank
		STA !DMA_CH5_AbusBank   	; Set Source address upper 8-bits
		LDX #$0fff					; # of bytes to copy (16k)
		STX !DMA_CH5_DAtaSizeLo 	      	   
 
		LDA #$81       			; Set DMA increment or decrement 
		STA !DMA_CH5_Set      	; using write mode 1 (meaning write a word to $2118/$2119)		
		LDA #%00100000        	; The registers we've been setting are for channel 0
		STA !DMA_Set_Enable_CHX
		
		rep #$30
		
		jsr incSaveFlag
		rts 		
	
	bufferFrameSave:
	incSaveFlag:
		lda.l !saveFlag
		inc a
		sta.l !saveFlag
		rts

	saveFrameFF:
		lda #$0000
		sta.l !saveFlag 

		sei						; set interupt again 
		lda #$80AB 
		STA.B rGameModePointer             		
		rts 
	
	dmaLoadRoutine:  	         				
		asl
		tax
		lda.l loadStateRoutines,x 
		sta !jumpTableE0 
		JMP.W (!jumpTableE0) 
		
	loadStateRoutines:
		dw $0000,bufferFrameLoad,loadPaletteAnim,loadFrame00,loadFrame01,loadFrame02,loadFrame03,loadFrame04_DMA,loadFrame05_DMA,loadFrame06_DMA,loadFrameFF

	loadPaletteAnim:			; breajs sine levels 
		lda.l $00102b 
		cmp #$0036				; water level check?? water level become corrupted FIXME!
		beq +
		cmp #$002b
		beq +
		
		LDX.W #$e000   			; src							
		LDY.W #$0000   			; des 
		LDA #$15fe   			; size 
		MVN $7F,$7F  			; bank des src	
		
	+	jsr incLoadFlag	
		rts 

	loadFrame00:				
		LDX.W #$8100				; src
		LDY.W #$0002   			; des
		LDA #$00FD   				; size 
		MVN $7E,$7F  				; bank des src	
		
		LDX.W #$8200				; src
		LDY.W #$0200   			; des
		LDA #$01ff   				; size 
		MVN $7E,$7F  				; bank des src	

		lda.l rJungleWeatherEffects
		bne +
		
		sep #$20	
		ldx #$0000					; FIXME sometime fails to load colors 
		lda #$00
		sta.l $802121
	-	lda.l $7ffe00,x 
		sta.l $802122		
		inx
		cpx #$00200
		bmi - 
		
	+	rep #$30 

	 	jsr incLoadFlag	
		rts 

	loadFrame01:
		LDX.W #$8400				; src
		LDY.W #$0400   			; des
		LDA #$08FF   				; size 
		MVN $7E,$7F  				; bank des src

		jsr incLoadFlag	
		rts 	

	loadFrame02:
		LDX.W #$8d00				; src
		LDY.W #$0D00   			; des
		LDA #$08FF   				; size 
		MVN $7E,$7F  				; bank des src

		jsr incLoadFlag
		rts 
	
	loadFrame03:
		LDX.W #$9600				; src
		LDY.W #$1600   			; des
		LDA #$09FF   				; size 
		MVN $7E,$7F  				; bank des src

		jsr incLoadFlag
		rts 

	loadFrame04_DMA:				; FIX ME!! to not make it wired offset you could just read VRAM bus $2118 once
		sep #$20					; set A to 8 bit
		rep #$10					; set x y to 16 bit  

		LDX.W #$5800     			; VRAM Target  
        STX.W !VRAM_AddressLo    	  
		LDA #$18        			; $2118 is the destination, so
		STA !DMA_CH5_Bbus       

		LDX #$a002					; Source Offset	
		STX !DMA_CH5_AbusLo 	
		LDA #$7f  					; Source bank
		STA !DMA_CH5_AbusBank   	; Set Source address upper 8-bits
		LDX #$0fff   				; # of bytes to copy (16k)
		STX !DMA_CH5_DAtaSizeLo   	      	   
 
		LDA #$01       			; Set DMA increment or decrement 
		STA !DMA_CH5_Set      	; using write mode 1 (meaning write a word to $2118/$2119)		
		LDA #%00100000        	; The registers we've been setting are for channel 0
		STA !DMA_Set_Enable_CHX	

		REP #$30 
		jsr incLoadFlag
		rts 

	loadFrame05_DMA:
		sep #$20					; set A to 8 bit
		rep #$10					; set x y to 16 bit   

		LDX.W #$6800     			; VRAM Target  
        STX.W !VRAM_AddressLo    	  
		LDA #$18        			; $2118 is the destination, so
		STA !DMA_CH5_Bbus       

		LDX #$b004					; Source Offset  
		STX !DMA_CH5_AbusLo 	
		LDA #$7f  					; Source bank
		STA !DMA_CH5_AbusBank   	; Set Source address upper 8-bits
		LDX #$1fff   				; # of bytes to copy (16k)
		STX !DMA_CH5_DAtaSizeLo 	      	   
 
		LDA #$01       			; Set DMA increment or decrement 
		STA !DMA_CH5_Set      	; using write mode 1 (meaning write a word to $2118/$2119)		
		LDA #%00100000        	; The registers we've been setting are for channel 0
		STA !DMA_Set_Enable_CHX	
		REP #$30
		
		jsr incLoadFlag
		rts 

		
	loadFrame06_DMA:
		sep #$20					; set A to 8 bit
		rep #$10					; set x y to 16 bit  

		LDX.W #$7800     			; VRAM Target  
        STX.W !VRAM_AddressLo    	  
		LDA #$18        			; $2118 is the destination, so
		STA !DMA_CH5_Bbus       

		LDX #$d006 				; Source Offset 7e3000
		STX !DMA_CH5_AbusLo 	
		LDA #$7f  					; Source bank
		STA !DMA_CH5_AbusBank   	; Set Source address upper 8-bits
		LDX #$0fff   				; # of bytes to copy (16k)
		STX !DMA_CH5_DAtaSizeLo   	      	   
 
		LDA #$01       			; Set DMA increment or decrement 
		STA !DMA_CH5_Set      	; using write mode 1 (meaning write a word to $2118/$2119)		
		LDA #%00100000        	; The registers we've been setting are for channel 0
		STA !DMA_Set_Enable_CHX	

		REP #$30 	
		
		jsr incLoadFlag
		rts 
		
;	loadCAMTrick:
;		lda $1a63
;		clc 
;		adc #$0002
;		sta $1a63 
;
;		jsr incLoadFlag
;		rts 

	bufferFrameLoad:
	incLoadFlag:
		lda.l !loadFlag
		inc a
		sta.l !loadFlag
		rts 

	loadFrameFF:
		lda #$0000
		sta.l !loadFlag
		
		lda.l !ok2LoadSaveState
		cmp #$0002
		bne +
		lda.l rPlayer_Flag40Pause
		eor #$0040
		sta.l rPlayer_Flag40Pause
	
	+	sei						; set interupt again 
		lda #$80AB 
		STA.B rGameModePointer           
		
		rts  
; ------end dma save load ---------------------------------------------------------------


	spawnEntity_00:
		bmi +
		cmp #$0004				; end of table we disable a lot since it is broken 
		bpl +
		asl
		tax 
		lda.l costumArrayEnemyPointer,x 
		bra ++
	-
	+ 	rts 
	spawnEntity_bonuses:
		bmi -
		cmp #$0015				; end of table 
		bpl -
		asl
		tax 
;		lda $b6bca8,x 		; get pointer bonuses 
		lda.l costumArrayBonusPointer,x 
	++	tay 
		jsl $b5804c			; spawner routine 
		
		ldx $86
		lda rPlayer_CurrentKong
		asl 
		tay
		lda.w rNorSpr_XPos,y 
		adc #$0040				; offset from Kong 
		sta.w rNorSpr_XPos,x 

		lda $1a67
		bpl +					; check direction to spawn in front
		lda.w rNorSpr_XPos,x 
		sbc #$0080
		sta.w rNorSpr_XPos,x 

	+	lda.w rNorSpr_YPos,y 
		sta.w rNorSpr_YPos,x 	
		rts 

	costumArrayEnemyPointer:
		dw $91b3,$91dd,$91c1,$91cf,$c683		 	; animal $91cf
;		dw $b413,$9955,$a471,$a411 			; enemy  $a51f,
;		dw $f841,$fa61,$f9bb,$f865,$f90d,$faaf,$fc55 ; bosses 
	costumArrayBonusPointer:
		dw $938F,$9155,$914B,$92A9
		dw $92EF,$9349,$A551,$A55D
		dw $A569,$A575,$A599,$A5AD
		dw $A5A3,$A5B7,$9227,$9255
		dw $E5A3,$E5D1,$E5FF,$E561,$E667

	resetLevel:
;		lda #$80ab				; dont know how to do a reset yet 
;		jml $808110

;		lda #$0001
;		eor.l !checkpointSwitchFlag
;		sta.l !checkpointSwitchFlag 
;		beq +
;		jsl $b6f6dd				; part of the checkpoint barrewl..
;		rts 
;	+	jsl $bcb963				; reset checkpoint 
		jsl $bcb963				; reset checkpoint 
		rts 



	
; ---------------------------------- end pause functions --------------------------

	practiceMain:							; runs when unpaused 
		lda #$0000							; clear pause menu OAM index 
		sta.l !MenuDrawOAMStart
		jsr enableVanillaDebuggScreens
		jsl executePracticeRoutines		
		jsr quickLoad
		jsl $B8B529 						; jijack Fix
		rtl 
	
	quickLoad:
		lda rHeldButtonsP1 
		bit #$0010
		beq +
		lda rPressedButtonsP1
		bit #$0040
		beq +		
		lda.l !ok2LoadSaveState			; make sure Ram will not get overwritten with nothing 
		beq +
		
		lda #$0002
		sta.l !ok2LoadSaveState			; flag to quit pasue after 
		
		lda #$0001
		sta.l !loadFlag
	
	+	rts

	enableVanillaDebuggScreens:
		lda rHeldButtonsP1					; hold button 
		bit #$0020
		beq ++
		
		lda rPressedButtonsP1				; check X button 
		bit #$0040
		beq +

		lda $535
		eor #$0001
		sta $535 
		
	+	lda rPressedButtonsP1
		bit #$0010
		beq ++
		lda.l !practiceModeVanilla
		clc
		adc #$0001
		sta.l !practiceModeVanilla
		cmp #$0005
		bmi ++
		lda #$0000
		sta !practiceModeVanilla
	++	rts 
	
	
	executePracticeRoutines:
		lda !practiceModeVanilla	
		asl 
		tax 
		lda.l practiceMenue,x 
		sta $02
		jmp.w ($02) 					

	practiceMenue:
		dw emptyPracticeRoutine,frameCounter,palleteDegugg,donkyProblem,hitBoxView,emptyPracticeRoutine

	emptyPracticeRoutine:
		rtl 
	donkyProblem:		; they could use rework..					
		jsl $B89B3F 
		rtl
	palleteDegugg:
;		jsl $F8830E	 
		jsl $F88313		; skip flag 
		rtl 
	hitBoxView:
		jsl $BCB13A  
		rtl 

	frameCounter:				
		lda rScreenBlackFade	; dont run dooring black fade
		cmp #$000f
		bmi +
		jsr confertFrames2Decimal 
		
	+	lda !scrapRam			; using a delay to stop timer ocne through transitions 
		beq +
		sec
		sbc #$0001
		sta !scrapRam
		bra ++

	+	lda rScreenBlackFade	; trigger time stop once screen fades starts 
		cmp #$000f
		beq ++
				
		lda !FramesDecimal
		sta !practiceFrameStop  
		lda #$0080
		sta !scrapRam 			; small cooldown to use the time stoper again  
		lda #$0000
		sta.l !FramesDecimal	; reset frameCounter for next section  
		
	++	LDY.B rOAMIndex                 
 
		TYA                             
        CMP.W #$03B8               ; slot free??     
        BPL +
;        LDA.W rFrameCounter01      ; src  
		lda.l !FramesDecimal
		LDX.W #$08b0               ; xy dest    
        JSL.L $B89E78              ; draw 2 OAM     

        LDA.l !practiceFrameStop                ; src  
        LDX.W #$08e0               ; xy dest    
        JSL.L $B89E78              ; draw 2 OAM     
 
	+	STY.B rOAMIndex   
		rtl 

	confertFrames2Decimal:
		lda rFrameCounter01
		cmp.l !framCounterMirror
		beq +
		
		sta.l !framCounterMirror	; add a frame once we advance a frame then update mirror for next check 
		sed
		lda.l !FramesDecimal		
		clc 
		adc #$0001
		sta.l !FramesDecimal
		cld 
	+	rts



;--------------------------------------------------------------------------
; ------- MAP Function ----------------------------------------------------
	newLevelSelectRoutine:				
;		lda rPressedButtonsP1
;		bit #$0010
;		beq +
;		lda rEntranceID
;		clc
;		adc #$0001
;		and #$00ff
;		sta rEntranceID
;	+	lda rPressedButtonsP1
;		bit #$0020
;		beq +
;		lda rEntranceID
;		sec
;		sbc #$0001
;		and #$00ff 
;		sta rEntranceID
;	+	lda rHeldButtons
;		cmp #$A000				; select + B will bring you to a plain 
;		bne +
;		lda #$00f6				; go funky 
;		sta rEntranceID
		
		lda.l !levelIDFailsave
		cmp rEntranceID
		beq +

		lda #$0000				; erase save when going to different levels 
		sta.l !ok2LoadSaveState
		
+		lda rHeldButtons
		cmp #$0030
		bne +
		lda #$00f6				; go funky 
		sta rEntranceID

	+	JSL.L $818CB0			; hijack fix 		
		rtl
;	levelOrder:
;		db $16, $0C, $01, $BF, $17, $E0, $D9, $2E, $07, $31, $42, $E1, $A5, 
;		db $A4, $D0, $43, $0D, $DE, $E5, $24, $6D, $A7, $3E, $14, $CE, $E2, 
;		db $40, $2F, $18, $22, $27, $41, $E3, $30, $12, $0A, $36, $2B, $E4, 
;		db $68


	gameGetFullSaveFileAtInit:
		STA.B $32                            ;C0BC73|8532    |000032;  
		
		ldx #$011e							; small loot so we have a full save file 
	-	lda.l saveFile,x 
		sta.l $b06000,x 
		dex
		dex
		bpl -
				
        LDA.W #$BC7B                         ;C0BC75|A97BBC  |      ; load initial game Pointer
		jml $C0BC78


	saveFile:
		db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $F2, $59, $0C, $03, $41, $52, $45, $52
		db $00, $08, $07, $73, $00, $16, $65, $00, $00, $8F, $00, $00, $00, $00, $00, $87
		db $00, $00, $07, $00, $07, $3F, $00, $00, $00, $00, $07, $00, $07, $00, $07, $07
		db $8F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $81, $00, $8F, $00, $00, $8F
		db $00, $00, $00, $87, $00, $00, $01, $0F, $83, $87, $00, $00, $00, $00, $07, $00
		db $00, $00, $00, $00, $00, $00, $01, $00, $9F, $07, $8F, $87, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $01, $00, $00, $00, $00, $8F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $8F, $00, $07
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $87, $00, $87, $00, $00, $00, $00, $00, $00, $00
		db $00, $03, $00, $00, $00, $00, $81, $00, $01, $81, $81, $81, $81, $01, $81, $81
		db $81, $01, $00, $00, $01, $81, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01
		
	easierMusicMenuInSaveSelect:		
		lda #$0009							; lunch music menu 
		sta $56b 

		INC.W $056D                          ;C0F97A|EE6D05  |80056D;  
        LDA.W $056D                          ;C0F97D|AD6D05  |80056D;  
		rtl
	
		
pushPC	

if !improvedDebuggScreen == 1 			; FIXME crashes when collecting Letters
org $FCB132
		nop
		nop 

org $FCB13A
	debugg_CamCollision: 				
		JSR.W $B102                    
		STY.B rOAMIndex                 		
		
		lda $56f		; selected player 
		asl
		tax 
		
		JSR.W CODE_FCB2FC               

        LDX.W #$0002                   
        JSR.W $B6E4                    
        JSL.L $BBA74D                  
        
		LDX.W #$0004                   
        JSR.W $B6E4                    
        JSL.L $BBA74D                  
		
		LDY.B rOAMIndex                 
	
		lda $56f		; selected player 
		asl
		tax 
		lda.w	$f25,x  
		LDX.W #$1404
		JSL.L $B89E78 
		STY.B rOAMIndex 		

		stz.w rPlayer_CollectedKONGLetters    ; prevent crash when getting letters

		rtl 
		;jmp $B1CF		; wired thing on the bottom 
	;	jmp $B255		
warnPC $FCB254		
	
org $fcb2fc
	CODE_FCB2FC: 
		LDY.B rOAMIndex                     
		LDA.W rNorSpr_XPos,x 
		phx 
		LDX.W #$0404                                         
		JSL.L $B89E78                   

;		LDX.W #$0C04                       		
		plx 
		LDA.W rNorSpr_YPos,x
		LDX.W #$0440                                         
		JSL.L $B89E78 
;		LDX.W #$04D8                   ; disable current level display
;		LDA.B rEntranceID              
;		JSL.L CODE_B89E78              
		STY.B rOAMIndex                
		RTS                                

endif 

; failed hijack attempts for save feature 
;org $C0A968
;		JML.L saveFunctionExecutionNMI                    ;C0A968|5C6CA980|80A96C; 
;org $C080AB
;		JML.L saveFunctionEndFrame 
;org $C080F7				; befor wait in frame used in mainGameLoop 
;	waitRoutine:
;		jmp hijackBeforeWait 
; org $C0FE81				; freeSpace 
;	hijackBeforeWait:		
;		jsl saveFunctionEndFrame
;	
;	-	WAI				; wait loop 
;		bra -

; failed palette dma 
;		LDA #$22        		; $2118 is the destination, so 39??
;		STA !DMA_CH5_Bbus       
;
;		LDX #$fe00 				; Source Offset 7fb000 - 7fffff
;		STX !DMA_CH5_AbusLo 	
;		LDA #$7f  				; Source bank
;		STA !DMA_CH5_AbusBank   ; Set Source address upper 8-bits
;		LDX #$01ff				; # of bytes to copy (16k)
;		STX !DMA_CH5_DAtaSizeLo 	      	   
; 
;		LDA #$81       			; Set DMA increment or decrement 
;		STA !DMA_CH5_Set      	; using write mode 1 (meaning write a word to $2118/$2119)		
;		LDA #%00100000        	; The registers we've been setting are for channel 0
;		STA !DMA_Set_Enable_CHX



; ------- unusedExampleCode: !!!!!!!!!!!!!!!
; --------------------------------------- setup broken !! FIXME attempt DMA WRAM
;		sep #$20					; set A to 8 bit
;		rep #$10					; set x y to 16 bit 
;		
;		LDX.w #$0002               	; Get lower 16-bits of source ptr
;		STX.w $4302              		
;		LDA #$c0       				; Get upper 8-bits of source ptr bank 
;		STA.w $4304              		
;		LDX.w #$2000              	; Set transfer size in bytes
;		STX.w $4305              		
;		LDX.w #$8100           		; Get lower 16-bits of destination ptr WRAM
;		STX.w $2181              		
;		LDA #$7f          			; Get upper 8-bits of dest ptr bank (only LSB is significant)
;		STA.w $2183              	
;		LDA #$80		              
;		STA.w $4301              	; DMA destination is $2180
;		STZ.w $4300              	; Write mode=0, 1 byte to $2180
;		LDA #$01               		; DMA transfer mode=auto increment
;		STA.w $420B              	; Initiate transfer using channel 0    	   
;		
;		rep #$30
;		jsr incSaveFlag	
;		rts 

;----------------------------------- WRAM PPU attempts 
;		sep #$20			; set A to 8 bit			setup broken !! FIXME
;		rep #$10			; set x y to 16 bit 

;		LDX #$9E00 			; Source Offset into source bank 
;		STX $4302       	; Set Source address lower 16-bits
;		LDA #$7f  			; Source bank
;		STA $4304       	; Set Source address upper 8-bits
;		LDX #$1000   		; # of bytes to copy (16k)
;		STX $4305       	; Set DMA transfer size
;		
;		LDA.B #$80       	; set dest  	    
;        STA.W $2115      	; VMAIN    	      	   
;        LDX.W #$D800     	; bg0 offset tilemap              	   
;        STX.W $2116      	; VRAM Address Registers (Low)     	   
;   	         	   		
;		LDA #$18        	; $2118 is the destination, so
;		STA $4301       	; set lower 8-bits of destination to $18
;		LDA #$01        	; Set DMA transfer mode: auto address increment
;		STA $4300       	;   using write mode 1 (meaning write a word to $2118/$2119)
;		LDA #$01        	; The registers we've been setting are for channel 0
;		STA $420B       	;   so Start DMA tra

; -------------------------------------------------------------------------------   	
;        LDA.B #$00     		; CPU > PPU	 increment 
;        STA.W $2115    		; VMAIN    	      	 
;        LDX.W #$d800  		; bg0 offset tilemap              	 
;        STX.W $2116    		; VRAM Address Registers (Low)     	 
;       
;		LDA.B #$7f     		 	 
;        LDX.W #$9E00 		; Load src Address    	
;        LDY.W #$1000 		; size              	 
;        STX.W $4302    		                      	 
;        STA.W $4304    		                      	 
;        STY.W $4305    		
;       
;	    LDA.B #$01     	    ; DMA Enable Register    	 
;        STA.W $4300    	             	 
;        LDA.B #$18     		; B Bus 	    	 
;        STA.W $4301    	                     	 
;        LDA.B #$01     	       	 
;        STA.W $420B 

		
;		rep #$30 


;		lda rPressedButtonsP1		; map out B not sure if needed??!
;		eor #$8000
;		sta rPressedButtonsP1


; free space mattrizzle   ; http://www.dkc-atlas.com/forum/viewtopic.php?f=2&t=2456#p43732

;007A21-007FFF (0x5DF bytes) 
;00FE81-00FFAF (0x12F bytes)
;0174BA-017FFF (0xB46 bytes)
;01F3E8-01FFFF (0xC18 bytes)    Very weird data; pattern doesn't exist in version 1.2
;02F7ED-02FFFF (0x813 bytes)
;04FDB2-04FFFF (0x24E bytes)
;08D9C1-08FFFF (0x263F bytes)   Duplicate sound sample data from 7C030
;0A6561-0A7FFF (0x1A9F bytes)   End of bank containing graphics and tilemap of Vine Valley (1st Map); contains fragment of early graphics!
;10E87C-10FFFF (0x1784 bytes)
;13E1A9-13FFFF (0x1E57 bytes)
;17FA3C-17FFFF (0x5C4 bytes)
;18EED0-18FFFF (0x1130 bytes)
;1CE9E0-1CFFFF (0x1620 bytes)

; ----------------------------------------------
	;RamLevelClear
	;50-100, 687-2000
; ----------------------------------------------

;org $C0BC75			 FAST LUNCH FAILS!!
;    LDA.W #$CCB6				;#$F894 			; #$BC7B                         ;C0BC75|A97BBC  |      ;  
;	jmp $DB75

;org $C0CC8E
;	LDA.W #$F894 			; LDA.W #$CCB6                    ;C0CC8E|A9B6CC  |      ;  


;	SetDataBankto80:		; better backup with stack 
;		SEP #$20		;Change data bank
;		LDA #$80
;		PHA     
;		PLB     
;		REP #$30
;		RTL
;     backupDB:
;		SEP #$20		;Change data bank
;		PHB
;		PLA 
;		STA !backupDB     
;		REP #$30
;		RTL 		
;	restoreDB:                                        
;		SEP #$20		;Change data bank
;		LDA !backupDB
;		PHA     
;		PLB     
;		REP #$30
;		RTL
	



; ----------------------------------------------	
; Mattrizzle Cutting debug leftover open 
;org $C0A1B1				; Camera & Collision Debug	; 084C: Camera's X-coordinate.	
;	jsl $BCB13A                                         ; 0118: Camera's Y-coordinate.
		                                                ; 0042: Level ID - RAM $3E
		                                                ; 0032: DK's current sprite ID - RAM $0D13 divided by 4
														; C000, 3274, 3288, ADFC, D225: Unknown data.
                                                        ; FFF1, FFDD: Relative X and Y coordinates of Donkey Kong's collision box.     
														; 0018, 0022: Width and height of Donkey Kong's collision box.
                                                        ; 0016: Unknown data.		


;org $C0A1B1				; DK's Problem Page   		; First two rows: The last 16 bytes of save RAM.
;   jsl $B89B3F                                     ; Third row: Level ID. - RAM $3E
														; Fourth row: ID of last exit taken. - RAM $40
														; Fifth row: Level status variable (see notes page for details) - RAM $1E15
														; Sixth row: Level ID for Continue Barrel - RAM $2E
														
													
;org $C0A1B1				; Level Completion Debug	; First row: Always 0000. In the promotional video it's 0811, which is probably a build date.	
;	jsl $F89D6B	                                        ; Second row: Level ID. - RAM $3E
;org $F89D72                                            ; Third row: First byte shows the number of completed rooms. This counts the bonus rooms and the level exit. 
;	db $80                                              ; The second byte is the total number of completable rooms in the level
	

;org $C0A1B1				; Palette Debug												
;	jsl $F8830E 
;
;org $F88311					; glag to not use this debug menu 
;	db $d0 

;org $F88340	
;	db $4d 						; pause force 
	
;		jsl $B89B3F				; unaqurate notes .. 
;		oam ID 20-27 0-7	atr 32
;			ID 30-37 8-f

;		oam ID 80-89 0-9	atr 30
;			ID 8A-90 :=?-./@
;			ID 91-9F A-O 
;			ID A2-AF R-Z!$&'

	
              
;		
;;		STY.B rOAMIndex    
;		rts 
;
;     textWriteRoutine: 						; CODE_F89C63
;		PHK                                 
;        PLB                                 
;        PHX                                 
;        JSR.W CODE_F89CAD                   
;        PLX                                 
;        LDA.W #$0100                        
;        SEC                                 
;        SBC.B $4C                           
;        LSR A                               
;        STA.B $4C                           
;        BRA CODE_F89CA4                     
;                                             
;                                             
;    CODE_F89C75: 
;		INX                                 
;        AND.W #$00FF                        
;        TAY                                 
;        LDA.W asciiTable,Y             
;        AND.W #$00FF                        
;        BEQ CODE_F89C9C                     
;        LDY.B rOAMIndex                     
;        CLC                                 
;        ADC.W #$0080                        
;        ORA.W #$3000                        
;        STA.W rMAP_currentPathID,Y          
;        LDA.B $4E                           
;        XBA                                 
;        ORA.B $4C                           
;        STA.W $0000,Y                       
;        INY                                 
;        INY                                 
;        INY                                 
;        INY                                 
;        STY.B rOAMIndex                     
;                                             
;	CODE_F89C9C: 
;		LDA.B $4C                           
;        CLC                                 
;        ADC.W #$0008                        
;        STA.B $4C                           
;                                             
;	CODE_F89CA4: 
;		LDA.W $0000,X                       
;        BIT.W #$0080                        
;        BEQ CODE_F89C75                     
;        RTS                                 
;                                             
;                                             
;	CODE_F89CAD: 
;		STZ.B $4C                           
;        BRA CODE_F89CBA                     
;                                             
;                                             
;	CODE_F89CB1: 
;		INX                                 
;        LDA.B $4C                           
;        CLC                                 
;        ADC.W #$0008                        
;        STA.B $4C                           
;                                             
;	CODE_F89CBA: 
;		LDA.W $0000,X                       
;        BIT.W #$0080                        
;        BEQ CODE_F89CB1                     
;        RTS                                 
;	asciiTable:
;		db $00,$00,$00,$00,$00,$00,$00,$00   ;F89CC3|        |      ;  
;		db $00,$00,$00,$00,$00,$00,$00,$00   ;F89CCB|        |      ;  
;		db $00,$00,$00,$00,$00,$00,$00,$00   ;F89CD3|        |      ;  
;		db $00,$00,$00,$00,$00,$00,$00,$00   ;F89CDB|        |      ;  
;		db $00,$2B,$2E,$0C,$2C,$0C,$2D,$2E   ;F89CE3|        |      ;  
;		db $0C,$0C,$0C,$0C,$2F,$0D,$0E,$0F   ;F89CEB|        |000C0C;  
;		db $00,$01,$02,$03,$04,$05,$06,$07   ;F89CF3|        |      ;  
;		db $08,$09,$0A,$0C,$0C,$0C,$0C,$0C   ;F89CFB|        |      ;  
;		db $10,$11,$12,$13,$14,$15,$16,$17   ;F89D03|        |F89D16;  
;		db $18,$19,$1A,$1B,$1C,$1D,$1E,$1F   ;F89D0B|        |      ;  
;		db $20,$21,$22,$23,$24,$25,$26,$27   ;F89D13|        |F82221;  
;		db $28,$29,$2A,$0C,$0C,$0C,$0C,$0C   ;F89D1B|        |      ;  
;		db $0C,$11,$12,$13,$14,$15,$16,$17   ;F89D23|        |001211;  
;		db $18,$19,$1A,$1B,$1C,$1D,$1E,$1F   ;F89D2B|        |      ;  
;		db $20,$21,$22,$23,$24,$25,$26,$27   ;F89D33|        |F82221;  
;		db $28,$29,$2A,$0C,$0C,$0C           ;F89D3B|        |      ;  	
;		
;		
;		