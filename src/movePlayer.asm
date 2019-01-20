movePlayer:; プレイヤの移動
    lda #$01
    sta $4016
    lda #$00
    sta $4016
    lda $4016   ; A
    lda $4016   ; B
    lda $4016   ; SELECT
    lda $4016   ; START
    lda $4016   ; UP
    lda $4016   ; DOWN
    lda $4016   ; LEFT
    and #$01
    beq movePlayer_notLeft
    lda v_nyaX
    sec
    sbc #1
    sta v_nyaX
    lda #%01000000
    sta v_nyaA
    jmp movePlayer_inputEnd
movePlayer_notLeft:
    lda $4016   ; RIGHT
    and #$01
    beq movePlayer_inputEnd
    lda v_nyaX
    clc
    adc #1
    sta v_nyaX
    lda #%00000000
    sta v_nyaA
movePlayer_inputEnd:

    ; プレイヤのY座標
    lda v_nyaY
    sta sp_nyaLT
    sta sp_nyaRT
    clc
    adc #8
    sta sp_nyaLB
    sta sp_nyaRB

    ; プレイヤのX座標
    ldx v_nyaA
    beq movePlayer_directionR
    lda v_nyaX
    sta sp_nyaRT + 3
    sta sp_nyaRB + 3
    clc
    adc #8
    sta sp_nyaLT + 3
    sta sp_nyaLB + 3
    jmp movePlayer_directionE
movePlayer_directionR:
    lda v_nyaX
    sta sp_nyaLT + 3
    sta sp_nyaLB + 3
    clc
    adc #8
    sta sp_nyaRT + 3
    sta sp_nyaRB + 3
movePlayer_directionE:
    stx sp_nyaLT + 2
    stx sp_nyaRT + 2
    stx sp_nyaLB + 2
    stx sp_nyaRB + 2

    ; プレイヤのパターン
    lda #$10
    sta sp_nyaLT + 1
    lda #$11
    sta sp_nyaRT + 1
    lda #$20
    sta sp_nyaLB + 1
    lda #$21
    sta sp_nyaRB + 1

    rts
