//
//  ErrorLogger.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 07.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import Foundation

class ErrorLogger {
    static let shared: ErrorLogger = {
        #if DEBUG
            return DebugErrorLogger()
        #else
            return ExternalErrorLogger()
        #endif
    }()

    func record(error: Error) {
        let nsError = error as NSError
        record(error: nsError)
    }

    func record(error: NSError) {
        fatalError("recordError(error:) not implemented!")
    }
}

#if DEBUG
private final class DebugErrorLogger: ErrorLogger {
    override func record(error: NSError) {
        print(error)
    }
}
#else
private final class ExternalErrorLogger: ErrorLogger {
    override func record(error: NSError) {
        // Record error to external loggers, for ex. Crashlytics
    }
}
#endif
