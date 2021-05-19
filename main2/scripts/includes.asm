.data
MAP0:	1,1,1,1,1,1,0,1,1,0,1,
	1,1,1,1,7,0,0,1,1,0,1,
	0,1,1,1,1,1,0,1,1,1,1,
	0,0,1,1,1,1,0,1,1,1,1,
	0,0,0,0,1,1,0,1,1,1,7,
	0,0,0,0,0,0,2,0,1,0,0,
	0,1,1,0,0,0,0,0,0,0,0,
	1,1,1,1,0,0,0,1,1,0,0,
	1,1,1,1,0,0,0,1,1,1,0,
	1,1,1,1,8,0,0,0,1,1,0,
	1,1,1,1,1,1,0,0,0,0,0

ENEMY0_XY: 152,112

SKIP: .string "\n"
.text
li a7,1
la s3,ENEMY0_XY
lw s2,0(s3)
lw s3,4(s3)
#get point
	li t0,52
	sub t5,s2,t0
	srli t5,t5,4
	li t0,32
	sub s11,s3,t0
	srli s11,s11,4
	li t0,11
	mul s11,s11,t0
	add s11,s11,t5

la s1,MAP0
slli s11,s11,2
add s1,s1,s11

lb t1,0(s1)
li t0,5
mv t1,t0
sb t1,(s1)
la s1,MAP0

li t5,0
li t6,11
li t3,121
li t4,0
LOOP:
beq t4,t3,END
beq t5,t6,JUMP_LINE
lw a0,0(s1)
ecall
addi s1,s1,4
addi t5,t5,1
addi t4,t4,1
j LOOP
JUMP_LINE:
li a7,4
la a0,SKIP
ecall
li a7,1
li t5,0
j LOOP
END:
sb t4,DIR,t3