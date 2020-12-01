//
//  FileBuilder.swift
//  FileModule
//
//  Created by Tibor Bodecs on 2020. 08. 23..
//
import FeatherCore

@_cdecl("createFileModule")
public func createFileModule() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(FileBuilder()).toOpaque()
}

public final class FileBuilder: ViperBuilder {

    public override func build() -> ViperModule {
        FileModule()
    }
}
