# Print Image
# %sprite passa o sprite que será movimentado
# %grid_reg passa o registrador que contém a informação de onde a imagem deve aparecer na tela
.eqv RIGHT 100
.eqv UP 119
.eqv LEFT 97
.eqv DOWN 115
.eqv FOUR 4
.eqv ESC 27
.eqv R 114

# Objetivo da macro de printar sprite:
# Printar ao mesmo tempo em que cuida da animação
# Os sprites serão no formato "strip"
# Onde todos os sprites de movimento ficam em uma mesma imagem
# %state é para saber se o "objeto" está andando ou parado
# %dir é para saber a direção para a qual o sprite está indo (passar 
# ---> Provável que eu tenha que modificar o script de clear
.macro animate_sprite(%sprite,%grid_reg,%state,%dir,%x,%y)
	la t0,%sprite # carregar o endereço do sprite em t0 apenas para passar para t1 e t2
	lw t1, 0(t0) # x -> primeira word - inicia em 0xFF000000 e termina em 0xFF00013F
	lw t2, 4(t0) # y -> segunda word
	mul t3,t2,t2 # y * y para obter a área -> t3 = área (16x16)
	addi t0,t0,8
	# Definir a posição inicial da imagem na tela
	li s0, 0xFF000000
	add s0,s0,%grid_reg
	sub s8,t1,t2 # Encontrar valor de line_break para os pixels
	# t1 passa o valor da dimensão x total da imagem, não de um único frame
	li t6,4
	div t1,t1,t6 # transformar t1 no valor de um frame e não do sprite inteiro
	# Achar o valor inicial de t0.
	# -> primeiro teste -> t0 inicia na posição 0
	# Carregar em t4 o valor da direção
	# Após isso, multiplicar em por t1, que será o intervalo de pixels de cada direção
	# Ao somar o valor gerado em t4 chega-se no novo valor inicial da imagem.
	la t4,%dir
	lh t4,0(t4)
	mul t4,t1,t4
	add t0,t0,t4
	
	# ----------------------
	# Animação do Sprite
	# ----------------------
	# Para animar o sprite preciso fazer ele passar por cada sprite dentro do conjunto
	# de uma direção
	# em t1 tenho o limite dos intervalos de frames
	# registradores sobrando: t4,t5,t6
	# Carregar STATE
	#la t4,%state
	#lh t4,0(t4)
	#li t5,4
	#bgt t4,t5,RSTATE
	#mul t5,t4,t2
	#add t0,t0,t5

	# Encontrar o nº de pixels a serem pulados
	li s9,320 # dimensão máxima da tela
	sub t1,s9,t2 # t2 armazena da dimensão máxima - o valor x do sprite
	mv s9,s8 # usar s9 como val de line_break
	li t6,0 # contador quebra de linha
	li t4, 0 # contador de parada
IMPRIMEA:
	bge t4, t3, BREAK_ANIMATION
	bge t6,t2, NEW_LINEA
	lw t5, 0(t0)
	sw t5, 0(s0)
	pp(t0,4)
	pp(s0,4)
	pp(t4,4)
	pp(t6,4)
	j IMPRIMEA
NEW_LINEA:
	add s0,s0,t1
	add t0,t0,s9 # valor de line_break com retorno para o mesmo ponto inicial em X na linha seguinte
	li t6,0 # retornar t6 para 0 para recomeçar a contagem
	j IMPRIMEA

BREAK_ANIMATION:
.end_macro

# Printa imagens estáticas na tela
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
	# Gerar vetor X por Y
	# -> o vetor da pos inicial deve ser gerado antes de chamar o clear pela primeira vez
	li s9,320
	mul s10,%y,s9
	add s10,s10,%x
	clear_sprite(%sprite,%old_sprite,%x,%y)
	check_input(%reg)
	beqz t2,PRINT_SCAPE
	
COMPUT_MOVEMENT:
	# Armazenar o valor do input do movimento em t2 para X e t3 para Y
	update_dir(t4,DIR,t5)
	li t2,4
	mul t2,t2,t0
	li t3,4
	mul t3,t3,t1
	
ANDAR_START:
	li s9,320
	# Incrementar X e Y com os valores de t2 e t3
	increment_pos_reg(%x,%y,t2,t3)
	update_pos(s1,s2,POS_X,POS_Y,t2)
	mul s10,%y,s9
	add s10,s10,%x
	animate_sprite(%sprite,s10,STATE,DIR,%x,%y)
	#print_img(%sprite,s10)
	j BREAK_WALK
	
# Print scape garante que caso haja input mas ele não gere movimento o lolo seja printado na posição onde já está
PRINT_SCAPE:
	li t2,0
	li t3,0
	j ANDAR_START

BREAK_WALK:
.end_macro

.macro clear_sprite(%sprite,%old_sprite,%x,%y)
	CLEAR:
	la t0,%sprite # carregar o endereço do sprite em t0 apenas para passar para t1 e t2
	li t1,16
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
	bge t4, t3, END_CLEAR
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
END_CLEAR:
.end_macro
