//
//  File.swift
//
//
//  Created by Tibor Bodecs on 2020. 06. 03..
//

import FeatherCore

final class FileDirectoryForm: Form {

    struct Input: Decodable {
        var key: String
        var name: String
    }

    var key = StringFormField()
    var name = StringFormField()
    var notification: String?
    
    var leafData: LeafData {
        .dictionary([
            "key": key,
            "name": name,
            "notification": notification,
        ])
    }

    init() {}

    init(req: Request) throws {
        let context = try req.content.decode(Input.self)
        key.value = context.key
        name.value = context.name
    }

    func validate(req: Request) -> EventLoopFuture<Bool> {
        var valid = true
               
        if name.value.isEmpty {
            name.error = "Name is required"
            valid = false
        }

        if Validator.characterSet(.alphanumerics).validate(key.value).isFailure ||
            Validator.characterSet(.alphanumerics).validate(name.value).isFailure {
            name.error = "Directory names can't contain special characters"
            valid = false
        }
        return req.eventLoop.future(valid)
    }
}
