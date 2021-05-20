.data
# ------------------------------------
# Valores dos elementos das matrizes
# ------------------------------------
# 0 - FREE: espaços em que o lolo pode andar livremente
# 1 - WALL: colisão com objetos sólidos
# os valores de 2 até 6 serão reservados para diferentes tipos de inimigos?
# 2 - LAGARTA
# 6 - CHEST_OPEN: baús coletável, se lolo passar por cima, ele libera a próxima fase
# 7 - HEARTS: corações coletáveis. Não possuem colisão
# 8 - CHESTS: baús - possuem colisão enquanto o Lolo não tiver coletado todos os corações
# 9 - DOOR: saída da fase
# os valores podem crescer para alem de números de 1 dígito

STAGE_CLEAR: 0

# ----------------
# CURRENT MAP
# ----------------
CURRENT_MAP:
	1,1,1,1,1,1,0,1,1,0,1,
	1,1,1,1,7,0,0,1,1,0,1,
	0,1,1,1,1,1,0,1,1,1,1,
	0,0,1,1,1,1,0,1,1,1,1,
	0,0,0,0,1,1,0,1,1,1,7,
	0,0,0,0,0,0,0,0,1,0,0,
	0,1,1,0,0,0,0,0,0,0,0,
	1,1,1,1,0,0,0,1,1,0,0,
	1,1,1,1,0,0,0,1,1,1,0,
	1,1,1,1,8,0,0,0,1,1,0,
	1,1,1,1,1,1,0,0,0,0,0
MAP: 0

# ----------------
# MAPA 1:
# ----------------
MAP0:	1,1,1,1,1,1,0,1,1,0,1,
	1,1,1,1,7,0,0,1,1,0,1,
	0,1,1,1,1,1,0,1,1,1,1,
	0,0,1,1,1,1,0,1,1,1,1,
	0,0,0,0,1,1,0,1,1,1,7,
	0,0,0,0,0,0,0,0,1,0,0,
	0,1,1,0,0,0,0,0,0,0,0,
	1,1,1,1,0,0,0,1,1,0,0,
	1,1,1,1,0,0,0,1,1,1,0,
	1,1,1,1,8,0,0,0,1,1,0,
	1,1,1,1,1,1,0,0,0,0,0

# Posição dos corações
# 1: X: 120 Y: 48

CHEST0: 0

# ENEMY_0:
ENEMY0_XY: 0,0
ENEMY0_DIR: 0
ENEMY0_OLDDIR: 0
ENEMY0_LIVE: 0
# posição de cada inimigo da matriz em ordem crescente
MAP0_MATRIXPOS_PER_ENEMY: 0
MAP0_ENEMY_COUNT: 0

# Collectables:
EXISTING_COLLECTABLE0: 2
COLLECTABLE0_POS: 216,96,120,48
COLLECTABLE0_MATRIX: 54,15
COLLECT_POWER_INCREASE0: 2,0
COLLECTED0: 0

# Chest: 
CHEST0_POS: 120,176

# ----------------
# MAPA 2:
# ----------------
MAP1:
	1,1,1,1,1,1,0,1,1,0,1,
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

# ENEMY:
ENEMY1_XY: 152,112
ENEMY1_DIR: 0
ENEMY1_OLDDIR: 0
ENEMY1_LIVE: 1
# posição de cada inimigo da matriz em ordem crescente
MAP1_MATRIXPOS_PER_ENEMY: 61
MAP1_ENEMY_COUNT: 1

# Collectables:
EXISTING_COLLECTABLE1: 2
COLLECTABLE1_POS: 216,96,120,48
COLLECTABLE1_MATRIX: 54,15
COLLECT_POWER_INCREASE1: 2,0
COLLECTED1: 0

# Chest: 
CHEST1_POS: 120,176	

# ----------------
# MAPA 3:
# ----------------
MAP2:
	0,0,0,0,0,9,0,0,0,0,0,
	0,0,0,1,1,0,0,1,0,0,0,
	0,0,1,1,7,0,1,1,1,0,0,
	1,0,1,1,1,0,1,1,1,0,1,
	1,0,1,1,1,0,0,1,0,0,1,
	1,0,0,0,0,0,0,0,0,0,1,
	1,0,1,1,1,0,1,1,1,0,1,
	1,0,1,1,1,2,1,1,1,0,1,
	0,0,1,1,1,7,7,1,1,0,0,
	0,0,1,1,1,1,1,1,1,0,0, 
	8,0,0,0,0,0,0,0,0,0,0
	
# ENEMY:
ENEMY2_XY: 136,144
ENEMY2_DIR: 0
ENEMY2_OLDDIR: 0
ENEMY2_LIVE: 1
# posição de cada inimigo da matriz em ordem crescente
MAP2_MATRIXPOS_PER_ENEMY: 82
MAP2_ENEMY_COUNT: 1

# Collectables:
EXISTING_COLLECTABLE2: 3
COLLECTABLE2_POS: 120,64,136,160,152,160
COLLECTABLE2_MATRIX: 26,93,94
COLLECT_POWER_INCREASE2: 2,0,0
COLLECTED2: 0

# Chest: 
CHEST2_POS: 56,192

# ----------------
# MAPA 4:
# ----------------
MAP3:
	0,0,0,0,1,9,1,0,0,0,0,
	7,0,0,0,1,0,1,0,0,0,7,
	0,1,0,0,1,0,1,0,0,1,0,
	0,0,1,0,1,0,1,0,1,0,0,
	0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,1,
	1,1,1,1,1,0,1,1,1,1,1,
	1,7,0,0,1,0,1,0,0,7,1,
	1,1,1,0,1,0,1,0,1,1,1,
	8,2,0,0,0,0,0,0,0,0,0, 
	1,0,0,0,0,7,0,0,0,0,0

# ENEMY:
ENEMY3_XY: 72,176
ENEMY3_DIR: 0
ENEMY3_OLDDIR: 0
ENEMY3_LIVE: 1
# posição de cada inimigo da matriz em ordem crescente
MAP3_MATRIXPOS_PER_ENEMY: 100
MAP3_ENEMY_COUNT: 1

# Collectables:
EXISTING_COLLECTABLE3: 5
COLLECTABLE3_POS: 72,176,56,48,216,48,72,144,200,144,136,192
COLLECTABLE3_MATRIX: 11,21,78,86,115
COLLECT_POWER_INCREASE3: 2,2,0,0,0
COLLECTED3: 0

# Chest: 
CHEST3_POS: 56,176

# ----------------
# MAPA 5:
# ----------------
MAP4:
	0,0,0,0,0,9,0,0,0,0,0,
	0,0,0,0,1,1,1,0,0,0,0,
	0,0,0,0,1,8,1,0,0,0,0,
	1,1,0,1,1,0,1,0,0,0,0,
	1,0,0,0,1,0,1,0,0,0,0,
	1,0,1,0,1,0,1,1,1,1,0,
	1,7,0,7,1,0,0,0,1,0,0,
	1,1,1,1,1,0,0,0,0,0,0,
	1,0,0,0,0,0,0,2,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,
	1,0,1,0,0,0,0,0,0,1,8


