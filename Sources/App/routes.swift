import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.post("api", "acronyms") { request -> Future<Acronym> in
        return try request.content.decode(Acronym.self)
            .flatMap(to: Acronym.self) { acronym in
            return acronym.save(on: request)
        }
    }
    
    router.get("api", "acronyms") { request -> Future<[Acronym]> in
        return Acronym.query(on: request).all()
    }
    
    router.get("api", "acronyms", Acronym.parameter) { request -> Future<Acronym> in
        return try request.parameters.next(Acronym.self)
    }
    
    router.put("api", "acronyms", Acronym.parameter) { request -> Future<Acronym> in
        return try flatMap(to: Acronym.self, request.parameters.next(Acronym.self), request.content.decode(Acronym.self)) { acronym, updatedAcronym in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: request)
        }
    }
    
    router.delete("api", "acronyms", Acronym.parameter) { request -> Future<HTTPStatus> in
        return try request.parameters.next(Acronym.self)
            .delete(on: request)
            .transform(to: HTTPStatus.noContent)
    }
    
    router.get("api", "acronyms", "search") { request -> Future<[Acronym]> in
        guard let searchTerm = request.query[String.self, at: "term"] else { throw Abort(.badRequest) }
        
        return Acronym.query(on: request)
            .filter(\.short == searchTerm)
            .all()
    }
    
    router.get("api", "acronyms", "sorted") { request -> Future<[Acronym]> in
        return Acronym.query(on: request)
            .sort(\.short, .ascending)
            .all()
    }
}
