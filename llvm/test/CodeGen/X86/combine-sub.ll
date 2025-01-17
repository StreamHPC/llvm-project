; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefixes=CHECK,SSE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=CHECK,AVX

; fold (sub x, 0) -> x
define <4 x i32> @combine_vec_sub_zero(<4 x i32> %a) {
; CHECK-LABEL: combine_vec_sub_zero:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %1 = sub <4 x i32> %a, zeroinitializer
  ret <4 x i32> %1
}

; fold (sub x, x) -> 0
define <4 x i32> @combine_vec_sub_self(<4 x i32> %a) {
; SSE-LABEL: combine_vec_sub_self:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_sub_self:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = sub <4 x i32> %a, %a
  ret <4 x i32> %1
}

; fold (sub x, c) -> (add x, -c)
define <4 x i32> @combine_vec_sub_constant(<4 x i32> %x) {
; SSE-LABEL: combine_vec_sub_constant:
; SSE:       # %bb.0:
; SSE-NEXT:    psubd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_sub_constant:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsubd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = sub <4 x i32> %x, <i32 0, i32 1, i32 2, i32 3>
  ret <4 x i32> %1
}

; Canonicalize (sub -1, x) -> ~x, i.e. (xor x, -1)
define <4 x i32> @combine_vec_sub_negone(<4 x i32> %x) {
; SSE-LABEL: combine_vec_sub_negone:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE-NEXT:    pxor %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_sub_negone:
; AVX:       # %bb.0:
; AVX-NEXT:    vpcmpeqd %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpxor %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = sub <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, %x
  ret <4 x i32> %1
}

; fold A-(A-B) -> B
define <4 x i32> @combine_vec_sub_sub(<4 x i32> %a, <4 x i32> %b) {
; SSE-LABEL: combine_vec_sub_sub:
; SSE:       # %bb.0:
; SSE-NEXT:    movaps %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_sub_sub:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovaps %xmm1, %xmm0
; AVX-NEXT:    retq
  %1 = sub <4 x i32> %a, %b
  %2 = sub <4 x i32> %a, %1
  ret <4 x i32> %2
}

; fold (A+B)-A -> B
define <4 x i32> @combine_vec_sub_add0(<4 x i32> %a, <4 x i32> %b) {
; SSE-LABEL: combine_vec_sub_add0:
; SSE:       # %bb.0:
; SSE-NEXT:    movaps %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_sub_add0:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovaps %xmm1, %xmm0
; AVX-NEXT:    retq
  %1 = add <4 x i32> %a, %b
  %2 = sub <4 x i32> %1, %a
  ret <4 x i32> %2
}

; fold (A+B)-B -> A
define <4 x i32> @combine_vec_sub_add1(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: combine_vec_sub_add1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %1 = add <4 x i32> %a, %b
  %2 = sub <4 x i32> %1, %b
  ret <4 x i32> %2
}

; fold C2-(A+C1) -> (C2-C1)-A
define <4 x i32> @combine_vec_sub_constant_add(<4 x i32> %a) {
; SSE-LABEL: combine_vec_sub_constant_add:
; SSE:       # %bb.0:
; SSE-NEXT:    pmovsxbd {{.*#+}} xmm1 = [3,1,4294967295,4294967293]
; SSE-NEXT:    psubd %xmm0, %xmm1
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_sub_constant_add:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovsxbd {{.*#+}} xmm1 = [3,1,4294967295,4294967293]
; AVX-NEXT:    vpsubd %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %1 = add <4 x i32> %a, <i32 0, i32 1, i32 2, i32 3>
  %2 = sub <4 x i32> <i32 3, i32 2, i32 1, i32 0>, %1
  ret <4 x i32> %2
}

; fold ((A+(B+C))-B) -> A+C
define <4 x i32> @combine_vec_sub_add_add(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; SSE-LABEL: combine_vec_sub_add_add:
; SSE:       # %bb.0:
; SSE-NEXT:    paddd %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_sub_add_add:
; AVX:       # %bb.0:
; AVX-NEXT:    vpaddd %xmm2, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = add <4 x i32> %b, %c
  %2 = add <4 x i32> %a, %1
  %3 = sub <4 x i32> %2, %b
  ret <4 x i32> %3
}

; fold ((A+(B-C))-B) -> A-C
define <4 x i32> @combine_vec_sub_add_sub(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; SSE-LABEL: combine_vec_sub_add_sub:
; SSE:       # %bb.0:
; SSE-NEXT:    psubd %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_sub_add_sub:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsubd %xmm2, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = sub <4 x i32> %b, %c
  %2 = add <4 x i32> %a, %1
  %3 = sub <4 x i32> %2, %b
  ret <4 x i32> %3
}

; fold ((A-(B-C))-C) -> A-B
define <4 x i32> @combine_vec_sub_sub_sub(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c) {
; SSE-LABEL: combine_vec_sub_sub_sub:
; SSE:       # %bb.0:
; SSE-NEXT:    psubd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_sub_sub_sub:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = sub <4 x i32> %b, %c
  %2 = sub <4 x i32> %a, %1
  %3 = sub <4 x i32> %2, %c
  ret <4 x i32> %3
}

; fold undef-A -> undef
define <4 x i32> @combine_vec_sub_undef0(<4 x i32> %a) {
; CHECK-LABEL: combine_vec_sub_undef0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %1 = sub <4 x i32> undef, %a
  ret <4 x i32> %1
}

; fold A-undef -> undef
define <4 x i32> @combine_vec_sub_undef1(<4 x i32> %a) {
; CHECK-LABEL: combine_vec_sub_undef1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %1 = sub <4 x i32> %a, undef
  ret <4 x i32> %1
}

; sub X, (sext Y i1) -> add X, (and Y 1)
define <4 x i32> @combine_vec_add_sext(<4 x i32> %x, <4 x i1> %y) {
; SSE-LABEL: combine_vec_add_sext:
; SSE:       # %bb.0:
; SSE-NEXT:    pslld $31, %xmm1
; SSE-NEXT:    psrad $31, %xmm1
; SSE-NEXT:    psubd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_add_sext:
; AVX:       # %bb.0:
; AVX-NEXT:    vpslld $31, %xmm1, %xmm1
; AVX-NEXT:    vpsrad $31, %xmm1, %xmm1
; AVX-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = sext <4 x i1> %y to <4 x i32>
  %2 = sub <4 x i32> %x, %1
  ret <4 x i32> %2
}

; sub X, (sextinreg Y i1) -> add X, (and Y 1)
define <4 x i32> @combine_vec_sub_sextinreg(<4 x i32> %x, <4 x i32> %y) {
; SSE-LABEL: combine_vec_sub_sextinreg:
; SSE:       # %bb.0:
; SSE-NEXT:    pslld $31, %xmm1
; SSE-NEXT:    psrad $31, %xmm1
; SSE-NEXT:    psubd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_sub_sextinreg:
; AVX:       # %bb.0:
; AVX-NEXT:    vpslld $31, %xmm1, %xmm1
; AVX-NEXT:    vpsrad $31, %xmm1, %xmm1
; AVX-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = shl <4 x i32> %y, <i32 31, i32 31, i32 31, i32 31>
  %2 = ashr <4 x i32> %1, <i32 31, i32 31, i32 31, i32 31>
  %3 = sub <4 x i32> %x, %2
  ret <4 x i32> %3
}

; sub C1, (xor X, C1) -> add (xor X, ~C2), C1+1
define i32 @combine_sub_xor_consts(i32 %x) {
; CHECK-LABEL: combine_sub_xor_consts:
; CHECK:       # %bb.0:
; CHECK-NEXT:    # kill: def $edi killed $edi def $rdi
; CHECK-NEXT:    xorl $-32, %edi
; CHECK-NEXT:    leal 33(%rdi), %eax
; CHECK-NEXT:    retq
  %xor = xor i32 %x, 31
  %sub = sub i32 32, %xor
  ret i32 %sub
}

define <4 x i32> @combine_vec_sub_xor_consts(<4 x i32> %x) {
; SSE-LABEL: combine_vec_sub_xor_consts:
; SSE:       # %bb.0:
; SSE-NEXT:    pxor {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE-NEXT:    paddd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_sub_xor_consts:
; AVX:       # %bb.0:
; AVX-NEXT:    vpxor {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vpaddd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
  %xor = xor <4 x i32> %x, <i32 28, i32 29, i32 -1, i32 -31>
  %sub = sub <4 x i32> <i32 1, i32 2, i32 3, i32 4>, %xor
  ret <4 x i32> %sub
}

define <4 x i32> @combine_vec_neg_xor_consts(<4 x i32> %x) {
; SSE-LABEL: combine_vec_neg_xor_consts:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE-NEXT:    psubd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_neg_xor_consts:
; AVX:       # %bb.0:
; AVX-NEXT:    vpcmpeqd %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %xor = xor <4 x i32> %x, <i32 -1, i32 -1, i32 -1, i32 -1>
  %sub = sub <4 x i32> zeroinitializer, %xor
  ret <4 x i32> %sub
}

; With AVX, this could use broadcast (an extra load) and
; load-folded 'add', but currently we favor the virtually
; free pcmpeq instruction.

define void @PR52032_oneuse_constant(<8 x i32>* %p) {
; SSE-LABEL: PR52032_oneuse_constant:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqu (%rdi), %xmm0
; SSE-NEXT:    movdqu 16(%rdi), %xmm1
; SSE-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE-NEXT:    psubd %xmm2, %xmm1
; SSE-NEXT:    psubd %xmm2, %xmm0
; SSE-NEXT:    movdqu %xmm0, (%rdi)
; SSE-NEXT:    movdqu %xmm1, 16(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: PR52032_oneuse_constant:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqu (%rdi), %ymm0
; AVX-NEXT:    vpcmpeqd %ymm1, %ymm1, %ymm1
; AVX-NEXT:    vpsubd %ymm1, %ymm0, %ymm0
; AVX-NEXT:    vmovdqu %ymm0, (%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %i3 = load <8 x i32>, <8 x i32>* %p, align 4
  %i4 = add nsw <8 x i32> %i3, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  store <8 x i32> %i4, <8 x i32>* %p, align 4
  ret void
}

; With AVX, we don't transform 'add' to 'sub' because that prevents load folding.
; With SSE, we do it because we can't load fold the other op without overwriting the constant op.

define void @PR52032(<8 x i32>* %p) {
; SSE-LABEL: PR52032:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE-NEXT:    movdqu (%rdi), %xmm1
; SSE-NEXT:    movdqu 16(%rdi), %xmm2
; SSE-NEXT:    movdqu 32(%rdi), %xmm3
; SSE-NEXT:    movdqu 48(%rdi), %xmm4
; SSE-NEXT:    psubd %xmm0, %xmm2
; SSE-NEXT:    psubd %xmm0, %xmm1
; SSE-NEXT:    movdqu %xmm1, (%rdi)
; SSE-NEXT:    movdqu %xmm2, 16(%rdi)
; SSE-NEXT:    psubd %xmm0, %xmm4
; SSE-NEXT:    psubd %xmm0, %xmm3
; SSE-NEXT:    movdqu %xmm3, 32(%rdi)
; SSE-NEXT:    movdqu %xmm4, 48(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: PR52032:
; AVX:       # %bb.0:
; AVX-NEXT:    vpbroadcastd {{.*#+}} ymm0 = [1,1,1,1,1,1,1,1]
; AVX-NEXT:    vpaddd (%rdi), %ymm0, %ymm1
; AVX-NEXT:    vmovdqu %ymm1, (%rdi)
; AVX-NEXT:    vpaddd 32(%rdi), %ymm0, %ymm0
; AVX-NEXT:    vmovdqu %ymm0, 32(%rdi)
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
  %i3 = load <8 x i32>, <8 x i32>* %p, align 4
  %i4 = add nsw <8 x i32> %i3, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  store <8 x i32> %i4, <8 x i32>* %p, align 4
  %p2 = getelementptr inbounds <8 x i32>, <8 x i32>* %p, i64 1
  %i8 = load <8 x i32>, <8 x i32>* %p2, align 4
  %i9 = add nsw <8 x i32> %i8, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  store <8 x i32> %i9, <8 x i32>* %p2, align 4
  ret void
}

; Same as above, but 128-bit ops:
; With AVX, we don't transform 'add' to 'sub' because that prevents load folding.
; With SSE, we do it because we can't load fold the other op without overwriting the constant op.

define void @PR52032_2(<4 x i32>* %p) {
; SSE-LABEL: PR52032_2:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE-NEXT:    movdqu (%rdi), %xmm1
; SSE-NEXT:    movdqu 16(%rdi), %xmm2
; SSE-NEXT:    psubd %xmm0, %xmm1
; SSE-NEXT:    movdqu %xmm1, (%rdi)
; SSE-NEXT:    psubd %xmm0, %xmm2
; SSE-NEXT:    movdqu %xmm2, 16(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: PR52032_2:
; AVX:       # %bb.0:
; AVX-NEXT:    vpbroadcastd {{.*#+}} xmm0 = [1,1,1,1]
; AVX-NEXT:    vpaddd (%rdi), %xmm0, %xmm1
; AVX-NEXT:    vmovdqu %xmm1, (%rdi)
; AVX-NEXT:    vpaddd 16(%rdi), %xmm0, %xmm0
; AVX-NEXT:    vmovdqu %xmm0, 16(%rdi)
; AVX-NEXT:    retq
  %i3 = load <4 x i32>, <4 x i32>* %p, align 4
  %i4 = add nsw <4 x i32> %i3, <i32 1, i32 1, i32 1, i32 1>
  store <4 x i32> %i4, <4 x i32>* %p, align 4
  %p2 = getelementptr inbounds <4 x i32>, <4 x i32>* %p, i64 1
  %i8 = load <4 x i32>, <4 x i32>* %p2, align 4
  %i9 = add nsw <4 x i32> %i8, <i32 1, i32 1, i32 1, i32 1>
  store <4 x i32> %i9, <4 x i32>* %p2, align 4
  ret void
}

; If we are starting with a 'sub', it is always better to do the transform.

define void @PR52032_3(<4 x i32>* %p) {
; SSE-LABEL: PR52032_3:
; SSE:       # %bb.0:
; SSE-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE-NEXT:    movdqu (%rdi), %xmm1
; SSE-NEXT:    movdqu 16(%rdi), %xmm2
; SSE-NEXT:    paddd %xmm0, %xmm1
; SSE-NEXT:    movdqu %xmm1, (%rdi)
; SSE-NEXT:    paddd %xmm0, %xmm2
; SSE-NEXT:    movdqu %xmm2, 16(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: PR52032_3:
; AVX:       # %bb.0:
; AVX-NEXT:    vpcmpeqd %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vpaddd (%rdi), %xmm0, %xmm1
; AVX-NEXT:    vmovdqu %xmm1, (%rdi)
; AVX-NEXT:    vpaddd 16(%rdi), %xmm0, %xmm0
; AVX-NEXT:    vmovdqu %xmm0, 16(%rdi)
; AVX-NEXT:    retq
  %i3 = load <4 x i32>, <4 x i32>* %p, align 4
  %i4 = sub nsw <4 x i32> %i3, <i32 1, i32 1, i32 1, i32 1>
  store <4 x i32> %i4, <4 x i32>* %p, align 4
  %p2 = getelementptr inbounds <4 x i32>, <4 x i32>* %p, i64 1
  %i8 = load <4 x i32>, <4 x i32>* %p2, align 4
  %i9 = sub nsw <4 x i32> %i8, <i32 1, i32 1, i32 1, i32 1>
  store <4 x i32> %i9, <4 x i32>* %p2, align 4
  ret void
}

; If there's no chance of profitable load folding (because of extra uses), we convert 'add' to 'sub'.

define void @PR52032_4(<4 x i32>* %p, <4 x i32>* %q) {
; SSE-LABEL: PR52032_4:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqu (%rdi), %xmm0
; SSE-NEXT:    movdqa %xmm0, (%rsi)
; SSE-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE-NEXT:    psubd %xmm1, %xmm0
; SSE-NEXT:    movdqu %xmm0, (%rdi)
; SSE-NEXT:    movdqu 16(%rdi), %xmm0
; SSE-NEXT:    movdqa %xmm0, 16(%rsi)
; SSE-NEXT:    psubd %xmm1, %xmm0
; SSE-NEXT:    movdqu %xmm0, 16(%rdi)
; SSE-NEXT:    retq
;
; AVX-LABEL: PR52032_4:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovdqu (%rdi), %xmm0
; AVX-NEXT:    vmovdqa %xmm0, (%rsi)
; AVX-NEXT:    vpcmpeqd %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vmovdqu %xmm0, (%rdi)
; AVX-NEXT:    vmovdqu 16(%rdi), %xmm0
; AVX-NEXT:    vmovdqa %xmm0, 16(%rsi)
; AVX-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vmovdqu %xmm0, 16(%rdi)
; AVX-NEXT:    retq
  %i3 = load <4 x i32>, <4 x i32>* %p, align 4
  store <4 x i32> %i3, <4 x i32>* %q
  %i4 = add nsw <4 x i32> %i3, <i32 1, i32 1, i32 1, i32 1>
  store <4 x i32> %i4, <4 x i32>* %p, align 4
  %p2 = getelementptr inbounds <4 x i32>, <4 x i32>* %p, i64 1
  %q2 = getelementptr inbounds <4 x i32>, <4 x i32>* %q, i64 1
  %i8 = load <4 x i32>, <4 x i32>* %p2, align 4
  store <4 x i32> %i8, <4 x i32>* %q2
  %i9 = add nsw <4 x i32> %i8, <i32 1, i32 1, i32 1, i32 1>
  store <4 x i32> %i9, <4 x i32>* %p2, align 4
  ret void
}
