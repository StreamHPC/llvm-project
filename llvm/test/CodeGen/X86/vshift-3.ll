; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown -mattr=+sse2 | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse2 | FileCheck %s --check-prefix=X64

; test vector shifts converted to proper SSE2 vector shifts when the shift
; amounts are the same.

; Note that x86 does have ashr

define void @shift1a(<2 x i64> %val, <2 x i64>* %dst) nounwind {
; X86-LABEL: shift1a:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,3,2,3]
; X86-NEXT:    movdqa %xmm0, %xmm1
; X86-NEXT:    psrad $31, %xmm1
; X86-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; X86-NEXT:    movdqa %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: shift1a:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,3,2,3]
; X64-NEXT:    movdqa %xmm0, %xmm1
; X64-NEXT:    psrad $31, %xmm1
; X64-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; X64-NEXT:    movdqa %xmm0, (%rdi)
; X64-NEXT:    retq
entry:
  %ashr = ashr <2 x i64> %val, < i64 32, i64 32 >
  store <2 x i64> %ashr, <2 x i64>* %dst
  ret void
}

define void @shift2a(<4 x i32> %val, <4 x i32>* %dst) nounwind {
; X86-LABEL: shift2a:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    psrad $5, %xmm0
; X86-NEXT:    movdqa %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: shift2a:
; X64:       # %bb.0: # %entry
; X64-NEXT:    psrad $5, %xmm0
; X64-NEXT:    movdqa %xmm0, (%rdi)
; X64-NEXT:    retq
entry:
  %ashr = ashr <4 x i32> %val, < i32 5, i32 5, i32 5, i32 5 >
  store <4 x i32> %ashr, <4 x i32>* %dst
  ret void
}

define void @shift2b(<4 x i32> %val, <4 x i32>* %dst, i32 %amt) nounwind {
; X86-LABEL: shift2b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X86-NEXT:    psrad %xmm1, %xmm0
; X86-NEXT:    movdqa %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: shift2b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movd %esi, %xmm1
; X64-NEXT:    psrad %xmm1, %xmm0
; X64-NEXT:    movdqa %xmm0, (%rdi)
; X64-NEXT:    retq
entry:
  %0 = insertelement <4 x i32> undef, i32 %amt, i32 0
  %1 = insertelement <4 x i32> %0, i32 %amt, i32 1
  %2 = insertelement <4 x i32> %1, i32 %amt, i32 2
  %3 = insertelement <4 x i32> %2, i32 %amt, i32 3
  %ashr = ashr <4 x i32> %val, %3
  store <4 x i32> %ashr, <4 x i32>* %dst
  ret void
}

define void @shift3a(<8 x i16> %val, <8 x i16>* %dst) nounwind {
; X86-LABEL: shift3a:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    psraw $5, %xmm0
; X86-NEXT:    movdqa %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: shift3a:
; X64:       # %bb.0: # %entry
; X64-NEXT:    psraw $5, %xmm0
; X64-NEXT:    movdqa %xmm0, (%rdi)
; X64-NEXT:    retq
entry:
  %ashr = ashr <8 x i16> %val, < i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5, i16 5 >
  store <8 x i16> %ashr, <8 x i16>* %dst
  ret void
}

define void @shift3b(<8 x i16> %val, <8 x i16>* %dst, i16 %amt) nounwind {
; X86-LABEL: shift3b:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movd %ecx, %xmm1
; X86-NEXT:    psraw %xmm1, %xmm0
; X86-NEXT:    movdqa %xmm0, (%eax)
; X86-NEXT:    retl
;
; X64-LABEL: shift3b:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movzwl %si, %eax
; X64-NEXT:    movd %eax, %xmm1
; X64-NEXT:    psraw %xmm1, %xmm0
; X64-NEXT:    movdqa %xmm0, (%rdi)
; X64-NEXT:    retq
entry:
  %0 = insertelement <8 x i16> undef, i16 %amt, i32 0
  %1 = insertelement <8 x i16> %0, i16 %amt, i32 1
  %2 = insertelement <8 x i16> %1, i16 %amt, i32 2
  %3 = insertelement <8 x i16> %2, i16 %amt, i32 3
  %4 = insertelement <8 x i16> %3, i16 %amt, i32 4
  %5 = insertelement <8 x i16> %4, i16 %amt, i32 5
  %6 = insertelement <8 x i16> %5, i16 %amt, i32 6
  %7 = insertelement <8 x i16> %6, i16 %amt, i32 7
  %ashr = ashr <8 x i16> %val, %7
  store <8 x i16> %ashr, <8 x i16>* %dst
  ret void
}
