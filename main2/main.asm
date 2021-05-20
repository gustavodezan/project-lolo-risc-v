.include "./scripts/macros.asm"
.include "./scripts/andar.asm"
.include "./scripts/maps.asm"
.eqv MMIO_add 0xff200004 # Data (ASCII value)
.eqv MMIO_set 0xff200000 # Control (boolean)
# ----------------------
# Player State Machine
# ----------------------
# 0 - Player State Free
# 1 - Player State WALK
# 3 - DEATH?
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
.text
# -----------------------------------------------------------------------------
# Imprimir na tela o menu inicial
# -----------------------------------------------------------------------------
li s0,0xFF100000

LOAD_GAME_START:
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
	li a6,15608
	#animate_sprite(digits,a6,LOLO_FRAME,DIR)
	li a6,5368
	animate_sprite(lolo_4_dir,a6,FALSE,HUD_LOLO)
	
	# -------------------------------------
	
	
	li a6,40
	print_img(clean_back,a6,s6,0xFF100000)
	li a6,0
	sw t2,0(s0)
	li s0,0xFF200604
	li t2,0
	sw t2,0(s0)
GAME_LOOP:
	load_pos(POS_X,POS_Y,s1,s2)
	li t1,0
	li t0, MMIO_set # ready bit MMIO
	lb t1,(t0)
	beqz t1,SKIP_MMIO_ADD # skip lolo routine enquanto ready bit == 0
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
	# update dir
	call CHECK_INPUT
POS_INPUT_CHECK:
	#beqz t2,SKIP_MMIO_ADD
	call PLAYER_ROUTINE
SKIP_MMIO_ADD:
	#call NEXT_STAGE_ROUTINE
	call MAP0_ROUTINE
	li a5,208
	li a6,16
	clear_sprite(map_start,a5,a6)
	# Update HUD
	call PROPAGATE_POWER
	call CHEST_ROUTINE
POS_POWER:
	
	j GAME_LOOP
	#Exit()


#move(a0,lolo_4_dir,lolo_walk,map_start,s1,s2,POS_X,POS_Y,LOLO_FRAME,DIR)
PLAYER_ROUTINE:
	# Gerar vetor X por Y
	# -> o vetor da pos inicial deve ser gerado antes de chamar o clear pela primeira vez
	beqz t2,PRINT_SCAPE
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

PRINT_SCAPE:
	li t2,0
	li t3,0
	li s9,320
	mul s10,s2,s9
	add s10,s10,s1
	animate_sprite(lolo_4_dir,s10,LOLO_FRAME,DIR)
	ret

MAP0_ROUTINE:
ENEMY_ROUTINE:
	# Rotina de printar cada inimigo:
	# checar se o inimigos está vivo:
	la t0,ENEMY0_LIVE
	lb t0,0(t0)
	li t1,1
	bne t0,t1,SKIP_ENEMY_PRINT
	load_other_pos(a5,a6,ENEMY0_XY)
	lagarta_dir(s1,a5,ENEMY0_DIR,ENEMY0_OLDDIR)
	la t0,ENEMY0_DIR
	lw t0,0(t0)
	la t1,ENEMY0_OLDDIR
	lw t1,0(t1)
	beq t1,t0,SKIP_ENEMY_PRINT
	clear_sprite(map_start,a5,a6)
	find_grid_pos(a5,a6)
	animate_sprite(lagarta,a6,FALSE,ENEMY0_DIR)
SKIP_ENEMY_PRINT:
	li a6,0
	li a5,0
	ret

# Sempre que o Lolo colidir com um coração ele iniciará essa rotina
# passos:
# acrescentar 2 de power quando convir
# apagar o coração
# s1 armazena o vetor com a posição da matriz de cada coração
# s2 aramzena o número de iterações
CALL_CHEST_ROUTINE:
	j CHEST_ROUTINE

HEARTS_ROUTINE:
	# checar se existem corações no mapa
	la t0,EXISTING_COLLECTABLE0
	lb t0,0(t0)
	la t1,COLLECTED0
	lb t1,0(t1)
	beq t1,t0,CALL_CHEST_ROUTINE
	# criar um loop que itera por todos os corações, checando se a posição deles bate com a do lolo
	# o loop deve ir de 0 até o valor de EXISTING_COLLECTABLE0
	li t4,0 # contador
	la s1,EXISTING_COLLECTABLE0
	lw t3,0(s1)
	la s1,COLLECTABLE0_MATRIX
	li t1,0 # contador de quantas vezes o valor foi aumentado em 9
LOOKING_FOR_HEARTS:
	beq t4,t3,THERES_NO_HEARTS
	lb t0,0(s1)
	beq t0,t6,HEART_FOUND
	addi t1,t1,8
	addi t4,t4,1
	addi s1,s1,4
	j LOOKING_FOR_HEARTS

HEART_FOUND:
	# Encontrar coração de acordo com sua posição na matriz e executar a lógica dele
	la s1,COLLECTABLE0_POS
	mv s2,t1
	add s1,s1,s2
	lw s6,0(s1)
	lw s7,4(s1)
	clear_sprite(map_start,s6,s7) # apagar o sprite
	change_matrix_value(COLLECTABLE0_POS,CURRENT_MAP,0,s2)
	
	# Atualizar o valor de power
	la t0,COLLECT_POWER_INCREASE0
	srli s2,s2,2
	add t0,t0,s2
	lb t0,0(t0)
	la t1,POWER_CHARGE
	lb t2,0(t1)
	add t2,t2,t0
	sb t2,(t1)
	la t1,COLLECTED0
	lb t1,0(t1)
	addi t1,t1,1
	sb t1,COLLECTED0,t2
	la t1,COLLECTED0
	lb t1,0(t1)
	la s1,EXISTING_COLLECTABLE0
	lb t0,0(s1)
THERES_NO_HEARTS:
	beq t1,t0,OPEN_CHEST
	j GAME_LOOP

OPEN_CHEST:
	la t0,CHEST0
	li t1,1
	sb t1,(t0)
	j GAME_LOOP

# Rotina do Poder
POWER_ROUTINE:
	# checar se o lolo tem cargas de poder
	la t0,POWER_CHARGE
	lb t0,0(t0)
	blez t0,SKIP_CASTING
	# permitir apenas um cast por vez
	la t1,POWER_EXIST
	lb t1,0(t1)
	bnez t1,SKIP_CASTING
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
	load_other_pos(s5,s6,POS_X,POS_Y) # Carregar a posição do lolo
	update_pos(s5,s6,POWER_POSX,POWER_POSY,t3) # Passa para o poder a posição do lolo
	# checar por colisões enquanto movimenta
PROPAGATE_POWER:
	la t1,POWER_EXIST # checar se existe o poder a ser propagado
	lb t1,0(t1)
	beqz t1,SKIP_CASTING
	load_pos(POWER_POSX,POWER_POSY,s5,s6)
	find_dir(POWER_DIR,t2,t3,4)
	li a6,1
	check_collision(s5,s6,t2,t3,a6)
	bgtz a6,DESTROY_COLLIDED_OBJECT
	update_pos(s5,s6,POWER_POSX,POWER_POSY,t3)
	#clear_sprite(map_start,s5,s6)
	mv s7,s6
	find_grid_pos(s5,s7)
	animate_sprite(power,s7,FALSE,POWER_DIR)
	clear_sprite(map_start,s5,s6)
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
	
	clear_sprite(map_start,s5,s6)
	li t0,56
	sub t0,s5,t0
	bltz t0,SKIP_OBJECT_DESTRUCTION
	li t0,32
	sub t0,s6,t0	
	bltz t0,SKIP_OBJECT_DESTRUCTION	
	la s8,CURRENT_MAP
	get_point(s5,s6,52,32,t6)
	check_col_type(t6,2,s8)
	beq t0,t1,KILL_EVERYTHING


SKIP_OBJECT_DESTRUCTION:
	ret

# Set the enemy state live to false
# -> como encontrar o inimigo pela sua posição?
KILL_EVERYTHING:
	li t1,0
	sw t1,ENEMY0_LIVE,t0
	change_matrix_value(ENEMY0_XY,CURRENT_MAP,0,zero)
	ret

CHEST_ROUTINE:
	li t0,0
	la t1,CHEST0
	lb t1,0(t1)
	beq t1,t0 THERE_ARE_STILL_HEARTS_TO_FIND
	#li t0,2
	#beq t1,t0 CHEST_EMPTY
	change_matrix_value(CHEST0_POS,CURRENT_MAP,0,zero)
	li t0,0
	la t1,STAGE_CLEAR
	sb t0,0(t1)
THERE_ARE_STILL_HEARTS_TO_FIND:
	j GAME_LOOP


GLOBAL_PAUSE:
	li t1,0
	li t0, MMIO_set # ready bit MMIO
	lb t1,(t0)
	beqz t1, GLOBAL_PAUSE # wait time enquanto ready bit == 0
	li a0, MMIO_add # Data address MMIO
	lw a0,(a0) # Recupera o valor de MMIO
	li s3,ESC
	bne a0,s3,GAME_LOOP
	j GLOBAL_PAUSE
	
CHECK_INPUT:
	li t0,0
	li t1,0
	li t2,0
	la t5,MV_MAGNITUDE
CAST_POWER:
	li s3,SPACE
	bne a0,s3,W_RIGHT
	call POWER_ROUTINE
	li t0,0
	li t1,0
	li t2,0
	la t5,MV_MAGNITUDE
	j END_CHECK_INPUT
W_RIGHT:
	li s3,RIGHT
	bne a0,s3,W_UP
	li t0,1
	li t4,0
	sb t4,DIR,t3
	li t2,1
W_UP:
	li s3,UP
	bne a0,s3,W_LEFT
	li t1,-1
	li t4,1
	sb t4,DIR,t3
	li t2,1
W_LEFT:
	li s3,LEFT
	bne a0,s3,W_DOWN
	li t0,-1
	li t4,2
	sb t4,DIR,t3
	li t2,1
W_DOWN:
	li s3,DOWN
	bne a0,s3,END_CHECK_INPUT
	li t1,1
	li t4,3
	sb t4,DIR,t3
	li t2,1
END_CHECK_INPUT:
	sb t0,0(t5)
	sb t1,4(t5)
	j POS_INPUT_CHECK

NEXT_STAGE_ROUTINE:
	la t0,MAP
	lb t0,0(t0)
	
	beqz t0,STAGE_1
	li t1,1
	beq t0,t1,STAGE_2
	li t2,2
	beq t0,t2,STAGE_3
	li t3,3
	beq t0,t3,STAGE_4
	li t4,4
	beq t0,t4,STAGE_5

STAGE_1:

STAGE_2:

STAGE_3:

STAGE_4:

STAGE_5:

# Pensamentos sobre a impressão de imagens:
# para printar uma imagem na tela com o script (em andar.asm) todos os registradores temp são usados,
# por conta disso, talvez gere complicações realizar algo mais detalhado do que isso. (-> hora de receber input do teclado)
# também armazenamos em um registrador salvo (s10) a última posição da imagem. Para poupar registradores
# não tem mais registradores temporários para essa função durante a execução do script... :)
# Registradores salvos utilizados:
# s0 -> é definido na hora de printar a imagem em seu valor base; depende de s10
# s1 -> X
# s2 -> Y
# s3 -> check_input
# s9 -> dimensão máxima da tela (é definido sempre que é necessário)
# s10 -> vetor de x por y
# s11 -> mapa atual
# Com o uso de s1 e s2 para determinar o a posição na tela sempre que algo for andar, fica mais fácil de implementar
# o desenho de partes menores do mapa.
.data
# -----------------------------------------
# 	   INCLUDES + EQUIVALENTES
# -----------------------------------------
.include "./assets/assets_data/lolo_4_dir.data"
.include "./assets/assets_data/Adventures_of_Lolo_Title.data"
.include "./assets/assets_data/lolo_walk.data"
.include "./assets/assets_data/clean_back.data"
.include "./assets/assets_data/map_start.data"
.include "./assets/assets_data/collectable.data"
.include "./assets/assets_data/digits.data"
.include "./assets/assets_data/hud.data"
.include "./assets/assets_data/chests.data"
.include "./assets/assets_data/lagarta.data"
.include "./assets/assets_data/power.data"
#.include "./scripts/ost.asm"
