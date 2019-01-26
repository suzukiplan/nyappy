    ; プレイヤ初期化
    lda #32
    sta v_nyaX
    lda #192
    sta v_nyaY

    ; マップタイルを描画
    lda #$22
    sta $2006
    lda #$c0
    sta $2006
    ldx #0
setup_map_tile_loop_22c0:
    lda map_tile_pattern_A, x
    sta $2007
    inx
    bne setup_map_tile_loop_22c0

    lda #$22
    sta $2006
    lda #$40
    sta $2006
    ldx #0
setup_map_tile_loop_2240:
    lda map_tile_pattern_A, x
    sta $2007
    inx
    bne setup_map_tile_loop_2240

    lda #$21
    sta $2006
    lda #$c0
    sta $2006
    ldx #0
setup_map_tile_loop_21c0:
    lda map_tile_pattern_A, x
    sta $2007
    inx
    bne setup_map_tile_loop_21c0

    lda #$21
    sta $2006
    lda #$40
    sta $2006
    ldx #0
setup_map_tile_loop_2140:
    lda map_tile_pattern_A, x
    sta $2007
    inx
    bne setup_map_tile_loop_2140

    lda #$20
    sta $2006
    lda #$c0
    sta $2006
    ldx #0
setup_map_tile_loop_20c0:
    lda map_tile_pattern_A, x
    sta $2007
    inx
    bne setup_map_tile_loop_20c0

    lda #$20
    sta $2006
    lda #$40
    sta $2006
    ldx #0
setup_map_tile_loop_2040:
    lda map_tile_pattern_A, x
    sta $2007
    inx
    bne setup_map_tile_loop_2040

setup_wait_vBlank:
    lda $2002
    bpl setup_wait_vBlank ; wait for vBlank
    lda #$00
    sta $2005
    lda #$00
    sta $2005

    ; screen on
    ; bit7: nmi interrupt
    ; bit6: PPU type (0=master, 1=slave)
    ; bit5: size of sprite (0=8x8, 1=8x16)
    ; bit4: BG chr table (0=$0000, 1=$1000)
    ; bit3: sprite chr table (0=$0000, 1=$1000)
    ; bit2: address addition (0=+1, 1=+32)
    ; bit1~0: main screen (0=$2000, 1=$2400, 2=$2800, 3=$2c00)
    ;     76543210
    lda #%00010000
    sta $2000

    ; bit7: red
    ; bit6: green
    ; bit5: blue
    ; bit4: sprite
    ; bit3: BG
    ; bit2: visible left-top 8x sprite
    ; bit1: visible left-top 8x BG
    ; bit0: color (0=full, 1=mono)
    lda #%00011000
    sta $2001
