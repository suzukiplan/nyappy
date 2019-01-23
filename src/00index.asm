;------------------------------------------
; 各種定義
;------------------------------------------
.setcpu     "6502"
.autoimport on

; iNES header
.segment "HEADER"
    .byte   $4E, $45, $53, $1A  ; "NES" Header
    .byte   $02                 ; PRG-BANKS
    .byte   $01                 ; CHR-BANKS
    .byte   $01                 ; Vertical Mirror
    .byte   $00                 ; 
    .byte   $00, $00, $00, $00  ; 
    .byte   $00, $00, $00, $00  ; 

.segment "STARTUP"
.proc Reset
    sei
    ldx #$ff
    txs

    ; Screen off
    lda #$00
    sta $2000
    sta $2001

    ; zero page
    lda #$00
    ldx #$00
    ldy #$ff
init_clear_ram0:
    sta $0000, x
    inx
    dey
    bne init_clear_ram0

    ; make palette table
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    ldx #$00
    ldy #$20
copy_pal:
    lda palettes, x
    sta $2007
    inx
    dey
    bne copy_pal

    ; initialize APU
    lda #%00001111
    sta $4015

.include "01title.asm"
.include "02setup.asm"
.include "03main.asm"
.include "movePlayer.asm"

.endproc

palettes:
    ; BG
    .byte   $0f, $00, $10, $20 ; 白色のグラデーション (mask, dark, middle, light)
    .byte   $0f, $18, $28, $38 ; 黄色のグラデーション (mask, dark, middle, light)
    .byte   $0f, $11, $2c, $16 ; 海の背景用 (mask, 海, 水面, 土)
    .byte   $0f, $00, $11, $20 ; タイトル画面
    ; Sprite
    .byte   $0f, $00, $10, $20 ; 白色のグラデーション (mask, dark, middle, light)
    .byte   $0f, $16, $28, $20 ; 爆発 (mask, 赤, 黄, 白)
    .byte   $0f, $18, $28, $38 ; 黄色のグラデーション (mask, dark, middle, light)
    .byte   $0f, $11, $2c, $16 ; 海のスプライト用 (mask, 海, 水面, 土)

nya_patterns_lt:
    .byte   $10, $10, $10, $10 ; おすわり
    .byte   $30, $32, $34, $36 ; 徒歩
    .byte   $50, $52, $54, $56 ; ダッシュ

nya_patterns_rt:
    .byte   $11, $11, $11, $11 ; おすわり
    .byte   $31, $33, $35, $37 ; 徒歩
    .byte   $51, $53, $55, $57 ; ダッシュ

nya_patterns_lb:
    .byte   $20, $20, $20, $20 ; おすわり
    .byte   $40, $42, $44, $46 ; 徒歩
    .byte   $60, $62, $64, $66 ; ダッシュ

nya_patterns_rb:
    .byte   $21, $21, $21, $21 ; おすわり
    .byte   $41, $43, $45, $47 ; 徒歩
    .byte   $61, $63, $65, $67 ; ダッシュ

.org $0000
v_counter:  .byte   $00     ; 00: フレームカウンタ
v_nyaX:     .byte   $00     ; 01: プレイヤX
v_nyaXF:    .byte   $00     ; 02: プレイヤX (小数点以下)
v_nyaY:     .byte   $00     ; 03: プレイヤY
v_nyaVXP:   .byte   $00     ; 04: X方向の加速度 (plus)
v_nyaVXM:   .byte   $00     ; 05: X方向の加速度 (minus)
v_nyaA:     .byte   $00     ; 06: プレイヤのスプライト属性
v_nyaDash:  .byte   $00     ; 07: プレイヤのBダッシュ
v_nyaPtn:   .byte   $00     ; 08: 表示パターン (上位5bitで種別, 下位3bitでアニメーション)

.org $0300
sp_zero:    .byte   $00, $00, $00, $00  ; 00: ウィンドウ分割用
sp_nyaLT:   .byte   $00, $00, $00, $00  ; 01: player(LT)
sp_nyaRT:   .byte   $00, $00, $00, $00  ; 02: player(RT)
sp_nyaLB:   .byte   $00, $00, $00, $00  ; 03: player(LB)
sp_nyaRB:   .byte   $00, $00, $00, $00  ; 04: player(RB)

.segment "VECINFO"
    .word   $0000
    .word   Reset
    .word   $0000

; pattern table
.segment "CHARS"
    .incbin "sprite.chr"
    .incbin "bg.chr"
