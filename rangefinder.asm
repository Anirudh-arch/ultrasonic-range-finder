//Ultrasonic Rangefinder. 
ORG 00H 
MOV P0, #0H //initializing p0 & p1 as output ports 
MOV P2, #0H 
MOV A, #38H //initializing lcd display as 2 rows and 
5x7 matrix. 
ACALL CMD //calling subroutine 'CMD' 
MOV A, #01H //clear LCD display 
ACALL CMD 
MOV A, #80H //move cursor to address '80H' 
ACALL CMD 
MOV DPTR,#FIRST //TO display the string 'ultrasonic' 
FIR: MOV A,#00H 
 MOVC A,@A+DPTR 
JZ OP 
ACALL DAT 
INC DPTR 
SJMP FIR 
OP: 
MOV A, #0C0H //TO display the string 'rangefinder' 
ACALL CMD 
MOV DPTR, #SECOND 
SEC: MOV A,#00H 
 MOVC A,@A+DPTR 
JZ OP1 
ACALL DAT 
INC DPTR 
SJMP SEC 
OP1: 
MOV R7,#10 // call delay of 1.42 sec 
RPT:LCALL DELAY2 
DJNZ R7,RPT 
 MOV A,#01H 
ACALL CMD 
MOV A,#80H 
ACALL CMD 
MOV DPTR,#DIST //to display the string 'Distance:' 
DIS: MOV A,#00H 
 MOVC A,@A+DPTR 
JZ OP2 
ACALL DAT 
INC DPTR 
SJMP DIS 
OP2: 
MOV A,#8DH //move cursor to display cms(centimeters) 
ACALL CMD 
MOV DPTR,#CMS 
CM: MOV A,#00H 
 MOVC A,@A+DPTR 
JZ OP4 
ACALL DAT 
INC DPTR 
SJMP CM 
// code for measuring distance using HCSR04 (ultrasonic sensor) 
OP4: 
CLR P3.0 
SETB P3.1 //initialize pin p3.1 as input port 
(echo pin) 
MOV TMOD,#00100000B //to initialize Timer1 in 8 bit auto 
reload mode 
MAIN: MOV TL1,#207D // store initial count value in TL1 
 MOV TH1,#207D //stores count reload value 
 MOV A,#00000000B 
 SETB P3.0 //sends a trigger of width 10us 
 ACALL DELAY1 
 CLR P3.0 
HERE: JNB P3.1,HERE //wait till echo becomes High 
BACK: SETB TR1 //start Timer1 
HERE1: JNB TF1,HERE1 //wait till overflow 
 CLR TR1 //stop timer 
 CLR TF1 //clear overflow flag 
 INC A //increments accumulator for every 
overflow 
OUT: JB P3.1,BACK //loops until echo becomes low 
 MOV R4,A //stores distance 
ACALL DLOOP 
 SJMP MAIN 
DLOOP: CLR P1.3 //subroutine for displaying value in 
LCD 
 CJNE R4,#16,GO 
 GO: JC GO1 
 SETB P1.3 
GO1: MOV A,#89H 
 ACALL CMD 
 MOV DPTR,#ASCII //lookup table for ASCII numbers 
 MOV A,R4 //to unpack the distance 
 MOV B,#100D 
 DIV AB 
 MOVC A,@A+DPTR 
 ACALL DAT 
 MOV A,B 
 MOV B,#10D 
 DIV AB 
 MOVC A,@A+DPTR 
 ACALL DAT 
 MOV A,B 
 MOVC A,@A+DPTR 
 ACALL DAT 
 MOV R5,#0FFH 
 L2:ACALL DELAY //Delay to make output data legible 
 DJNZ R5,L2 
 RET 
 CMD: CLR P3.5 //subroutine to send commands to LCD 
 CLR P3.6 
MOV P2,A 
SETB P3.7 
ACALL DELAY 
CLR P3.7 
RET 
DAT: SETB P3.5 //subroutine to send commands to 
LCD 
 CLR P3.6 
MOV P2,A 
SETB P3.7 
ACALL DELAY 
CLR P3.7 
RET 
DELAY1: MOV R6,#2D 
LABEL1: DJNZ R6,LABEL1 
 RET 
DELAY : MOV R1,#0FFH 
 L1: DJNZ R1,L1 
 RET 
DELAY2: MOV R1,#0FFH 
 L12: MOV R3,#0FFH 
L21: DJNZ R3,L21 
DJNZ R1,L12 
RET 
DIST: DB "Distance:",0 
FIRST: DB "Ultrasonic",0 
SECOND : DB "Rangefinder",0 
CMS: DB "cms",0 
ASCII : DB 30H,31H,32H,33H,34H,35H,36H,37H,38H,39H 
END
