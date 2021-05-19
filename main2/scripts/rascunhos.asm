.data
LENGTH: .word 121
MATRIZ: 1,1,1,1,1,1,0,1,1,0,1,
	1,1,1,1,0,0,0,1,1,0,1,
	0,1,1,1,1,1,0,1,1,1,1,
	0,0,1,1,1,1,0,1,1,1,1,
	0,0,0,0,1,1,0,1,1,1,0,
	0,0,0,0,0,0,0,0,1,0,0,
	0,1,1,0,0,0,0,0,0,0,0,
	1,1,1,1,0,0,0,1,1,0,0,
	1,1,1,1,0,0,0,1,1,1,0,
	1,1,1,1,0,0,0,0,1,1,0,
	1,1,1,1,1,1,0,0,0,0, 0

SKIP: .string "\n"
SPACE: .string " "

.text
la s1,LENGTH
lw s2,0(s1)
la s1,MATRIZ
li t0,0
li t1,0 # contador de quebra de linha
li t2,11
li a7,1
LOOP:
beq t0,s2,EXIT
beq t1,t2,LINE_BREAK
li a7,1
lb a0,0(s1)
ecall
li a7,4
la a0,SPACE
ecall
addi s1,s1,4
addi t0,t0,1
addi t1,t1,1
j LOOP
LINE_BREAK:
	li a7,4
	la a0,SKIP
	ecall
	li a7,1
	li t1,0
	j LOOP
EXIT:
	la s1,LENGTH
	lw s2,0(s1)
	la s1,MATRIZ
	li t0,11
	slli t0,t0,2
	lb a0,0(s1)
	li a7,1
	ecall
