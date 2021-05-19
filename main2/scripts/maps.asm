.data
# ------------------------------------
# Valores dos elementos das matrizes
# ------------------------------------
# 0 - FREE: espa�os em que o lolo pode andar livremente
# 1 - WALL: colis�o com objetos s�lidos
# os valores de 2 at� 6 ser�o reservados para diferentes tipos de inimigos?
# 2 - LAGARTA
# 7 - HEARTS: cora��es colet�veis. N�o possuem colis�o
# 8 - CHESTS: ba�s - possuem colis�o enquanto o Lolo n�o tiver coletado todos os cora��es
# 9 - DOOR: sa�da da fase
# os valores podem crescer para alem de n�meros de 1 d�gito

# ----------------
# CURRENT MAP
# ----------------
CURRENT_MAP:
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

# ----------------
# MAPA 1:
# ----------------
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
	
# Posi��o dos cora��es
# 1: X: 120 Y: 48

MAP: 0
CHEST: 0

# ENEMY_0:
ENEMY0_XY: 152,112
ENEMY0_DIR: 0
ENEMY0_OLDDIR: 0
ENEMY0_LIVE: 1

# Collectables:
COLLECTABLE: 216,96
COLLECT_POWER_INCREASE: 2

# Chest: 


# posi��o de cada inimigo da matriz em ordem crescente
MAP0_MATRIXPOS_PER_ENEMY: 61
MAP0_ENEMY_COUNT: 1



	

# ----------------
# MAPA 2:
# ----------------
MAP1:
	0,0,0,0,0,9,0,0,0,0,0,
	0,0,2,1,1,0,1,1,2,0,0,
	0,0,1,1,7,0,1,1,1,0,0,
	1,0,1,1,1,0,1,1,1,0,1,
	1,0,1,1,1,0,1,1,1,0,1,
	1,0,0,0,0,0,0,0,0,0,1,
	1,0,1,1,1,0,1,1,1,0,1,
	1,0,1,1,1,0,1,1,1,0,1,
	0,0,1,1,1,0,7,1,1,0,0,
	0,0,1,1,1,2,1,1,1,0,0, 
	8,0,0,0,0,0,0,0,0,0,0
# ----------------
# MAPA 3:
# ----------------
MAP2:
	0,0,0,0,1,9,1,0,0,0,0,
	2,0,0,0,1,0,1,0,0,0,2,
	0,1,0,0,1,0,1,0,0,1,0,
	0,0,1,0,1,0,1,0,1,0,0,
	0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,
	1,1,1,1,1,0,1,1,1,1,1,
	1,7,0,0,1,0,1,0,0,7,1,
	1,1,1,0,1,0,1,0,1,1,1,
	0,0,0,0,0,0,0,0,0,0,0, 
	8,0,3,0,0,7,0,0,0,0,0
# ----------------
# MAPA 4:
# ----------------
MAP3:
	0,0,0,0,0,0,0,7,1,9,2,
	0,1,1,1,1,1,1,1,1,0,1,
	0,0,0,0,0,0,0,0,0,0,1,
	0,0,1,0,1,0,1,0,1,0,1,
	0,0,1,0,1,0,1,0,1,0,1,
	0,0,1,7,1,0,1,0,1,0,0,
	0,0,1,2,1,0,1,8,1,0,0,
	0,0,1,1,1,0,1,1,1,0,0,
	0,0,0,0,0,0,0,0,0,0,0,
	0,1,1,1,1,1,1,1,1,1,1,
	0,0,0,2,2,2,0,0,0,0,0,
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
	1,7,0,7,1,0,0,0,2,0,0,
	1,1,1,1,1,0,0,0,0,0,0,
	2,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,
	1,0,3,0,0,0,0,0,0,3,8,


