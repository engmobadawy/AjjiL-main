//
//  PointRepository.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//


import Foundation

protocol PointRepository {
    func getPoints() async throws -> PointsData
    func redeemPoints(amount: Int) async throws -> RedeemPointsData
    func calcPoints(amount: Int) async throws -> CalcPointsData
}