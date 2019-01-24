movePlayer:; プレイヤの移動
    ; 4フレームに1回アニメーション
    lda v_counter
    and #%00000011
    cmp #%00000011
    bne movePlayer_endAnimate
    lda v_nyaPtn
    and #%00000011
    cmp #%00000011
    beq movePlayer_resetAnimate
    clc
    adc #1
    sta v_nyaPtn
    jmp movePlayer_endAnimate
movePlayer_resetAnimate:
    lda v_nyaPtn
    and #%11111100
    sta v_nyaPtn
movePlayer_endAnimate:

    ; キー入力判定
    lda #$01
    sta $4016
    lda #$00
    sta $4016
    lda $4016   ; A
    and #$01
    beq movePlayer_endPushA
    lda v_nyaJmp
    bne movePlayer_endPushA
    lda #1
    sta v_nyaJmp
movePlayer_endPushA:
    lda $4016   ; B
    and #$01
    sta v_nyaDash ; Bダッシュ
    lda $4016   ; SELECT
    lda $4016   ; START
    lda $4016   ; UP
    lda $4016   ; DOWN

    lda #$00
    sta v_nyaKey
    lda $4016   ; LEFT
    and #$01
    beq movePlayer_notLeft
    lda #$ff
    sta v_nyaKey
    jsr movePlayerLeft ; 左入力（マイナスの加速度up）
    jmp movePlayer_inputEnd
movePlayer_notLeft:
    lda $4016   ; RIGHT
    and #$01
    beq movePlayer_inputNotLR
    lda #$01
    sta v_nyaKey
    jsr movePlayerRight ; 右入力（プラスの加速度up）
    jmp movePlayer_inputEnd
movePlayer_inputNotLR: ; 左右の入力が無い（加速度がゼロで無ければ減速）
    lda v_nyaVXP
    beq movePlayer_inputNotLR_vxp0
    ; プラスの加速度が残っているので減速
    sec
    sbc #5
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
    sbc #5
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
    ; 加速度0なので表示パターンを「おすわり」にする
    lda v_nyaPtn
    and #%00000011
    sta v_nyaPtn
    jmp movePlayer_calcXEnd

movePlayer_calcXPlus:
    ; ダッシュ中に逆方向のキー（左）を入れている場合はブレーキ状態
    lda v_nyaDash
    beq movePlayer_calcXPlus_notBreak
    lda v_nyaKey
    cmp #$ff
    bne movePlayer_calcXPlus_notBreak
    lda v_nyaPtn
    and #%00000011
    ora #%00010000
    sta v_nyaPtn
    jmp movePlayer_calcXPlus_start
movePlayer_calcXPlus_notBreak:
    ; 加速度が$F0未満なら徒歩、90以上ならダッシュのパターンを設定
    lda v_nyaVXP
    cmp #$F0
    bcc movePlayer_calcXPlus_walk
    lda v_nyaPtn
    and #%00000011
    ora #%00001000
    sta v_nyaPtn
    jmp movePlayer_calcXPlus_start
movePlayer_calcXPlus_walk:
    lda v_nyaPtn
    and #%00000011
    ora #%00000100
    sta v_nyaPtn
movePlayer_calcXPlus_start:
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
    ; ダッシュ中に逆方向のキー（右）を入れている場合はブレーキ状態
    lda v_nyaDash
    beq movePlayer_calcXMinus_notBreak
    lda v_nyaKey
    cmp #$01
    bne movePlayer_calcXMinus_notBreak
    lda v_nyaPtn
    and #%00000011
    ora #%00010000
    sta v_nyaPtn
    jmp movePlayer_calcXMinus_start
movePlayer_calcXMinus_notBreak:
    ; 加速度が$F0未満なら徒歩、90以上ならダッシュのパターンを設定
    lda v_nyaVXM
    cmp #$F0
    bcc movePlayer_calcXMinus_walk
    lda v_nyaPtn
    and #%00000011
    ora #%00001000
    sta v_nyaPtn
    jmp movePlayer_calcXMinus_start
movePlayer_calcXMinus_walk:
    lda v_nyaPtn
    and #%00000011
    ora #%00000100
    sta v_nyaPtn
movePlayer_calcXMinus_start:
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

    ; ジャンプ
    ldx v_nyaJmp
    beq movePlayer_endJump
    lda v_nyaPtn
    and #%00000011
    ora #%00001100
    sta v_nyaPtn
    lda nya_jump_table, x
    clc
    adc v_nyaY
    sta v_nyaY
    inx
    stx v_nyaJmp
    cpx #38
    bne movePlayer_endJump
    ldx #0
    stx v_nyaJmp
movePlayer_endJump:

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
    ldx v_nyaPtn
    lda nya_patterns_lt, x
    sta sp_nyaLT + 1
    lda nya_patterns_rt, x
    sta sp_nyaRT + 1
    lda nya_patterns_lb, x
    sta sp_nyaLB + 1
    lda nya_patterns_rb, x
    sta sp_nyaRB + 1
    rts

movePlayerLeft:
    lda v_nyaDash
    beq movePlayerLeft_notDash
    jmp movePlayerLeftD
movePlayerLeft_notDash:
    lda v_nyaVXP
    bne movePlayerLeft_break ; プラスの加速度が残っているので減速
    lda v_nyaVXM
    clc
    adc #$08
    bmi movePlayerLeft_over ; 加速度が上限（7F）を超えた
    bcs movePlayerLeftD_over ; 加速度が上限（FF）を超えた
    sta v_nyaVXM
    rts
movePlayerLeft_over:
    rts
movePlayerLeft_break: ; プラスの加速度を減速
    sec
    sbc #$0c
    bcc movePlayerLeft_break_end
    sta v_nyaVXP
    rts
movePlayerLeft_break_end:
    lda #0
    sta v_nyaVXP
    rts
movePlayerLeftD: ; ダッシュ中の場合
    lda v_nyaVXP
    bne movePlayerLeftD_break ; プラスの加速度が残っているので減速
    lda v_nyaVXM
    clc
    adc #$08
    bcs movePlayerLeftD_over ; 加速度が上限（FF）を超えた
    sta v_nyaVXM
    rts
movePlayerLeftD_over:
    lda #$ff
    sta v_nyaVXM
    rts
movePlayerLeftD_break: ; プラスの加速度を減速
    sec
    sbc #$0c
    bcc movePlayerLeftD_break_end
    sta v_nyaVXP
    rts
movePlayerLeftD_break_end:
    lda #0
    sta v_nyaVXP
    rts

movePlayerRight:
    lda v_nyaDash
    beq movePlayerRight_notDash
    jmp movePlayerRightD
movePlayerRight_notDash:
    lda v_nyaVXM
    bne movePlayerRight_break ; マイナスの加速度が残っているので減速
    lda v_nyaVXP
    clc
    adc #$08
    bmi movePlayerRight_over ; 加速度が上限（7F）を超えた
    bcs movePlayerRightD_over ; 加速度が上限（FF）を超えた
    sta v_nyaVXP
    rts
movePlayerRight_over:
    rts
movePlayerRight_break: ; マイナスの加速度を減速
    sec
    sbc #$0c
    bcc movePlayerRight_break_end
    sta v_nyaVXM
    rts
movePlayerRight_break_end:
    lda #0
    sta v_nyaVXM
    rts
movePlayerRightD:
    lda v_nyaVXM
    bne movePlayerRightD_break ; マイナスの加速度が残っているので減速
    lda v_nyaVXP
    clc
    adc #$08
    bcs movePlayerRightD_over ; 加速度が上限（FF）を超えた
    sta v_nyaVXP
    rts
movePlayerRightD_over:
    lda #$ff
    sta v_nyaVXP
    rts
movePlayerRightD_break: ; マイナスの加速度を減速
    sec
    sbc #$0c
    bcc movePlayerRightD_break_end
    sta v_nyaVXM
    rts
movePlayerRightD_break_end:
    lda #0
    sta v_nyaVXM
    rts
