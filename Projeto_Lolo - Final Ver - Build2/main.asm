.include "./scripts/macros.asm"
.include "./scripts/maps.asm"
.include "./scripts/music.asm"
.eqv MMIO_add 0xff200004 # Data (ASCII value)
.eqv MMIO_set 0xff200000 # Control (boolean)

# ----------------------------------------------
# Build 2 do projeto pós entrega e apresentação
# ----------------------------------------------
# - Mais de um inimigo por fase
# - Atalhos para pular fase
# - Correção de alguns bugs - e alguns novos

# ----------------------------------------------
# INPUTS
# ----------------------------------------------
# Movimento: w a s d
# Poder: space bar
# Recomeçar fase atual: r
# Ir para a fase desejada: 1, 2, 3
# ----------------------------------------------

.data
LOLO_FRAME: .byte 0	# o lolo possui 5 frames para cada dir. Como definir isso mais adiante para os inimigos?
POS_X:  .half 0               # x e y
POS_Y:  .half 0
MV_MAGNITUDE: .byte 0,0
# O vetor DIR guarda a última direção para a qual o sprite olhou
# Vai de 0 até 3, seguindo o sentido de um plano cartesiano
DIR:    .byte 3
FALSE: .byte 0
HUD_LOLO: .half 3
# POWER
POWER_CHARGE: .byte 0
POWER_DIR: .byte 0
POWER_POSX: .half 0
POWER_POSY: .half 0
POWER_EXIST: .byte 0
#MAP_IMG: .word 208,224
.byte
.text
# -----------------------------------------------------------------------------
# Imprimir na tela o menu inicial
# -----------------------------------------------------------------------------
li s0,0xFF100000

LOAD_GAME_START:
	#new2old_map(MAP_IMG,map_start)
	# carrega em s1 e s0 as posições de início do lolo
	li s1,56
	li s2,112
	update_pos(s1,s2,POS_X,POS_Y,t2)	
	li a6,40
	# printa o menu no frame 1 enquanto printa o mapa no frame 0
	print_img(Adventures_of_Lolo_Title,a6,s6,0xFF100000) # title é a correta para 320 x 240, Adventures_of_Lolo_Title é para 240 x 240
	li s0,0xFF200604
	li t2,1
	sw t2,0(s0)
	print_img(map_start,a6,s0,0xFF000000)
	li a6,0
	# Descomentar música
	#play_music(NUM0,NOTAS0,5,30,32)
	
WAIT_START:
	li t0, MMIO_set # ready bit MMIO
	lb t1,(t0)
	beqz t1, WAIT_START # wait time enquanto ready bit == 0
	
LOAD_MAP_START:
	# Elementos do Mapa 1
	# Corações
	li a6 15480
	print_img(collectable,a6,s0,0xFF000000)
	li a6, 30936
	print_img(collectable,a6,s0,0xFF000000)
	li a6, 56440
	animate_sprite(chests,a6,CHEST0,CHEST0)
	# -------------------------------------
	# Load HUD
	li a6,248
	print_img(hud,a6,s0,0xFF000000)
	li a6,5368
	animate_sprite(lolo_4_dir,a6,FALSE,HUD_LOLO)
	
	# -------------------------------------
	
	# Realizar a transiçãoo com uma imagem preta
	li a6,40
	print_img(clean_back,a6,s6,0xFF100000)
	# Iniciar o frame 0
	li a6,0
	sw t2,0(s0)
	li s0,0xFF200604
	li t2,0
	sw t2,0(s0)
	j GAME_LOOP
	
V_SKIP_MMIO_ADD:
	j SKIP_MMIO_ADD 

GAME_LOOP:
	# delay
	delay(10)
	# atualizar o lolo do HUD
	li a5,152
	li a6,112
	clear_sprite(map_start,a5,a6)
	li a5,0
	li a6,5368
	animate_sprite(lolo_4_dir,a6,FALSE,DIR)
	load_pos(POS_X,POS_Y,s1,s2)
	li t1,0
	li t0, MMIO_set # ready bit MMIO
	lb t1,(t0)
	beqz t1,V_SKIP_MMIO_ADD # skip lolo routine enquanto ready bit == 0
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
	# update dir
	call CHECK_INPUT
POS_INPUT_CHECK:
	#beqz t2,SKIP_MMIO_ADD
	call PLAYER_ROUTINE
SKIP_MMIO_ADD:
	call MAP0_ROUTINE
POS_ENEMY_R:
	li a5,208
	li a6,16
	clear_sprite(map_start,a5,a6)
	call PROPAGATE_POWER
	#call CHEST_ROUTINE
	call NEXT_STAGE_ROUTINE
POS_POWER:
	j GAME_LOOP
	#Exit()
	
# ----------------------------------------------------------------------------------------
# Check Input recebe diversas informações do usuário e gera valores que poderão ser usados
# ----------------------------------------------------------------------------------------

CHECK_INPUT:
	li t0,0
	li t1,0
	li t2,0
	la t5,MV_MAGNITUDE
CAST_POWER:
	li t3,SPACE
	bne a0,t3,V_W_RIGHT
	call POWER_ROUTINE
	li t0,0
	li t1,0
	li t2,0
	la t5,MV_MAGNITUDE
	j POS_INPUT_CHECK
W_RIGHT:
	li t3,RIGHT
	bne a0,t3,V_W_UP
	li t0,1
	li t4,0
	sb t4,DIR,t3
	li t2,1
W_UP:
	li t3,UP
	bne a0,t3,V_W_LEFT
	li t1,-1
	li t4,1
	sb t4,DIR,t3
	li t2,1
W_LEFT:
	li t3,LEFT
	bne a0,t3,V_W_DOWN
	li t0,-1
	li t4,2
	sb t4,DIR,t3
	li t2,1
W_DOWN:
	li t3,DOWN
	bne a0,t3,V_PSSWD_0
	li t1,1
	li t4,3
	sb t4,DIR,t3
	li t2,1
PSSWD_0:
	li t3,48
	bne a0,t3,V_PSSWD_1
	call STAGE_1
PSSWD_1:
	li t3,49
	bne a0,t3,V_PSSWD_2
	call STAGE_1
PSSWD_2:
	li t3,50
	bne a0,t3,V_PSSWD_3
	call STAGE_2
PSSWD_3:
	li t3,51
	bne a0,t3,V_RESTART_STAGE
	call STAGE_3

RESTART_STAGE:
	li t3,R
	bne a0,t3,V_END_CHECK_INPUT
	la t1,MAP
	lb t0,0(t1)
	li t2,1
	sub t2,t0,t2
	sb t2,0(t1)
	j CHANGE_STAGE

END_CHECK_INPUT:
	sb t0,0(t5)
	sb t1,4(t5)
	j POS_INPUT_CHECK



# --------------------------------------
# JOGADOR: Movimento + Colisão
# --------------------------------------
PLAYER_ROUTINE:
	# Gerar vetor X por Y
	# -> o vetor da pos inicial deve ser gerado antes de chamar o clear pela primeira vez
	beqz t2,V_PRINT_ESCAPE
	clear_sprite(map_start,s1,s2)
	li a0 0
COMPUT_MOVEMENT:
	# Armazenar o valor do input do movimento em t2 para X e t3 para Y
	la t4,MV_MAGNITUDE
	lb t1,4(t4)
	lb t0,0(t4)
	li t2,4
	mul t2,t2,t0
	li t3,4
	mul t3,t3,t1

ANDAR_START:
	# Incrementar X e Y com os valores de t2 e t3
	li s11,0
	check_collision(s1,s2,t2,t3,s11)
	li s9,320
	update_pos(s1,s2,POS_X,POS_Y,t2)
	mul s10,s2,s9
	add s10,s10,s1
	animate_sprite(lolo_walk,s10,LOLO_FRAME,DIR)
	#print_img(%sprite,s10)
# Print scape garante que caso haja input mas ele não gere movimento o lolo seja printado na posição onde já está
	ret

PRINT_ESCAPE:
	la s1,POS_X
	lh s1,0(s1)
	la s2,POS_Y
	lh s2,0(s2)
	li t2,0
	li t3,0
	li s9,320
	mul s10,s2,s9
	add s10,s10,s1
	animate_sprite(lolo_4_dir,s10,LOLO_FRAME,DIR)
	j GAME_LOOP

# -----------------
# Enemy Things
# -----------------
MAP0_ROUTINE:
ENEMY_ROUTINE:
	la t0,MAP0_ENEMY_COUNT # número de inimigos existentes na fase
	# para conseguir printar mais de um inimigo será preciso colocar checador de intervalos
	# dentro do loop deverá estar tudo desde o check se o inimigo está vivo até sua animação
	# checar se o inimigos está vivo:
	lb s1,0(t0) # número de inimigos existentes na fase
	li s2,0 # contador
	li s3,0 # contador de intervalos
IF_THERES_SOMEONE:
	beq s1,s2,V_END_ENEMY_ROUTINE # se o contador base for igual ao número total de indivíduos nas fases terminar rotina
	la t0,ENEMY0_LIVE # carregar em t0 a lista de ENEMY_LIVE
	add t0,t0,s3 # somar ao valor de início o valor do número de iterações salvo vezes 4
	lb t0,0(t0) # carregar em t0 o byte salvo em 0(t0)
	li t1,1
	bne t0,t1,V_SKIP_ENEMY_PRINT # se o valor de live for igual a 0
	load_other_pos(a5,a6,ENEMY0_XY,s3) # cerregar em a5 e a6 a posição de ENEMY_XY a partir de s3
	lagarta_dir(POS_X,a5,ENEMY0_DIR,ENEMY0_OLDDIR,s3)
	la t0,ENEMY0_DIR
	add t0,t0,s3
	lb t0,0(t0)
	la t1,ENEMY0_OLDDIR
	add t1,t1,s3
	lb t1,0(t1)
	beq t1,t0,V_SKIP_ENEMY_PRINT
	clear_sprite(map_start,a5,a6)
	find_grid_pos(a5,a6)
	la t0,ENEMY0_DIR
	add t0,t0,s3
	lb t0,0(t0)
	sb t0,ACTUAL_ENEMY,t1
	animate_sprite(lagarta,a6,FALSE,ACTUAL_ENEMY)
SKIP_ENEMY_PRINT:
	addi s2,s2,1
	addi s3,s3,4
	j IF_THERES_SOMEONE
END_ENEMY_ROUTINE:
	li a5,0
	li a6,0
	j POS_ENEMY_R



# Sempre que o Lolo colidir com um coração ele iniciará essa rotina
# passos:
# acrescentar 2 de power quando convir
# apagar o coração
# s1 armazena o vetor com a posição da matriz de cada coração
# s2 aramzena o número de iterações
CALL_CHEST_ROUTINE: j CHEST_ROUTINE

HEARTS_ROUTINE:
	# checar se existem corações no mapa
	# criar um loop que itera por todos os corações, checando se a posição deles bate com a do lolo
	# o loop deve ir de 0 até o valor de EXISTING_COLLECTABLE0
	li t4,0 # contador
	la s1,EXISTING_COLLECTABLE0
	lw t3,0(s1)
	la s1,COLLECTABLE0_MATRIX
	li t1,0 # contador de quantas vezes o valor foi aumentado em 9
LOOKING_FOR_HEARTS:
	beq t4,t3,V_THERES_NO_HEARTS
	lb t0,0(s1)
	beq t0,s3,V_HEART_FOUND
	addi t1,t1,8
	addi t4,t4,1
	addi s1,s1,4
	j LOOKING_FOR_HEARTS

HEART_FOUND:
	# Encontrar cora��o de acordo com sua posição na matriz e executar a lógica dele
	la s1,COLLECTABLE0_POS
	mv s2,t1
	add s1,s1,s2
	lw s6,0(s1)
	lw s7,4(s1)	
	clear_sprite(map_start,s6,s7) # apagar o sprite
	change_matrix_value(COLLECTABLE0_POS,CURRENT_MAP,0,s2)
	sound_effect(72,400,121,60)
	# Atualizar o valor de power de acordo com o coração coletado
	la t0,COLLECT_POWER_INCREASE0
	srli s2,s2,2
	add t0,t0,s2
	lb t0,0(t0)
	la t1,POWER_CHARGE
	lb t2,0(t1)
	add t2,t2,t0
	sb t2,(t1)
	
	# Comparar collected com hearts existentes
	la t1,COLLECTED0
	lb t1,0(t1)
	addi t1,t1,1
	sb t1,COLLECTED0,t2
	la t1,COLLECTED0
	lb t1,0(t1)
	la s1,EXISTING_COLLECTABLE0
	lb t0,0(s1)
THERES_NO_HEARTS:
	beq t1,t0,V_OPEN_CHEST
	j GAME_LOOP

OPEN_CHEST:
	la t0,CHEST0
	li t1,1
	sb t1,(t0)
	change_matrix_value(CHEST0_POS,CURRENT_MAP,6,zero)
	j GAME_LOOP

# ------------------------------------------------------
#  Estação
# ------------------------------------------------------
V_SKIP_ENEMY_PRINT: j SKIP_ENEMY_PRINT
V_END_ENEMY_ROUTINE: j END_ENEMY_ROUTINE
V_CALL_CHEST_ROUTINE: j CALL_CHEST_ROUTINE
V_THERES_NO_HEARTS: j THERES_NO_HEARTS
V_SKIP_CASTING: j SKIP_CASTING
V_DESTROY_COLLIDED_OBJECT: j DESTROY_COLLIDED_OBJECT
V_SKIP_OBJECT_DESTRUCTION: j SKIP_OBJECT_DESTRUCTION
V_KILL_EVERYTHING: j KILL_EVERYTHING
V_THERE_ARE_STILL_HEARTS_TO_FIND: j THERE_ARE_STILL_HEARTS_TO_FIND
V_W_RIGHT: j W_RIGHT
V_W_UP: j W_UP
V_W_LEFT: j W_LEFT
V_W_DOWN: j W_DOWN
V_END_CHECK_INPUT: j END_CHECK_INPUT
V_OPEN_CHEST: j OPEN_CHEST
V_HEART_FOUND: j HEART_FOUND
V_CHANGE_STAGE: j CHANGE_STAGE
V_PSSWD_0: j PSSWD_0
V_STAGE_1: j STAGE_1
V_STAGE_2: j STAGE_2
V_STAGE_3: j STAGE_3
V_STAGE_4: j STAGE_4
V_PSSWD_1: j PSSWD_1
V_PSSWD_2: j PSSWD_2
V_PSSWD_3: j PSSWD_3
V_PRINT_ESCAPE: j PRINT_ESCAPE
V_RESTART_STAGE: j RESTART_STAGE
V_ITS_SAFE_HERE: j ITS_SAFE_HERE
V_ENEMY_DETECTED: j ENEMY_DETECTED

# Rotina do Poder
POWER_ROUTINE:
	# checar se o lolo tem cargas de poder
	la t0,POWER_CHARGE
	lb t0,0(t0)
	blez t0,V_SKIP_CASTING
	# permitir apenas um cast por vez
	la t1,POWER_EXIST
	lb t1,0(t1)
	bnez t1,V_SKIP_CASTING
	# diminuir em 1 o número de cargas
	li t1,1
	sub t0,t0,t1
	sh t0,POWER_CHARGE,t1
	# encontrar a posição e a direção de propagação do poder
	# a partir do Lolo
	la t0,DIR
	lb t0,0(t0)
	sb t0,POWER_DIR,t6
	
CREATE_POWER:
	sound_effect(69,400,127,60) # tocar efeito sonoro do poder
	li t1 1
	sb t1,POWER_EXIST,t2 # atualizar POWER_EXIST para true
	load_pos(POS_X,POS_Y,s5,s6) # Carregar a posição do lolo
	update_pos(s5,s6,POWER_POSX,POWER_POSY,t3) # Passa para o poder a posição do lolo
	# checar por colisões enquanto movimenta
PROPAGATE_POWER:
	la t1,POWER_EXIST # checar se existe o poder a ser propagado
	lb t1,0(t1)
	beqz t1,V_SKIP_CASTING
	load_pos(POWER_POSX,POWER_POSY,s5,s6)
	find_dir(POWER_DIR,t2,t3,4)
	li a6,1
	check_collision(s5,s6,t2,t3,a6)
	bgtz a6,V_DESTROY_COLLIDED_OBJECT
	update_pos(s5,s6,POWER_POSX,POWER_POSY,t3)
	#clear_sprite(map_start,s5,s6)
	mv s7,s6
	find_grid_pos(s5,s7)
	animate_sprite(power,s7,FALSE,POWER_DIR)
	delay(10)
	clear_sprite(map_start,s5,s6)
	call PRINT_ESCAPE
SKIP_CASTING:
	ret

# Destruir objeto com o qual o poder colidiu:
DESTROY_COLLIDED_OBJECT:
	li t1,0
	sb t1,POWER_EXIST,t2
	# encontrar a direção de propagação
	find_dir(POWER_DIR,s7,s11,16)
START_DESTRUCTION:
	load_pos(POWER_POSX,POWER_POSY,s5,s6)
	increment_pos_numb(s5,s6,s7,s11)
	
	# tornar o clear_sprite relacionado ao inimigo
	#%sprite,%grid_reg,%frame,%dir
	clear_sprite(map_start,s5,s6)
	li s10,320
	mul s10,s10,s6
	add s10,s10,s5
	
	li t0,56
	sub t0,s5,t0
	bltz t0,V_SKIP_OBJECT_DESTRUCTION
	li t0,32
	sub t0,s6,t0
	bltz t0,V_SKIP_OBJECT_DESTRUCTION
	la s8,CURRENT_MAP
	get_point(s5,s6,52,32,s3)
	check_col_type(s3,2,s8)
	beq t0,t1,V_KILL_EVERYTHING


SKIP_OBJECT_DESTRUCTION:
	ret

# Set the enemy state live to false
# -> como encontrar o inimigo pela sua posição?
KILL_EVERYTHING:
	li t4,0 # contador
	la s1,MAP0_ENEMY_COUNT
	lw t3,0(s1)
	la s1,MAP0_MATRIXPOS_PER_ENEMY
	li t1,0 # contador de quantas vezes o valor foi aumentado 2 a 2
HUNTING_ENEMIES:
	beq t4,t3,V_ITS_SAFE_HERE
	lb t0,0(s1)
	beq t0,s3,V_ENEMY_DETECTED
	addi t1,t1,8
	addi t4,t4,1
	addi s1,s1,4
	j HUNTING_ENEMIES
ENEMY_DETECTED:
	# Encontrar inimigo de acordo com sua posição na matriz e o definir como *morto*
	la s1,ENEMY0_XY
	mv s2,t1
	add s1,s1,s2
	lw s6,0(s1)
	lw s7,4(s1)
	clear_sprite(map_start,s6,s7) # apagar o sprite do inimigo
	change_matrix_value(ENEMY0_XY,CURRENT_MAP,0,s2) # definir sua posição na matriz como null
	# definir inimigo atingido como live = 0
	la t0,ENEMY0_LIVE
	add t0,t0,s2
	li t1,0
	sb t1,0(t0)
ITS_SAFE_HERE:
	ret	

CHEST_ROUTINE:
	change_matrix_value(CHEST0_POS,CURRENT_MAP,0,zero)
	li t0,1
	la t1,STAGE_CLEAR
	sb t0,0(t1)
THERE_ARE_STILL_HEARTS_TO_FIND:
	j GAME_LOOP

NEXT_STAGE_ROUTINE:
	#play_music(NUM2,NOTAS2,99,60)
	la t0,STAGE_CLEAR
	lb t0,0(t0)
	li t1,1
	beq t1,t0,V_CHANGE_STAGE
	j GAME_LOOP
CHANGE_STAGE:
	la t0,MAP
	lb t0,0(t0)

	beqz t0,V_STAGE_1
	li t1,1
	beq t0,t1,V_STAGE_2
	li t2,2
	beq t0,t2,V_STAGE_3
	li t3,3
	beq t0,t3,V_STAGE_4
	#li t4,4
	#beq t0,t4,V_STAGE_5

STAGE_0:
	li t0,0
	la t1,STAGE_CLEAR
	sb t0,0(t1)
	# Increase Map Count
	la t1,MAP
	li t0,1
	sb t0,0(t1)
	# Upgrade Matrix
	upgrade_matrix(CURRENT_MAP,MAP0)
	# Load New Enemy Values
	load_enemy_xy(ENEMY0_XY,ENEMY00_XY)
	load_enemy_values(ENEMY0_DIR,ENEMY00_DIR)
	load_enemy_values(ENEMY0_LIVE,ENEMY00_LIVE)
	load_enemy_values(ENEMY0_OLDDIR,ENEMY00_OLDDIR)
	#load_enemy_values(ENEMY0_LIVE,ENEMY1_LIVE)
	load_enemy_values(MAP0_MATRIXPOS_PER_ENEMY,MAP00_MATRIXPOS_PER_ENEMY)
	load_enemy_values(MAP0_ENEMY_COUNT,MAP00_ENEMY_COUNT)
	# Load Hearts Positions
	load_enemy_values(EXISTING_COLLECTABLE0,EXISTING_COLLECTABLE00)
	load_new_collect(COLLECTABLE0_POS,COLLECTABLE00_POS,EXISTING_COLLECTABLE00)
	load_new_values(COLLECTABLE0_MATRIX,COLLECTABLE00_MATRIX,EXISTING_COLLECTABLE00,4)
	update_dir(zero,COLLECTED0,t0)
	load_new_values(COLLECT_POWER_INCREASE0,COLLECT_POWER_INCREASE00,EXISTING_COLLECTABLE00,4)
	# ATT chest Position
	load_enemy_xy(CHEST0_POS,CHEST00_POS)
	li t0,0
	la t1,CHEST00
	sb t0,0(t1)
	# Att Lolo Position
	# Apaga o Lolo
	load_pos(POS_X,POS_Y,s1,s2)
	clear_sprite(map_start,s1,s2)
	li s1,56
	li s2,112
	update_pos(s1,s2,POS_X,POS_Y,t2)
	li s9,320
	mul s10,s2,s9
	add s10,s10,s1
	animate_sprite(lolo_walk,s10,LOLO_FRAME,DIR)
	
	# Load new map
	li a6,40
	print_img(clean_map,a6,s0,0xFF000000)
	new2old_map(map_start,map_start_reload)
	
	# Reset Lolo Power
	la t1,POWER_CHARGE
	li t0,0
	sb t0,0(t1)
	li a6,40
	print_img(map_start,a6,s0,0xFF000000)
	li a6 15480
	print_img(collectable,a6,s0,0xFF000000)
	li a6, 30936
	print_img(collectable,a6,s0,0xFF000000)
	li a6, 56440
	animate_sprite(chests,a6,FALSE,CHEST0)
	j LETS_GO

STAGE_1:
	li t0,0
	la t1,STAGE_CLEAR
	sb t0,0(t1)
	# Increase Map Count
	la t1,MAP
	li t0,1
	sb t0,0(t1)
	# Upgrade Matrix
	upgrade_matrix(CURRENT_MAP,MAP1)
	# Load New Enemy Values
	load_enemy_xy(ENEMY0_XY,ENEMY1_XY)
	load_enemy_values(ENEMY0_DIR,ENEMY1_DIR)
	load_enemy_values(ENEMY0_LIVE,ENEMY1_LIVE)
	load_enemy_values(ENEMY0_OLDDIR,ENEMY1_OLDDIR)
	#load_enemy_values(ENEMY0_LIVE,ENEMY1_LIVE)
	load_enemy_values(MAP0_MATRIXPOS_PER_ENEMY,MAP1_MATRIXPOS_PER_ENEMY)
	load_enemy_values(MAP0_ENEMY_COUNT,MAP1_ENEMY_COUNT)
	# Load Hearts Positions
	load_enemy_values(EXISTING_COLLECTABLE0,EXISTING_COLLECTABLE1)
	load_new_collect(COLLECTABLE0_POS,COLLECTABLE1_POS,EXISTING_COLLECTABLE1)
	load_new_values(COLLECTABLE0_MATRIX,COLLECTABLE1_MATRIX,EXISTING_COLLECTABLE1,4)
	update_dir(zero,COLLECTED0,t0)
	load_new_values(COLLECT_POWER_INCREASE0,COLLECT_POWER_INCREASE1,EXISTING_COLLECTABLE1,4)
	# ATT chest Position
	load_enemy_xy(CHEST0_POS,CHEST1_POS)
	li t0,0
	la t1,CHEST0
	sb t0,0(t1)
	# Att Lolo Position
	# Apaga o Lolo
	load_pos(POS_X,POS_Y,s1,s2)
	clear_sprite(map_start,s1,s2)
	li s1,56
	li s2,112
	update_pos(s1,s2,POS_X,POS_Y,t2)
	li s9,320
	mul s10,s2,s9
	add s10,s10,s1
	animate_sprite(lolo_walk,s10,LOLO_FRAME,DIR)
	
	# Load new map
	li a6,40
	print_img(clean_map,a6,s0,0xFF000000)
	new2old_map(map_start,map_start_reload)
	
	# Reset Lolo Power
	la t1,POWER_CHARGE
	li t0,0
	sb t0,0(t1)
	li a6,40
	print_img(map_start,a6,s0,0xFF000000)
	li a6 15480
	print_img(collectable,a6,s0,0xFF000000)
	li a6, 30936
	print_img(collectable,a6,s0,0xFF000000)
	li a6, 56440
	animate_sprite(chests,a6,FALSE,CHEST0)
	j LETS_GO
STAGE_2:
	li t0,0
	la t1,STAGE_CLEAR
	sb t0,0(t1)
	# Increase Map Count
	la t1,MAP
	li t0,2
	sb t0,0(t1)
	# Upgrade Matrix
	upgrade_matrix(CURRENT_MAP,MAP2)
	# Load New Enemy Values
	load_enemy_xy(ENEMY0_XY,ENEMY2_XY)
	load_enemy_values(ENEMY0_DIR,ENEMY2_DIR)
	load_enemy_values(ENEMY0_LIVE,ENEMY2_LIVE)
	load_enemy_values(ENEMY0_OLDDIR,ENEMY2_OLDDIR)
	#load_enemy_values(ENEMY0_LIVE,ENEMY2_LIVE)
	load_enemy_values(MAP0_MATRIXPOS_PER_ENEMY,MAP2_MATRIXPOS_PER_ENEMY)
	load_enemy_values(MAP0_ENEMY_COUNT,MAP2_ENEMY_COUNT)
	# Load Hearts Positions
	load_enemy_values(EXISTING_COLLECTABLE0,EXISTING_COLLECTABLE2)
	load_new_collect(COLLECTABLE0_POS,COLLECTABLE2_POS,EXISTING_COLLECTABLE2)
	load_new_values(COLLECTABLE0_MATRIX,COLLECTABLE2_MATRIX,EXISTING_COLLECTABLE2,4)
	update_dir(zero,COLLECTED0,t0)
	load_new_values(COLLECT_POWER_INCREASE0,COLLECT_POWER_INCREASE2,EXISTING_COLLECTABLE2,4)
	# ATT chest Position
	load_enemy_xy(CHEST0_POS,CHEST2_POS)
	li t0,0
	la t1,CHEST0
	sb t0,0(t1)
	# Reset Lolo Power
	la t1,POWER_CHARGE
	li t0,0
	sb t0,0(t1)
	# Att Lolo Position
	# Apaga o Lolo
	load_pos(POS_X,POS_Y,s1,s2)
	clear_sprite(map_start,s1,s2)
	li s1,136
	li s2,192
	update_pos(s1,s2,POS_X,POS_Y,t2)
	li s9,320
	mul s10,s2,s9
	add s10,s10,s1
	animate_sprite(lolo_walk,s10,LOLO_FRAME,DIR)
	
	# pass new_map to old_map
	li a6,40
	print_img(clean_map,a6,s0,0xFF000000)
	new2old_map(map_start,map2)
	li a6,40
	print_img(map_start,a6,s0,0xFF000000)
	# heart1
	li a6 20600
	print_img(collectable,a6,s0,0xFF000000)
	# heart2
	li a6, 51336
	print_img(collectable,a6,s0,0xFF000000)
	# heart3
	li a6, 51352
	print_img(collectable,a6,s0,0xFF000000)
	# chest
	li a6, 61496
	animate_sprite(chests,a6,FALSE,CHEST0)
	j LETS_GO
STAGE_3:
	li t0,0
	la t1,STAGE_CLEAR
	sb t0,0(t1)
	# Increase Map Count
	la t1,MAP
	li t0,3
	sb t0,0(t1)
	# Upgrade Matrix
	upgrade_matrix(CURRENT_MAP,MAP3)
	# Load New Enemy Values
	load_enemy_values(MAP0_ENEMY_COUNT,MAP3_ENEMY_COUNT)
	load_new_collect(ENEMY0_XY,ENEMY3_XY,MAP3_ENEMY_COUNT)
	
	la t0,ENEMY0_XY
	li a7,1
	li t1,0
	li t3,6
MINI_LOOP:
	beq t1,t3,SKIP_SKIP_SKIP
	addi t0,t0,4
	addi t1,t1,1
	j MINI_LOOP
SKIP_SKIP_SKIP:
	load_new_values(ENEMY0_DIR,ENEMY3_DIR,MAP3_ENEMY_COUNT,4)
	load_new_values(ENEMY0_LIVE,ENEMY3_LIVE,MAP3_ENEMY_COUNT,4)
	load_new_values(ENEMY0_OLDDIR,ENEMY3_OLDDIR,MAP3_ENEMY_COUNT,4)
	#load_new_values(ENEMY0_LIVE,ENEMY3_LIVE)
	load_new_values(MAP0_MATRIXPOS_PER_ENEMY,MAP3_MATRIXPOS_PER_ENEMY,MAP3_ENEMY_COUNT,4)

	# Load Hearts Positions
	load_enemy_values(EXISTING_COLLECTABLE0,EXISTING_COLLECTABLE3)
	load_new_collect(COLLECTABLE0_POS,COLLECTABLE3_POS,EXISTING_COLLECTABLE3)
	load_new_values(COLLECTABLE0_MATRIX,COLLECTABLE3_MATRIX,EXISTING_COLLECTABLE3,4)
	update_dir(zero,COLLECTED0,t0)
	load_new_values(COLLECT_POWER_INCREASE0,COLLECT_POWER_INCREASE3,EXISTING_COLLECTABLE3,4)
	# ATT chest Position
	load_enemy_xy(CHEST0_POS,CHEST3_POS)
	li t0,0
	la t1,CHEST0
	sb t0,0(t1)
	# Reset Lolo Power
	la t1,POWER_CHARGE
	li t0,0
	sb t0,0(t1)
	# Att Lolo Position
	# Apaga o Lolo
	load_pos(POS_X,POS_Y,s1,s2)
	clear_sprite(map_start,s1,s2)
	li s1,136
	li s2,80
	update_pos(s1,s2,POS_X,POS_Y,t2)
	li s9,320
	mul s10,s2,s9
	add s10,s10,s1
	animate_sprite(lolo_walk,s10,LOLO_FRAME,DIR)
	
	# pass new_map to old_map
	li a6,40
	print_img(clean_map,a6,s0,0xFF000000)
	new2old_map(map_start,map3)
	li a6,40
	print_img(map_start,a6,s0,0xFF000000)
	# heart1
	li a6 15416
	print_img(collectable,a6,s0,0xFF000000)
	# heart2
	li a6, 15576
	print_img(collectable,a6,s0,0xFF000000)
	# heart3
	li a6, 46152
	print_img(collectable,a6,s0,0xFF000000)
	# heart4
	li a6, 46280
	print_img(collectable,a6,s0,0xFF000000)
	# heart5
	li a6, 61576
	print_img(collectable,a6,s0,0xFF000000)
	# chest
	li a6, 56376
	animate_sprite(chests,a6,FALSE,CHEST0)
	j LETS_GO
STAGE_4:
	Exit()
LETS_GO:
	play_music(NUM2,NOTAS2,99,40,31)
	j GAME_LOOP
# Registradores salvos utilizados:
# s0 -> é definido na hora de printar a imagem em seu valor base; depende de s10
# s1 -> X
# s2 -> Y
# s3 -> check_input
# s9 -> dimensão máxima da tela (é definido sempre que necessário)
# s10 -> vetor de x por y
# s11 -> mapa atual
# Com o uso de s1 e s2 para determinar o a posição na tela sempre que algo for andar, fica mais fácil de implementar
# o desenho de partes menores do mapa.
.data
# ------------------------------------------------------------
# 	   INCLUDES + EQUIVALENTES
# ------------------------------------------------------------
.include "./assets/assets_data/lolo_4_dir.data"
.include "./assets/assets_data/Adventures_of_Lolo_Title.data"
.include "./assets/assets_data/lolo_walk.data"
.include "./assets/assets_data/clean_back.data"
.include "./assets/assets_data/clean_map.data"
.include "./assets/assets_data/map_start.data"
.include "./assets/assets_data/map_start_reload.data"
.include "./assets/assets_data/map2.data"
.include "./assets/assets_data/map3.data"
.include "./assets/assets_data/collectable.data"
.include "./assets/assets_data/digits.data"
.include "./assets/assets_data/hud.data"
.include "./assets/assets_data/chests.data"
.include "./assets/assets_data/lagarta.data"
.include "./assets/assets_data/power.data"