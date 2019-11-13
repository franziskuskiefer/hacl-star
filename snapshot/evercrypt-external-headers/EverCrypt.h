/* 
  This file was generated by KreMLin <https://github.com/FStarLang/kremlin>
  KreMLin invocation: /home/everest/hacl-star/kremlin/krml -silent -minimal -bundle EverCrypt+EverCrypt.AEAD+EverCrypt.AutoConfig2+EverCrypt.HKDF+EverCrypt.HMAC+EverCrypt.Hash+EverCrypt.Hash.Incremental+EverCrypt.Cipher+EverCrypt.Poly1305+EverCrypt.Chacha20Poly1305+EverCrypt.Curve25519=*[rename=EverCrypt] -library EverCrypt,EverCrypt.* -add-include <inttypes.h> -add-include <stdbool.h> -add-include <kremlin/internal/types.h> -add-include <kremlin/internal/target.h> -skip-compilation -tmpdir dist/evercrypt-external-headers/ obj/prims.krml obj/FStar_Pervasives_Native.krml obj/FStar_Pervasives.krml obj/FStar_Squash.krml obj/FStar_Classical.krml obj/FStar_FunctionalExtensionality.krml obj/FStar_Set.krml obj/FStar_Map.krml obj/FStar_StrongExcludedMiddle.krml obj/FStar_List_Tot_Base.krml obj/FStar_List_Tot_Properties.krml obj/FStar_List_Tot.krml obj/FStar_Seq_Base.krml obj/FStar_Seq_Properties.krml obj/FStar_Seq.krml obj/FStar_Mul.krml obj/Vale_Lib_Seqs_s.krml obj/FStar_Preorder.krml obj/FStar_Calc.krml obj/FStar_Math_Lib.krml obj/FStar_Math_Lemmas.krml obj/FStar_BitVector.krml obj/FStar_UInt.krml obj/FStar_UInt32.krml obj/FStar_UInt8.krml obj/Vale_Def_Words_s.krml obj/Vale_Def_Words_Four_s.krml obj/Vale_Def_Words_Two_s.krml obj/Vale_Def_Words_Seq_s.krml obj/Vale_Def_Opaque_s.krml obj/Vale_Def_Types_s.krml obj/Vale_X64_Machine_s.krml obj/Vale_Lib_Map16.krml obj/Vale_Def_Prop_s.krml obj/Vale_X64_Flags.krml obj/Vale_AES_AES_s.krml obj/FStar_Float.krml obj/FStar_UInt64.krml obj/FStar_Exn.krml obj/FStar_Monotonic_Witnessed.krml obj/FStar_Ghost.krml obj/FStar_ErasedLogic.krml obj/FStar_PropositionalExtensionality.krml obj/FStar_PredicateExtensionality.krml obj/FStar_TSet.krml obj/FStar_Monotonic_Heap.krml obj/FStar_Heap.krml obj/FStar_ST.krml obj/FStar_All.krml obj/FStar_IO.krml obj/Vale_Def_PossiblyMonad.krml obj/FStar_List.krml obj/Vale_Lib_Meta.krml obj/Vale_Def_Words_Two.krml obj/Vale_Lib_Seqs.krml obj/Vale_Def_TypesNative_s.krml obj/Vale_Arch_TypesNative.krml obj/Vale_Def_Words_Seq.krml obj/Vale_Arch_Types.krml obj/FStar_UInt16.krml obj/FStar_Monotonic_HyperHeap.krml obj/FStar_Monotonic_HyperStack.krml obj/FStar_HyperStack.krml obj/FStar_HyperStack_ST.krml obj/FStar_Universe.krml obj/FStar_GSet.krml obj/FStar_ModifiesGen.krml obj/FStar_Range.krml obj/FStar_Reflection_Types.krml obj/FStar_Tactics_Types.krml obj/FStar_Tactics_Result.krml obj/FStar_Tactics_Effect.krml obj/FStar_Tactics_Util.krml obj/FStar_Reflection_Data.krml obj/FStar_Reflection_Const.krml obj/FStar_Char.krml obj/FStar_String.krml obj/FStar_Order.krml obj/FStar_Reflection_Basic.krml obj/FStar_Reflection_Derived.krml obj/FStar_Tactics_Builtins.krml obj/FStar_Reflection_Formula.krml obj/FStar_Reflection_Derived_Lemmas.krml obj/FStar_Reflection.krml obj/FStar_Tactics_Derived.krml obj/FStar_Tactics_Logic.krml obj/FStar_Tactics.krml obj/FStar_BigOps.krml obj/LowStar_Monotonic_Buffer.krml obj/LowStar_BufferView_Down.krml obj/LowStar_BufferView_Up.krml obj/Vale_Interop_Views.krml obj/FStar_Option.krml obj/Vale_Lib_Set.krml obj/Vale_X64_Instruction_s.krml obj/Vale_X64_Bytes_Code_s.krml obj/Vale_Math_Poly2_Defs_s.krml obj/Vale_Math_Poly2_s.krml obj/Vale_Math_Poly2_Bits_s.krml obj/Lib_LoopCombinators.krml obj/FStar_Int.krml obj/FStar_Int64.krml obj/FStar_Int63.krml obj/FStar_Int32.krml obj/FStar_Int16.krml obj/FStar_Int8.krml obj/FStar_UInt63.krml obj/FStar_Int_Cast.krml obj/FStar_UInt128.krml obj/FStar_Int_Cast_Full.krml obj/FStar_Int128.krml obj/Lib_IntTypes.krml obj/Lib_RawIntTypes.krml obj/Lib_Sequence.krml obj/Lib_ByteSequence.krml obj/Spec_Hash_Definitions.krml obj/Spec_Hash_Lemmas0.krml obj/Spec_Hash_PadFinish.krml obj/Spec_Loops.krml obj/Spec_SHA2_Constants.krml obj/Spec_SHA2.krml obj/Vale_X64_CryptoInstructions_s.krml obj/Vale_X64_CPU_Features_s.krml obj/Vale_X64_Instructions_s.krml obj/LowStar_Buffer.krml obj/Vale_Arch_HeapTypes_s.krml obj/Vale_Interop_Types.krml obj/Vale_Arch_MachineHeap_s.krml obj/Vale_Interop_Heap_s.krml obj/LowStar_Modifies.krml obj/LowStar_ModifiesPat.krml obj/LowStar_BufferView.krml obj/Vale_Lib_BufferViewHelpers.krml obj/Vale_Interop.krml obj/Vale_Arch_HeapImpl.krml obj/Vale_Arch_Heap.krml obj/Vale_X64_Machine_Semantics_s.krml obj/LowStar_ImmutableBuffer.krml obj/Vale_Interop_Base.krml obj/Vale_X64_Memory.krml obj/Vale_Arch_MachineHeap.krml obj/Vale_X64_Stack_i.krml obj/Vale_X64_Stack_Sems.krml obj/Vale_X64_BufferViewStore.krml obj/Vale_X64_Memory_Sems.krml obj/Vale_X64_Regs.krml obj/Vale_X64_State.krml obj/Vale_X64_StateLemmas.krml obj/Vale_X64_Lemmas.krml obj/Vale_X64_Print_s.krml obj/Vale_X64_Decls.krml obj/Vale_X64_Taint_Semantics.krml obj/Vale_X64_InsLemmas.krml obj/Vale_X64_QuickCode.krml obj/Vale_X64_InsAes.krml obj/Spec_Chacha20.krml obj/Meta_Attribute.krml obj/LowStar_BufferOps.krml obj/FStar_HyperStack_All.krml obj/FStar_Kremlin_Endianness.krml obj/C_Endianness.krml obj/C.krml obj/C_Loops.krml obj/Lib_Loops.krml obj/Lib_Buffer.krml obj/Lib_ByteBuffer.krml obj/Lib_IntVector_Intrinsics.krml obj/Spec_GaloisField.krml obj/Spec_AES.krml obj/Lib_IntVector.krml obj/Hacl_Spec_Chacha20_Vec.krml obj/Hacl_Spec_Chacha20_Lemmas.krml obj/Lib_Sequence_Lemmas.krml obj/Hacl_Spec_Chacha20_Equiv.krml obj/Hacl_Impl_Chacha20_Core32xN.krml obj/Hacl_Impl_Chacha20_Vec.krml obj/Vale_Curve25519_Fast_lemmas_internal.krml obj/Vale_Curve25519_Fast_defs.krml obj/FStar_Algebra_CommMonoid.krml obj/FStar_Tactics_CanonCommSemiring.krml obj/Vale_Curve25519_FastUtil_helpers.krml obj/Vale_Curve25519_FastHybrid_helpers.krml obj/Vale_Curve25519_Fast_lemmas_external.krml obj/Vale_X64_QuickCodes.krml obj/Vale_X64_InsBasic.krml obj/Vale_X64_InsMem.krml obj/Vale_X64_InsVector.krml obj/Vale_X64_InsStack.krml obj/Vale_Curve25519_X64_FastHybrid.krml obj/Vale_Bignum_Defs.krml obj/Vale_Bignum_X64.krml obj/Vale_Curve25519_FastSqr_helpers.krml obj/Vale_Curve25519_X64_FastSqr.krml obj/Vale_Curve25519_FastMul_helpers.krml obj/Vale_Curve25519_X64_FastMul.krml obj/Vale_Curve25519_X64_FastWide.krml obj/Vale_Curve25519_X64_FastUtil.krml obj/Vale_X64_MemoryAdapters.krml obj/Vale_Interop_Assumptions.krml obj/Vale_Interop_X64.krml obj/Vale_AsLowStar_ValeSig.krml obj/Vale_AsLowStar_LowStarSig.krml obj/Vale_AsLowStar_MemoryHelpers.krml obj/Vale_AsLowStar_Wrapper.krml obj/Vale_Stdcalls_X64_Fadd.krml obj/Vale_Wrapper_X64_Fadd.krml obj/Vale_Math_Poly2_Defs.krml obj/Vale_Math_Poly2.krml obj/Vale_Math_Poly2_Lemmas.krml obj/Vale_Math_Poly2_Bits.krml obj/Vale_Math_Poly2_Words.krml obj/Vale_AES_GF128_s.krml obj/Vale_AES_GF128.krml obj/Vale_AES_OptPublic.krml obj/Vale_AES_X64_GF128_Mul.krml obj/Vale_AES_X64_PolyOps.krml obj/Vale_X64_Stack.krml obj/FStar_BV.krml obj/Vale_Lib_Bv_s.krml obj/Vale_Math_Bits.krml obj/Vale_Lib_Tactics.krml obj/FStar_Reflection_Arith.krml obj/FStar_Tactics_BV.krml obj/Vale_Poly1305_Bitvectors.krml obj/Vale_AES_GCTR_s.krml obj/Vale_AES_GCM_helpers.krml obj/Vale_AES_GCTR.krml obj/Vale_AES_AES256_helpers.krml obj/Vale_AES_X64_AES256.krml obj/Vale_AES_AES_helpers.krml obj/Vale_AES_X64_AES128.krml obj/Vale_AES_X64_AES.krml obj/Vale_AES_GHash_s.krml obj/Vale_AES_GHash.krml obj/Vale_AES_X64_GF128_Init.krml obj/Vale_Transformers_Locations.krml obj/Spec_SHA1.krml obj/Spec_MD5.krml obj/Spec_Agile_Hash.krml obj/Spec_Hash_Incremental.krml obj/Spec_Hash_Lemmas.krml obj/Hacl_Hash_Lemmas.krml obj/Hacl_Hash_Definitions.krml obj/Hacl_Hash_PadFinish.krml obj/Hacl_Hash_MD.krml obj/Spec_SHA2_Lemmas.krml obj/Vale_SHA_SHA_helpers.krml obj/Vale_X64_InsSha.krml obj/Vale_SHA_X64.krml obj/Vale_Stdcalls_X64_Sha.krml obj/Vale_Math_Lemmas_Int.krml obj/FStar_Tactics_Canon.krml obj/Vale_Poly1305_Spec_s.krml obj/Vale_Poly1305_Math.krml obj/Vale_Poly1305_Util.krml obj/Vale_Poly1305_X64.krml obj/Vale_Stdcalls_X64_Poly.krml obj/Vale_Wrapper_X64_Poly.krml obj/FStar_Endianness.krml obj/Vale_Arch_BufferFriend.krml obj/Vale_SHA_Simplify_Sha.krml obj/Vale_Wrapper_X64_Sha.krml obj/Hacl_Hash_Core_SHA2_Constants.krml obj/Hacl_Hash_Core_SHA2.krml obj/Hacl_Hash_SHA2.krml obj/Hacl_Hash_Core_SHA1.krml obj/Hacl_Hash_SHA1.krml obj/Hacl_Hash_Core_MD5.krml obj/Hacl_Hash_MD5.krml obj/C_String.krml obj/C_Failure.krml obj/FStar_Int31.krml obj/FStar_UInt31.krml obj/FStar_Integers.krml obj/EverCrypt_StaticConfig.krml obj/Vale_Lib_Basic.krml obj/Vale_Lib_X64_Cpuid.krml obj/Vale_Lib_X64_Cpuidstdcall.krml obj/Vale_Stdcalls_X64_Cpuid.krml obj/Vale_Wrapper_X64_Cpuid.krml obj/EverCrypt_TargetConfig.krml obj/EverCrypt_AutoConfig2.krml obj/EverCrypt_Helpers.krml obj/EverCrypt_Hash.krml obj/Spec_SHA3_Constants.krml obj/Spec_Curve25519_Lemmas.krml obj/Spec_Curve25519.krml obj/Spec_Ed25519.krml obj/Hacl_Spec_Ed25519_Field56_Definition.krml obj/Hacl_Impl_Ed25519_Field56.krml obj/Hacl_Spec_Curve25519_Field51_Definition.krml obj/Hacl_Impl_Curve25519_Lemmas.krml obj/Hacl_Spec_Curve25519_Field51_Lemmas.krml obj/Hacl_Spec_Curve25519_Field51.krml obj/Hacl_Spec_Curve25519_Field64_Definition.krml obj/Hacl_Spec_Curve25519_Field64_Lemmas.krml obj/Hacl_Spec_Curve25519_Field64_Core.krml obj/Hacl_Spec_Curve25519_Field64.krml obj/Hacl_Impl_Curve25519_Fields_Core.krml obj/Hacl_Impl_Curve25519_Field51.krml obj/Hacl_Impl_Ed25519_Field51.krml obj/Hacl_Spec_Curve25519_Finv.krml obj/Hacl_Impl_Curve25519_Field64.krml obj/Hacl_Impl_Curve25519_Fields.krml obj/FStar_List_Pure_Base.krml obj/FStar_List_Pure_Properties.krml obj/FStar_List_Pure.krml obj/Meta_Interface.krml obj/Hacl_Spec_Curve25519_AddAndDouble.krml obj/Hacl_Impl_Curve25519_AddAndDouble.krml obj/Hacl_Impl_Curve25519_Finv.krml obj/Hacl_Impl_Curve25519_Generic.krml obj/Hacl_Meta_Curve25519.krml obj/Hacl_Curve25519_51.krml obj/Hacl_Curve25519_Finv_Field51.krml obj/Hacl_Bignum25519.krml obj/Hacl_Impl_Ed25519_PointAdd.krml obj/Hacl_Impl_Ed25519_PointDouble.krml obj/Lib_IntTypes_Compatibility.krml obj/Hacl_Impl_Ed25519_SwapConditional.krml obj/Hacl_Impl_Ed25519_Ladder.krml obj/Hacl_Impl_Ed25519_PointCompress.krml obj/Hacl_Impl_Ed25519_SecretExpand.krml obj/Hacl_Impl_Ed25519_SecretToPublic.krml obj/Hacl_Spec_BignumQ_Definitions.krml obj/Hacl_Spec_BignumQ_Lemmas.krml obj/Hacl_Spec_BignumQ_Mul.krml obj/Hacl_Impl_BignumQ_Mul.krml obj/Hacl_Impl_Load56.krml obj/Hacl_Impl_Store56.krml obj/Hacl_Impl_SHA512_ModQ.krml obj/Hacl_Impl_Ed25519_Sign_Steps.krml obj/Hacl_Impl_Ed25519_Sign.krml obj/Hacl_Impl_Ed25519_Sign_Expanded.krml obj/Vale_AES_X64_AESopt2.krml obj/Vale_AES_X64_AESGCM_expected_code.krml obj/Spec_Poly1305.krml obj/Hacl_Spec_Poly1305_Vec.krml obj/Hacl_Spec_Poly1305_Field32xN.krml obj/Hacl_Poly1305_Field32xN_Lemmas.krml obj/Hacl_Impl_Poly1305_Lemmas.krml obj/Hacl_Spec_Poly1305_Field32xN_Lemmas.krml obj/Hacl_Impl_Poly1305_Field32xN.krml obj/Hacl_Spec_Poly1305_Lemmas.krml obj/Hacl_Spec_Poly1305_Equiv.krml obj/Hacl_Impl_Poly1305_Field32xN_256.krml obj/Hacl_Impl_Poly1305_Field32xN_128.krml obj/Hacl_Impl_Poly1305_Field32xN_32.krml obj/Hacl_Impl_Poly1305_Fields.krml obj/Hacl_Impl_Poly1305.krml obj/Spec_Chacha20Poly1305.krml obj/Hacl_Impl_Chacha20Poly1305_PolyCore.krml obj/Hacl_Impl_Chacha20Poly1305.krml obj/Hacl_Meta_Chacha20Poly1305.krml obj/MerkleTree_Spec.krml obj/Hacl_Meta_Chacha20_Vec.krml obj/Hacl_Chacha20_Vec256.krml obj/Hacl_Meta_Poly1305.krml obj/Hacl_Poly1305_256.krml obj/Hacl_Chacha20Poly1305_256.krml obj/Spec_Agile_HMAC.krml obj/Hacl_HMAC.krml obj/Hacl_Impl_Chacha20_Core32.krml obj/Hacl_Impl_Chacha20.krml obj/Hacl_Chacha20.krml obj/Hacl_Poly1305_32.krml obj/Hacl_Chacha20Poly1305_32.krml obj/FStar_Dyn.krml obj/EverCrypt_Vale.krml obj/EverCrypt_Specs.krml obj/EverCrypt_OpenSSL.krml obj/EverCrypt_Hacl.krml obj/EverCrypt_BCrypt.krml obj/EverCrypt_Cipher.krml obj/Vale_Stdcalls_X64_Fswap.krml obj/Vale_Wrapper_X64_Fswap.krml obj/Vale_X64_Print_Inline_s.krml obj/Vale_Inline_X64_Fswap_inline.krml obj/Vale_Stdcalls_X64_Fsqr.krml obj/Vale_Wrapper_X64_Fsqr.krml obj/Vale_Inline_X64_Fsqr_inline.krml obj/Vale_Stdcalls_X64_Fmul.krml obj/Vale_Wrapper_X64_Fmul.krml obj/Vale_Inline_X64_Fmul_inline.krml obj/Vale_Stdcalls_X64_Fsub.krml obj/Vale_Wrapper_X64_Fsub.krml obj/Vale_Inline_X64_Fadd_inline.krml obj/Hacl_Impl_Curve25519_Field64_Vale.krml obj/Hacl_Curve25519_64.krml obj/EverCrypt_Curve25519.krml obj/Hacl_Poly1305_128.krml obj/Vale_Poly1305_Equiv.krml obj/Vale_Poly1305_CallingFromLowStar.krml obj/EverCrypt_Poly1305.krml obj/EverCrypt_HMAC.krml obj/Spec_Agile_HKDF.krml obj/Hacl_HKDF.krml obj/EverCrypt_HKDF.krml obj/EverCrypt.krml obj/Spec_Salsa20.krml obj/Spec_SecretBox.krml obj/Spec_SecretBox_Test.krml obj/Vale_AES_X64_GHash.krml obj/Vale_AES_X64_AESCTR.krml obj/Vale_AES_X64_AESCTRplain.krml obj/Hacl_Impl_Salsa20_Core32.krml obj/Hacl_Impl_Salsa20.krml obj/Hacl_Impl_HSalsa20.krml obj/Hacl_Salsa20.krml obj/Vale_AES_Gcm_simplify.krml obj/Vale_AES_GCM_s.krml obj/Vale_Transformers_BoundedInstructionEffects.krml obj/Vale_Transformers_InstructionReorder.krml obj/Vale_Transformers_Transform.krml obj/Vale_AES_X64_AESopt.krml obj/Vale_AES_X64_AESGCM.krml obj/Vale_AES_X64_GCTR.krml obj/Vale_AES_GCM.krml obj/Vale_AES_X64_GCMencryptOpt.krml obj/Vale_AES_X64_GCMdecryptOpt.krml obj/Vale_Stdcalls_X64_GCMdecryptOpt.krml obj/Vale_Stdcalls_X64_Aes.krml obj/Vale_Wrapper_X64_AES.krml obj/Vale_Wrapper_X64_GCMdecryptOpt.krml obj/Vale_Wrapper_X64_GCMdecryptOpt256.krml obj/Hacl_Chacha20_Vec128.krml obj/Hacl_Chacha20Poly1305_128.krml obj/EverCrypt_Chacha20Poly1305.krml obj/Vale_Stdcalls_X64_GCM_IV.krml obj/Vale_Wrapper_X64_GCM_IV.krml obj/Vale_Stdcalls_X64_GCMencryptOpt.krml obj/Vale_Wrapper_X64_GCMencryptOpt.krml obj/Vale_Wrapper_X64_GCMencryptOpt256.krml obj/Vale_Stdcalls_X64_AesHash.krml obj/Vale_Wrapper_X64_AEShash.krml obj/Spec_Agile_Cipher.krml obj/Spec_Cipher_Expansion.krml obj/EverCrypt_CTR_Keys.krml obj/Spec_Agile_AEAD.krml obj/EverCrypt_Error.krml obj/EverCrypt_AEAD.krml obj/WasmSupport.krml obj/Lib_RandomSequence.krml obj/Vale_Transformers_InstructionReorderSanityChecks.krml obj/Spec_SHA3.krml obj/Hacl_Impl_SHA3.krml obj/LowStar_Vector.krml obj/LowStar_Regional.krml obj/LowStar_RVector.krml obj/LowStar_Regional_Instances.krml obj/TestLib.krml obj/MerkleTree_New_High.krml obj/MerkleTree_New_Low.krml obj/Hacl_Impl_Ed25519_Pow2_252m2.krml obj/Hacl_Impl_Ed25519_RecoverX.krml obj/Hacl_Impl_Ed25519_PointDecompress.krml obj/Hacl_Impl_Ed25519_PointEqual.krml obj/Hacl_Impl_Ed25519_Verify.krml obj/Hacl_Ed25519.krml obj/Lib_PrintBuffer.krml obj/Hacl_Test_Ed25519.krml obj/EverCrypt_Hash_Incremental.krml obj/Lib_RandomBuffer_System.krml obj/Test_Vectors_Chacha20Poly1305.krml obj/Vale_Test_X64_Args.krml obj/LowStar_Endianness.krml obj/Vale_Test_X64_Vale_memcpy.krml obj/MerkleTree_New_High_Correct_Base.krml obj/MerkleTree_New_High_Correct_Flushing.krml obj/MerkleTree_New_High_Correct_Rhs.krml obj/Test_Vectors_Curve25519.krml obj/Spec_Box.krml obj/Hacl_Impl_SecretBox.krml obj/Hacl_Impl_Box.krml obj/Hacl_NaCl.krml obj/Vale_Test_X64_Memcpy.krml obj/Hacl_Impl_Curve25519_Field64_Hacl.krml obj/Hacl_Curve25519_64_Slow.krml obj/Vale_Math_Poly2_Galois_IntTypes.krml obj/Vale_Math_Poly2_Galois.krml obj/Vale_Math_Poly2_Galois_Lemmas.krml obj/Lib_RawBuffer.krml obj/Vale_Lib_MapTree.krml obj/Test_Vectors_Poly1305.krml obj/Hacl_SHA3.krml obj/Vale_X64_Leakage_s.krml obj/Vale_X64_Leakage_Helpers.krml obj/Vale_X64_Leakage_Ins.krml obj/Vale_X64_Leakage.krml obj/Test_Lowstarize.krml obj/Test_Vectors.krml obj/Spec_Agile_CTR.krml obj/Lib_PrintSequence.krml obj/Spec_Curve25519_Test.krml obj/Spec_Chacha20_Test.krml obj/Vale_Lib_Operator.krml obj/MerkleTree_New_Low_Serialization.krml obj/MerkleTree_New_High_Correct_Path.krml obj/MerkleTree_New_High_Correct_Insertion.krml obj/MerkleTree_New_High_Correct.krml obj/Test_Hash.krml obj/Hacl_Impl_Curve25519_Field64_Local.krml obj/Hacl_Test_CSHAKE.krml obj/Spec_Hash_Test.krml obj/Vale_Stdcalls_X64_GCTR.krml obj/Vale_Wrapper_X64_GCTR.krml obj/Vale_Bignum_Lemmas.krml obj/Test_Vectors_Aes128.krml obj/Hacl_Curve25519_64_Local.krml obj/Hacl_Hash_Agile.krml obj/EverCrypt_Ed25519.krml obj/Hacl_Chacha20_Vec32.krml obj/Vale_X64_Xmms.krml obj/Hacl_Test_SHA3.krml obj/Spec_Chacha20Poly1305_Test.krml obj/Spec_Salsa20_Test.krml obj/Vale_Transformers_DebugPrint.krml obj/Vale_Lib_Lists.krml obj/Vale_FDefMulx_X64.krml obj/Vale_AsLowStar_Test.krml obj/Spec_SHA3_Test.krml obj/Test_NoHeap.krml obj/EverCrypt_CTR.krml obj/Test_Vectors_Aes128Gcm.krml obj/Spec_Box_Test.krml obj/Vale_X64_Bytes_Semantics.krml obj/Test.krml
  F* version: cb3125ec
  KreMLin version: e324b7e6
 */
#include <inttypes.h>
#include <stdbool.h>
#include <kremlin/internal/types.h>
#include <kremlin/internal/target.h>

#ifndef __EverCrypt_H
#define __EverCrypt_H




#define Spec_Hash_Definitions_SHA2_224 0
#define Spec_Hash_Definitions_SHA2_256 1
#define Spec_Hash_Definitions_SHA2_384 2
#define Spec_Hash_Definitions_SHA2_512 3
#define Spec_Hash_Definitions_SHA1 4
#define Spec_Hash_Definitions_MD5 5

typedef uint8_t Spec_Hash_Definitions_hash_alg;

#define Spec_Cipher_Expansion_Hacl_CHACHA20 0
#define Spec_Cipher_Expansion_Vale_AES128 1
#define Spec_Cipher_Expansion_Vale_AES256 2

typedef uint8_t Spec_Cipher_Expansion_impl;

#define Spec_Agile_AEAD_AES128_GCM 0
#define Spec_Agile_AEAD_AES256_GCM 1
#define Spec_Agile_AEAD_CHACHA20_POLY1305 2
#define Spec_Agile_AEAD_AES128_CCM 3
#define Spec_Agile_AEAD_AES256_CCM 4
#define Spec_Agile_AEAD_AES128_CCM8 5
#define Spec_Agile_AEAD_AES256_CCM8 6

typedef uint8_t Spec_Agile_AEAD_alg;

#define EverCrypt_Error_Success 0
#define EverCrypt_Error_UnsupportedAlgorithm 1
#define EverCrypt_Error_InvalidKey 2
#define EverCrypt_Error_AuthenticationFailure 3
#define EverCrypt_Error_InvalidIVLength 4

typedef uint8_t EverCrypt_Error_error_code;

extern uint32_t EverCrypt_random_init();

extern void EverCrypt_random_sample(uint32_t len, uint8_t *out1);

extern void EverCrypt_random_cleanup();

#define EverCrypt_AES128_OPENSSL 0
#define EverCrypt_AES128_BCRYPT 1
#define EverCrypt_AES128_VALE 2
#define EverCrypt_AES128_HACL 3

typedef uint8_t EverCrypt_aes128_key_s_tags;

typedef struct EverCrypt_aes128_key_s_s EverCrypt_aes128_key_s;

extern bool EverCrypt_uu___is_AES128_OPENSSL(EverCrypt_aes128_key_s projectee);

extern FStar_Dyn_dyn
EverCrypt___proj__AES128_OPENSSL__item__st(EverCrypt_aes128_key_s projectee);

extern bool EverCrypt_uu___is_AES128_BCRYPT(EverCrypt_aes128_key_s projectee);

extern FStar_Dyn_dyn
EverCrypt___proj__AES128_BCRYPT__item__st(EverCrypt_aes128_key_s projectee);

extern bool EverCrypt_uu___is_AES128_VALE(EverCrypt_aes128_key_s projectee);

extern uint8_t *EverCrypt___proj__AES128_VALE__item__w(EverCrypt_aes128_key_s projectee);

extern uint8_t *EverCrypt___proj__AES128_VALE__item__sbox(EverCrypt_aes128_key_s projectee);

extern bool EverCrypt_uu___is_AES128_HACL(EverCrypt_aes128_key_s projectee);

extern uint8_t *EverCrypt___proj__AES128_HACL__item__w(EverCrypt_aes128_key_s projectee);

extern uint8_t *EverCrypt___proj__AES128_HACL__item__sbox(EverCrypt_aes128_key_s projectee);

typedef EverCrypt_aes128_key_s *EverCrypt_aes128_key;

extern EverCrypt_aes128_key_s *EverCrypt_aes128_create(uint8_t *k1);

extern void
EverCrypt_aes128_compute(EverCrypt_aes128_key_s *k1, uint8_t *plain, uint8_t *cipher1);

extern void EverCrypt_aes128_free(EverCrypt_aes128_key_s *pk);

#define EverCrypt_AES256_OPENSSL 0
#define EverCrypt_AES256_BCRYPT 1
#define EverCrypt_AES256_HACL 2

typedef uint8_t EverCrypt_aes256_key_s_tags;

typedef struct EverCrypt_aes256_key_s_s EverCrypt_aes256_key_s;

extern bool EverCrypt_uu___is_AES256_OPENSSL(EverCrypt_aes256_key_s projectee);

extern FStar_Dyn_dyn
EverCrypt___proj__AES256_OPENSSL__item__st(EverCrypt_aes256_key_s projectee);

extern bool EverCrypt_uu___is_AES256_BCRYPT(EverCrypt_aes256_key_s projectee);

extern FStar_Dyn_dyn
EverCrypt___proj__AES256_BCRYPT__item__st(EverCrypt_aes256_key_s projectee);

extern bool EverCrypt_uu___is_AES256_HACL(EverCrypt_aes256_key_s projectee);

extern uint8_t *EverCrypt___proj__AES256_HACL__item__w(EverCrypt_aes256_key_s projectee);

extern uint8_t *EverCrypt___proj__AES256_HACL__item__sbox(EverCrypt_aes256_key_s projectee);

typedef EverCrypt_aes256_key_s *EverCrypt_aes256_key;

extern EverCrypt_aes256_key_s *EverCrypt_aes256_create(uint8_t *k1);

extern void
EverCrypt_aes256_compute(EverCrypt_aes256_key_s *k1, uint8_t *plain, uint8_t *cipher1);

extern void EverCrypt_aes256_free(EverCrypt_aes256_key_s *pk);

extern void
EverCrypt_aes128_gcm_encrypt(
  uint8_t *key,
  uint8_t *iv,
  uint8_t *ad,
  uint32_t adlen,
  uint8_t *plaintext,
  uint32_t len,
  uint8_t *cipher1,
  uint8_t *tag
);

extern uint32_t
EverCrypt_aes128_gcm_decrypt(
  uint8_t *key,
  uint8_t *iv,
  uint8_t *ad,
  uint32_t adlen,
  uint8_t *plaintext,
  uint32_t len,
  uint8_t *cipher1,
  uint8_t *tag
);

extern void
EverCrypt_aes256_gcm_encrypt(
  uint8_t *key,
  uint8_t *iv,
  uint8_t *ad,
  uint32_t adlen,
  uint8_t *plaintext,
  uint32_t len,
  uint8_t *cipher1,
  uint8_t *tag
);

extern uint32_t
EverCrypt_aes256_gcm_decrypt(
  uint8_t *key,
  uint8_t *iv,
  uint8_t *ad,
  uint32_t adlen,
  uint8_t *plaintext,
  uint32_t len,
  uint8_t *cipher1,
  uint8_t *tag
);

#define EverCrypt_AES128_CBC 0
#define EverCrypt_AES256_CBC 1
#define EverCrypt_TDES_EDE_CBC 2

typedef uint8_t EverCrypt_block_cipher_alg;

extern bool EverCrypt_uu___is_AES128_CBC(EverCrypt_block_cipher_alg projectee);

extern bool EverCrypt_uu___is_AES256_CBC(EverCrypt_block_cipher_alg projectee);

extern bool EverCrypt_uu___is_TDES_EDE_CBC(EverCrypt_block_cipher_alg projectee);

extern uint32_t EverCrypt_block_cipher_keyLen(EverCrypt_block_cipher_alg uu___0_9512);

extern uint32_t EverCrypt_block_cipher_blockLen(EverCrypt_block_cipher_alg uu___1_9522);

#define EverCrypt_RC4_128 0

typedef uint8_t EverCrypt_stream_cipher_alg;

extern bool EverCrypt_uu___is_RC4_128(EverCrypt_stream_cipher_alg projectee);

#define EverCrypt_AES128_GCM 0
#define EverCrypt_AES256_GCM 1
#define EverCrypt_CHACHA20_POLY1305 2
#define EverCrypt_AES128_CCM 3
#define EverCrypt_AES256_CCM 4
#define EverCrypt_AES128_CCM8 5
#define EverCrypt_AES256_CCM8 6

typedef uint8_t EverCrypt_aead_alg;

extern bool EverCrypt_uu___is_AES128_GCM(EverCrypt_aead_alg projectee);

extern bool EverCrypt_uu___is_AES256_GCM(EverCrypt_aead_alg projectee);

extern bool EverCrypt_uu___is_CHACHA20_POLY1305(EverCrypt_aead_alg projectee);

extern bool EverCrypt_uu___is_AES128_CCM(EverCrypt_aead_alg projectee);

extern bool EverCrypt_uu___is_AES256_CCM(EverCrypt_aead_alg projectee);

extern bool EverCrypt_uu___is_AES128_CCM8(EverCrypt_aead_alg projectee);

extern bool EverCrypt_uu___is_AES256_CCM8(EverCrypt_aead_alg projectee);

KRML_DEPRECATED("Please use EverCrypt_AEAD.h (from C) or EverCrypt.AEAD.fsti (from F*) ")

extern uint32_t EverCrypt_aead_keyLen(EverCrypt_aead_alg uu___2_9629);

KRML_DEPRECATED("Please use EverCrypt_AEAD.h (from C) or EverCrypt.AEAD.fsti (from F*) ")

extern uint32_t EverCrypt_aead_tagLen(EverCrypt_aead_alg uu___3_9643);

KRML_DEPRECATED("Please use EverCrypt_AEAD.h (from C) or EverCrypt.AEAD.fsti (from F*) ")

extern uint32_t EverCrypt_aead_ivLen(EverCrypt_aead_alg a);

#define EverCrypt_AEAD_OPENSSL 0
#define EverCrypt_AEAD_BCRYPT 1
#define EverCrypt_AEAD_AES128_GCM_VALE 2
#define EverCrypt_AEAD_AES256_GCM_VALE 3
#define EverCrypt_AEAD_CHACHA20_POLY1305_HACL 4

typedef uint8_t EverCrypt__aead_state_tags;

typedef struct EverCrypt__aead_state_s EverCrypt__aead_state;

typedef EverCrypt__aead_state EverCrypt_aead_state_s;

typedef EverCrypt__aead_state *EverCrypt_aead_state;

extern EverCrypt__aead_state *EverCrypt_aead_create(EverCrypt_aead_alg alg, uint8_t *k1);

extern void
EverCrypt_aead_encrypt(
  EverCrypt__aead_state *pkey,
  uint8_t *iv,
  uint8_t *ad,
  uint32_t adlen,
  uint8_t *plaintext,
  uint32_t len,
  uint8_t *cipher1,
  uint8_t *tag
);

extern uint32_t
EverCrypt_aead_decrypt(
  EverCrypt__aead_state *pkey,
  uint8_t *iv,
  uint8_t *ad,
  uint32_t adlen,
  uint8_t *plaintext,
  uint32_t len,
  uint8_t *cipher1,
  uint8_t *tag
);

extern void EverCrypt_aead_free(EverCrypt__aead_state *pk);

#define EverCrypt_DH_OPENSSL 0
#define EverCrypt_DH_DUMMY 1

typedef uint8_t EverCrypt__dh_state_tags;

typedef struct EverCrypt__dh_state_s EverCrypt__dh_state;

typedef EverCrypt__dh_state EverCrypt_dh_state_s;

typedef EverCrypt__dh_state *EverCrypt_dh_state;

extern EverCrypt__dh_state
*EverCrypt_dh_load_group(
  uint8_t *dh_p,
  uint32_t dh_p_len,
  uint8_t *dh_g,
  uint32_t dh_g_len,
  uint8_t *dh_q,
  uint32_t dh_q_len
);

extern void EverCrypt_dh_free_group(EverCrypt__dh_state *st);

extern uint32_t EverCrypt_dh_keygen(EverCrypt__dh_state *st, uint8_t *public);

extern uint32_t
EverCrypt_dh_compute(
  EverCrypt__dh_state *st,
  uint8_t *public,
  uint32_t public_len,
  uint8_t *out1
);

#define EverCrypt_ECC_P256 0
#define EverCrypt_ECC_P384 1
#define EverCrypt_ECC_P521 2
#define EverCrypt_ECC_X25519 3
#define EverCrypt_ECC_X448 4

typedef uint8_t EverCrypt_ec_curve;

extern bool EverCrypt_uu___is_ECC_P256(EverCrypt_ec_curve projectee);

extern bool EverCrypt_uu___is_ECC_P384(EverCrypt_ec_curve projectee);

extern bool EverCrypt_uu___is_ECC_P521(EverCrypt_ec_curve projectee);

extern bool EverCrypt_uu___is_ECC_X25519(EverCrypt_ec_curve projectee);

extern bool EverCrypt_uu___is_ECC_X448(EverCrypt_ec_curve projectee);

#define EverCrypt_ECDH_OPENSSL 0
#define EverCrypt_ECDH_DUMMY 1

typedef uint8_t EverCrypt__ecdh_state_tags;

typedef struct EverCrypt__ecdh_state_s EverCrypt__ecdh_state;

typedef EverCrypt__ecdh_state EverCrypt_ecdh_state_s;

typedef EverCrypt__ecdh_state *EverCrypt_ecdh_state;

extern EverCrypt__ecdh_state *EverCrypt_ecdh_load_curve(EverCrypt_ec_curve g1);

extern void EverCrypt_ecdh_free_curve(EverCrypt__ecdh_state *st);

extern void EverCrypt_ecdh_keygen(EverCrypt__ecdh_state *st, uint8_t *outx, uint8_t *outy);

extern uint32_t
EverCrypt_ecdh_compute(EverCrypt__ecdh_state *st, uint8_t *inx, uint8_t *iny, uint8_t *out1);

typedef struct EverCrypt_AEAD_state_s_s
{
  Spec_Cipher_Expansion_impl impl;
  uint8_t *ek;
}
EverCrypt_AEAD_state_s;

extern bool EverCrypt_AEAD_uu___is_Ek(Spec_Agile_AEAD_alg a, EverCrypt_AEAD_state_s projectee);

extern Spec_Cipher_Expansion_impl
EverCrypt_AEAD___proj__Ek__item__impl(Spec_Agile_AEAD_alg a, EverCrypt_AEAD_state_s projectee);

extern uint8_t
*EverCrypt_AEAD___proj__Ek__item__ek(Spec_Agile_AEAD_alg a, EverCrypt_AEAD_state_s projectee);

extern Spec_Agile_AEAD_alg EverCrypt_AEAD_alg_of_state(EverCrypt_AEAD_state_s *a);

extern EverCrypt_Error_error_code
EverCrypt_AEAD_create_in(Spec_Agile_AEAD_alg a, EverCrypt_AEAD_state_s **r, uint8_t *dst);

extern EverCrypt_Error_error_code
EverCrypt_AEAD_encrypt(
  EverCrypt_AEAD_state_s *a,
  uint8_t *s,
  uint32_t iv,
  uint8_t *iv_len,
  uint32_t ad,
  uint8_t *ad_len,
  uint32_t plain,
  uint8_t *plain_len,
  uint8_t *cipher1
);

extern EverCrypt_Error_error_code
EverCrypt_AEAD_decrypt(
  EverCrypt_AEAD_state_s *a,
  uint8_t *s,
  uint32_t iv,
  uint8_t *iv_len,
  uint32_t ad,
  uint8_t *ad_len,
  uint32_t cipher1,
  uint8_t *cipher_len,
  uint8_t *tag
);

extern void EverCrypt_AEAD_free(EverCrypt_AEAD_state_s *a);

extern bool EverCrypt_AutoConfig2_has_shaext();

extern bool EverCrypt_AutoConfig2_has_aesni();

extern bool EverCrypt_AutoConfig2_has_pclmulqdq();

extern bool EverCrypt_AutoConfig2_has_avx2();

extern bool EverCrypt_AutoConfig2_has_avx();

extern bool EverCrypt_AutoConfig2_has_bmi2();

extern bool EverCrypt_AutoConfig2_has_adx();

extern bool EverCrypt_AutoConfig2_wants_vale();

extern bool EverCrypt_AutoConfig2_wants_hacl();

extern bool EverCrypt_AutoConfig2_wants_openssl();

extern bool EverCrypt_AutoConfig2_wants_bcrypt();

extern void EverCrypt_AutoConfig2_recall();

extern void EverCrypt_AutoConfig2_init();

typedef void (*EverCrypt_AutoConfig2_disabler)();

extern void EverCrypt_AutoConfig2_disable_avx2();

extern void EverCrypt_AutoConfig2_disable_avx();

extern void EverCrypt_AutoConfig2_disable_bmi2();

extern void EverCrypt_AutoConfig2_disable_adx();

extern void EverCrypt_AutoConfig2_disable_shaext();

extern void EverCrypt_AutoConfig2_disable_aesni();

extern void EverCrypt_AutoConfig2_disable_pclmulqdq();

extern void EverCrypt_AutoConfig2_disable_vale();

extern void EverCrypt_AutoConfig2_disable_hacl();

extern void EverCrypt_AutoConfig2_disable_openssl();

extern void EverCrypt_AutoConfig2_disable_bcrypt();

extern void
EverCrypt_HKDF_expand_sha1(
  uint8_t *okm,
  uint8_t *prk,
  uint32_t prklen,
  uint8_t *info,
  uint32_t infolen,
  uint32_t len
);

extern void
EverCrypt_HKDF_extract_sha1(
  uint8_t *prk,
  uint8_t *salt,
  uint32_t saltlen,
  uint8_t *ikm,
  uint32_t ikmlen
);

extern void
EverCrypt_HKDF_expand_sha2_256(
  uint8_t *okm,
  uint8_t *prk,
  uint32_t prklen,
  uint8_t *info,
  uint32_t infolen,
  uint32_t len
);

extern void
EverCrypt_HKDF_extract_sha2_256(
  uint8_t *prk,
  uint8_t *salt,
  uint32_t saltlen,
  uint8_t *ikm,
  uint32_t ikmlen
);

extern void
EverCrypt_HKDF_expand_sha2_384(
  uint8_t *okm,
  uint8_t *prk,
  uint32_t prklen,
  uint8_t *info,
  uint32_t infolen,
  uint32_t len
);

extern void
EverCrypt_HKDF_extract_sha2_384(
  uint8_t *prk,
  uint8_t *salt,
  uint32_t saltlen,
  uint8_t *ikm,
  uint32_t ikmlen
);

extern void
EverCrypt_HKDF_expand_sha2_512(
  uint8_t *okm,
  uint8_t *prk,
  uint32_t prklen,
  uint8_t *info,
  uint32_t infolen,
  uint32_t len
);

extern void
EverCrypt_HKDF_extract_sha2_512(
  uint8_t *prk,
  uint8_t *salt,
  uint32_t saltlen,
  uint8_t *ikm,
  uint32_t ikmlen
);

extern void
EverCrypt_HKDF_expand(
  Spec_Hash_Definitions_hash_alg a,
  uint8_t *okm,
  uint8_t *prk,
  uint32_t prklen,
  uint8_t *info,
  uint32_t infolen,
  uint32_t len
);

extern void
EverCrypt_HKDF_extract(
  Spec_Hash_Definitions_hash_alg a,
  uint8_t *prk,
  uint8_t *salt,
  uint32_t saltlen,
  uint8_t *ikm,
  uint32_t ikmlen
);

KRML_DEPRECATED("expand")

extern void
EverCrypt_HKDF_hkdf_expand(
  Spec_Hash_Definitions_hash_alg a,
  uint8_t *okm,
  uint8_t *prk,
  uint32_t prklen,
  uint8_t *info,
  uint32_t infolen,
  uint32_t len
);

KRML_DEPRECATED("extract")

extern void
EverCrypt_HKDF_hkdf_extract(
  Spec_Hash_Definitions_hash_alg a,
  uint8_t *prk,
  uint8_t *salt,
  uint32_t saltlen,
  uint8_t *ikm,
  uint32_t ikmlen
);

extern void
EverCrypt_HMAC_compute_sha1(
  uint8_t *dst,
  uint8_t *key,
  uint32_t key_len,
  uint8_t *data,
  uint32_t data_len
);

extern void
EverCrypt_HMAC_compute_sha2_256(
  uint8_t *dst,
  uint8_t *key,
  uint32_t key_len,
  uint8_t *data,
  uint32_t data_len
);

extern void
EverCrypt_HMAC_compute_sha2_384(
  uint8_t *dst,
  uint8_t *key,
  uint32_t key_len,
  uint8_t *data,
  uint32_t data_len
);

extern void
EverCrypt_HMAC_compute_sha2_512(
  uint8_t *dst,
  uint8_t *key,
  uint32_t key_len,
  uint8_t *data,
  uint32_t data_len
);

extern bool EverCrypt_HMAC_is_supported_alg(Spec_Hash_Definitions_hash_alg uu___0_5855);

typedef Spec_Hash_Definitions_hash_alg EverCrypt_HMAC_supported_alg;

extern void
EverCrypt_HMAC_compute(
  Spec_Hash_Definitions_hash_alg a,
  uint8_t *mac,
  uint8_t *key,
  uint32_t keylen,
  uint8_t *data,
  uint32_t datalen
);

typedef Spec_Hash_Definitions_hash_alg EverCrypt_Hash_alg;

extern C_String_t EverCrypt_Hash_string_of_alg(Spec_Hash_Definitions_hash_alg uu___0_6);

typedef Spec_Hash_Definitions_hash_alg EverCrypt_Hash_broken_alg;

typedef Spec_Hash_Definitions_hash_alg EverCrypt_Hash_alg13;

typedef void *EverCrypt_Hash_e_alg;

#define EverCrypt_Hash_MD5_s 0
#define EverCrypt_Hash_SHA1_s 1
#define EverCrypt_Hash_SHA2_224_s 2
#define EverCrypt_Hash_SHA2_256_s 3
#define EverCrypt_Hash_SHA2_384_s 4
#define EverCrypt_Hash_SHA2_512_s 5

typedef uint8_t EverCrypt_Hash_state_s_tags;

typedef struct EverCrypt_Hash_state_s_s
{
  EverCrypt_Hash_state_s_tags tag;
  union {
    uint32_t *case_MD5_s;
    uint32_t *case_SHA1_s;
    uint32_t *case_SHA2_224_s;
    uint32_t *case_SHA2_256_s;
    uint64_t *case_SHA2_384_s;
    uint64_t *case_SHA2_512_s;
  }
  ;
}
EverCrypt_Hash_state_s;

extern bool
EverCrypt_Hash_uu___is_MD5_s(
  Spec_Hash_Definitions_hash_alg uu____151,
  EverCrypt_Hash_state_s projectee
);

extern uint32_t
*EverCrypt_Hash___proj__MD5_s__item__p(
  Spec_Hash_Definitions_hash_alg uu____179,
  EverCrypt_Hash_state_s projectee
);

extern bool
EverCrypt_Hash_uu___is_SHA1_s(
  Spec_Hash_Definitions_hash_alg uu____202,
  EverCrypt_Hash_state_s projectee
);

extern uint32_t
*EverCrypt_Hash___proj__SHA1_s__item__p(
  Spec_Hash_Definitions_hash_alg uu____230,
  EverCrypt_Hash_state_s projectee
);

extern bool
EverCrypt_Hash_uu___is_SHA2_224_s(
  Spec_Hash_Definitions_hash_alg uu____253,
  EverCrypt_Hash_state_s projectee
);

extern uint32_t
*EverCrypt_Hash___proj__SHA2_224_s__item__p(
  Spec_Hash_Definitions_hash_alg uu____281,
  EverCrypt_Hash_state_s projectee
);

extern bool
EverCrypt_Hash_uu___is_SHA2_256_s(
  Spec_Hash_Definitions_hash_alg uu____304,
  EverCrypt_Hash_state_s projectee
);

extern uint32_t
*EverCrypt_Hash___proj__SHA2_256_s__item__p(
  Spec_Hash_Definitions_hash_alg uu____332,
  EverCrypt_Hash_state_s projectee
);

extern bool
EverCrypt_Hash_uu___is_SHA2_384_s(
  Spec_Hash_Definitions_hash_alg uu____355,
  EverCrypt_Hash_state_s projectee
);

extern uint64_t
*EverCrypt_Hash___proj__SHA2_384_s__item__p(
  Spec_Hash_Definitions_hash_alg uu____383,
  EverCrypt_Hash_state_s projectee
);

extern bool
EverCrypt_Hash_uu___is_SHA2_512_s(
  Spec_Hash_Definitions_hash_alg uu____406,
  EverCrypt_Hash_state_s projectee
);

extern uint64_t
*EverCrypt_Hash___proj__SHA2_512_s__item__p(
  Spec_Hash_Definitions_hash_alg uu____434,
  EverCrypt_Hash_state_s projectee
);

extern Spec_Hash_Definitions_hash_alg EverCrypt_Hash_alg_of_state(EverCrypt_Hash_state_s *a);

extern EverCrypt_Hash_state_s *EverCrypt_Hash_create_in(Spec_Hash_Definitions_hash_alg a);

extern EverCrypt_Hash_state_s *EverCrypt_Hash_create(Spec_Hash_Definitions_hash_alg a);

extern void EverCrypt_Hash_init(EverCrypt_Hash_state_s *a);

extern void EverCrypt_Hash_update_multi_256(uint32_t *s, uint8_t *blocks, uint32_t n1);

extern void EverCrypt_Hash_update(EverCrypt_Hash_state_s *a, uint8_t *s);

extern void
EverCrypt_Hash_update_multi(EverCrypt_Hash_state_s *a, uint8_t *s, uint32_t blocks);

extern void
EverCrypt_Hash_update_last_256(
  uint32_t *s,
  uint64_t prev_len,
  uint8_t *input,
  uint32_t input_len
);

extern void EverCrypt_Hash_update_last(EverCrypt_Hash_state_s *a, uint8_t *s, uint64_t last1);

extern void EverCrypt_Hash_finish(EverCrypt_Hash_state_s *a, uint8_t *s);

extern void EverCrypt_Hash_free(EverCrypt_Hash_state_s *ea);

extern void EverCrypt_Hash_copy(EverCrypt_Hash_state_s *a, EverCrypt_Hash_state_s *s_src);

extern void EverCrypt_Hash_hash_256(uint8_t *input, uint32_t input_len, uint8_t *dst);

extern void EverCrypt_Hash_hash_224(uint8_t *input, uint32_t input_len, uint8_t *dst);

extern void
EverCrypt_Hash_hash(
  Spec_Hash_Definitions_hash_alg a,
  uint8_t *dst,
  uint8_t *input,
  uint32_t len
);

typedef uint8_t *EverCrypt_Hash_Incremental_any_hash_t;

typedef struct EverCrypt_Hash_Incremental_state_s_s
{
  EverCrypt_Hash_state_s *hash_state;
  uint8_t *buf;
  uint64_t total_len;
}
EverCrypt_Hash_Incremental_state_s;

extern bool
EverCrypt_Hash_Incremental_uu___is_State(
  Spec_Hash_Definitions_hash_alg a,
  EverCrypt_Hash_Incremental_state_s projectee
);

extern EverCrypt_Hash_state_s
*EverCrypt_Hash_Incremental___proj__State__item__hash_state(
  Spec_Hash_Definitions_hash_alg a,
  EverCrypt_Hash_Incremental_state_s projectee
);

extern uint8_t
*EverCrypt_Hash_Incremental___proj__State__item__buf(
  Spec_Hash_Definitions_hash_alg a,
  EverCrypt_Hash_Incremental_state_s projectee
);

extern uint64_t
EverCrypt_Hash_Incremental___proj__State__item__total_len(
  Spec_Hash_Definitions_hash_alg a,
  EverCrypt_Hash_Incremental_state_s projectee
);

extern Spec_Hash_Definitions_hash_alg
EverCrypt_Hash_Incremental_alg_of_state(EverCrypt_Hash_Incremental_state_s *a);

extern EverCrypt_Hash_Incremental_state_s
*EverCrypt_Hash_Incremental_create_in(Spec_Hash_Definitions_hash_alg a);

extern void EverCrypt_Hash_Incremental_init(EverCrypt_Hash_Incremental_state_s *a);

extern void
EverCrypt_Hash_Incremental_update(
  EverCrypt_Hash_Incremental_state_s *a,
  uint8_t *p1,
  uint32_t data
);

extern void
EverCrypt_Hash_Incremental_finish(EverCrypt_Hash_Incremental_state_s *a, uint8_t *s);

extern void EverCrypt_Hash_Incremental_free(EverCrypt_Hash_Incremental_state_s *a);

extern void
EverCrypt_Cipher_chacha20(
  uint32_t len,
  uint8_t *dst,
  uint8_t *src,
  uint8_t *key,
  uint8_t *iv,
  uint32_t ctr
);

extern void
EverCrypt_Poly1305_poly1305(uint8_t *dst, uint8_t *src, uint32_t len, uint8_t *key);

extern void
EverCrypt_Chacha20Poly1305_aead_encrypt(
  uint8_t *k,
  uint8_t *n1,
  uint32_t aadlen,
  uint8_t *aad,
  uint32_t mlen,
  uint8_t *m,
  uint8_t *cipher,
  uint8_t *tag
);

extern uint32_t
EverCrypt_Chacha20Poly1305_aead_decrypt(
  uint8_t *k,
  uint8_t *n1,
  uint32_t aadlen,
  uint8_t *aad,
  uint32_t mlen,
  uint8_t *m,
  uint8_t *cipher,
  uint8_t *tag
);

extern void EverCrypt_Curve25519_secret_to_public(uint8_t *pub, uint8_t *priv);

extern void
EverCrypt_Curve25519_scalarmult(uint8_t *shared, uint8_t *my_priv, uint8_t *their_pub);

extern bool EverCrypt_Curve25519_ecdh(uint8_t *shared, uint8_t *my_priv, uint8_t *their_pub);

#define __EverCrypt_H_DEFINED
#endif
