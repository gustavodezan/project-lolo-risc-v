# --------------------------------------
#  Equivalências para o keyboard_input
# --------------------------------------
.eqv RIGHT 100
.eqv UP 119
.eqv LEFT 97
.eqv DOWN 115
.eqv FOUR 4
.eqv ESC 27
.eqv R 114
.eqv SPACE 32


# --------------------------------------
# Funções de Movimentação
# --------------------------------------
# Print Image
# %sprite passa o sprite que será movimentado
# %grid_reg passa o registrador que contém a informação de onde a imagem deve aparecer na tela

# ----------------------
# Animação do Sprite
# ----------------------
# Objetivo da macro de printar sprite:
# Printar ao mesmo tempo em que cuida da animação
# Os sprites serão no formato "strip"
# Onde todos os sprites de movimento ficam em uma mesma imagem
# %state é para saber se o "objeto" está andando ou parado
# %dir é para saber a direção para a qual o sprite está indo (passar 
# ---> Provável que eu tenha que modificar o script de clear
# ----------------------------------------------------------
# Para animar o sprite preciso fazer ele passar por cada sprite dentro do conjunto
# de uma direção
# em t1 tenho o limite dos intervalos de frames
# registradores sobrando: t4,t5,t6
#%sprite,%r1,%r2,%frame,%ret,%temp1,%temp3
.text
LOAD_HUD



