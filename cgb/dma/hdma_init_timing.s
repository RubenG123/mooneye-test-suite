; This test tries to see what happens when we start hdma at the "start" of ly=143
; We should expect 1 block to be copied
; Also uses wram banking

; TODO: what happens if hdma is triggered mid hblank??

.define CART_CGB

.include "common.s"

  ; set up hdma src and dest
  ; src: 0xC000
  ; dest: 0x8000

  ; HDMA1
  ld c, $51 
  ld a, $C0
  ld ($FF00+c), a

  ; HDMA2
  ld c, $52 
  ld a, $00
  ld ($FF00+C), a

  ; HDMA3
  ld c, $53
  ld ($FF00+C), a

  ; HDMA4
  ld c, $54
  ld ($FF00+C), a

  ; clear VRAM
  ld hl, $8000
  ld a, $0
.repeat 32 INDEX i
  ld (hl+), a
.endr

  ;set wram bank (because we can?)
  ld c, $70
  ld a, $01
  ld ($FF00+c), a 

  ;init working ram
  ld hl, $C000
  ld a, $07
.repeat 32 INDEX i
  ld (hl+), a
.endr

  ; wait for ly=143
  ld c, $44
- ld a, ($FF00+C)
  cp a, 143 ;
  jr nz, - 

  ; HDMA5
  ld c, $55
  ld a, $81 ; request to copy 2 blocks
  ld ($FF00+C), a

  wait_vblank

; only one block should be copied
assert_copy:
  ld hl, $8000

.repeat 16 INDEX i
  ld a, (hl+)
  ld c, i
  cp a, $07
  jp nz, test_fail_assert_copy
.endr

.repeat 16 INDEX i
  ld a, i
  add a, $10
  ld c, a

  ld a, (hl+)
  cp a, $00
  jp nz, test_finish
.endr




test_finish:
  ld b, a

  setup_assertions
  assert_b $00
  assert_c 31
  quit_check_asserts

test_fail_assert_copy:
  ld b, a

  setup_assertions
  assert_b $07
  assert_c 31
  quit_check_asserts

.org INTR_VEC_SERIAL
  inc e
  jp test_finish