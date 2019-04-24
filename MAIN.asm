;LED=60-65H
;ADC=8-CH
;STA=70-7EH

ORG 0000H
AJMP JUDGE

ORG 000BH	   
AJMP TIMER0ISR

ORG 0010H
DB 	0E8H,0E9H,0EAH,0EDH

ORG 001BH		  
AJMP TIMER1ISR

ORG 002BH	   
AJMP ADCISR

ORG 003BH	   
AJMP PWMISR

	   
JUDGE:
DJNZ ACC,$
JNB 0B7H,NORMAL
JNB 0B5H,INITT
SJMP $
INITT:LJMP INIT

NORMAL:
MOV 0C7H,#83H
MOV 0C5H,#1
MOV R0,#6FH
MOV R2,#0EH
READ:INC R0
MOV 0C6H,#5AH
MOV 0C6H,#0A5H
NOP
INC 0C4H
MOV @R0,0C2H
DJNZ R2,READ
MOV 0C5H,#0
MOV 0C7H,#0
MOV 0C6H,#0
MOV 0C4H,#0

MOV 81H,#30H   ;SPSET

MOV 0A8H,#0AAH	;IE-ADC,T0,1
MOV 0B7H,#0A0H  ;IPH-PCA,ADC
SETB 0B9H	   ;IP-T0
MOV 9DH,#67H   ;ADCP1.0-2,5,6
MOV 96H,#0FCH  ;P2P2-7

MOV 89H,#2	   ;TIMER0SET

MOV 0D9H,#08H  ;PWMCLK
;MOV 0DAH,#53H ;PWMMODE
MOV 0DBH,#53H
MOV R6,#2
MOV R1,#6
MOV 0A0H,#0FDH	   
;MOV 0FAH,#80H ;DUTY
MOV 0FBH,#080H

SETB 0DEH	   ;PWMSTR
SETB 8CH	   ;TIMER0STR
SETB 8EH	   ;TIMER1STR
sjmp $

TIMER0ISR:			  ;R4,R1,R0   
MOV 80H,#0FFH
DJNZ R1,NEXTLI
MOV R1,#6
MOV 0A0H,#0FDH
NEXTLI:PUSH ACC
MOV R4,0A0H
MOV 0A0H,#0FFH
MOV A,R1
ADD A,#5FH
MOV R0,A
MOV 80H,@R0
MOV A,R4
RL A
MOV 0A0H,A
POP ACC
RETI

CURRENTH:CLR 0AFH
MOV 0A0H,#0E0H
MOV 80H,#80H
ACALL HALT
HALTC:MOV R0,#0
MOV R1,#10H
LLL:DJNZ ACC,$
DJNZ R0,LLL
DJNZ R1,LLL
CPL 0A0H
SJMP HALTC

POWERH:CLR 0AFH
MOV 0A0H,#1EH
MOV 80H,#80H
ACALL HALT
SJMP $

POWERL:CLR 0AFH
MOV 0A0H,#0
MOV 80H,#0BFH
ACALL HALT
HALTL:MOV R0,#0
MOV R1,#80H
LL:DJNZ ACC,$
DJNZ R0,LL
DJNZ R1,LL
CPL 0A0H
SJMP HALTL

HALT:MOV 0BCH,#0		 ;ADCPOWERDOWN
MOV 0FAH,#0		 ;PWMOUT-1
MOV 0FBH,#0
MOV 0EAH,#0
MOV 0EBH,#0
CLR A
RET

TIMER1ISR:
CLR C
MOV A,78H
SUBB A,0BH
JC CURRENTH
MOV A,70H
SUBB A,8
JC	POWERH
MOV A,8
SUBB A,71H
;JC POWERL

MOV A,0AH
MOV B,75H
DIV AB
JZ LS10V
MOV 60H,#0F9H
MOV A,B
MOV B,7AH
DIV AB
ACALL TRAN
ANL A,#7FH
MOV 61H,A
MOV A,B
MOV B,7BH
DIV AB
ACALL TRAN
MOV 62H,A
LS10V:MOV A,B
MOV B,7AH
DIV AB
ACALL TRAN
ANL A,#7FH
MOV 60H,A
MOV A,B
MOV B,7BH
DIV AB
ACALL TRAN
MOV 61H,A
MOV A,B
MOV B,7CH					  
DIV AB
ACALL TRAN
MOV 62H,A

MOV A,0BH
SUBB A,76H
MOV B,77H
DIV AB
ACALL TRAN
ANL A,#7FH
MOV 63H,A
MOV A,B
MOV B,7DH
DIV AB
ACALL TRAN						
MOV 64H,A
MOV A,B
MOV B,7EH
DIV AB
ACALL TRAN						
MOV 65H,A

MOV A,0CH		   ;TUNE-VALUE
MOV B,79H        ;(15V-9V)
MUL AB
MOV A,B
ADD A,73H
MOV R3,A
RETI

ADCISR:      	 ;A,R7,R0
PUSH ACC
MOV A,R7	   ;SAVERES
ADD A,#7
MOV R0,A
MOV @R0,0BDH
DJNZ R7,FF
MOV 0BCH,#0E6H	   ;ADCPAUSE
PUSH 0D0H	   ;RETRO-DUTY
MOV A,9
CLR C
SUBB A,72H
ADD A,0FBH
MOV 0FBH,A
MOV A,0AH
CLR C
SUBB A,R3
ADD A,0FAH
MOV 0FAH,A
POP 0D0H
POP ACC
RETI
FF:MOV DPTR,#7 ;NEXTADC
MOVC A,@A+DPTR
MOV 0BCH,A
DEC R7
POP ACC
RETI

PWMISR:      	      ;R6,R7
DJNZ R6,EE
MOV R7,#5
MOV 0BCH,#0EEH ;ADCSE&ST
;MOV 0DBH,#53H  ;???
MOV R6,#2
EE:CLR 0D8H
CLR 0D9H
RETI

TRAN:MOV DPTR,#0250H
MOVC A,@A+DPTR
RET




INIT:
MOV 81H,#30H   ;SPSET

MOV R1,#6
MOV 0A8H,#82H	;IE-T0
MOV 9DH,#67H   ;ADCP1.0-2,5,6
MOV 96H,#0FCH  ;P2P2-7
MOV 89H,#2	   ;TIMER0SET
SETB 8CH	   ;TIMER0STR
MOV R7,#0FEH
SJMP DECT

LEDDON:MOV 63H,#0A1H
MOV 64H,#0A3H
MOV 65H,#0ABH
DECT:MOV 0BCH,#0EEH
NOP
NOP
NOP
NOP
WAIT:MOV A,0BCH
JNB 0E4H,WAIT
MOV A,0BDH
MOV 0BCH,#80H
SUBB A,#18H
JC BSTART
SUBB A,#0D0H
JNC BSAVE
SJMP DECT


BSTART:MOV A,R7
JB 0E0H,DECT
INC R7
INC R7
MOV 63H,#92H		 ;LSTR
MOV 64H,#87H
MOV 65H,#88H
MOV A,R7
MOV DPTR,#0260H
JMP @A+DPTR

BSAVE:MOV A,R7
JNB 0E0H,DECT
INC R7
MOV 63H,#92H		  ;LSAV
MOV 64H,#88H
MOV 65H,#0C1H
MOV A,R7
MOV DPTR,#0300H
JMP @A+DPTR

ORG 0250H
DB 0C0H,0F9H,0A4H,0B0H,99H,92H,82H,0F8H,80H,90H

ORG 0260H
AJMP STAPH
AJMP STAPL
AJMP STAFIV
AJMP STATNIV
AJMP STATFIFV;(SAVE6V)
AJMP STATEV
AJMP STAZRA
AJMP STAONA
AJMP STACOPTA

STAPH:MOV 60H,#8CH
MOV 61H,#0F9H
MOV 62H,#0B0H
DEC R7
AJMP DECT
STAPL:MOV 60H,#8CH
MOV 61H,#0C0H
MOV 62H,#82H
DEC R7
AJMP DECT
STAFIV:MOV 60H,#0A3H
MOV 61H,#92H
MOV 62H,#0C1H
DEC R7
AJMP DECT
STATNIV:MOV 61H,#0C0H
MOV 62H,#90H
DEC R7
AJMP DECT
STATFIFV:MOV 61H,#0F9H;(SAVE6V)
MOV 62H,#92H
DEC R7
AJMP DECT
STATEV:MOV 61H,#0F9H
MOV 62H,#0C0H
DEC R7
AJMP DECT
STAZRA:MOV 60H,#88H
MOV 61H,#0C0H
MOV 62H,#88H
DEC R7
AJMP DECT
STAONA:MOV 61H,#0F9H
DEC R7
AJMP DECT
STACOPTA:MOV 60H,#0C6H
MOV 61H,#79H
MOV 62H,#0A4H
DEC R7
AJMP DECT


ORG 0300H
AJMP SSTAPH
AJMP SSTAPL
AJMP SSTAFIV
AJMP SSTATNIV
AJMP SSTATFIFV;(SAVE6V)
AJMP SSTATEV
AJMP SSTAZRA
AJMP SSTAONA
AJMP SSTACOPTA
WAITADC:MOV A,0BCH
JNB 0E4H,WAITADC
MOV A,0BDH
MOV 0BCH,#80H
RET


SSTAPH:MOV 0BCH,#0E8H
ACALL WAITADC
MOV 70H,A
AJMP LEDDON
SSTAPL:MOV 0BCH,#0E8H
ACALL WAITADC
MOV 71H,A
AJMP LEDDON
SSTAFIV:MOV 0BCH,#0E9H
ACALL WAITADC
MOV 72H,A
AJMP LEDDON
SSTATNIV:MOV 0BCH,#0EAH
ACALL WAITADC
MOV 73H,A
AJMP LEDDON
SSTATFIFV:MOV 0BCH,#0EAH;(SAVE6V)
ACALL WAITADC
MOV 74H,A
AJMP LEDDON
SSTATEV:MOV 0BCH,#0EAH
ACALL WAITADC
MOV 75H,A
AJMP LEDDON
SSTAZRA:MOV 0BCH,#0EDH
ACALL WAITADC
MOV 76H,A
AJMP LEDDON
SSTAONA:MOV 0BCH,#0EDH
ACALL WAITADC
MOV 77H,A
AJMP LEDDON
SSTACOPTA:MOV 0BCH,#0EDH
ACALL WAITADC
MOV 78H,A

MOV 60H,#88H
MOV 61H,#0CFH
MOV 62H,#0CFH
MOV 63H,#0C6H	 ;CHE
MOV 64H,#89H
MOV 65H,#86H
MOV A,74H
SUBB A,73H
MOV 79H,A			 ;STA-T-6V
MOV A,77H			 ;STA-1A-RERI
SUBB A,76H
MOV 77H,A
MOV B,#0AH
DIV AB
MOV 7DH,A		 ;STA-0.1A
MOV B,#0AH
DIV AB
MOV 7EH,A		  ;STA-0.01A
MOV A,75H
MOV B,#0AH
DIV AB
MOV 7AH,A         ;STA-1V
MOV B,#0AH
DIV AB
MOV 7BH,A		;STA-0.1V
MOV B,#0AH
DIV AB
MOV 7CH,A		  ;STA-0.01V

MOV 0C7H,#83H
MOV 0C5H,#3
MOV 0C6H,#5AH
MOV 0C6H,#0A5H
NOP
MOV 0C5H,#2
MOV R0,#6FH
MOV R2,#0EH
PROGRAM:INC R0
MOV 0C2H,@R0
MOV 0C6H,#5AH
MOV 0C6H,#0A5H
NOP
INC 0C4H
DJNZ R2,PROGRAM
MOV 0C5H,#0
MOV 0C7H,#0
MOV 63H,#0A1H
MOV 64H,#0A3H
MOV 65H,#0ABH
SJMP $

end
