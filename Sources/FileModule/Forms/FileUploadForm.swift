//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 06. 03..
//

import FeatherCore

final class FileUploadForm: Form {

    struct Input: Decodable {
        var key: String
        var files: [File]
    }

    var key = StringFormField()
    var files = FileArrayFormField()
    var notification: String?
    
    var leafData: LeafData {
        .dictionary([
            "key": key,
            "files": files,
            "notification": notification,
        ])
    }
    
    init() {}

    init(req: Request) throws {
        let context = try req.content.decode(Input.self)
        key.value = context.key
        files.values = context.files.compactMap { file -> FileDataValue? in
            guard let data = file.data.getData(at: 0, length: file.data.readableBytes), !data.isEmpty else {
                return nil
            }
            return .init(name: file.filename, data: data)
        }
    }

    func validate(req: Request) -> EventLoopFuture<Bool> {
        var valid = true
       
        if files.values.isEmpty {
            valid = false
            files.error = "At least one file is required"
        }

        return req.eventLoop.future(valid)
    }
}
