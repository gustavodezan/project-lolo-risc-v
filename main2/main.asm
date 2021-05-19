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
POWER_CHARGE: .byte 10
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
	animate_sprite(chests,a6,CHEST,CHEST)
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
	check_input(a0)
	beqz t2,SKIP_MMIO_ADD
	call PLAYER_ROUTINE
SKIP_MMIO_ADD:
	call MAP0_ROUTINE
	li a5,208
	li a6,16
	clear_sprite(map_start,a5,a6)
	# Update HUD
	call PROPAGATE_POWER
POS_POWER:
	
	j GAME_LOOP
	Exit()


#move(a0,lolo_4_dir,lolo_walk,map_start,s1,s2,POS_X,POS_Y,LOLO_FRAME,DIR)
PLAYER_ROUTINE:
	# Gerar vetor X por Y
	# -> o vetor da pos inicial deve ser gerado antes de chamar o clear pela primeira vez
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
	li s9,0
	check_collision(s1,s2,t2,t3,s9)
	li s9,320
	update_pos(s1,s2,POS_X,POS_Y,t2)
	mul s10,s2,s9
	add s10,s10,s1
	animate_sprite(lolo_walk,s10,LOLO_FRAME,DIR)
	#print_img(%sprite,s10)
	j BREAK_WALK
# Print scape garante que caso haja input mas ele não gere movimento o lolo seja printado na posição onde já está
BREAK_WALK:
	j SKIP_MMIO_ADD

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
HEARTS_ROUTINE:
	la t1,COLLECTABLE
	lw s6,0(t1)
	lw s7,4(t1)
	clear_sprite(map_start,s6,s7) # apagar o sprite
	change_matrix_value(COLLECTABLE,CURRENT_MAP,0)
	
	# Atualizar o valor de power
	la t0,COLLECT_POWER_INCREASE
	lb t0,0(t0)
	la t1,POWER_CHARGE
	lb t2,0(t1)
	add t2,t2,t0
	sb t2,(t1)
	ret

# Rotina do Poder
POWER_ROUTINE:
	# checar se o lolo tem cargas de poder
	la t0,POWER_CHARGE
	lh t0,0(t0)
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
	sb t0,POWER_DIR,t1
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
	
	la t0,POWER_DIR # encontrar a direção do poder
	lb t0,0(t0)
	beqz t0,PROPAGATE_POWER_X
	li t1,2
	bne t0,t1,PROPAGATE_POWER_Y
PROPAGATE_POWER_X:
	load_pos(POWER_POSX,POWER_POSY,s5,s6)

	la t0,POWER_DIR
	lb t0,0(t0)
	bnez t0,NEG_X_MV
	li t2,4
	j INCREASE_POWER_POSITIONX
NEG_X_MV:
	li t2,-4
INCREASE_POWER_POSITIONX:
	li t3,0
	li s9,1
	check_collision(s5,s6,t2,t3,s9)
	bgtz s9,DESTROY_COLLIDED_OBJECT
	update_pos(s5,s6,POWER_POSX,POWER_POSY,t3)
	clear_sprite(map_start,s5,s6)
	find_grid_pos(s5,s6)
	animate_sprite(power,s6,FALSE,POWER_DIR)
	j SKIP_CASTING
PROPAGATE_POWER_Y:
	#increment_pos_reg(a5,a6,%r1,%r2)
	#update_pos(a5,a6,POWER_POSX,POWER_POSY,t3)
	#check_collision(a5,a6,a5,a6)
SKIP_CASTING:
	li t2 0
	j POS_POWER

# Destruir objeto com o qual o poder colidiu:
DESTROY_COLLIDED_OBJECT:
	li t1,0
	sb t1,POWER_EXIST,t2
	# encontrar a direção de propagação
	find_dir(POWER_DIR,s7,s11,16)

START_DESTRUCTION:
	load_pos(POWER_POSX,POWER_POSY,s5,s6)
	increment_pos_numb(s5,s6,s7,s11)
	clear_sprite(map_start,s5,s6)
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
	change_matrix_value(ENEMY0_XY,CURRENT_MAP,0)
	ret

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