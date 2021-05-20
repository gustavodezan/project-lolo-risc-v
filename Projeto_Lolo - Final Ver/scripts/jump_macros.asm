# --------------------------------------
#  Equival�ncias para o keyboard_input
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
# Fun��es de Movimenta��o
# --------------------------------------
# Print Image
# %sprite passa o sprite que ser� movimentado
# %grid_reg passa o registrador que cont�m a informa��o de onde a imagem deve aparecer na tela

# ----------------------
# Anima��o do Sprite
# ----------------------
# Objetivo da macro de printar sprite:
# Printar ao mesmo tempo em que cuida da anima��o
# Os sprites ser�o no formato "strip"
# Onde todos os sprites de movimento ficam em uma mesma imagem
# %state � para saber se o "objeto" est� andando ou parado
# %dir � para saber a dire��o para a qual o sprite est� indo (passar 
# ---> Prov�vel que eu tenha que modificar o script de clear
# ----------------------------------------------------------
# Para animar o sprite preciso fazer ele passar por cada sprite dentro do conjunto
# de uma dire��o
# em t1 tenho o limite dos intervalos de frames
# registradores sobrando: t4,t5,t6
#%sprite,%r1,%r2,%frame,%ret,%temp1,%temp3
.text
LOAD_HUD



