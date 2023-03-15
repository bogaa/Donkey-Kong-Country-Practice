                       
					   rGameModePointer = $00001C           ;      |        
					   rMAP_currentPathID = $000002         ;      |        |      ;  
                       rFrameCounter00 = $000028            ;      |        |      ;  
                       rFrameCounter01 = $00002A            ;      |        |      ;  
                    
                       rEntranceID = $00003E                ;      |        |      ;  
 
;						oam 4c OAM_Slot_8_Offset size offset??
;						oam 4c OAM xy possition
;						oam 4e x y pos offset 
;						oam 52 slotOffset? 
;						oam 58
					   
					   rNorSpr_CurrentIndex = $000082       ;      |        |      ;  
                       ; child index for extra spawn 86 
						; 86 processing Entity slot Offset 
					rOAMIndex = $00008E                  ;      |        |      ;  
                       rLevelDataPointer24bitMap32 = $0000D3;      |        |      ;  
                       rCam1_Xpos = $0000BE                 ;      |        |      ;  
                       rCam1_Ypos = $0000C0                 ;      |        |      ;  
                       rLevelDataR5CMask = $0000D1          ;      |        |      ;  
                       rLevelCollusionD9Pointer01 = $0000D5 ;      |        |      ;  
                       rLevelCollusionD9Pointer02 = $0000D7 ;      |        |      ;  
                       rProgressionLeft_Xpos = $0000EF      ;      |        |      ;  
                       rProgressionRight_Xpos = $0000F1     ;      |        |      ;  
                       rPlayerSlopeFallModifyer = $0000F3   ;      |        |      ;  
                       rOAMBuffer = $000200                 ;      |        |      ;  
                       rHeldButtonsP1 = $000500             ;      |        |      ;  
                       rHeldButtonsP2 = $000502             ;      |        |      ;  
                       rPressedButtonsP1 = $000504          ;      |        |      ;  
                       rPressedButtonsP2 = $000506          ;      |        |      ;  
                       rHeldButtons = $00050E               ;      |        |      ;  
                       rPressedButtons = $000510            ;      |        |      ;  
                       rPlayerAnimalID = $000512            ;      |        |      ;  
                    ;   rPlDiddyAnimalID = $000514 
					  rScreenBlackFade = $00051A           ;      |        |      ;  
                       rScreenBlackFadeTimer = $00051B      ;      |        |      ;  
                       rPlayer_DisplayedBananaCount = $000529;      |        |      ;  
                       rPlayer_BananaCountOnesDigit = $00052B;      |        |      ;  
                       rPlayer_BananaCountTensDigit = $00052C;      |        |      ;  
                       rPlayer_BananaCountHundredsDigit = $00052D;      |        |      ;  
                       rLevel_ShowBananaCountTimer = $00052F;      |        |      ;  
                       rLevel_FreeMovementDebugFlag = $000535;      |        |      ;  
                       rLevelCompleationArray = $000538     ;      |        |      ;  
                       rLevel_GiveBackAnimalBuddyFlag = $00055D;      |        |      ;  
                       rCurrentLanguage = $000567           ;      |        |      ;  
                       rCheatCodeFlags = $00056B            ;      |        |      ;  
                       rFileSelect_WaitToFadeBackToIntroTimer = $00056D;      |        |      ;  
                       rPlayer_CurrentKong = $00056F        ;      |        |      ;  
                       rPlayer_AnimalTokenCount = $000571   ;      |        |      ;  
                       rPlayer_CurrentLifeCount = $000575   ;      |        |      ;  
                       rPlayer_DisplayedLifeCount = $000577 ;      |        |      ;  
                       rPlayer_Flag40Pause = $000579        ;      |        |      ;  
                       rPlayer_CurrentBananaCount = $00057B ;      |        |      ;  
                       rPlayer_CollectedKONGLetters = $00057F;      |        |      ;  
                       rFileSelect_CurrentSelection = $000581;      |        |      ;  
                       rLayer2_ModDonno = $000697           ;      |        |      ;  
                       rLayer1XPos = $00088B                ;      |        |      ;  
                       rLayer1YPos = $000895                ;      |        |      ;  
                       rNorSpr_CurrentOAMZPos = $000A7D     ;      |        |      ;  
                       rNorSpr_DrawOrderIndex = $000AB1     ;      |        |      ;  
                       rNorSpr_DisplayedPose = $000AE5      ;      |        |      ;  
                       rNorSpr_XPos = $000B19               ;      |        |      ;  
                       rNorSpr_OAMZPos = $000B8D            ; priority     |        |      ;  
                       rNorSpr_YPos = $000BC1               ;      |        |      ;  
                       rNorSpr_RAMTable0C35 = $000C35       ;      |        |      ;  
                       rNorSpr_LoByteYXPPCCCT_HighByteYXPPCCCT = $000C69;      |        |      ;  
                       rNorSpr_RAMTable0CDD = $000CDD       ;      |        |      ;  
                       rNorSpr_CurrentPose = $000D11        ;      |        |      ;  
                       rNorSpr_SpriteID = $000D45           ;      |        |      ;  
                       rNorSpr_Table0DB9 = $000DB9          ;      |        |      ;  
                       rNorSpr_Table0DED = $000DED          ;      |        |      ;  
                       rNorSpr_Table0E21 = $000E21          ;      |        |      ;  
                       rNorSpr_Table0E55 = $000E55          ;      |        |      ;  
                       rNorSpr_Table0EBD = $000EBD          ;      |        |      ;  
                       rNorSpr_YSpeed = $000EF1             ;      |        |      ;  
                       rNorSpr_Table0F25 = $000F25          ;      |        |      ;  
                       rNorSpr_Table0F59 = $000F59          ;      |        |      ;  
                       rNorSpr_Table0F8D = $000F8D          ;      |        |      ;  
                       rNorSpr_Table0FC1 = $000FC1          ;      |        |      ;  
                       rNorSpr_Table0FF5 = $000FF5          ;      |        |      ;  
                       rNorSpr_Table1029 = $001029          ;      |        |      ;  
                       rNorSpr_Table109D = $00109D          ;      |        |      ;  
                       rNorSpr_AnimationID = $0010D1        ;      |        |      ;  
                       rNorSpr_DisplayCurrentPoseTimer = $001105;      |        |      ;  
                       rNorSpr_AnimationSpeed = $001139     ;      |        |      ;  
                       rNorSpr_AnimationScriptIndex = $00116D;      |        |      ;  
                       rNorSpr_Table11A1 = $0011A1          ;      |        |      ;  
                       rNorSpr_Table11D5 = $0011D5          ;      |        |      ;  
                       rNorSpr_Table1209 = $001209          ;      |        |      ;  
                       rNorSpr_Table123D = $00123D          ;      |        |      ;  
                       rNorSpr_Table1271 = $001271          ;      |        |      ;  
                       rNorSpr_Table12A5 = $0012A5          ;      |        |      ;  
                       rNorSpr_Table12D9 = $0012D9          ;      |        |      ;  
                       rNorSpr_Table130D = $00130D          ;      |        |      ;  
                       rNorSpr_Table1341 = $001341          ;      |        |      ;  
                       rNorSpr_Table1375 = $001375          ;      |        |      ;  
                       rNorSpr_Table13E9 = $0013E9          ;      |        |      ;  
                       rNorSpr_Table145D = $00145D          ;      |        |      ;  
                       rNorSpr_Table1491 = $001491          ;      |        |      ;  
                       rNorSpr_Table14C5 = $0014C5          ;      |        |      ;  
                       rNorSpr_Table14F9 = $0014F9          ;      |        |      ;  
                       rNorSpr_Table152D = $00152D          ;      |        |      ;  
                       rNorSpr_Table1561 = $001561          ;      |        |      ;  
                       rNorSpr_Table1595 = $001595          ;      |        |      ;  
                       rNorSpr_Table15C9 = $0015C9          ;      |        |      ;  
                       rNorSpr_Table15FD = $0015FD          ;      |        |      ;  
                       rNorSpr_Table1631 = $001631          ;      |        |      ;  
                       rNorSpr_Table1665 = $001665          ;      |        |      ;  
                       ; 1a67 facing direction flag ffff 0000
					   rNorSpr_GraphicsDMATable = $00170F   ;      |        |      ;  
					   ; !DKC_DMA_REG_Enable_buffer = $1B03                  
					   rLevel_CameraYPos = $001A4C          ;      |        |      ;  
                       rLevel_CameraXPos = $001A62          ;      |        |      ;  
                       rSpritePaletteUploadTable = $001A8F  ;      |        |      ;  
                       rCurrentlyadedSpritePalettePtrs = $001AD3;      |        |      ;  
                       rJungleWeatherEffects = $001DF1      ;      |        |      ;  
      