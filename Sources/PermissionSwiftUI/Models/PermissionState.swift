enum PermissionState: Sendable {
    case notDetermined
    case authorized(AuthorizedPermission)
    case failure(error: PermissionError)
}
