	!jumpTableAddress = $1c 
	; $1e2b win screen  ; 01 win, 02 lose, 03, win continue 04 leave
	!practiceModeVanilla = $7f8000 
		
;00056C,Flags, 09 music menu in save select 


org $C0A1B1
        JSL.L practiceMain 					; CODE_B8B529                    ;C0A1B1|2229B5B8|B8B529;  		
		

pullPC										; freeSpace 
	practiceMain:
		jsr enableVanillaDebuggScreens
		jsl executePracticeRoutines

		
		jsl $B8B529 						; jijack Fix
		rtl 
	
	-	rts 
	enableVanillaDebuggScreens:
		lda rHeldButtons					; hold button 
		bit #$0020
		beq -
		
		lda rPressedButtonsP1				; check down button 
		bit #$0040
		beq +

		lda $535
		eor #$0001
		sta $535 
		
	+	lda rPressedButtonsP1
		bit #$0010
		beq +
		lda.l !practiceModeVanilla
		clc
		adc #$0001
		sta.l !practiceModeVanilla
		cmp #$0004
		bmi +
		lda #$0000
		sta !practiceModeVanilla
	+	rts 
	
	
	executePracticeRoutines:
		lda !practiceModeVanilla
		beq ++
		cmp #$0001
		bne +
		jsl $BCB13A   
		bra ++
	+	cmp #$0002
		bne +
		jsl $B89B3F 
		bra ++	
	+	cmp #$0003
		bne ++
		jsl $F8830E	 	  
	++	rtl 


pushPC	



;org $C0BC75
;    LDA.W #$CCB6				;#$F894 			; #$BC7B                         ;C0BC75|A97BBC  |      ;  
;	jmp $DB75

;org $C0CC8E
;	LDA.W #$F894 			; LDA.W #$CCB6                    ;C0CC8E|A9B6CC  |      ;  





	

;org $C0A1B1				; Camera & Collision Debug		; 084C: Camera's X-coordinate.	
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
org $F88311
	db $d0 

org $F88340	
	db $4d 