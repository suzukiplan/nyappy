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

.org $0000
v_counter:  .byte   $00     ; 00: フレームカウンタ
v_nyaX:     .byte   $00     ; 01: プレイヤX
v_nyaY:     .byte   $00     ; 02: プレイヤY

.org $0300
sp_nyaLT:   .byte   $00, $00, $00, $00  ; 00: player(LT)
sp_nyaRT:   .byte   $00, $00, $00, $00  ; 00: player(RT)
sp_nyaLB:   .byte   $00, $00, $00, $00  ; 00: player(LB)
sp_nyaRB:   .byte   $00, $00, $00, $00  ; 00: player(RB)

.segment "VECINFO"
    .word   $0000
    .word   Reset
    .word   $0000

; pattern table
.segment "CHARS"
    .incbin "sprite.chr"
    .incbin "bg.chr"
