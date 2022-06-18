.INCLUDE "./files/utility.s"

.GLOBAL _main

.DATA
array:  .FILL 8, 1, 48 # Array inizialmente a 0 (codificati in ASCII)
pos:    .BYTE 0x00 # Posizione del cursore

.TEXT
_main:  NOP

        # Stampa l'array attuale
punto1: LEA array, %EBX
        CALL stampa

        # Validazione comandi in input
input:  CALL inchar
        CMP $'a', %AL
        JE sinistra
        CMP $'d', %AL
        JE destra
        CMP $'s', %AL
        JE somma
        CMP $'0', %AL
        JB input
        CMP $'9', %AL
        JBE numero
        JMP input

# Comando che sposta il cursore a sinistra ('a')
sinistra:
        CMPB $0, pos
        JE input # Cursore già al limite sinistro
        DECB pos
        JMP punto1

# Comando che sposta il cursore a destra ('d')
destra:
        CMPB $7, pos
        JE input # Cursore già al limite destro
        INCB pos
        JMP punto1

# Comando che sovrascrive il cursore ('0-9')
numero:
        XOR %EDX, %EDX
        MOVB pos, %DL
        MOV %AL, array(%EDX)
        JMP punto1

# Comando che calcola la somma ('s')
somma:
        XOR %ECX, %ECX
        XOR %DL, %DL # DL = somma delle cifre dell'array
ciclo1: ADD array(%ECX), %DL
        SUB $'0', %DL # Converto da codifica ASCII a numero
        INC %ECX
        CMP $8, %ECX
        JNE ciclo1
        MOV %DL, %AL
        CALL outdecimal_byte
        CALL newline
        JMP fine

fine:   XOR %EAX, %EAX # EAX = 0 -> programma terminato correttamente
        RET

# ############ Sottoprogramma di stampa ############
# Programma che stampa lo stato attuale dell'array puntato da EBX
# Ingresso: %EBX -> puntatore al primo elemento dell'array
stampa: PUSH %ECX
        PUSH %DX
        PUSH %AX

        XOR %ECX, %ECX
ciclo:  XOR %DL, %DL
        CMP pos, %CL
        JNE next
        MOV $1, %DL # DL = 1 se siamo nella posizione del cursore
        MOV $'(', %AL
        CALL outchar
next:   MOV (%EBX, %ECX, 1), %AL
        CALL outchar
        CMP $1, %DL # DL = 1 se siamo nella posizione del cursore
        JNE dopo
        MOV $')', %AL
        CALL outchar
dopo:   INC %CL
        CMP $8, %CL
        JNE ciclo
        CALL newline

        POP %AX
        POP %DX
        POP %ECX
        RET
