//
//  SessionsController.swift
//  DaradanayaTales
//
//  Created by Maxim Lanskoy on 06.07.2024.
//

//import FluentKit
//import Foundation
//import Hummingbird
//import HummingbirdFluent
//
//struct SessionsController<Context: RequestContext> {
//    
//    let fluent: Fluent
//    
//    func addRoutes(to group:RouterGroup<Context>) {
//        group
//            .get(use: self.index)
//            .get(":id", use: self.show)
//            .post(use: self.create)
//            .put(":id", use: self.update)
//            .delete(":id", use: self.delete)
//    }
//    
//    // MARK: - index
//    /// Returns with all sessions in the database
//    @Sendable func index(_ request: Request, context: TGContext) async throws -> [Session] {
//        try await Session.query(on: self.fluent.db()).all()
//    }
//    
//    
//    // MARK: - show
//    // Return with session with specified id
//    @Sendable func show(_ request: Request, context: TGContext) async throws -> Session? {
//        let id = try context.parameters.require("id", as: Int64.self)
//        guard let session = try await Session.find(id, on: fluent.db()) else {
//            throw HTTPError(.notFound)
//        }
//        
//        return session
//    }
//    
//    // MARK: - create
//    /// Saves session to the database
//    //
//    // curl --location 'http://127.0.0.1:8080/api/v1/sessions' \
//    // --header 'Content-Type: application/json' \
//    // --data '{
//    //     "name" : "Kharkiv",
//    //     "coordinates": {
//    //         "latitude" : 49.987503,
//    //         "longitude": 36.234968
//    //     }
//    // }'
//    //'
//    @Sendable func create(_ request: Request, context: TGContext) async throws -> Session {
//        let session = try await request.decode(as: Session.self, context: context)
//        try await session.save(on: fluent.db())
//        return session
//    }
//    
//    // MARK: - update
//    /// Updates session with specified id
//    //
//    //    curl --location --request PUT 'http://127.0.0.1:8080/api/v1/sessions/079BAE9C-FCFB-4556-BF02-9C274659E022' \
//    //    --header 'Content-Type: application/json' \
//    //    --data '   {
//    //         "name" : "Kharkiv Session",
//    //         "coordinates": {
//    //                "latitude" : 49.987503,
//    //                 "longitude": 36.234968
//    //           }
//    //     }'
//    //
//    @Sendable func update(_ request: Request, context: TGContext) async throws -> HTTPResponse.Status {
//        let id = try context.parameters.require("id", as: Int64.self)
//        guard let session = try await Session.find(id, on: fluent.db()) else {
//            throw HTTPError(.notFound)
//        }
//        
//        let updatedSession = try await request.decode(as: Session.self, context: context)
//        session.update(with: updatedSession)
//        try await session.save(on: fluent.db())
//        return .ok
//    }
//    
//    // MARK: - delete
//    /// Deletes session with specified
//    //
//    // curl --location --request DELETE 'http://127.0.0.1:8080/api/v1/sessions/079BAE9C-FCFB-4556-BF02-9C274659E022'
//    //
//    @Sendable func delete(_ request: Request, context: TGContext) async throws -> HTTPResponse.Status {
//        let id = try context.parameters.require("id", as: Int64.self)
//        guard let session = try await Session.find(id, on: fluent.db()) else {
//            throw HTTPError(.notFound)
//        }
//        
//        try await session.delete(on: fluent.db())
//        return .ok
//    }
//}
