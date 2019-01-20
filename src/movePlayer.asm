movePlayer:; プレイヤの移動
    ; キー入力判定
    lda #$01
    sta $4016
    lda #$00
    sta $4016
    lda $4016   ; A
    lda $4016   ; B
    and #$01
    sta v_nyaDash ; Bダッシュ
    lda $4016   ; SELECT
    lda $4016   ; START
    lda $4016   ; UP
    lda $4016   ; DOWN

    lda $4016   ; LEFT
    and #$01
    beq movePlayer_notLeft
    jsr movePlayerLeft ; 左入力（マイナスの加速度up）
    jmp movePlayer_inputEnd
movePlayer_notLeft:
    lda $4016   ; RIGHT
    and #$01
    beq movePlayer_inputNotLR
    jsr movePlayerRight ; 右入力（プラスの加速度up）
    jmp movePlayer_inputEnd
movePlayer_inputNotLR: ; 左右の入力が無い（加速度がゼロで無ければ減速）
    lda v_nyaVXP
    beq movePlayer_inputNotLR_vxp0
    ; プラスの加速度が残っているので減速
    sec
    sbc #8
    bcc movePlayer_inputNotLR_vxpMinus
    sta v_nyaVXP
    jmp movePlayer_inputEnd
movePlayer_inputNotLR_vxpMinus:
    lda #0
    sta v_nyaVXP
    jmp movePlayer_inputEnd
movePlayer_inputNotLR_vxp0:
    lda v_nyaVXM
    beq movePlayer_inputEnd
    ; マイナスの加速度が残っているので減速
    sec
    sbc #8
    bcc movePlayer_inputNotLR_vxmMinus
    sta v_nyaVXM
    jmp movePlayer_inputEnd
movePlayer_inputNotLR_vxmMinus:
    lda #0
    sta v_nyaVXM
movePlayer_inputEnd:

movePlayer_calcX:; 加速度の値を見てプレイヤを動かす
    lda v_nyaVXP
    bne movePlayer_calcXPlus
    lda v_nyaVXM
    bne movePlayer_calcXMinus
    jmp movePlayer_calcXEnd

movePlayer_calcXPlus:
    lda v_nyaXF
    ldy #4
movePlayer_calcXPlusLoop:
    clc
    adc v_nyaVXP
    sta v_nyaXF
    bcc movePlayer_calcXPlusEnd
    inc v_nyaX
movePlayer_calcXPlusEnd:
    dey
    bne movePlayer_calcXPlusLoop
    lda #%00000000
    sta v_nyaA
    jmp movePlayer_calcXEnd

movePlayer_calcXMinus:
    lda v_nyaXF
    ldy #4
movePlayer_calcXMinusLoop:
    sec
    sbc v_nyaVXM
    sta v_nyaXF
    bcs movePlayer_calcXMinusEnd
    dec v_nyaX
movePlayer_calcXMinusEnd:
    dey
    bne movePlayer_calcXMinusLoop
    lda #%01000000
    sta v_nyaA
movePlayer_calcXEnd:

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

movePlayerLeft:
    lda v_nyaVXP
    bne movePlayerLeft_break ; プラスの加速度が残っているので減速
    lda v_nyaVXM
    clc
    adc #$10
    bmi movePlayerLeft_over ; 加速度が上限（7F）を超えた
    sta v_nyaVXM
    rts
movePlayerLeft_over:
    lda #$7f
    sta v_nyaVXM
    rts
movePlayerLeft_break: ; プラスの加速度を減速
    sec
    sbc #$10
    bcs movePlayerLeft_break_end
    sta v_nyaVXP
    rts
movePlayerLeft_break_end:
    lda #0
    sta v_nyaVXP
    rts

movePlayerRight:
    lda v_nyaVXM
    bne movePlayerRight_break ; マイナスの加速度が残っているので減速
    lda v_nyaVXP
    clc
    adc #$10
    bmi movePlayerRight_over ; 加速度が上限（7F）を超えた
    sta v_nyaVXP
    rts
movePlayerRight_over:
    lda #$7f
    sta v_nyaVXP
    rts
movePlayerRight_break: ; プラスの加速度を減速
    sec
    sbc #$10
    bcs movePlayerRight_break_end
    sta v_nyaVXM
    rts
movePlayerRight_break_end:
    lda #0
    sta v_nyaVXM
    rts
