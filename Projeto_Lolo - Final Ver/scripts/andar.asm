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
.eqv SPACE 32

.macro animate_sprite(%sprite,%grid_reg,%frame,%dir)
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
	mult_div(div,t6,t1,4)
	mv t1,t6 # transformar t1 no valor de um frame e não do sprite inteiro -> totalFrames
	la t4,%dir
	lb t4,0(t4)
	mul t4,t1,t4
	add t0,t0,t4
	image_cicle(%sprite,t1,t2,%frame,t4,t5,t6)
	add t0,t0,t4
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
	addi t0,t0,4
	addi s0,s0,4
	addi t4,t4,4
	addi t6,t6,4
	j IMPRIMEA
NEW_LINEA:
	add s0,s0,t1
	add t0,t0,s9 # valor de line_break com retorno para o mesmo ponto inicial em X na linha seguinte
	li t6,0 # retornar t6 para 0 para recomeçar a contagem
	j IMPRIMEA
BREAK_ANIMATION:
.end_macro

# Printa imagens estáticas na tela
.macro print_img(%sprite,%grid_reg,%f_reg,%f_adress)
	la t0,%sprite # carregar o endereço de tela em t0
	lw t1, 0(t0) # x -> primeira word - inicia em 0xFF000000 e termina em 0xFF00013F
	lw t2, 4(t0) # y -> segunda word
	mul t3,t1,t2 # x * y para obter a área -> t3 = área
	addi t0,t0,8 # 0 é x, 4 é y, portanto em 8 começa a imagem
	li %f_reg, %f_adress
	li s9,320 #dimensão máxima da tela
	sub t2,s9,t1
	add %f_reg,%f_reg,%grid_reg
	li t6,0 # contador quebra de linha
	li t4, 0 # contador de parada
IMPRIME:
	bge t4, t3, BREAK_PRINT
	bge t6,t1, NEW_LINE 
	lw t5, 0(t0)
	sw t5, 0(%f_reg)
	addi t0,t0,4
	addi %f_reg,%f_reg,4
	addi t4,t4,4
	addi t6,t6,4
	j IMPRIME
NEW_LINE: 
	add %f_reg,%f_reg,t2
	li t6,0 # retornar t6 para 0 para recomeçar a contagem
	j IMPRIME
BREAK_PRINT:
.end_macro

# Player collision deve vir sempre que for chamada a função de movimentar o jogador
# Desse modo, será checado se há colisão no próximo espaço que o Lolo irá ocupar
# se houver, ele não movimenta, se estiver livre, ele movimenta normalmente
.macro check_collision(%x,%y,%x_mv,%y_mv,%col_type)
	# Checar se está em uma das bordas do mapa
	# como todas as unidades estão sujeitas ao mapa, serve para todas
	mv t5,%x_mv
	mv t6,%y_mv
	add %x_mv,%x,%x_mv
	add %y_mv,%y,%y_mv
	li t0,52 # pixel x onde começa o mapa, após a parede
	li t1,28 # pixel y onde começa o mapa, após a parede
	ble %x_mv,t0,V_END_CHECK_COL # checar colisão na esquerda
	ble %y_mv,t1,V_END_CHECK_COL # checar colisão encima
	li t0,220
	li t1,196
	bge %x_mv,t0,V_END_CHECK_COL # checar colisão na direita
	bge %y_mv,t1,V_END_CHECK_COL #checar colisão inferior
	
CHECK_COL_STEP2:
	# Passo 2:
	# checar se há algum objeto com colisão perto
	li a7,1
	la s8,CURRENT_MAP
	li t4,0

# SUPERIOR_ESQUERDO: X = 56 Y = 32
# SUPERIOR_DIREITO: X = 44 Y = 32
# INFERIOR_ESQUERDO: X = 56 Y =¨20
# INFERIOS_DIREITO: X = 44 Y = 20
	j START_POINT_CHECKING
	
V_END_CHECK_COL: j END_CHECK_COLLISION
V_CHECK_COLLISION_TYPE: j CHECK_COL_TYPE

START_POINT_CHECKING:
	get_point(%x_mv,%y_mv,56,32,t6)
	check_col_type(t6,1,s8)
	beq t1,t0,V_END_CHECK_COL
	li t1,2
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,6
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,7
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,8
	beq t1,t0,V_END_CHECK_COL
	
	get_point(%x_mv,%y_mv,44,32,t6)
	check_col_type(t6,1,s8)
	beq t1,t0,V_END_CHECK_COL
	li t1,2
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,6
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,7
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,8
	beq t1,t0,V_END_CHECK_COL
	
	get_point(%x_mv,%y_mv,56,20,t6)
	check_col_type(t6,1,s8)
	beq t1,t0,V_END_CHECK_COL
	li t1,2
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,6
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,7
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,8
	beq t1,t0,V_END_CHECK_COL
	
	get_point(%x_mv,%y_mv,44,20,t6)
	check_col_type(t6,1,s8)
	beq t1,t0,V_END_CHECK_COL
	li t1,2
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,6
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,7
	beq t1,t0,V_CHECK_COLLISION_TYPE
	li t1,8
	beq t1,t0,V_END_CHECK_COL

ESCAPE_CHECK_COL:
	increment_pos_reg(%x,%y,%x_mv,%y_mv)
	li %col_type,0
	j END_CHECK_COLLISION
CHECK_COL_TYPE:
	bnez %col_type,NEXT_CHECK_COL0
	li t0,7
	bne t0,t1,NEXT_CHECK_COL0
	call HEARTS_ROUTINE
NEXT_CHECK_COL0:
	li t0,6
	bne t0,t1,NEXT_CHECK_COL1
	call CHEST_ROUTINE
NEXT_CHECK_COL1:	
	beqz %col_type,V_END_CHECK_COL
	mv %col_type,t1 # se a colisão for do poder, informar que a colisão ocorreu

END_CHECK_COLLISION:
.end_macro


.macro clear_sprite(%old_sprite,%x,%y)
CLEAR:
	li s9,320
	mul s10,%y,s9
	add s10,s10,%x
	li t1,16
	mul t3,t1,t1 # x * y para obter a área -> t3 = área
	la t0,%old_sprite # carregar em t0 o valor do sprite anterior, para acessar as cores dele
	addi t0,t0,8
	li s0, 0xFF000000
	add s0,s0,s10
	li s9,320 # dimensão máxima da tela
	sub t2,s9,t1
	# Como X e Y não estão em vetor, posso facilmente achar a posição relativa do background em 240x240
	la s9,%old_sprite
	lw s9,0(s9) # armazenar em s9 o valor y do mapa
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