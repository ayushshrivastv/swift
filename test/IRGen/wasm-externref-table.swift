// RUN: %swift-frontend -target wasm32-unknown-wasip1 -parse-stdlib -module-name Swift -emit-ir -enable-experimental-feature Extern -enable-experimental-feature WasmExternref %s | %FileCheck %s

// REQUIRES: CODEGENERATOR=WebAssembly
// REQUIRES: swift_feature_Extern
// REQUIRES: swift_feature_WasmExternref

typealias Void = ()
enum Optional<T> {}

@_extern(c, "use_table")
public func use_table(
  _ table: Builtin.WasmExternRefTable,
  _ source: Builtin.WasmExternRefTable,
  _ value: Builtin.WasmExternRef,
  _ sourceIndex: Builtin.Int32,
  _ destinationIndex: Builtin.Int32,
  _ count: Builtin.Int32
) -> Builtin.WasmExternRef {
  _ = Builtin.wasmRefNullExtern()
  _ = Builtin.wasmTableSizeExternRef(table)
  Builtin.wasmTableSetExternRef(table, destinationIndex, value)
  Builtin.wasmTableFillExternRef(table, destinationIndex, value, count)
  _ = Builtin.wasmTableGrowExternRef(table, value, count)
  Builtin.wasmTableCopyExternRef(
    table, source, sourceIndex, destinationIndex, count)
  return Builtin.wasmTableGetExternRef(table, sourceIndex)
}

// CHECK: define {{.*}}ptr addrspace(10) @use_table(ptr addrspace(1) %0, ptr addrspace(1) %1, ptr addrspace(10) %2, i32 %3, i32 %4, i32 %5)
// CHECK: call ptr addrspace(10) @llvm.wasm.ref.null.extern()
// CHECK: call i32 @llvm.wasm.table.size(ptr addrspace(1) %0)
// CHECK: call void @llvm.wasm.table.set.externref(ptr addrspace(1) %0, i32 %4, ptr addrspace(10) %2)
// CHECK: call void @llvm.wasm.table.fill.externref(ptr addrspace(1) %0, i32 %4, ptr addrspace(10) %2, i32 %5)
// CHECK: call i32 @llvm.wasm.table.grow.externref(ptr addrspace(1) %0, ptr addrspace(10) %2, i32 %5)
// CHECK: call void @llvm.wasm.table.copy(ptr addrspace(1) %0, ptr addrspace(1) %1, i32 %3, i32 %4, i32 %5)
// CHECK: call ptr addrspace(10) @llvm.wasm.table.get.externref(ptr addrspace(1) %0, i32 %3)
