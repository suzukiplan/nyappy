mainloop:
    ; increment frame counter
    ldx v_counter
    inx
    stx v_counter

    ; プレイヤのY座標
    lda v_nyaY
    sta sp_nyaLT
    sta sp_nyaRT
    clc
    adc #8
    sta sp_nyaLB
    sta sp_nyaRB

    ; プレイヤのX座標
    lda v_nyaX
    sta sp_nyaLT + 3
    sta sp_nyaLB + 3
    clc
    adc #8
    sta sp_nyaRT + 3
    sta sp_nyaRB + 3

    ; プレイヤのパターン
    lda #$10
    sta sp_nyaLT + 1
    lda #$11
    sta sp_nyaRT + 1
    lda #$20
    sta sp_nyaLB + 1
    lda #$21
    sta sp_nyaRB + 1

    ; プレイヤの属性
    lda #%00000000
    sta sp_nyaLT + 2
    sta sp_nyaRT + 2
    sta sp_nyaLB + 2
    sta sp_nyaRB + 2

mainloop_wait_vBlank:
    lda $2002
    bpl mainloop_wait_vBlank ; wait for vBlank
    lda #$3
    sta $4014
    jmp mainloop
