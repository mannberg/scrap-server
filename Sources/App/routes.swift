import Vapor

enum Route: String {
    case register
}

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }
    
    app.post(.constant(Route.register.rawValue)) { req -> HTTPStatus in
        try RegisterUser.validate(req)
        _ = try req.content.decode(RegisterUser.self)
        
        return .ok
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
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .password)
    }
}
