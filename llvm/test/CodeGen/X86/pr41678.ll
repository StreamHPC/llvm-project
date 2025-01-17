; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -O0 -mtriple=i386-pc-linux-gnu -mattr=avx512f | FileCheck %s

define void @a() {
; CHECK-LABEL: a:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    subl $2, %esp
; CHECK-NEXT:    .cfi_def_cfa_offset 6
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    kmovw %k6, %eax
; CHECK-NEXT:    # kill: def $ax killed $ax killed $eax
; CHECK-NEXT:    movw %ax, (%esp)
; CHECK-NEXT:    addl $2, %esp
; CHECK-NEXT:    .cfi_def_cfa_offset 4
; CHECK-NEXT:    retl
entry:
  %b = alloca i16, align 2
  %0 = call i16 asm "", "={k6},~{dirflag},~{fpsr},~{flags}"() #1
  store i16 %0, i16* %b, align 2
  ret void
}

define void @b() {
; CHECK-LABEL: b:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    subl $2, %esp
; CHECK-NEXT:    .cfi_def_cfa_offset 6
; CHECK-NEXT:    #APP
; CHECK-NEXT:    #NO_APP
; CHECK-NEXT:    # kill: def $k0 killed $k6
; CHECK-NEXT:    kmovw %k6, (%esp)
; CHECK-NEXT:    addl $2, %esp
; CHECK-NEXT:    .cfi_def_cfa_offset 4
; CHECK-NEXT:    retl
entry:
  %b = alloca <16 x i1>, align 2
  %0 = call <16 x i1> asm "", "={k6},~{dirflag},~{fpsr},~{flags}"() #1
  store <16 x i1> %0, ptr %b, align 2
  ret void
}
