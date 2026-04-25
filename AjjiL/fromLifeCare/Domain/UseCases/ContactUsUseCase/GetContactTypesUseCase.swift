//
//  GetContactTypesUseCase.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 24/04/2026.
//


import Foundation

struct GetContactTypesUseCase {
    private let repository: ContactRepository

    init(repository: ContactRepository) {
        self.repository = repository
    }

    func execute() async throws -> [ContactType] {
        return try await repository.getContactTypes()
    }
}