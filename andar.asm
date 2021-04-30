# Print Image
# %sprite passa o sprite que será movimentado
# %grid_reg passa o registrador que contém a informação de onde a imagem deve aparecer na tela
.eqv RIGHT 100
.eqv UP 119
.eqv LEFT 97
.eqv DOWN 115

.macro print_img(%sprite,%grid_reg)
	la t0,%sprite # carregar o endereço de tela em t0
	lw t1, 0(t0) # x -> primeira word - inicia em 0xFF000000 e termina em 0xFF00013F
	lw t2, 4(t0) # y -> segunda word
	mul t3,t1,t2 # x * y para obter a área -> t3 = área
	addi t0,t0,8 # 0 é x, 4 é y, portanto em 8 começa a imagem
	li s0, 0xFF000000
	li s9,320 #dimensão máxima da tela
	sub t2,s9,t1
	add s0,s0,%grid_reg
	li t6,0 # contador quebra de linha
	li t4, 0 # contador de parada
IMPRIME:
	bge t4, t3, BREAK_PRINT
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
BREAK_PRINT:
.end_macro

# %reg -> recebe o valor ASCII do input do teclado
# %sprite -> recebe o sprite que será movimentado
# %old_sprite -> recebe a imagem do back_ground que será reimpressa
# %x e %y serão passados para que o vetor deles seja gerado a partir deles.
# o movimento é computado de 4 em 4 pixels
.macro andar(%reg,%sprite,%old_sprite,%x,%y)
	# Os medidores de magnitude serão t0 e t1
	# t0 é a magnitude de X
	# t1 é a magnitude de Y
	# Checar se é para a direita
	# Resetando os valores de t0 e t1 para 0
	li t0,0
	li t1,0
	li s3,RIGHT
	bne %reg,s3,W_UP
	li t0,1
	W_UP:
	li s3,UP
	bne %reg,s3,W_LEFT
	li t1,-1
	W_LEFT:
	li s3,LEFT
	bne %reg,s3,W_DOWN
	li t0,-1
	W_DOWN:
	li s3,DOWN
	bne %reg,s3,COMPUT_MOVEMENT
	li t1,1
	
COMPUT_MOVEMENT:
	# Armazenar o valor do input do movimento em a1 para X e a2 para Y
	li a1,4
	mul a1,a1,t0
	li a2,4
	mul a2,a2,t1
	# Gerar vetor X por Y
	mul s10,%y,s9
	add s10,s10,%x
	j CLEAR
ANDAR_START:
	li s9,320
	# Incrementar X e Y com os valores de a1 e a2
	add %x,%x,a1
	add %y,%y,a2
	mul s10,%y,s9
	add s10,s10,%x
	print_img(%sprite,s10)
	j BREAK_WALK
CLEAR:
	la t0,%sprite # carregar o endereço do sprite em t0 apenas para passar para t1 e t2
	lw t1, 0(t0) # x -> primeira word - inicia em 0xFF000000 e termina em 0xFF00013F
	lw t2, 4(t0) # y -> segunda word
	mul t3,t1,t2 # x * y para obter a área -> t3 = área
	la t0,%old_sprite # carregar em t0 o valor do sprite anterior, para acessar as cores dele
	addi t0,t0,8
	li s0, 0xFF000000
	add s0,s0,s10
	li s9,320 # dimensão máxima da tela
	sub t2,s9,t1
	# Como X e Y não estão em vetor, posso facilmente achar a posição relativa do background em 240x240
	li s9,240
	mul s10,%y,s9
	li s9,40
	sub s9,%x,s9
	add s10,s10,s9
	add t0,t0,s10
	la s9,%old_sprite
	lw s9,0(s9) # armazenar em s9 o valor X do mapa
	sub s9,s9,t1 # subtrair X do sprite de X do mapa
	li t6,0 # contador quebra de linha
	li t4, 0 # contador de parada
CLEAR_LOOP:
	bge t4, t3, ANDAR_START
	bge t6,t1, CLEAR_LINE
	lw t5,0(t0)
	sw t5, 0(s0)
	pp(t0,4)
	pp(s0,4)
	pp(t4,4)
	pp(t6,4)
	j CLEAR_LOOP
CLEAR_LINE: 
	add s0,s0,t2
	add t0,t0,s9 # valor de line_break com retorno para o mesmo ponto inicial em X na linha seguinte
	li t6,0 # retornar t6 para 0 para recomeçar a contagem
	j CLEAR_LOOP
BREAK_WALK:
.end_macro


