# Print Image


.macro print_img(%sprite)
	la t0,%sprite # carregar o endereço de tela em t0
	lw t1, 0(t0) # x -> primeira word - inicia em 0xFF000000 e termina em 0xFF00013F
	lw t2, 4(t0) # y -> segunda word
	mul t3,t1,t2 # x * y para obter a área -> t3 = área
	addi t0,t0,8 # 0 é x, 4 é y, portanto em 8 começa a imagem
	li s0, 0xFF000000
	li s9,320 #dimensão máxima da tela
	sub t2,s9,t1
	add s0,s0,s10
	li t6,0 # t6 é um contador secundário que vai de até o valor de t1 (x) e retorna para 0
	li t4, 0 # contador de parada
IMPRIME:
	bge t4, t3, RETURN_PRINT
	bge t6,t1, NEW_LINE 
	lw t5, 0(t0)
	sw t5, 0(s0)
	pp(t0,4)
	pp(s0,4)
	pp(t4,4)
	pp(t6,4)
	j IMPRIME
NEW_LINE: 
	add s0,s0,t2
	li t6,0 # retornar t6 para 0 para recomeçar a contagem
	j IMPRIME
RETURN_PRINT:
.end_macro

.macro andar(%reg,%sprite) # posteriormente passar um %reg para andar() para ele checar o tipo de movimento
	# Checar se é para a direita
	li s3,RIGHT
	beq %reg,s3,CONTINUE
	li s3,UP
	beq %reg,s3,CONTINUE
	li s3,LEFT
	beq %reg,s3,CONTINUE
	li s3,DOWN
	beq %reg,s3,CONTINUE
	
	#j OUT
	
	CONTINUE:
	j CLEAR
	ANDAR_START:
	addi s10,s10,4
	print_img(%sprite)
	j RETURN_WALK
CLEAR:
	la t0,%sprite # carregar o endereço de tela em t0
	lw t1, 0(t0) # x -> primeira word - inicia em 0xFF000000 e termina em 0xFF00013F
	lw t2, 4(t0) # y -> segunda word
	mul t3,t1,t2 # x * y para obter a área -> t3 = área
	li s0, 0xFF000000
	add s0,s0,s10
	li s9,320 #dimensão máxima da tela
	sub t2,s9,t1
	li t6,0 # t6 é um contador secundário que vai de até o valor de t1 (x) e retorna para 0
	li t4, 0 # contador de parada
CLEAR_LOOP:
	bge t4, t3, ANDAR_START
	bge t6,t1, CLEAR_LINE
	lw t5,0xff00dc00
	sw t5, 0(s0)
	addi s0, s0, 4
	addi t4, t4, 4
	addi t6,t6,4
	j CLEAR_LOOP
CLEAR_LINE: 
	add s0,s0,t2
	li t6,0 # retornar t6 para 0 para recomeçar a contagem
	j CLEAR_LOOP
RETURN_WALK:
.end_macro
