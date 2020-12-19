//
//  FileModule+Install.swift
//  FileModule
//
//  Created by Tibor Bodecs on 2020. 12. 19..
//

import FeatherCore

extension FileModule {

    func userPermissionInstallHook(args: HookArguments) -> [[String: Any]] {
        FileModule.permissions +
        [
            [
                "module": Self.name.lowercased(),
                "context": "browser",
                "action": "list",
                "name": "List items",
            ],
            [
                "module": Self.name.lowercased(),
                "context": "browser",
                "action": "create",
                "name": "Upload items",
            ],
            [
                "module": Self.name.lowercased(),
                "context": "browser",
                "action": "delete",
                "name": "Remove items",
            ]
        ]

    }
}
