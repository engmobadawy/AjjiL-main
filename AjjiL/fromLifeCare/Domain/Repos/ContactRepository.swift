//
//  ContactRepository.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 24/04/2026.
//


import Foundation

protocol ContactRepository {
    func getContactTypes() async throws -> [ContactType]
    func sendContactUs(email: String, message: String, contactTypeId: Int) async throws -> String
}