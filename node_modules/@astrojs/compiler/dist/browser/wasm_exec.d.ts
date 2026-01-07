declare class Go {
    importObject: {
        gojs: {
            'runtime.wasmExit': (sp: any) => void;
            'runtime.wasmWrite': (sp: any) => void;
            'runtime.resetMemoryDataView': (sp: any) => void;
            'runtime.nanotime1': (sp: any) => void;
            'runtime.walltime': (sp: any) => void;
            'runtime.scheduleTimeoutEvent': (sp: any) => void;
            'runtime.clearTimeoutEvent': (sp: any) => void;
            'runtime.getRandomData': (sp: any) => void;
            'syscall/js.finalizeRef': (sp: any) => void;
            'syscall/js.stringVal': (sp: any) => void;
            'syscall/js.valueGet': (sp: any) => void;
            'syscall/js.valueSet': (sp: any) => void;
            'syscall/js.valueDelete': (sp: any) => void;
            'syscall/js.valueIndex': (sp: any) => void;
            'syscall/js.valueSetIndex': (sp: any) => void;
            'syscall/js.valueCall': (sp: any) => void;
            'syscall/js.valueInvoke': (sp: any) => void;
            'syscall/js.valueNew': (sp: any) => void;
            'syscall/js.valueLength': (sp: any) => void;
            'syscall/js.valuePrepareString': (sp: any) => void;
            'syscall/js.valueLoadString': (sp: any) => void;
            'syscall/js.valueInstanceOf': (sp: any) => void;
            'syscall/js.copyBytesToGo': (sp: any) => void;
            'syscall/js.copyBytesToJS': (sp: any) => void;
            debug: (value: any) => void;
        };
    };
    constructor();
    run(instance: any): Promise<void>;
    private _resume;
    private _makeFuncWrapper;
}

export { Go as default };
