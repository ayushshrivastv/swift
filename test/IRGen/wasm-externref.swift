// RUN: %empty-directory(%t)
// RUN: split-file %s %t
// RUN: %swift-frontend -target wasm32-unknown-wasip1 -parse-stdlib -module-name Swift -emit-ir -enable-experimental-feature Extern -enable-experimental-feature WasmExternref -I %t %t/test.swift | %FileCheck %s

// REQUIRES: CODEGENERATOR=WebAssembly
// REQUIRES: swift_feature_Extern
// REQUIRES: swift_feature_WasmExternref

//--- wasm_externref.h
__externref_t c_roundtrip_externref(__externref_t);

//--- module.modulemap
module wasm_externref {
  header "wasm_externref.h"
  export *
}

//--- test.swift
import wasm_externref

/// ===== Minimal stdlib definitions =====
typealias Void = ()
enum Optional<T> {}

@frozen
public struct WasmExternref {
  public var _rawValue: Builtin.WasmExternRef

  public init(_ value: Builtin.WasmExternRef) {
    _rawValue = value
  }
}
/// ======================================

@_extern(c, "swift_roundtrip_externref")
public func swift_roundtrip_externref(_ value: WasmExternref) -> WasmExternref {
  value
}

public func test(_ value: WasmExternref) -> WasmExternref {
  let imported = c_roundtrip_externref(value)
  return swift_roundtrip_externref(imported)
}

// CHECK: declare ptr addrspace(10) @c_roundtrip_externref(ptr addrspace(10))
// CHECK: define {{.*}}ptr addrspace(10) @swift_roundtrip_externref(ptr addrspace(10)
// CHECK: call ptr addrspace(10) @c_roundtrip_externref(ptr addrspace(10)
// CHECK: call ptr addrspace(10) @swift_roundtrip_externref(ptr addrspace(10)
