        INCLUDE "../Include/BareMetal.i"

ExecSupervisor  EQU -30
exec_AttnFlags  EQU 296

;-----------------------------------------------------------

        SECTION Code,CODE_C

Main:
        MOVE.L  4.w,a6
        SUB.L   a0,a0

        BTST.B  #0,exec_AttnFlags(a6)
        BEQ.B   .NoVBR

        LEA.L   GetVBR(PC),a5
        JSR     ExecSupervisor(a6)
        MOVE.L  d0,a0

.NoVBR:
        LEA     $DFF000,a5

        MOVE.W  INTENAR(a5),d7
        OR.W    #$8000,d7

        MOVE.L  IRQ4(a0),OldVector

        MOVE.L  #AudioHandler,IRQ4(a0)

        ; ---------------------------------------------------
        ; FIX IMPORTANT :
        ; arrêt propre du DMA avant configuration
        ; évite état instable du canal audio
        ; ---------------------------------------------------
        MOVE.W  #$0001,DMACON(a5)      ; stop AUD0 DMA

        ; ---------------------------------------------------
        ; FIX IMPORTANT :
        ; désactivation IRQ audio pendant setup
        ; évite interruption pendant initialisation
        ; ---------------------------------------------------
        MOVE.W  #$0080,INTENA(a5)

        ; setup audio
        MOVE.L  #SndData,AUD0LC(a5)
        MOVE.W  #SndLen>>1,AUD0LEN(a5)
        MOVE.W  #64,AUD0VOL(a5)
        MOVE.W  #296,AUD0PER(a5)

        ; start DMA
        MOVE.W  #$8201,DMACON(a5)

.WaitLoop:
        MOVE.W  AH_Count(PC),d0
        CMPI.W  #2,d0
        BGE.B   .EndWait

        BTST    #6,CIAAPRA
        BNE.B   .WaitLoop

.EndWait:
        MOVE.W  #$0001,DMACON(a5)
        MOVE.W  #$0080,INTENA(a5)

        MOVE.L  OldVector(PC),IRQ4(a0)
        MOVE.W  d7,INTENA(a5)

        RTS

;-----------------------------------------------------------

GetVBR:
        DC.L    $4E7A0801
        RTE

;-----------------------------------------------------------

AudioHandler:
        MOVE.W  #$0080,INTREQ          ; ACK interrupt

        ; ---------------------------------------------------
        ; FIX IMPORTANT :
        ; suppression du changement AUD0LC dans l'IRQ
        ; (causait désynchronisation DMA -> tick / silence)
        ; ---------------------------------------------------

        ADDQ.W  #1,AH_Count

        RTE

;-----------------------------------------------------------

AH_Count:
        DC.W    0

OldVector:
        DC.L    0

;-----------------------------------------------------------

SndData:
        EVEN
        INCBIN "../Assets/Audio-Sample.raw"

SndLen  EQU *-SndData
