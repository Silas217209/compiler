const std = @import("std");

const typeidx = u32;
const funcidx = u32;
const tableidx = u32;
const memidx = u32;
const globalidx = u32;
const elemidx = u32;
const dataidx = u32;
const localidx = u32;
const labelidx = u32;

const NumType = enum(u8) {
    i32 = 0x7F,
    i64 = 0x7E,
    f32 = 0x7D,
    f64 = 0x7C,
};

const VecType = enum(u8) {
    v128 = 0x7B,
};

const RefType = enum(u8) {
    funcref = 0x70,
    externref = 0x6F,
};

const ValType = enum(type) {
    numtype = NumType,
    vectype = VecType,
    reftype = RefType,
};

const ResultType = []ValType;

const FuncType = struct {
    parameters: ResultType,
    results: ResultType,
};

const Limits = struct {
    min: u32,
    max: ?u32,
};

const TableType = struct {
    limits: Limits,
    type: RefType,
};

const Table = TableType;

const MemType = Limits;

const Mem = MemType;

const Instr = enum(u8) {};

const Expr = []Instr;

const Func = struct {
    type: typeidx,
    locals: []ValType,
    body: []Instr,
};

const Mut = enum(u8) {
    immutable = 0x00, // const
    mutable = 0x01, // var
};

const GlobalType = struct {
    mut: Mut,
    type: ValType,
};

const Global = struct {
    type: GlobalType,
    init: Expr,
};

const Module = struct {
    types: []FuncType,
    funcs: []Func,
    tables: []Table,
    mems: []Mem,
    globals: []Global,
    // elems: []Elem
    // datas: []Data,
    // start: ?Start,
    // imports: []Import,
    // exports: []Export,
};
