LDI r1, 100
LDI r2, 200
LDI r3, 300
LDI r4, 144
PSH r4
LDI r4, 400
CAL 16
POP r0
LDI r1, 1234
LDI r2, 5678
LDI r3, 9101
LDI r4, 144
PSH r4
CAL 84
POP r0
HLT
PSH r1
LSP r1
ADI r1, 3
LDR r1, r1
STR IMR, r1
INC r1
STR SR, r1
INC r1
STR ERR, r1
INC r1
STR RET, r1
INC r1
STR PC, r1
INC r1
STR SP, r1
INC r1
STR r25, r1
INC r1
STR r24, r1
INC r1
STR r23, r1
INC r1
STR r22, r1
INC r1
STR r21, r1
INC r1
STR r20, r1
INC r1
STR r19, r1
INC r1
STR r18, r1
INC r1
STR r17, r1
INC r1
STR r16, r1
INC r1
STR r15, r1
INC r1
STR r14, r1
INC r1
STR r13, r1
INC r1
STR r12, r1
INC r1
STR r11, r1
INC r1
STR r10, r1
INC r1
STR r9, r1
INC r1
STR r8, r1
INC r1
STR r7, r1
INC r1
STR r6, r1
INC r1
STR r5, r1
INC r1
STR r4, r1
INC r1
STR r3, r1
INC r1
STR r2, r1
INC r1
MOV r2, r1
POP r1
STR r1, r2
RET
LSP r1
ADI r1, 2
LDR r1, r1
LDR IMR, r1
INC r1
LDR SR, r1
INC r1
LDR ERR, r1
INC r1
LDR RET, r1
INC r1
LDR PC, r1
INC r1
LDR SP, r1
INC r1
LDR r25, r1
INC r1
LDR r24, r1
INC r1
LDR r23, r1
INC r1
LDR r22, r1
INC r1
LDR r21, r1
INC r1
LDR r20, r1
INC r1
LDR r19, r1
INC r1
LDR r18, r1
INC r1
LDR r17, r1
INC r1
LDR r16, r1
INC r1
LDR r15, r1
INC r1
LDR r14, r1
INC r1
LDR r13, r1
INC r1
LDR r12, r1
INC r1
LDR r11, r1
INC r1
LDR r10, r1
INC r1
LDR r9, r1
INC r1
LDR r8, r1
INC r1
LDR r7, r1
INC r1
LDR r6, r1
INC r1
LDR r5, r1
INC r1
LDR r4, r1
INC r1
LDR r3, r1
INC r1
LDR r2, r1
INC r1
LDR r1, r1
RET
