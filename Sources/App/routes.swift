import Vapor

enum Route: String {
    case register
}

func routes(_ app: Application) throws {
    app.get { req in
        return #"{"name":"test"}"#
    }
    
    app.post(.constant(Route.register.rawValue)) { req -> String in
        
            try RegisterUser.validate(req)
            _ = try req.content.decode(RegisterUser.self)
        
        return #"{"name":"test"}"#
        
//        return .ok
    }
}

//TODO: Put models in separate framework

struct RegisterUser: Codable {
    var email: String
    var password: String
}

extension RegisterUser: Content {}

extension RegisterUser: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .customEmail)
        validations.add("password", as: String.self, is: .password)
    }
}
