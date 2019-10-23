//
//  NotarizeProcessError.swift
//  
//
//  Created by phimage on 23/10/2019.
//

import Foundation
import NotarizationInfo

/// Error thrown by `NotarizeProcess`.
public enum NotarizeProcessError: Error {
    /// Error from notarization
    case notaryError(NotarizationError)
    /// Runtime process error
    case processError(Error)
    /// Data decoding error
    case decodingError(DecodingError)
    /// Timed out waiting for notarization requests
    case timeOut(TimeInterval)
}
