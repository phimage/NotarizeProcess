//
//  NotarizationInfo+AuditLog.swift
//  
//
//  Created by phimage on 21/10/2019.
//

import Foundation
import Combine

import NotarizationInfo
import NotarizationAuditLog

extension NotarizationInfo {

    public func auditLogPublisher() -> AnyPublisher<NotarizationAuditLog, Error>? {
        guard let urlString = self.logFileUrl,
            let url = URL(string: urlString) else {
                return nil
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: NotarizationAuditLog.self,
                    decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

}
