.data
TESTE: 10,44

.text
	li a7,1
	la s0,TESTE
	lh a0,4(s0)
	ecall
	lh a0,0(s0)
	ecall